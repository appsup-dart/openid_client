part of openid.model;

class TokenResponse extends JsonObject {
  /// OAuth 2.0 Access Token
  ///
  /// This is returned unless the response_type value used is `id_token`.
  String get accessToken => this['access_token'];

  /// OAuth 2.0 Token Type value
  ///
  /// The value MUST be Bearer or another token_type value that the Client has
  /// negotiated with the Authorization Server.
  String get tokenType => this['token_type'];

  /// Refresh token
  String get refreshToken => this['refresh_token'];

  /// Expiration time of the Access Token since the response was generated.
  Duration get expiresIn => getTyped('expires_in');

  /// ID Token
  IdToken get idToken =>
      getTyped('id_token', factory: (v) => IdToken.unverified(v));

  DateTime get expiresAt => getTyped('expires_at');

  TokenResponse.fromJson(Map<String, dynamic> json)
      : super.from({
          if (json.containsKey('expires_in'))
            'expires_at': DateTime.now()
                    .add(Duration(seconds: int.parse(json['expires_in'].toString())))
                    .millisecondsSinceEpoch ~/
                1000,
          ...json,
        });
}
