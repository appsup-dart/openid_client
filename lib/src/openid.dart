library openid_client.openid;

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:jose/jose.dart';
import 'package:pointycastle/digests/sha256.dart';

import 'http_util.dart' as http;
import 'model.dart';

export 'model.dart';
export 'http_util.dart' show HttpRequestException;

/// Represents an OpenId Provider
class Issuer {
  /// The OpenId Provider's metadata
  final OpenIdProviderMetadata metadata;

  final Map<String, String> claimsMap;

  final JsonWebKeyStore _keyStore;

  /// Creates an issuer from its metadata.
  Issuer(this.metadata, {this.claimsMap = const {}})
      : _keyStore = metadata.jwksUri == null
            ? JsonWebKeyStore()
            : (JsonWebKeyStore()..addKeySetUrl(metadata.jwksUri!));

  /// Url of the facebook issuer.
  ///
  /// Note: facebook does not support OpenID Connect, but the authentication
  /// works.
  static final Uri facebook = Uri.parse('https://www.facebook.com');

  /// Url of the google issuer.
  static final Uri google = Uri.parse('https://accounts.google.com');

  /// Url of the yahoo issuer.
  static final Uri yahoo = Uri.parse('https://api.login.yahoo.com');

  /// Url of the microsoft issuer.
  static final Uri microsoft =
      Uri.parse('https://login.microsoftonline.com/common');

  /// Url of the salesforce issuer.
  static final Uri salesforce = Uri.parse('https://login.salesforce.com');

  static Uri firebase(String id) =>
      Uri.parse('https://securetoken.google.com/$id');

  static final Map<Uri, Issuer?> _discoveries = {
    facebook: Issuer(OpenIdProviderMetadata.fromJson({
      'issuer': facebook.toString(),
      'authorization_endpoint': 'https://www.facebook.com/v2.8/dialog/oauth',
      'token_endpoint': 'https://graph.facebook.com/v2.8/oauth/access_token',
      'userinfo_endpoint': 'https://graph.facebook.com/v2.8/879023912133394',
      'response_types_supported': ['token', 'code', 'code token'],
      'token_endpoint_auth_methods_supported': ['client_secret_post'],
      'scopes_supported': [
        'public_profile',
        'user_friends',
        'email',
        'user_about_me',
        'user_actions.books',
        'user_actions.fitness',
        'user_actions.music',
        'user_actions.news',
        'user_actions.video',
        'user_birthday',
        'user_education_history',
        'user_events',
        'user_games_activity',
        'user_hometown',
        'user_likes',
        'user_location',
        'user_managed_groups',
        'user_photos',
        'user_posts',
        'user_relationships',
        'user_relationship_details',
        'user_religion_politics',
        'user_tagged_places',
        'user_videos',
        'user_website',
        'user_work_history',
        'read_custom_friendlists',
        'read_insights',
        'read_audience_network_insights',
        'read_page_mailboxes',
        'manage_pages',
        'publish_pages',
        'publish_actions',
        'rsvp_event',
        'pages_show_list',
        'pages_manage_cta',
        'pages_manage_instant_articles',
        'ads_read',
        'ads_management',
        'business_management',
        'pages_messaging',
        'pages_messaging_subscriptions',
        'pages_messaging_phone_number'
      ]
    })),
    google: null,
    yahoo: null,
    microsoft: null,
    salesforce: null
  };

  static Iterable<Uri> get knownIssuers => _discoveries.keys;

  /// Discovers the OpenId Provider's metadata based on its uri.
  static Future<Issuer> discover(Uri uri, {http.Client? httpClient}) async {
    if (_discoveries[uri] != null) return _discoveries[uri]!;

    var segments = uri.pathSegments.toList();
    if (segments.isNotEmpty && segments.last.isEmpty) {
      segments.removeLast();
    }
    segments.addAll(['.well-known', 'openid-configuration']);
    uri = uri.replace(pathSegments: segments);

    var json = await http.get(uri, client: httpClient);
    return _discoveries[uri] = Issuer(OpenIdProviderMetadata.fromJson(json));
  }
}

/// Represents the client application.
class Client {
  /// The id of the client.
  final String clientId;

  /// A secret for authenticating the client to the OP.
  final String? clientSecret;

  /// The [Issuer] representing the OP.
  final Issuer issuer;

  final http.Client? httpClient;

  Client(this.issuer, this.clientId, {this.clientSecret, this.httpClient});

  static Future<Client> forIdToken(String idToken,
      {http.Client? httpClient}) async {
    var token = JsonWebToken.unverified(idToken);
    var claims = OpenIdClaims.fromJson(token.claims.toJson());
    var issuer = await Issuer.discover(claims.issuer, httpClient: httpClient);
    if (!await token.verify(issuer._keyStore)) {
      throw ArgumentError('Unable to verify token');
    }
    var clientId = claims.authorizedParty ?? claims.audience.single;
    return Client(issuer, clientId, httpClient: httpClient);
  }

  /// Creates a [Credential] for this client.
  Credential createCredential(
          {String? accessToken,
          String? tokenType,
          String? refreshToken,
          Duration? expiresIn,
          DateTime? expiresAt,
          String? idToken}) =>
      Credential._(
          this,
          TokenResponse.fromJson({
            'access_token': accessToken,
            'token_type': tokenType,
            'refresh_token': refreshToken,
            'id_token': idToken,
            if (expiresIn != null) 'expires_in': expiresIn.inSeconds,
            if (expiresAt != null)
              'expires_at': expiresAt.millisecondsSinceEpoch ~/ 1000
          }),
          null);
}

class Credential {
  TokenResponse _token;
  final Client client;
  final String? nonce;

  final StreamController<TokenResponse> _onTokenChanged =
      StreamController.broadcast();

  Credential._(this.client, this._token, this.nonce);

  Map<String, dynamic>? get response => _token.toJson();

  Future<UserInfo> getUserInfo() async {
    var uri = client.issuer.metadata.userinfoEndpoint;
    if (uri == null) {
      throw UnsupportedError('Issuer does not support userinfo endpoint.');
    }
    return UserInfo.fromJson(await _get(uri));
  }

  /// Emits a new [TokenResponse] every time the token is refreshed
  Stream<TokenResponse> get onTokenChanged => _onTokenChanged.stream;

  /// Allows clients to notify the authorization server that a previously
  /// obtained refresh or access token is no longer needed
  ///
  /// See https://tools.ietf.org/html/rfc7009
  Future<void> revoke() async {
    var uri = client.issuer.metadata.revocationEndpoint;
    if (uri == null) {
      throw UnsupportedError('Issuer does not support revocation endpoint.');
    }
    var request = _token.refreshToken != null
        ? {'token': _token.refreshToken, 'token_type_hint': 'refresh_token'}
        : {'token': _token.accessToken, 'token_type_hint': 'access_token'};
    await _post(uri, body: request);
  }

  /// Returns an url to redirect to for a Relying Party to request that an
  /// OpenID Provider log out the End-User.
  ///
  /// [redirectUri] is an url to which the Relying Party is requesting that the
  /// End-User's User Agent be redirected after a logout has been performed.
  ///
  /// [state] is an opaque value used by the Relying Party to maintain state
  /// between the logout request and the callback to [redirectUri].
  ///
  /// See https://openid.net/specs/openid-connect-rpinitiated-1_0.html
  Uri? generateLogoutUrl({Uri? redirectUri, String? state}) {
    return client.issuer.metadata.endSessionEndpoint?.replace(queryParameters: {
      'id_token_hint': _token.idToken.toCompactSerialization(),
      if (redirectUri != null)
        'post_logout_redirect_uri': redirectUri.toString(),
      if (state != null) 'state': state
    });
  }

  http.Client createHttpClient([http.Client? baseClient]) =>
      http.AuthorizedClient(
          baseClient ?? client.httpClient ?? http.Client(), this);

  Future _get(uri) async {
    return http.get(uri, client: createHttpClient());
  }

  Future _post(uri, {dynamic body}) async {
    return http.post(uri, client: createHttpClient(), body: body);
  }

  IdToken get idToken => _token.idToken;

  Stream<Exception> validateToken(
      {bool validateClaims = true, bool validateExpiry = true}) async* {
    var keyStore = JsonWebKeyStore();
    var jwksUri = client.issuer.metadata.jwksUri;
    if (jwksUri != null) {
      keyStore.addKeySetUrl(jwksUri);
    }
    if (!await idToken.verify(keyStore,
        allowedArguments:
            client.issuer.metadata.idTokenSigningAlgValuesSupported)) {
      yield JoseException('Could not verify token signature');
    }

    yield* Stream.fromIterable(idToken.claims
        .validate(
            expiryTolerance: const Duration(seconds: 30),
            issuer: client.issuer.metadata.issuer,
            clientId: client.clientId,
            nonce: nonce)
        .where((e) =>
            validateExpiry ||
            !(e is JoseException && e.message.startsWith('JWT expired.'))));
  }

  String? get refreshToken => _token.refreshToken;

  Future<TokenResponse> getTokenResponse([bool forceRefresh = false]) async {
    if (!forceRefresh &&
        _token.accessToken != null &&
        (_token.expiresAt == null ||
            _token.expiresAt!.isAfter(DateTime.now()))) {
      return _token;
    }
    if (_token.accessToken == null && _token.refreshToken == null) {
      return _token;
    }

    var json = await http.post(client.issuer.tokenEndpoint,
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': _token.refreshToken,
          'client_id': client.clientId,
          if (client.clientSecret != null) 'client_secret': client.clientSecret
        },
        client: client.httpClient);

    updateToken(json);
    return _token;
  }

  /// Updates the token with the given [json] and notifies all listeners
  /// of the new token.
  ///
  /// This method is used internally by [getTokenResponse], but can also be
  /// used to update the token manually, e.g. when no refresh token is available
  /// and the token is updated by other means.
  void updateToken(Map<String, dynamic> json) {
    _token =
        TokenResponse.fromJson({'refresh_token': _token.refreshToken, ...json});
    _onTokenChanged.add(_token);
  }

  Credential.fromJson(Map<String, dynamic> json, {http.Client? httpClient})
      : this._(
            Client(
                Issuer(OpenIdProviderMetadata.fromJson(
                    (json['issuer'] as Map).cast())),
                json['client_id'],
                clientSecret: json['client_secret'],
                httpClient: httpClient),
            TokenResponse.fromJson((json['token'] as Map).cast()),
            json['nonce']);

  Map<String, dynamic> toJson() => {
        'issuer': client.issuer.metadata.toJson(),
        'client_id': client.clientId,
        'client_secret': client.clientSecret,
        'token': _token.toJson(),
        'nonce': nonce
      };
}

extension _IssuerX on Issuer {
  Uri get tokenEndpoint {
    var endpoint = metadata.tokenEndpoint;
    if (endpoint == null) {
      throw OpenIdException.missingTokenEndpoint();
    }
    return endpoint;
  }
}

enum FlowType {
  implicit,
  authorizationCode,
  proofKeyForCodeExchange,
  jwtBearer,
  password,
}

class Flow {
  final FlowType type;

  final String? responseType;

  final Client client;

  final List<String> scopes = [];

  final String state;

  final Map<String, String> _additionalParameters;

  Uri redirectUri;

  Flow._(this.type, this.responseType, this.client,
      {String? state,
      String? codeVerifier,
      Map<String, String>? additionalParameters,
      Uri? redirectUri,
      List<String> scopes = const ['openid', 'profile', 'email']})
      : state = state ?? _randomString(20),
        _additionalParameters = {...?additionalParameters},
        redirectUri = redirectUri ?? Uri.parse('http://localhost') {
    var supportedScopes = client.issuer.metadata.scopesSupported ?? [];
    for (var s in scopes) {
      if (supportedScopes.contains(s)) {
        this.scopes.add(s);
      }
    }

    var verifier = codeVerifier ?? _randomString(50);
    var challenge = base64Url
        .encode(SHA256Digest().process(Uint8List.fromList(verifier.codeUnits)))
        .replaceAll('=', '');
    _proofKeyForCodeExchange = {
      'code_verifier': verifier,
      'code_challenge': challenge
    };
  }

  /// Creates a new [Flow] for the password flow.
  ///
  /// This flow can be used for active authentication by highly-trusted
  /// applications. Call [Flow.loginWithPassword] to authenticate a user with
  /// their username and password.
  Flow.password(Client client,
      {List<String> scopes = const ['openid', 'profile', 'email']})
      : this._(
          FlowType.password,
          '',
          client,
          scopes: scopes,
        );

  Flow.authorizationCode(Client client,
      {String? state,
      String? prompt,
      String? accessType,
      Uri? redirectUri,
      List<String> scopes = const ['openid', 'profile', 'email']})
      : this._(FlowType.authorizationCode, 'code', client,
            state: state,
            additionalParameters: {
              if (prompt != null) 'prompt': prompt,
              if (accessType != null) 'access_type': accessType,
            },
            scopes: scopes,
            redirectUri: redirectUri);

  Flow.authorizationCodeWithPKCE(
    Client client, {
    String? state,
    String? prompt,
    List<String> scopes = const ['openid', 'profile', 'email'],
    String? codeVerifier,
  }) : this._(
          FlowType.proofKeyForCodeExchange,
          'code',
          client,
          state: state,
          scopes: scopes,
          codeVerifier: codeVerifier,
          additionalParameters: {
            if (prompt != null) 'prompt': prompt,
          },
        );

  Flow.implicit(Client client, {String? state, String? device, String? prompt})
      : this._(
            FlowType.implicit,
            [
              'token id_token',
              'id_token token',
              'id_token',
              'token',
            ].firstWhere((v) =>
                client.issuer.metadata.responseTypesSupported.contains(v)),
            client,
            state: state,
            scopes: [
              'openid',
              'profile',
              'email',
              if (device != null) 'offline_access'
            ],
            additionalParameters: {
              if (device != null) 'device': device,
              if (prompt != null) 'prompt': prompt,
            });

  Flow.jwtBearer(Client client) : this._(FlowType.jwtBearer, null, client);

  Uri get authenticationUri => client.issuer.metadata.authorizationEndpoint
      .replace(queryParameters: _authenticationUriParameters);

  late Map<String, String> _proofKeyForCodeExchange;

  final String _nonce = _randomString(16);

  Map<String, String?> get _authenticationUriParameters {
    var v = {
      ..._additionalParameters,
      'response_type': responseType,
      'scope': scopes.join(' '),
      'client_id': client.clientId,
      'redirect_uri': redirectUri.toString(),
      'state': state
    }..addAll(
        responseType!.split(' ').contains('id_token') ? {'nonce': _nonce} : {});

    if (type == FlowType.proofKeyForCodeExchange) {
      v.addAll({
        'code_challenge_method': 'S256',
        'code_challenge': _proofKeyForCodeExchange['code_challenge']
      });
    }
    return v;
  }

  Future<TokenResponse> _getToken(String? code) async {
    var methods = client.issuer.metadata.tokenEndpointAuthMethodsSupported;
    dynamic json;
    if (type == FlowType.jwtBearer) {
      json = await http.post(client.issuer.tokenEndpoint,
          body: {
            'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
            'assertion': code,
          },
          client: client.httpClient);
    } else if (type == FlowType.proofKeyForCodeExchange) {
      json = await http.post(client.issuer.tokenEndpoint,
          body: {
            'grant_type': 'authorization_code',
            'code': code,
            'redirect_uri': redirectUri.toString(),
            'client_id': client.clientId,
            if (client.clientSecret != null)
              'client_secret': client.clientSecret,
            'code_verifier': _proofKeyForCodeExchange['code_verifier']
          },
          client: client.httpClient);
    } else if (methods!.contains('client_secret_post')) {
      json = await http.post(client.issuer.tokenEndpoint,
          body: {
            'grant_type': 'authorization_code',
            'code': code,
            'redirect_uri': redirectUri.toString(),
            'client_id': client.clientId,
            'client_secret': client.clientSecret
          },
          client: client.httpClient);
    } else if (methods.contains('client_secret_basic')) {
      var h =
          base64.encode('${client.clientId}:${client.clientSecret}'.codeUnits);
      json = await http.post(client.issuer.tokenEndpoint,
          headers: {'authorization': 'Basic $h'},
          body: {
            'grant_type': 'authorization_code',
            'code': code,
            'redirect_uri': redirectUri.toString()
          },
          client: client.httpClient);
    } else {
      throw UnsupportedError('Unknown auth methods: $methods');
    }
    return TokenResponse.fromJson(json);
  }

  /// Login with username and password
  ///
  /// Only allowed for [Flow.password] flows.
  Future<Credential> loginWithPassword(
      {required String username, required String password}) async {
    if (type != FlowType.password) {
      throw UnsupportedError('Flow is not password');
    }
    var json = await http.post(client.issuer.tokenEndpoint,
        body: {
          'grant_type': 'password',
          'username': username,
          'password': password,
          'scope': scopes.join(' '),
          'client_id': client.clientId,
        },
        client: client.httpClient);
    return Credential._(client, TokenResponse.fromJson(json), null);
  }

  Future<Credential> callback(Map<String, String> response) async {
    if (response['state'] != state) {
      throw ArgumentError('State does not match');
    }
    if (type == FlowType.jwtBearer) {
      var code = response['jwt'];
      return Credential._(client, await _getToken(code), null);
    } else if (response.containsKey('code') &&
        (type == FlowType.proofKeyForCodeExchange ||
            client.clientSecret != null)) {
      var code = response['code'];
      return Credential._(client, await _getToken(code), null);
    } else if (response.containsKey('access_token') ||
        response.containsKey('id_token')) {
      return Credential._(client, TokenResponse.fromJson(response), _nonce);
    } else {
      return Credential._(client, TokenResponse.fromJson(response), _nonce);
    }
  }
}

String _randomString(int length) {
  var r = Random.secure();
  var chars = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  return Iterable.generate(length, (_) => chars[r.nextInt(chars.length)])
      .join();
}

/// An exception thrown when a response is received in the openid error format.
class OpenIdException implements Exception {
  /// An error code
  final String? code;

  /// Human-readable text description of the error.
  final String? message;

  /// A URI identifying a human-readable web page with information about the
  /// error, used to provide the client developer with additional information
  /// about the error.
  final String? uri;

  static const _defaultMessages = {
    'duplicate_requests':
        'The Client sent simultaneous requests to the User Questioning Polling Endpoint for the same question_id. This error is responded to oldest requests. The last request is processed normally.',
    'forbidden':
        'The Client sent a request to the User Questioning Polling Endpoint whereas it is configured with a client_notification_endpoint.',
    'high_rate_client':
        'The Client sent requests at a too high rate, amongst all question_id. Information about the allowed and recommended rates can be included in the error_description.',
    'high_rate_question':
        'The Client sent requests at a too high rate for a given question_id. Information about the allowed and recommended rates can be included in the error_description.',
    'invalid_question_id':
        'The Client sent a request to the User Questioning Polling Endpoint for a question_id that does not exist or is not valid for the requesting Client.',
    'invalid_request':
        'The User Questioning Request is not valid. The request is missing a required parameter, includes an unsupported parameter value (other than grant type), repeats a parameter, includes multiple credentials, utilizes more than one mechanism for authenticating the client, or is otherwise malformed.',
    'no_suitable_method':
        'There is no Questioning Method suitable with the User Questioning Request. The OP can use this error code when it does not implement mechanisms suitable for the wished AMR or ACR.',
    'timeout':
        'The Questioned User did not answer in the allowed period of time.',
    'unauthorized':
        'The Client is not authorized to use the User Questioning API or did not send a valid Access Token.',
    'unknown_user':
        'The Questioned User mentioned in the user_id attribute of the User Questioning Request is unknown.',
    'unreachable_user':
        'The Questioned User mentioned in the User Questioning Request (either in the Access Token or in the user_id attribute) is unreachable. The OP can use this error when it does not have a reachability identifier (e.g. MSISDN) for the Question User or when the reachability identifier is not operational (e.g. unsubscribed MSISDN).',
    'user_refused_to_answer':
        'The Questioned User refused to make a statement to the question.',
    'interaction_required':
        'The Authorization Server requires End-User interaction of some form to proceed. This error MAY be returned when the prompt parameter value in the Authentication Request is none, but the Authentication Request cannot be completed without displaying a user interface for End-User interaction.',
    'login_required':
        'The Authorization Server requires End-User authentication. This error MAY be returned when the prompt parameter value in the Authentication Request is none, but the Authentication Request cannot be completed without displaying a user interface for End-User authentication.',
    'account_selection_required':
        'The End-User is REQUIRED to select a session at the Authorization Server. The End-User MAY be authenticated at the Authorization Server with different associated accounts, but the End-User did not select a session. This error MAY be returned when the prompt parameter value in the Authentication Request is none, but the Authentication Request cannot be completed without displaying a user interface to prompt for a session to use.',
    'consent_required':
        'The Authorization Server requires End-User consent. This error MAY be returned when the prompt parameter value in the Authentication Request is none, but the Authentication Request cannot be completed without displaying a user interface for End-User consent.',
    'invalid_request_uri':
        'The request_uri in the Authorization Request returns an error or contains invalid data.',
    'invalid_request_object':
        'The request parameter contains an invalid Request Object.',
    'request_not_supported':
        'The OP does not support use of the request parameter',
    'request_uri_not_supported':
        'The OP does not support use of the request_uri parameter',
    'registration_not_supported':
        'The OP does not support use of the registration parameter',
    'invalid_redirect_uri':
        'The value of one or more redirect_uris is invalid.',
    'invalid_client_metadata':
        'The value of one of the Client Metadata fields is invalid and the server has rejected this request. Note that an Authorization Server MAY choose to substitute a valid value for any requested parameter of a Client\'s Metadata.',
  };

  /// Thrown when trying to get a token, but the token endpoint is missing from
  /// the issuer metadata
  const OpenIdException.missingTokenEndpoint()
      : this._('missing_token_endpoint',
            'The issuer metadata does not contain a token endpoint.');

  const OpenIdException._(this.code, this.message) : uri = null;

  OpenIdException(this.code, String? message, [this.uri])
      : message = message ?? _defaultMessages[code!];

  @override
  String toString() => 'OpenIdException($code): $message';
}
