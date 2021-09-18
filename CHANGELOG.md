# Changelog

## 0.4.3

- handle non successful http requests correctly, throwing either an `OpenIdException` when the response is in the openid error format or an `HttpRequestException` otherwise

## 0.4.2

- `client` in `Flow`, `issuer` and `clientId` in `Client` and `client` in `Credential` are now non-nullable

## 0.4.1

- Bugfixes

## 0.4.0

- Null safety

## 0.3.1

- Fix not using Client's httpClient for getTokenResponse 

## 0.3.0

- Add http.Client arguments
- *Breaking change*: `clientSecret` is now a named argument in `Client` constructor
- Add optional `forceRefresh` argument to `getTokenResponse`
- Add `fromJson` and `toJson` to `Credential` 
- Add `revoke` method to `Credential`
- Add `generateLogoutUrl` method to `Credential`

## 0.2.5

- Add jwtBearer flow for grant_type `urn:ietf:params:oauth:grant-type:jwt-bearer`
- Added `getTokenResponse` method
- Added `createHttpClient` method

## 0.2.4

- Allow only signing algorithms specified in `id_token_signing_alg_values_supported` 
parameter of issuer metadata

## 0.2.1

- Fix Authorization Code PKCE flow

## 0.2.0

- Dart 2/flutter compatibility


## 0.1.0

- Initial version
