## 0.4.7

 - **FIX**: update contentSecurityPolicy of keycloak server to allow silent refresh with iframe. ([df9ef506](https://github.com/appsup-dart/openid_client/commit/df9ef506d0dd3e690f86d5fcc2efd073f0a51109))
 - **FIX**: initial token persisted in browser Authenticator. ([a4ac2c50](https://github.com/appsup-dart/openid_client/commit/a4ac2c5095859e2e78308366cbc270d628420c4d))
 - **FIX**: logout from Authenticator on web. ([05343c8a](https://github.com/appsup-dart/openid_client/commit/05343c8a048354792c38c0e81cc919edb8f449c9))
 - **FIX**: length of random string always 50. ([850acc96](https://github.com/appsup-dart/openid_client/commit/850acc961347436c4f5a2fc6828b5a926b51423d))
 - **FIX**: bug only first supported scope included in the auth request (pull request [#63](https://github.com/appsup-dart/openid_client/issues/63) from insertjokehere). ([fd2f3b3e](https://github.com/appsup-dart/openid_client/commit/fd2f3b3ee18b823897f2bb1fe4c4cc1b37791fb0))
 - **FEAT**: add optional prompt parameter to Flow and Authenticator constructors. ([f0af92fc](https://github.com/appsup-dart/openid_client/commit/f0af92fcd2da842401a4bc44f4fa2d8bdce1dfd4))
 - **FEAT**: add `trySilentRefresh` method to browser `Authenticator`. ([e74d8e3f](https://github.com/appsup-dart/openid_client/commit/e74d8e3fe6e8717c944ebdb5b889c408ef950da4))
 - **FEAT**: add device parameter to implicit flow. ([5a6bf046](https://github.com/appsup-dart/openid_client/commit/5a6bf046e34946ff1745376b0c67974fa4019dd7))
 - **FEAT**: add support for password flow. ([c89d11b1](https://github.com/appsup-dart/openid_client/commit/c89d11b172c842bf13f5ce47632de20012eddd1d))
 - **FEAT**: add scopes argument to Flow.authorizationCodeWithPKCE constructor (pull request [#64](https://github.com/appsup-dart/openid_client/issues/64) from insertjokehere). ([bd37e6d9](https://github.com/appsup-dart/openid_client/commit/bd37e6d95feca2f28da5b22c8a7f80150a2bc9a5))
 - **FEAT**: added possibility to hide or change message after redirect (pull request [#66](https://github.com/appsup-dart/openid_client/issues/66) from BetterBOy). ([aafaab80](https://github.com/appsup-dart/openid_client/commit/aafaab80ea80d1bfa725c28bd4eff3bec2776460))
 - **DOCS**: add docs to Authenticators. ([65f9b285](https://github.com/appsup-dart/openid_client/commit/65f9b285b2137f522634f7ca37872f2420ebb675))
 - **DOCS**: fix logout button in browser_example. ([70ffbebc](https://github.com/appsup-dart/openid_client/commit/70ffbebcd41647b21caa479e67aa511dda46237e))
 - **DOCS**: add funding info. ([e006d6de](https://github.com/appsup-dart/openid_client/commit/e006d6de4473360c78722f7ad6226ad6a5fc3c29))
 - **DOCS**: add example usage with keycloak server. ([a2939419](https://github.com/appsup-dart/openid_client/commit/a29394192789931ec44d6e6b64f16765325505e4))

# Changelog

## 0.4.6

- keep old refresh token when access token refreshed and no new refresh token received
## 0.4.5

- handle tokens without expiration

## 0.4.4

- added `onTokenChanged` stream to `Credential`
- added `Authenticator.fromFlow` constructor

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
