part of openid.model;

@JsonSerializable()
class UserInfo extends _$UserInfoSerializerMixin {
  /// Identifier for the End-User at the Issuer.
  @JsonKey("sub")
  final String subject;

  /// End-User's full name in displayable form including all name parts,
  /// possibly including titles and suffixes, ordered according to the
  /// End-User's locale and preferences.
  final String name;

  /// Given name(s) or first name(s) of the End-User.
  ///
  /// Note that in some cultures, people can have multiple given names; all can
  /// be present, with the names being separated by space characters.
  final String givenName;

  /// Surname(s) or last name(s) of the End-User.
  ///
  /// Note that in some cultures, people can have multiple family names or no
  /// family name; all can be present, with the names being separated by space
  /// characters.
  final String familyName;

  /// Middle name(s) of the End-User.
  ///
  /// Note that in some cultures, people can have multiple middle names; all can
  /// be present, with the names being separated by space characters. Also note
  /// that in some cultures, middle names are not used.
  final String middleName;

  /// Casual name of the End-User that may or may not be the same as the
  /// given name.
  final String nickname;

  /// Shorthand name by which the End-User wishes to be referred to at the RP,
  /// such as janedoe or j.doe. T
  final String preferredUsername;

  /// URL of the End-User's profile page.
  final Uri profile;

  /// URL of the End-User's profile picture.
  final Uri picture;

  /// URL of the End-User's Web page or blog.
  final Uri website;

  /// End-User's preferred e-mail address.
  final String email;

  /// `true` if the End-User's e-mail address has been verified.
  final bool emailVerified;

  /// End-User's gender.
  ///
  /// Values defined by the specification are `female` and `male`. Other values
  /// MAY be used when neither of the defined values are applicable.
  final String gender;

  /// End-User's birthday.
  ///
  /// Date represented as an ISO 8601:2004 [ISO8601‑2004] YYYY-MM-DD format.
  /// The year MAY be 0000, indicating that it is omitted. To represent only the
  /// year, YYYY format is allowed.
  final String birthdate;

  /// The End-User's time zone.
  ///
  /// For example, Europe/Paris or America/Los_Angeles.
  final String zoneinfo;

  /// End-User's locale.
  final String locale;

  /// End-User's preferred telephone number.
  final String phoneNumber;

  /// `true if the End-User's phone number has been verified`
  final bool phoneNumberVerified;

  /// End-User's preferred postal address.
  final Address address;

  /// Time the End-User's information was last updated.
  final DateTime updatedAt;

  UserInfo(
      {this.subject,
      this.name,
      this.givenName,
      this.familyName,
      this.middleName,
      this.nickname,
      this.preferredUsername,
      this.profile,
      this.picture,
      this.website,
      this.email,
      this.emailVerified,
      this.gender,
      this.birthdate,
      this.zoneinfo,
      this.locale,
      this.phoneNumber,
      this.phoneNumberVerified,
      this.address,
      this.updatedAt});

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);
}

@JsonSerializable()
class Address extends _$AddressSerializerMixin {
  /// Full mailing address, formatted for display or use on a mailing label.
  final String formatted;

  /// Full street address component.
  final String streetAddress;

  /// City or locality component.
  final String locality;

  /// State, province, prefecture, or region component.
  final String region;

  /// Zip code or postal code component.
  final String postalCode;

  /// Country name component.
  final String country;

  Address(
      {this.formatted,
      this.streetAddress,
      this.locality,
      this.region,
      this.postalCode,
      this.country});

  factory Address.fromJson(Map<String, dynamic> json) =>
      _$AddressFromJson(json);
}

@JsonSerializable()
class OpenIdJwtClaimSet extends JwtClaimSet
    with _$OpenIdJwtClaimSetSerializerMixin
    implements UserInfo {
  /// Issuer Identifier
  @JsonKey("iss")
  final Uri issuer;

  /// Audience(s) that this ID Token is intended for.
  @JsonKey("aud")
  final List<String> audience;

  /// Expiration time on or after which the ID Token MUST NOT be accepted for
  /// processing.
  @JsonKey("exp")
  final DateTime expiry;

  /// Time at which the JWT was issued.
  @JsonKey("iat")
  final DateTime issuedAt;

  /// Time when the End-User authentication occurred.
  final DateTime authTime;

  /// String value used to associate a Client session with an ID Token, and to
  /// mitigate replay attacks.
  final String nonce;

  /// Identifies the Authentication Context Class that the authentication
  /// performed satisfied.
  @JsonKey("acr")
  final String authenticationContextClassReference;

  /// List of strings that are identifiers for authentication methods used in
  /// the authentication.
  @JsonKey("amr")
  final List<String> authenticationMethodsReferences;

  /// The party to which the ID Token was issued.
  @JsonKey("azp")
  final String authorizedParty;

  @override
  @JsonKey("sub")
  final String subject;

  @override
  final String name;

  @override
  final String givenName;

  @override
  final String familyName;

  @override
  final String middleName;

  @override
  final String nickname;

  @override
  final String preferredUsername;

  @override
  final Uri profile;

  @override
  final Uri picture;

  @override
  final Uri website;

  @override
  final String email;

  @override
  final bool emailVerified;

  @override
  final String gender;

  @override
  final String birthdate;

  @override
  final String zoneinfo;

  @override
  final String locale;

  @override
  final String phoneNumber;

  @override
  final bool phoneNumberVerified;

  @override
  final Address address;

  @override
  final DateTime updatedAt;

  OpenIdJwtClaimSet(
      {this.subject,
      this.name,
      this.givenName,
      this.familyName,
      this.middleName,
      this.nickname,
      this.preferredUsername,
      this.profile,
      this.picture,
      this.website,
      this.email,
      this.emailVerified,
      this.gender,
      this.birthdate,
      this.zoneinfo,
      this.locale,
      this.phoneNumber,
      this.phoneNumberVerified,
      this.address,
      this.updatedAt,
      this.issuer,
      this.audience,
      this.expiry,
      this.issuedAt,
      this.authTime,
      this.nonce,
      this.authenticationContextClassReference,
      this.authenticationMethodsReferences,
      this.authorizedParty});

  factory OpenIdJwtClaimSet.fromJson(Map<String, dynamic> json) =>
      _$OpenIdJwtClaimSetFromJson(json);

  Set<ConstraintViolation> validate(
      JwtClaimSetValidationContext validationContext) {
    final now = new DateTime.now();
    final diff = now.difference(expiry);
    if (diff > validationContext.expiryTolerance) {
      return new Set()
        ..add(new ConstraintViolation(
            'JWT expired. Expiry ($expiry) is more than tolerance '
            '(${validationContext.expiryTolerance}) before now ($now)'));
    }

    return new Set.identity();
  }
}
