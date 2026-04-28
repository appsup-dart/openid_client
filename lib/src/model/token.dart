part of '../model.dart';

class IdToken extends JsonWebToken {
  IdToken.unverified(super.serialization) : super.unverified();

  @override
  OpenIdClaims get claims => OpenIdClaims.fromJson(super.claims.toJson());
}
