part of openid.model;

class IdToken extends JsonWebToken {
  IdToken.unverified(String serialization) : super.unverified(serialization);

  @override
  OpenIdClaims get claims => OpenIdClaims.fromJson(super.claims.toJson());
}
