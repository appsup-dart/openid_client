// GENERATED CODE - DO NOT MODIFY BY HAND

part of openid.model;

// **************************************************************************
// Generator: JsonSerializableGenerator
// Target: class OpenIdProviderMetadata
// **************************************************************************

OpenIdProviderMetadata _$OpenIdProviderMetadataFromJson(Map json) => new OpenIdProviderMetadata(
    issuer: json['issuer'] == null ? null : Uri.parse(json['issuer']),
    authorizationEndpoint: json['authorization_endpoint'] == null
        ? null
        : Uri.parse(json['authorization_endpoint']),
    tokenEndpoint: json['token_endpoint'] == null
        ? null
        : Uri.parse(json['token_endpoint']),
    userinfoEndpoint: json['userinfo_endpoint'] == null
        ? null
        : Uri.parse(json['userinfo_endpoint']),
    jwksUri: json['jwks_uri'] == null ? null : Uri.parse(json['jwks_uri']),
    registrationEndpoint: json['registration_endpoint'] == null
        ? null
        : Uri.parse(json['registration_endpoint']),
    scopesSupported:
        (json['scopes_supported'] as List)?.map((v0) => v0 as String)?.toList(),
    responseTypesSupported: (json['response_types_supported'] as List)
        ?.map((v0) => v0 as String)
        ?.toList(),
    responseModesSupported: (json['response_modes_supported'] as List)
        ?.map((v0) => v0 as String)
        ?.toList(),
    grantTypesSupported: (json['grant_types_supported'] as List)
        ?.map((v0) => v0 as String)
        ?.toList(),
    acrValuesSupported: (json['acr_values_supported'] as List)
        ?.map((v0) => v0 as String)
        ?.toList(),
    subjectTypesSupported: (json['subject_types_supported'] as List)
        ?.map((v0) => v0 as String)
        ?.toList(),
    idTokenSigningAlgValuesSupported:
        (json['id_token_signing_alg_values_supported'] as List)
            ?.map((v0) => v0 as String)
            ?.toList(),
    idTokenEncryptionAlgValuesSupported:
        (json['id_token_encryption_alg_values_supported'] as List)
            ?.map((v0) => v0 as String)
            ?.toList(),
    idTokenEncryptionEncValuesSupported:
        (json['id_token_encryption_enc_values_supported'] as List)
            ?.map((v0) => v0 as String)
            ?.toList(),
    userinfoSigningAlgValuesSupported:
        (json['userinfo_signing_alg_values_supported'] as List)
            ?.map((v0) => v0 as String)
            ?.toList(),
    userinfoEncryptionAlgValuesSupported:
        (json['userinfo_encryption_alg_values_supported'] as List)
            ?.map((v0) => v0 as String)
            ?.toList(),
    userinfoEncryptionEncValuesSupported:
        (json['userinfo_encryption_enc_values_supported'] as List)?.map((v0) => v0 as String)?.toList(),
    requestObjectSigningAlgValuesSupported: (json['request_object_signing_alg_values_supported'] as List)?.map((v0) => v0 as String)?.toList(),
    requestObjectEncryptionAlgValuesSupported: (json['request_object_encryption_alg_values_supported'] as List)?.map((v0) => v0 as String)?.toList(),
    requestObjectEncryptionEncValuesSupported: (json['request_object_encryption_enc_values_supported'] as List)?.map((v0) => v0 as String)?.toList(),
    tokenEndpointAuthMethodsSupported: (json['token_endpoint_auth_methods_supported'] as List)?.map((v0) => v0 as String)?.toList(),
    tokenEndpointAuthSigningAlgValuesSupported: (json['token_endpoint_auth_signing_alg_values_supported'] as List)?.map((v0) => v0 as String)?.toList(),
    displayValuesSupported: (json['display_values_supported'] as List)?.map((v0) => v0 as String)?.toList(),
    claimTypesSupported: (json['claim_types_supported'] as List)?.map((v0) => v0 as String)?.toList(),
    claimsSupported: (json['claims_supported'] as List)?.map((v0) => v0 as String)?.toList(),
    serviceDocumentation: json['service_documentation'] == null ? null : Uri.parse(json['service_documentation']),
    claimsLocalesSupported: (json['claims_locales_supported'] as List)?.map((v0) => v0 as String)?.toList(),
    uiLocalesSupported: (json['ui_locales_supported'] as List)?.map((v0) => v0 as String)?.toList(),
    claimsParameterSupported: json['claims_parameter_supported'] as bool,
    requestParameterSupported: json['request_parameter_supported'] as bool,
    requestUriParameterSupported: json['request_uri_parameter_supported'] as bool,
    requireRequestUriRegistration: json['require_request_uri_registration'] as bool,
    opPolicyUri: json['op_policy_uri'] == null ? null : Uri.parse(json['op_policy_uri']),
    opTosUri: json['op_tos_uri'] == null ? null : Uri.parse(json['op_tos_uri']),
    checkSessionIframe: json['check_session_iframe'] == null ? null : Uri.parse(json['check_session_iframe']),
    endSessionEndpoint: json['end_session_endpoint'] == null ? null : Uri.parse(json['end_session_endpoint']),
    revocationEndpoint: json['revocation_endpoint'] == null ? null : Uri.parse(json['revocation_endpoint']),
    revocationEndpointAuthMethodsSupported: (json['revocation_endpoint_auth_methods_supported'] as List)?.map((v0) => v0 as String)?.toList(),
    revocationEndpointAuthSigningAlgValuesSupported: (json['revocation_endpoint_auth_signing_alg_values_supported'] as List)?.map((v0) => v0 as String)?.toList(),
    introspectionEndpoint: json['introspection_endpoint'] == null ? null : Uri.parse(json['introspection_endpoint']),
    introspectionEndpointAuthMethodsSupported: (json['introspection_endpoint_auth_methods_supported'] as List)?.map((v0) => v0 as String)?.toList(),
    introspectionEndpointAuthSigningAlgValuesSupported: (json['introspection_endpoint_auth_signing_alg_values_supported'] as List)?.map((v0) => v0 as String)?.toList(),
    codeChallengeMethodsSupported: (json['code_challenge_methods_supported'] as List)?.map((v0) => v0 as String)?.toList());

abstract class _$OpenIdProviderMetadataSerializerMixin {
  Uri get issuer;
  Uri get authorizationEndpoint;
  Uri get tokenEndpoint;
  Uri get userinfoEndpoint;
  Uri get jwksUri;
  Uri get registrationEndpoint;
  List get scopesSupported;
  List get responseTypesSupported;
  List get responseModesSupported;
  List get grantTypesSupported;
  List get acrValuesSupported;
  List get subjectTypesSupported;
  List get idTokenSigningAlgValuesSupported;
  List get idTokenEncryptionAlgValuesSupported;
  List get idTokenEncryptionEncValuesSupported;
  List get userinfoSigningAlgValuesSupported;
  List get userinfoEncryptionAlgValuesSupported;
  List get userinfoEncryptionEncValuesSupported;
  List get requestObjectSigningAlgValuesSupported;
  List get requestObjectEncryptionAlgValuesSupported;
  List get requestObjectEncryptionEncValuesSupported;
  List get tokenEndpointAuthMethodsSupported;
  List get tokenEndpointAuthSigningAlgValuesSupported;
  List get displayValuesSupported;
  List get claimTypesSupported;
  List get claimsSupported;
  Uri get serviceDocumentation;
  List get claimsLocalesSupported;
  List get uiLocalesSupported;
  bool get claimsParameterSupported;
  bool get requestParameterSupported;
  bool get requestUriParameterSupported;
  bool get requireRequestUriRegistration;
  Uri get opPolicyUri;
  Uri get opTosUri;
  Uri get checkSessionIframe;
  Uri get endSessionEndpoint;
  Uri get revocationEndpoint;
  List get revocationEndpointAuthMethodsSupported;
  List get revocationEndpointAuthSigningAlgValuesSupported;
  Uri get introspectionEndpoint;
  List get introspectionEndpointAuthMethodsSupported;
  List get introspectionEndpointAuthSigningAlgValuesSupported;
  List get codeChallengeMethodsSupported;
  Map<String, dynamic> toJson() => _removeNulls(<String, dynamic>{
        'issuer': issuer?.toString(),
        'authorization_endpoint': authorizationEndpoint?.toString(),
        'token_endpoint': tokenEndpoint?.toString(),
        'userinfo_endpoint': userinfoEndpoint?.toString(),
        'jwks_uri': jwksUri?.toString(),
        'registration_endpoint': registrationEndpoint?.toString(),
        'scopes_supported': scopesSupported,
        'response_types_supported': responseTypesSupported,
        'response_modes_supported': responseModesSupported,
        'grant_types_supported': grantTypesSupported,
        'acr_values_supported': acrValuesSupported,
        'subject_types_supported': subjectTypesSupported,
        'id_token_signing_alg_values_supported':
            idTokenSigningAlgValuesSupported,
        'id_token_encryption_alg_values_supported':
            idTokenEncryptionAlgValuesSupported,
        'id_token_encryption_enc_values_supported':
            idTokenEncryptionEncValuesSupported,
        'userinfo_signing_alg_values_supported':
            userinfoSigningAlgValuesSupported,
        'userinfo_encryption_alg_values_supported':
            userinfoEncryptionAlgValuesSupported,
        'userinfo_encryption_enc_values_supported':
            userinfoEncryptionEncValuesSupported,
        'request_object_signing_alg_values_supported':
            requestObjectSigningAlgValuesSupported,
        'request_object_encryption_alg_values_supported':
            requestObjectEncryptionAlgValuesSupported,
        'request_object_encryption_enc_values_supported':
            requestObjectEncryptionEncValuesSupported,
        'token_endpoint_auth_methods_supported':
            tokenEndpointAuthMethodsSupported,
        'token_endpoint_auth_signing_alg_values_supported':
            tokenEndpointAuthSigningAlgValuesSupported,
        'display_values_supported': displayValuesSupported,
        'claim_types_supported': claimTypesSupported,
        'claims_supported': claimsSupported,
        'service_documentation': serviceDocumentation?.toString(),
        'claims_locales_supported': claimsLocalesSupported,
        'ui_locales_supported': uiLocalesSupported,
        'claims_parameter_supported': claimsParameterSupported,
        'request_parameter_supported': requestParameterSupported,
        'request_uri_parameter_supported': requestUriParameterSupported,
        'require_request_uri_registration': requireRequestUriRegistration,
        'op_policy_uri': opPolicyUri?.toString(),
        'op_tos_uri': opTosUri?.toString(),
        'check_session_iframe': checkSessionIframe?.toString(),
        'end_session_endpoint': endSessionEndpoint?.toString(),
        'revocation_endpoint': revocationEndpoint?.toString(),
        'revocation_endpoint_auth_methods_supported':
            revocationEndpointAuthMethodsSupported,
        'revocation_endpoint_auth_signing_alg_values_supported':
            revocationEndpointAuthSigningAlgValuesSupported,
        'introspection_endpoint': introspectionEndpoint?.toString(),
        'introspection_endpoint_auth_methods_supported':
            introspectionEndpointAuthMethodsSupported,
        'introspection_endpoint_auth_signing_alg_values_supported':
            introspectionEndpointAuthSigningAlgValuesSupported,
        'code_challenge_methods_supported': codeChallengeMethodsSupported
      });
  Map<String, dynamic> _removeNulls(Map<String, dynamic> json) =>
      new Map.fromIterable(json.keys.where((k) => json[k] != null),
          value: (k) => json[k]);
}

// **************************************************************************
// Generator: JsonSerializableGenerator
// Target: class JsonWebKey
// **************************************************************************

JsonWebKey _$JsonWebKeyFromJson(Map json) => new JsonWebKey(
    keyType: json['kty'] as String,
    use: json['use'] as String,
    keyOperations:
        (json['key_ops'] as List)?.map((v0) => v0 as String)?.toList(),
    algorithm:
        json['alg'] == null ? null : JsonWebAlgorithm.lookup(json['alg']),
    keyId: json['kid'] as String,
    x509Url: json['x5u'] as String,
    x509CertificateChain:
        (json['x5c'] as List)?.map((v0) => v0 as String)?.toList(),
    x509CertificateThumbprint: json['x5t'] as String,
    x509CertificateSha256Thumbprint: json['x5t#S256'] as String,
    n: json['n'] as String,
    e: json['e'] as String);

abstract class _$JsonWebKeySerializerMixin {
  String get keyType;
  String get use;
  List get keyOperations;
  JsonWebAlgorithm get algorithm;
  String get keyId;
  String get x509Url;
  List get x509CertificateChain;
  String get x509CertificateThumbprint;
  String get x509CertificateSha256Thumbprint;
  String get n;
  String get e;
  Map<String, dynamic> toJson() => _removeNulls(<String, dynamic>{
        'kty': keyType,
        'use': use,
        'key_ops': keyOperations,
        'alg': algorithm?.toString(),
        'kid': keyId,
        'x5u': x509Url,
        'x5c': x509CertificateChain,
        'x5t': x509CertificateThumbprint,
        'x5t#S256': x509CertificateSha256Thumbprint,
        'n': n,
        'e': e
      });
  Map<String, dynamic> _removeNulls(Map<String, dynamic> json) =>
      new Map.fromIterable(json.keys.where((k) => json[k] != null),
          value: (k) => json[k]);
}

// **************************************************************************
// Generator: JsonSerializableGenerator
// Target: class JsonWebKeySet
// **************************************************************************

JsonWebKeySet _$JsonWebKeySetFromJson(Map json) =>
    new JsonWebKeySet((json['keys'] as List)
        ?.map((v0) => v0 == null ? null : new JsonWebKey.fromJson(v0))
        ?.toList());

abstract class _$JsonWebKeySetSerializerMixin {
  List get keys;
  Map<String, dynamic> toJson() =>
      _removeNulls(<String, dynamic>{'keys': keys});
  Map<String, dynamic> _removeNulls(Map<String, dynamic> json) =>
      new Map.fromIterable(json.keys.where((k) => json[k] != null),
          value: (k) => json[k]);
}

// **************************************************************************
// Generator: JsonSerializableGenerator
// Target: class TokenResponse
// **************************************************************************

TokenResponse _$TokenResponseFromJson(Map json) => new TokenResponse(
    accessToken: json['access_token'] as String,
    tokenType: json['token_type'] as String,
    refreshToken: json['refresh_token'] as String,
    expiresIn: json['expires_in'] == null
        ? null
        : json['expires_in'] is String
            ? int.parse(json['expires_in'])
            : json['expires_in'],
    idToken:
        json['id_token'] == null ? null : new IdToken.decode(json['id_token']));

abstract class _$TokenResponseSerializerMixin {
  String get accessToken;
  String get tokenType;
  String get refreshToken;
  int get expiresIn;
  IdToken get idToken;
  Map<String, dynamic> toJson() => _removeNulls(<String, dynamic>{
        'access_token': accessToken,
        'token_type': tokenType,
        'refresh_token': refreshToken,
        'expires_in': expiresIn,
        'id_token': idToken
      });
  Map<String, dynamic> _removeNulls(Map<String, dynamic> json) =>
      new Map.fromIterable(json.keys.where((k) => json[k] != null),
          value: (k) => json[k]);
}

// **************************************************************************
// Generator: JsonSerializableGenerator
// Target: class UserInfo
// **************************************************************************

UserInfo _$UserInfoFromJson(Map json) => new UserInfo(
    subject: json['sub'] as String,
    name: json['name'] as String,
    givenName: json['given_name'] as String,
    familyName: json['family_name'] as String,
    middleName: json['middle_name'] as String,
    nickname: json['nickname'] as String,
    preferredUsername: json['preferred_username'] as String,
    profile: json['profile'] == null ? null : Uri.parse(json['profile']),
    picture: json['picture'] == null ? null : Uri.parse(json['picture']),
    website: json['website'] == null ? null : Uri.parse(json['website']),
    email: json['email'] as String,
    emailVerified: json['email_verified'] as bool,
    gender: json['gender'] as String,
    birthdate: json['birthdate'] as String,
    zoneinfo: json['zoneinfo'] as String,
    locale: json['locale'] as String,
    phoneNumber: json['phone_number'] as String,
    phoneNumberVerified: json['phone_number_verified'] as bool,
    address:
        json['address'] == null ? null : new Address.fromJson(json['address']),
    updatedAt: json['updated_at'] == null
        ? null
        : json['updated_at'] is num
            ? new DateTime.fromMillisecondsSinceEpoch(
                (json['updated_at'] * 1000).toInt())
            : DateTime.parse(json['updated_at']));

abstract class _$UserInfoSerializerMixin {
  String get subject;
  String get name;
  String get givenName;
  String get familyName;
  String get middleName;
  String get nickname;
  String get preferredUsername;
  Uri get profile;
  Uri get picture;
  Uri get website;
  String get email;
  bool get emailVerified;
  String get gender;
  String get birthdate;
  String get zoneinfo;
  String get locale;
  String get phoneNumber;
  bool get phoneNumberVerified;
  Address get address;
  DateTime get updatedAt;
  Map<String, dynamic> toJson() => _removeNulls(<String, dynamic>{
        'sub': subject,
        'name': name,
        'given_name': givenName,
        'family_name': familyName,
        'middle_name': middleName,
        'nickname': nickname,
        'preferred_username': preferredUsername,
        'profile': profile?.toString(),
        'picture': picture?.toString(),
        'website': website?.toString(),
        'email': email,
        'email_verified': emailVerified,
        'gender': gender,
        'birthdate': birthdate,
        'zoneinfo': zoneinfo,
        'locale': locale,
        'phone_number': phoneNumber,
        'phone_number_verified': phoneNumberVerified,
        'address': address,
        'updated_at': updatedAt?.toIso8601String()
      });
  Map<String, dynamic> _removeNulls(Map<String, dynamic> json) =>
      new Map.fromIterable(json.keys.where((k) => json[k] != null),
          value: (k) => json[k]);
}

// **************************************************************************
// Generator: JsonSerializableGenerator
// Target: class Address
// **************************************************************************

Address _$AddressFromJson(Map json) => new Address(
    formatted: json['formatted'] as String,
    streetAddress: json['street_address'] as String,
    locality: json['locality'] as String,
    region: json['region'] as String,
    postalCode: json['postal_code'] as String,
    country: json['country'] as String);

abstract class _$AddressSerializerMixin {
  String get formatted;
  String get streetAddress;
  String get locality;
  String get region;
  String get postalCode;
  String get country;
  Map<String, dynamic> toJson() => _removeNulls(<String, dynamic>{
        'formatted': formatted,
        'street_address': streetAddress,
        'locality': locality,
        'region': region,
        'postal_code': postalCode,
        'country': country
      });
  Map<String, dynamic> _removeNulls(Map<String, dynamic> json) =>
      new Map.fromIterable(json.keys.where((k) => json[k] != null),
          value: (k) => json[k]);
}

// **************************************************************************
// Generator: JsonSerializableGenerator
// Target: class OpenIdJwtClaimSet
// **************************************************************************

OpenIdJwtClaimSet _$OpenIdJwtClaimSetFromJson(Map json) => new OpenIdJwtClaimSet(
    subject: json['sub'] as String,
    name: json['name'] as String,
    givenName: json['given_name'] as String,
    familyName: json['family_name'] as String,
    middleName: json['middle_name'] as String,
    nickname: json['nickname'] as String,
    preferredUsername: json['preferred_username'] as String,
    profile: json['profile'] == null ? null : Uri.parse(json['profile']),
    picture: json['picture'] == null ? null : Uri.parse(json['picture']),
    website: json['website'] == null ? null : Uri.parse(json['website']),
    email: json['email'] as String,
    emailVerified: json['email_verified'] as bool,
    gender: json['gender'] as String,
    birthdate: json['birthdate'] as String,
    zoneinfo: json['zoneinfo'] as String,
    locale: json['locale'] as String,
    phoneNumber: json['phone_number'] as String,
    phoneNumberVerified: json['phone_number_verified'] as bool,
    address:
        json['address'] == null ? null : new Address.fromJson(json['address']),
    updatedAt: json['updated_at'] == null
        ? null
        : json['updated_at'] is num
            ? new DateTime.fromMillisecondsSinceEpoch(
                (json['updated_at'] * 1000).toInt())
            : DateTime.parse(json['updated_at']),
    issuer: json['iss'] == null ? null : Uri.parse(json['iss']),
    audience: ((json['aud'] is List ? json['aud'] : json['aud'] == null ? [] : [json['aud']]) as List)
        ?.map((v0) => v0 as String)
        ?.toList(),
    expiry: json['exp'] == null
        ? null
        : json['exp'] is num
            ? new DateTime.fromMillisecondsSinceEpoch(
                (json['exp'] * 1000).toInt())
            : DateTime.parse(json['exp']),
    issuedAt: json['iat'] == null
        ? null
        : json['iat'] is num
            ? new DateTime.fromMillisecondsSinceEpoch(
                (json['iat'] * 1000).toInt())
            : DateTime.parse(json['iat']),
    authTime: json['auth_time'] == null
        ? null
        : json['auth_time'] is num ? new DateTime.fromMillisecondsSinceEpoch((json['auth_time'] * 1000).toInt()) : DateTime.parse(json['auth_time']),
    nonce: json['nonce'] as String,
    authenticationContextClassReference: json['acr'] as String,
    authenticationMethodsReferences: (json['amr'] as List)?.map((v0) => v0 as String)?.toList(),
    authorizedParty: json['azp'] as String);

abstract class _$OpenIdJwtClaimSetSerializerMixin {
  Uri get issuer;
  List get audience;
  DateTime get expiry;
  DateTime get issuedAt;
  DateTime get authTime;
  String get nonce;
  String get authenticationContextClassReference;
  List get authenticationMethodsReferences;
  String get authorizedParty;
  String get subject;
  String get name;
  String get givenName;
  String get familyName;
  String get middleName;
  String get nickname;
  String get preferredUsername;
  Uri get profile;
  Uri get picture;
  Uri get website;
  String get email;
  bool get emailVerified;
  String get gender;
  String get birthdate;
  String get zoneinfo;
  String get locale;
  String get phoneNumber;
  bool get phoneNumberVerified;
  Address get address;
  DateTime get updatedAt;
  Map<String, dynamic> toJson() => _removeNulls(<String, dynamic>{
        'iss': issuer?.toString(),
        'aud': audience,
        'exp': expiry?.toIso8601String(),
        'iat': issuedAt?.toIso8601String(),
        'auth_time': authTime?.toIso8601String(),
        'nonce': nonce,
        'acr': authenticationContextClassReference,
        'amr': authenticationMethodsReferences,
        'azp': authorizedParty,
        'sub': subject,
        'name': name,
        'given_name': givenName,
        'family_name': familyName,
        'middle_name': middleName,
        'nickname': nickname,
        'preferred_username': preferredUsername,
        'profile': profile?.toString(),
        'picture': picture?.toString(),
        'website': website?.toString(),
        'email': email,
        'email_verified': emailVerified,
        'gender': gender,
        'birthdate': birthdate,
        'zoneinfo': zoneinfo,
        'locale': locale,
        'phone_number': phoneNumber,
        'phone_number_verified': phoneNumberVerified,
        'address': address,
        'updated_at': updatedAt?.toIso8601String()
      });
  Map<String, dynamic> _removeNulls(Map<String, dynamic> json) =>
      new Map.fromIterable(json.keys.where((k) => json[k] != null),
          value: (k) => json[k]);
}
