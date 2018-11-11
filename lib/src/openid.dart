library openid_client.openid;

import 'dart:async';
import 'http_util.dart' as http;
import 'dart:convert';
import 'package:jose/jose.dart';
import 'dart:math';
import 'model.dart';
export 'model.dart';
import 'dart:typed_data';
import 'package:pointycastle/digests/sha256.dart';

/// Represents an OpenId Provider
class Issuer {
  /// The OpenId Provider's metadata
  final OpenIdProviderMetadata metadata;

  final Map<String, String> claimsMap;

  final JsonWebKeyStore _keyStore;

  /// Creates an issuer from its metadata.
  Issuer(this.metadata, {this.claimsMap: const {}})
      : _keyStore = new JsonWebKeyStore()..addKeySetUrl(metadata.jwksUri);

  /// Url of the facebook issuer.
  ///
  /// Note: facebook does not support OpenID Connect, but the authentication
  /// works.
  static final Uri facebook = Uri.parse("https://www.facebook.com");

  /// Url of the google issuer.
  static final Uri google = Uri.parse("https://accounts.google.com");

  /// Url of the yahoo issuer.
  static final Uri yahoo = Uri.parse("https://api.login.yahoo.com");

  /// Url of the microsoft issuer.
  static final Uri microsoft =
      Uri.parse("https://login.microsoftonline.com/common");

  /// Url of the salesforce issuer.
  static final Uri salesforce = Uri.parse("https://login.salesforce.com");

  static Uri firebase(String id) =>
      Uri.parse("https://securetoken.google.com/$id");

  static final Map<Uri, Issuer> _discoveries = {
    facebook: new Issuer(new OpenIdProviderMetadata.fromJson({
      "issuer": facebook.toString(),
      "authorization_endpoint": "https://www.facebook.com/v2.8/dialog/oauth",
      "token_endpoint": "https://graph.facebook.com/v2.8/oauth/access_token",
      "userinfo_endpoint": "https://graph.facebook.com/v2.8/879023912133394",
      "response_types_supported": ["token", "code", "code token"],
      "token_endpoint_auth_methods_supported": ["client_secret_post"],
      "scopes_supported": [
        "public_profile",
        "user_friends",
        "email",
        "user_about_me",
        "user_actions.books",
        "user_actions.fitness",
        "user_actions.music",
        "user_actions.news",
        "user_actions.video",
        "user_birthday",
        "user_education_history",
        "user_events",
        "user_games_activity",
        "user_hometown",
        "user_likes",
        "user_location",
        "user_managed_groups",
        "user_photos",
        "user_posts",
        "user_relationships",
        "user_relationship_details",
        "user_religion_politics",
        "user_tagged_places",
        "user_videos",
        "user_website",
        "user_work_history",
        "read_custom_friendlists",
        "read_insights",
        "read_audience_network_insights",
        "read_page_mailboxes",
        "manage_pages",
        "publish_pages",
        "publish_actions",
        "rsvp_event",
        "pages_show_list",
        "pages_manage_cta",
        "pages_manage_instant_articles",
        "ads_read",
        "ads_management",
        "business_management",
        "pages_messaging",
        "pages_messaging_subscriptions",
        "pages_messaging_phone_number"
      ]
    })),
    google: null,
    yahoo: null,
    microsoft: null,
    salesforce: null
  };

  static Iterable<Uri> get knownIssuers => _discoveries.keys;

  /// Discovers the OpenId Provider's metadata based on its uri.
  static Future<Issuer> discover(Uri uri) async {
    if (_discoveries[uri] != null) return _discoveries[uri];

    var segments = uri.pathSegments.toList();
    if (segments.isNotEmpty && segments.last.isEmpty) {
      segments.removeLast();
    }
    segments.addAll([".well-known", "openid-configuration"]);
    uri = uri.replace(pathSegments: segments);

    var json = await http.get(uri);
    return _discoveries[uri] =
        new Issuer(new OpenIdProviderMetadata.fromJson(json));
  }
}

/// Represents the client application.
class Client {
  /// The id of the client.
  final String clientId;

  /// A secret for authenticating the client to the OP.
  final String clientSecret;

  /// The [Issuer] representing the OP.
  final Issuer issuer;

  Client(this.issuer, this.clientId, [this.clientSecret]);

  static Future<Client> forIdToken(String idToken) async {
    var token = JsonWebToken.unverified(idToken);
    var claims = new OpenIdClaims.fromJson(token.claims.toJson());
    if (claims.issuer == null) throw new ArgumentError("Token has no issuer.");
    var issuer = await Issuer.discover(claims.issuer);
    if (!await token.verify(issuer._keyStore)) {
      throw new ArgumentError("Unable to verify token");
    }
    var clientId = claims.authorizedParty ?? claims.audience.single;
    return new Client(issuer, clientId);
  }

  /// Creates a [Credential] for this client.
  Credential createCredential(
          {String accessToken,
          String tokenType,
          String refreshToken,
          String idToken}) =>
      new Credential._(
          this,
          new TokenResponse.fromJson({
            "access_token": accessToken,
            "token_type": tokenType,
            "refresh_token": refreshToken,
            "id_token": idToken
          }),
          null);
}

class Credential {
  TokenResponse _token;
  final Client client;
  final String nonce;

  Credential._(this.client, this._token, this.nonce);

  Map<String, dynamic> get response => _token.toJson();

  Future<UserInfo> getUserInfo() async {
    var uri = client.issuer.metadata.userinfoEndpoint;
    if (uri == null) {
      throw new UnsupportedError("Issuer does not support userinfo endpoint.");
    }
    return new UserInfo.fromJson(await _get(uri));
  }

  Future _get(uri) async {
    if (_token.accessToken == null) {
      var json = await http.post(client.issuer.metadata.tokenEndpoint, body: {
        "grant_type": "refresh_token",
        "refresh_token": _token.refreshToken,
        "client_id": client.clientId,
      });
      if (json["error"] != null) {
        throw new Exception(json["error_description"]);
      }

      _token = new TokenResponse.fromJson(json);
    }
    if (_token.tokenType != null && _token.tokenType.toLowerCase() != "bearer")
      throw new UnsupportedError("Unknown token type: ${_token.tokenType}");

    return http
        .get(uri, headers: {"authorization": "Bearer ${_token.accessToken}"});
  }

  IdToken get idToken => _token.idToken;

  Stream<Exception> validateToken(
      {bool validateClaims: true, bool validateExpiry: true}) async* {
    var keyStore = new JsonWebKeyStore()
      ..addKeySetUrl(client.issuer.metadata.jwksUri);
    if (!await idToken.verify(keyStore)) {
      yield new JoseException("Could not verify token signature");
    }

    yield* new Stream.fromIterable(idToken.claims.validate(
        expiryTolerance: validateExpiry ? const Duration(seconds: 30) : null,
        issuer: client.issuer.metadata.issuer,
        clientId: client.clientId,
        nonce: nonce));
  }

  String get refreshToken => _token.refreshToken;
}

enum FlowType { implicit, authorizationCode, proofKeyForCodeExchange }

class Flow {
  final FlowType type;

  final String responseType;

  final Client client;

  final List<String> scopes = [];

  final String state;

  Uri redirectUri = Uri.parse("http://localhost");

  Flow._(this.type, this.responseType, this.client, {String state})
      : state = state ?? _randomString(20) {
    var scopes = client.issuer.metadata.scopesSupported;
    for (var s in const ["openid", "profile", "email"]) {
      if (scopes.contains(s)) {
        this.scopes.add(s);
        break;
      }
    }

    var verifier = _randomString(50);
    var challenge = base64Url
        .encode(new SHA256Digest()
            .process(new Uint8List.fromList(verifier.codeUnits)))
        .replaceAll("=", "");
    _proofKeyForCodeExchange = {
      "code_verifier": verifier,
      "code_challenge": challenge
    };
  }

  Flow.authorizationCode(Client client, {String state})
      : this._(FlowType.authorizationCode, "code", client, state: state);

  Flow.authorizationCodeWithPKCE(Client client, {String state})
      : this._(FlowType.proofKeyForCodeExchange, "code", client, state: state);

  Flow.implicit(Client client, {String state})
      : this._(
            FlowType.implicit,
            ["token id_token", "id_token", "token"].firstWhere((v) =>
                client.issuer.metadata.responseTypesSupported.contains(v)),
            client,
            state: state);

  Uri get authenticationUri => client.issuer.metadata.authorizationEndpoint
      .replace(queryParameters: _authenticationUriParameters);

  Map<String, String> _proofKeyForCodeExchange;

  final String _nonce = _randomString(16);

  Map<String, String> get _authenticationUriParameters {
    var v = {
      "response_type": responseType,
      "scope": scopes.join(" "),
      "client_id": client.clientId,
      "redirect_uri": redirectUri.toString(),
      "state": state
    }..addAll(
        responseType.split(" ").contains("id_token") ? {"nonce": _nonce} : {});

    if (type == FlowType.proofKeyForCodeExchange) {
      v.addAll({
        "code_challenge_method": "S256",
        "code_challenge": _proofKeyForCodeExchange["code_challenge"]
      });
    }
    return v;
  }

  Future<TokenResponse> _getToken(String code) async {
    var methods = client.issuer.metadata.tokenEndpointAuthMethodsSupported;
    var json;
    if (type == FlowType.proofKeyForCodeExchange) {
      json = await http.post(client.issuer.metadata.tokenEndpoint, body: {
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": redirectUri.toString(),
        "client_id": client.clientId,
        "code_verifier": _proofKeyForCodeExchange["code_verifier"]
      });
    } else if (methods.contains("client_secret_post")) {
      json = await http.post(client.issuer.metadata.tokenEndpoint, body: {
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": redirectUri.toString(),
        "client_id": client.clientId,
        "client_secret": client.clientSecret
      });
    } else if (methods.contains("client_secret_basic")) {
      var h =
          base64.encode("${client.clientId}:${client.clientSecret}".codeUnits);
      json = await http.post(client.issuer.metadata.tokenEndpoint, headers: {
        "authorization": "Basic $h"
      }, body: {
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": redirectUri.toString()
      });
    } else {
      throw new UnsupportedError("Unknown auth methods: $methods");
    }
    if (json["error"] != null) {
      throw new Exception(json["error_description"]);
    }
    return new TokenResponse.fromJson(json);
  }

  Future<Credential> callback(Map<String, String> response) async {
    if (response["state"] != state) {
      throw new ArgumentError("State does not match");
    }
    if (response.containsKey("code") &&
        (type == FlowType.proofKeyForCodeExchange ||
            client.clientSecret != null)) {
      var code = response["code"];
      return new Credential._(client, await _getToken(code), null);
    } else if (response.containsKey("access_token") ||
        response.containsKey("id_token")) {
      return new Credential._(
          client, new TokenResponse.fromJson(response), _nonce);
    } else {
      return new Credential._(
          client, new TokenResponse.fromJson(response), _nonce);
    }
  }
}

String _randomString(int length) {
  var r = new Random.secure();
  var chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
  return new Iterable.generate(50, (_) => chars[r.nextInt(chars.length)])
      .join();
}
