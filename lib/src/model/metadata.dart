
part of openid.model;

/// OpenID Provider Metadata
@JsonSerializable()
class OpenIdProviderMetadata extends _$OpenIdProviderMetadataSerializerMixin {

  /// URL that the OP asserts as its OpenIdProviderMetadata Identifier.
  final Uri issuer;

  /// URL of the OP's OAuth 2.0 Authorization Endpoint.
  final Uri authorizationEndpoint;

  /// URL of the OP's OAuth 2.0 Token Endpoint.
  final Uri tokenEndpoint;

  /// URL of the OP's UserInfo Endpoint.
  final Uri userinfoEndpoint;

  /// URL of the OP's JSON Web Key Set document.
  ///
  /// This contains the signing key(s) the RP uses to validate signatures from the OP.
  final Uri jwksUri;

  /// URL of the OP's Dynamic Client Registration Endpoint.
  final Uri registrationEndpoint;

  /// A list of the OAuth 2.0 scope values that this server supports.
  final List<String> scopesSupported;

  /// A list of the OAuth 2.0 `response_type` values that this OP supports.
  final List<String> responseTypesSupported;

  /// A list of the OAuth 2.0 `response_mode` values that this OP supports.
  final List<String> responseModesSupported;

  /// A list of the OAuth 2.0 Grant Type values that this OP supports.
  final List<String> grantTypesSupported;

  /// A list of the Authentication Context Class References that this OP supports.
  final List<String> acrValuesSupported;

  /// A list of the Subject Identifier types that this OP supports.
  ///
  /// Valid types include `pairwise` and `public`.
  final List<String> subjectTypesSupported;

  /// A list of the JWS signing algorithms (`alg` values) supported by the OP for
  /// the ID Token to encode the Claims in a JWT.
  ///
  /// The algorithm `RS256` MUST be included. The value `none` MAY be supported,
  /// but MUST NOT be used unless the Response Type used returns no ID Token
  /// from the Authorization Endpoint (such as when using the Authorization Code
  /// Flow).
  final List<String> idTokenSigningAlgValuesSupported;

  /// A list of the JWE encryption algorithms (`alg` values) supported by the OP
  /// for the ID Token to encode the Claims in a JWT.
  final List<String> idTokenEncryptionAlgValuesSupported;

  /// A list of the JWE encryption algorithms (`enc` values) supported by the OP
  /// for the ID Token to encode the Claims in a JWT.
  final List<String> idTokenEncryptionEncValuesSupported;

  /// A list of the JWS signing algorithms (`alg` values) supported by the
  /// UserInfo Endpoint to encode the Claims in a JWT.
  final List<String> userinfoSigningAlgValuesSupported;

  /// A list of the JWE encryption algorithms (`alg` values) supported by the
  /// UserInfo Endpoint to encode the Claims in a JWT.
  final List<String> userinfoEncryptionAlgValuesSupported;

  /// A list of the JWE encryption algorithms (`enc` values) supported by the
  /// UserInfo Endpoint to encode the Claims in a JWT.
  final List<String> userinfoEncryptionEncValuesSupported;

  /// A list of the JWS signing algorithms (`alg` values) supported by the OP
  /// for Request Objects.
  ///
  /// These algorithms are used both when the Request Object is passed by value
  /// (using the request parameter) and when it is passed by reference (using
  /// the request_uri parameter).
  final List<String> requestObjectSigningAlgValuesSupported;

  /// A list of the JWE encryption algorithms (`alg` values) supported by the OP
  /// for Request Objects.
  ///
  /// These algorithms are used both when the Request Object is passed by value
  /// and when it is passed by reference.
  final List<String> requestObjectEncryptionAlgValuesSupported;

  /// A list of the JWE encryption algorithms (`enc` values) supported by the OP
  /// for Request Objects.
  ///
  /// These algorithms are used both when the Request Object is passed by value
  /// and when it is passed by reference.
  final List<String> requestObjectEncryptionEncValuesSupported;

  /// A list of Client Authentication methods supported by this Token Endpoint.
  ///
  /// The options are `client_secret_post`, `client_secret_basic`,
  /// `client_secret_jwt`, and `private_key_jwt`. Other authentication methods
  /// MAY be defined by extensions.
  final List<String> tokenEndpointAuthMethodsSupported;

  /// A list of the JWS signing algorithms (`alg` values) supported by the Token
  /// Endpoint for the signature on the JWT used to authenticate the Client at
  /// the Token Endpoint for the `private_key_jwt` and `client_secret_jwt`
  /// authentication methods.
  final List<String> tokenEndpointAuthSigningAlgValuesSupported;

  /// A list of the display parameter values that the OpenID Provider supports.
  final List<String> displayValuesSupported;

  /// A list of the Claim Types that the OpenID Provider supports.
  ///
  /// Values defined by the specification are `normal`, `aggregated`, and
  /// `distributed`. If omitted, the implementation supports only `normal` Claims.
  final List<String> claimTypesSupported;

  /// A list of the Claim Names of the Claims that the OpenID Provider MAY be
  /// able to supply values for.
  ///
  /// Note that for privacy or other reasons, this might not be an exhaustive
  /// list.
  final List<String> claimsSupported;

  /// URL of a page containing human-readable information that developers might
  /// want or need to know when using the OpenID Provider.
  final Uri serviceDocumentation;

  /// Languages and scripts supported for values in Claims being returned.
  ///
  /// Not all languages and scripts are necessarily supported for all Claim values.
  final List<String> claimsLocalesSupported;

  /// Languages and scripts supported for the user interface.
  final List<String> uiLocalesSupported;

  /// `true` when the OP supports use of the `claims` parameter.
  final bool claimsParameterSupported;

  /// `true` when the OP supports use of the `request` parameter.
  final bool requestParameterSupported;

  /// `true` when the OP supports use of the `request_uri` parameter.
  final bool requestUriParameterSupported;

  /// `true` when the OP requires any `request_uri` values used to be
  /// pre-registered using the request_uris registration parameter.
  final bool requireRequestUriRegistration;

  /// URL that the OpenID Provider provides to the person registering the Client
  /// to read about the OP's requirements on how the Relying Party can use the
  /// data provided by the OP.
  final Uri opPolicyUri;

  /// URL that the OpenID Provider provides to the person registering the Client
  /// to read about OpenID Provider's terms of service.
  final Uri opTosUri;

  /// URL of an OP iframe that supports cross-origin communications for session
  /// state information with the RP Client, using the HTML5 postMessage API.
  ///
  /// The page is loaded from an invisible iframe embedded in an RP page so that
  /// it can run in the OP's security context. It accepts postMessage requests
  /// from the relevant RP iframe and uses postMessage to post back the login
  /// status of the End-User at the OP.
  final Uri checkSessionIframe;

  /// URL at the OP to which an RP can perform a redirect to request that the
  /// End-User be logged out at the OP.
  final Uri endSessionEndpoint;

  /// URL of the authorization server's OAuth 2.0 revocation endpoint.
  final Uri revocationEndpoint;

  /// A list of client authentication methods supported by this revocation
  /// endpoint.
  final List<String> revocationEndpointAuthMethodsSupported;

  /// A list of the JWS signing algorithms (`alg` values) supported by the
  /// revocation endpoint for the signature on the JWT used to authenticate the
  /// client at the revocation endpoint for the `private_key_jwt` and
  /// `client_secret_jwt` authentication methods.
  final List<String> revocationEndpointAuthSigningAlgValuesSupported;

  /// URL of the authorization server's OAuth 2.0 introspection endpoint.
  final Uri introspectionEndpoint;

  /// A list of client authentication methods supported by this introspection
  /// endpoint.
  final List<String> introspectionEndpointAuthMethodsSupported;

  /// A list of the JWS signing algorithms (`alg` values) supported by the
  /// introspection endpoint for the signature on the JWT used to authenticate
  /// the client at the introspection endpoint for the `private_key_jwt` and
  /// `client_secret_jwt` authentication methods.
  final List<String> introspectionEndpointAuthSigningAlgValuesSupported;

  /// A list of PKCE code challenge methods supported by this authorization
  /// server.
  final List<String> codeChallengeMethodsSupported;


  OpenIdProviderMetadata({
  this.issuer,
  this.authorizationEndpoint,
  this.tokenEndpoint,
  this.userinfoEndpoint,
  this.jwksUri,
  this.registrationEndpoint,
  this.scopesSupported,
  this.responseTypesSupported,
  this.responseModesSupported: const ["query", "fragment"],
  this.grantTypesSupported: const ["authorization_code", "implicit"],
  this.acrValuesSupported,
  this.subjectTypesSupported,
  this.idTokenSigningAlgValuesSupported,
  this.idTokenEncryptionAlgValuesSupported,
  this.idTokenEncryptionEncValuesSupported,
  this.userinfoSigningAlgValuesSupported,
  this.userinfoEncryptionAlgValuesSupported,
  this.userinfoEncryptionEncValuesSupported,
  this.requestObjectSigningAlgValuesSupported,
  this.requestObjectEncryptionAlgValuesSupported,
  this.requestObjectEncryptionEncValuesSupported,
  this.tokenEndpointAuthMethodsSupported: const ['client_secret_basic'],
  this.tokenEndpointAuthSigningAlgValuesSupported,
  this.displayValuesSupported,
  this.claimTypesSupported: const ['normal'],
  this.claimsSupported,
  this.serviceDocumentation,
  this.claimsLocalesSupported,
  this.uiLocalesSupported,
  this.claimsParameterSupported: false,
  this.requestParameterSupported: false,
  this.requestUriParameterSupported: true,
  this.requireRequestUriRegistration: false,
  this.opPolicyUri,
  this.opTosUri,
  this.checkSessionIframe,
  this.endSessionEndpoint,
  this.revocationEndpoint,
  this.revocationEndpointAuthMethodsSupported,
  this.revocationEndpointAuthSigningAlgValuesSupported,
  this.introspectionEndpoint,
  this.introspectionEndpointAuthMethodsSupported,
  this.introspectionEndpointAuthSigningAlgValuesSupported,
  this.codeChallengeMethodsSupported});

  factory OpenIdProviderMetadata.fromJson(Map<String, dynamic> json) => _$OpenIdProviderMetadataFromJson(json);

}

