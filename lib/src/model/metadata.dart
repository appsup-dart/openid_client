part of '../model.dart';

/// OpenID Provider Metadata
class OpenIdProviderMetadata extends JsonObject {
  /// URL that the OP asserts as its OpenIdProviderMetadata Identifier.
  Uri get issuer => getTyped('issuer')!;

  /// URL of the OP's OAuth 2.0 Authorization Endpoint.
  Uri get authorizationEndpoint => getTyped('authorization_endpoint')!;

  /// URL of the OP's OAuth 2.0 Token Endpoint.
  Uri? get tokenEndpoint => getTyped('token_endpoint');

  /// URL of the OP's UserInfo Endpoint.
  Uri? get userinfoEndpoint => getTyped('userinfo_endpoint');

  /// URL of the OP's JSON Web Key Set document.
  ///
  /// This contains the signing key(s) the RP uses to validate signatures from the OP.
  Uri? get jwksUri => getTyped('jwks_uri');

  /// URL of the OP's Dynamic Client Registration Endpoint.
  Uri? get registrationEndpoint => getTyped('registration_endpoint');

  /// A list of the OAuth 2.0 scope values that this server supports.
  List<String>? get scopesSupported => getTypedList('scopes_supported');

  /// A list of the OAuth 2.0 `response_type` values that this OP supports.
  List<String> get responseTypesSupported =>
      getTypedList('response_types_supported')!;

  /// A list of the OAuth 2.0 `response_mode` values that this OP supports.
  List<String>? get responseModesSupported =>
      getTypedList('response_modes_supported');

  /// A list of the OAuth 2.0 Grant Type values that this OP supports.
  List<String>? get grantTypesSupported =>
      getTypedList('grant_types_supported');

  /// A list of the Authentication Context Class References that this OP supports.
  List<String>? get acrValuesSupported => getTypedList('acr_values_supported');

  /// A list of the Subject Identifier types that this OP supports.
  ///
  /// Valid types include `pairwise` and `public`.
  List<String> get subjectTypesSupported =>
      getTypedList('subject_types_supported')!;

  /// A list of the JWS signing algorithms (`alg` values) supported by the OP for
  /// the ID Token to encode the Claims in a JWT.
  ///
  /// The algorithm `RS256` MUST be included. The value `none` MAY be supported,
  /// but MUST NOT be used unless the Response Type used returns no ID Token
  /// from the Authorization Endpoint (such as when using the Authorization Code
  /// Flow).
  List<String> get idTokenSigningAlgValuesSupported =>
      getTypedList('id_token_signing_alg_values_supported')!;

  /// A list of the JWE encryption algorithms (`alg` values) supported by the OP
  /// for the ID Token to encode the Claims in a JWT.
  List<String>? get idTokenEncryptionAlgValuesSupported =>
      getTypedList('id_token_encryption_alg_values_supported');

  /// A list of the JWE encryption algorithms (`enc` values) supported by the OP
  /// for the ID Token to encode the Claims in a JWT.
  List<String>? get idTokenEncryptionEncValuesSupported =>
      getTypedList('id_token_encryption_enc_values_supported');

  /// A list of the JWS signing algorithms (`alg` values) supported by the
  /// UserInfo Endpoint to encode the Claims in a JWT.
  List<String>? get userinfoSigningAlgValuesSupported =>
      getTypedList('userinfo_signing_alg_values_supported');

  /// A list of the JWE encryption algorithms (`alg` values) supported by the
  /// UserInfo Endpoint to encode the Claims in a JWT.
  List<String>? get userinfoEncryptionAlgValuesSupported =>
      getTypedList('userinfo_encryption_alg_values_supported');

  /// A list of the JWE encryption algorithms (`enc` values) supported by the
  /// UserInfo Endpoint to encode the Claims in a JWT.
  List<String>? get userinfoEncryptionEncValuesSupported =>
      getTypedList('userinfo_encryption_enc_values_supported');

  /// A list of the JWS signing algorithms (`alg` values) supported by the OP
  /// for Request Objects.
  ///
  /// These algorithms are used both when the Request Object is passed by value
  /// (using the request parameter) and when it is passed by reference (using
  /// the request_uri parameter).
  List<String>? get requestObjectSigningAlgValuesSupported =>
      getTypedList('request_object_signing_alg_values_supported');

  /// A list of the JWE encryption algorithms (`alg` values) supported by the OP
  /// for Request Objects.
  ///
  /// These algorithms are used both when the Request Object is passed by value
  /// and when it is passed by reference.
  List<String>? get requestObjectEncryptionAlgValuesSupported =>
      getTypedList('request_object_encryption_alg_values_supported');

  /// A list of the JWE encryption algorithms (`enc` values) supported by the OP
  /// for Request Objects.
  ///
  /// These algorithms are used both when the Request Object is passed by value
  /// and when it is passed by reference.
  List<String>? get requestObjectEncryptionEncValuesSupported =>
      getTypedList('request_object_encryption_enc_values_supported');

  /// A list of Client Authentication methods supported by this Token Endpoint.
  ///
  /// The options are `client_secret_post`, `client_secret_basic`,
  /// `client_secret_jwt`, and `private_key_jwt`. Other authentication methods
  /// MAY be defined by extensions.
  List<String>? get tokenEndpointAuthMethodsSupported =>
      getTypedList('token_endpoint_auth_methods_supported');

  /// A list of the JWS signing algorithms (`alg` values) supported by the Token
  /// Endpoint for the signature on the JWT used to authenticate the Client at
  /// the Token Endpoint for the `private_key_jwt` and `client_secret_jwt`
  /// authentication methods.
  List<String>? get tokenEndpointAuthSigningAlgValuesSupported =>
      getTypedList('token_endpoint_auth_signing_alg_values_supported');

  /// A list of the display parameter values that the OpenID Provider supports.
  List<String>? get displayValuesSupported =>
      getTypedList('display_values_supported');

  /// A list of the Claim Types that the OpenID Provider supports.
  ///
  /// Values defined by the specification are `normal`, `aggregated`, and
  /// `distributed`. If omitted, the implementation supports only `normal` Claims.
  List<String>? get claimTypesSupported =>
      getTypedList('claim_types_supported');

  /// A list of the Claim Names of the Claims that the OpenID Provider MAY be
  /// able to supply values for.
  ///
  /// Note that for privacy or other reasons, this might not be an exhaustive
  /// list.
  List<String>? get claimsSupported => getTypedList('claims_supported');

  /// URL of a page containing human-readable information that developers might
  /// want or need to know when using the OpenID Provider.
  Uri? get serviceDocumentation => getTyped('service_documentation');

  /// Languages and scripts supported for values in Claims being returned.
  ///
  /// Not all languages and scripts are necessarily supported for all Claim values.
  List<String>? get claimsLocalesSupported =>
      getTypedList('claims_locales_supported');

  /// Languages and scripts supported for the user interface.
  List<String>? get uiLocalesSupported => getTypedList('ui_locales_supported');

  /// `true` when the OP supports use of the `claims` parameter.
  bool get claimsParameterSupported =>
      this['claims_parameter_supported'] ?? false;

  /// `true` when the OP supports use of the `request` parameter.
  bool get requestParameterSupported =>
      this['request_parameter_supported'] ?? false;

  /// `true` when the OP supports use of the `request_uri` parameter.
  bool get requestUriParameterSupported =>
      this['request_uri_parameter_supported'] ?? true;

  /// `true` when the OP requires any `request_uri` values used to be
  /// pre-registered using the request_uris registration parameter.
  bool get requireRequestUriRegistration =>
      this['require_request_uri_registration'] ?? false;

  /// URL that the OpenID Provider provides to the person registering the Client
  /// to read about the OP's requirements on how the Relying Party can use the
  /// data provided by the OP.
  Uri? get opPolicyUri => getTyped('op_policy_uri');

  /// URL that the OpenID Provider provides to the person registering the Client
  /// to read about OpenID Provider's terms of service.
  Uri? get opTosUri => getTyped('op_tos_uri');

  /// URL of an OP iframe that supports cross-origin communications for session
  /// state information with the RP Client, using the HTML5 postMessage API.
  ///
  /// The page is loaded from an invisible iframe embedded in an RP page so that
  /// it can run in the OP's security context. It accepts postMessage requests
  /// from the relevant RP iframe and uses postMessage to post back the login
  /// status of the End-User at the OP.
  Uri? get checkSessionIframe => getTyped('check_session_iframe');

  /// URL at the OP to which an RP can perform a redirect to request that the
  /// End-User be logged out at the OP.
  Uri? get endSessionEndpoint => getTyped('end_session_endpoint');

  /// URL of the authorization server's OAuth 2.0 revocation endpoint.
  Uri? get revocationEndpoint => getTyped('revocation_endpoint');

  /// A list of client authentication methods supported by this revocation
  /// endpoint.
  List<String>? get revocationEndpointAuthMethodsSupported =>
      getTypedList('revocation_endpoint_auth_methods_supported');

  /// A list of the JWS signing algorithms (`alg` values) supported by the
  /// revocation endpoint for the signature on the JWT used to authenticate the
  /// client at the revocation endpoint for the `private_key_jwt` and
  /// `client_secret_jwt` authentication methods.
  List<String>? get revocationEndpointAuthSigningAlgValuesSupported =>
      getTypedList('revocation_endpoint_auth_signing_alg_values_supported');

  /// URL of the authorization server's OAuth 2.0 introspection endpoint.
  Uri? get introspectionEndpoint => getTyped('introspection_endpoint');

  /// A list of client authentication methods supported by this introspection
  /// endpoint.
  List<String>? get introspectionEndpointAuthMethodsSupported =>
      getTypedList('introspection_endpoint_auth_methods_supported');

  /// A list of the JWS signing algorithms (`alg` values) supported by the
  /// introspection endpoint for the signature on the JWT used to authenticate
  /// the client at the introspection endpoint for the `private_key_jwt` and
  /// `client_secret_jwt` authentication methods.
  List<String>? get introspectionEndpointAuthSigningAlgValuesSupported =>
      getTypedList('introspection_endpoint_auth_signing_alg_values_supported');

  /// A list of PKCE code challenge methods supported by this authorization
  /// server.
  List<String>? get codeChallengeMethodsSupported =>
      getTypedList('code_challenge_methods_supported');

  OpenIdProviderMetadata.fromJson(Map<String, dynamic> json) : super.from(json);
}
