
part of openid.model;


@JsonSerializable()
class TokenResponse extends _$TokenResponseSerializerMixin {

  final String accessToken;

  final String tokenType;

  final String refreshToken;

  final int expiresIn;

  final IdToken idToken;


  TokenResponse({this.accessToken, this.tokenType, this.refreshToken,
  this.expiresIn, this.idToken});


  factory TokenResponse.fromJson(Map<String,dynamic> json) =>
      _$TokenResponseFromJson(json);
}