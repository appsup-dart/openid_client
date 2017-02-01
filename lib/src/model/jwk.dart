part of openid.model;

@JsonSerializable()
class JsonWebKey extends _$JsonWebKeySerializerMixin {

  /// The cryptographic algorithm family used with the key, such as `RSA` or
  /// `EC`.
  @JsonKey('kty')
  final String keyType;

  /// The intended use of the public key.
  ///
  /// Values defined by the specification are:
  ///
  /// * `sig` (signature)
  /// * `enc` (encryption)
  final String use;


  /// The operation(s) that the key is intended to be used for.
  ///
  /// Values defined by the specification are:
  ///
  /// * `sign` (compute digital signature or MAC)
  /// * `verify` (verify digital signature or MAC)
  /// * `encrypt` (encrypt content)
  /// * `decrypt` (decrypt content and validate decryption, if applicable)
  /// * `wrapKey` (encrypt key)
  /// * `unwrapKey` (decrypt key and validate decryption, if applicable)
  /// * `deriveKey` (derive key)
  /// * `deriveBits` (derive bits not to be used as a key)
  @JsonKey('key_ops')
  final List<String> keyOperations;


  /// The algorithm intended for use with the key.
  @JsonKey('alg')
  final JsonWebAlgorithm algorithm;

  /// Used to match a specific key.
  ///
  /// This is used, for instance, to choose among a set of keys within a JWK Set
  /// during key rollover.
  @JsonKey('kid')
  final String keyId;

  /// A resource for an X.509 public key certificate or certificate chain.
  @JsonKey('x5u')
  final String x509Url;

  /// A chain of one or more PKIX certificates.
  @JsonKey('x5c')
  final List<String> x509CertificateChain;

  /// A base64url encoded SHA-1 thumbprint (a.k.a. digest) of the DER encoding
  /// of an X.509 certificate.
  @JsonKey('x5t')
  final String x509CertificateThumbprint;

  /// A base64url encoded SHA-256 thumbprint (a.k.a. digest) of the DER encoding
  /// of an X.509 certificate.
  @JsonKey('x5t#S256')
  final String x509CertificateSha256Thumbprint;

  final String n;
  final String e;

  RSAPublicKey get publicKey {
    _decode(String s) {
      s = s + new Iterable.generate((4-s.length%4)%4,(i)=>"=").join();
      return new BigInteger.fromBytes(1,BASE64URL.decode(s));
    }
    return new RSAPublicKey(_decode(n), _decode(e));
  }

  JsonWebKey({this.keyType, this.use, this.keyOperations, this.algorithm,
    this.keyId, this.x509Url, this.x509CertificateChain,
    this.x509CertificateThumbprint, this.x509CertificateSha256Thumbprint,
    this.n, this.e
  });

  factory JsonWebKey.fromJson(Map<String,dynamic> json) =>
      _$JsonWebKeyFromJson(json);
}

@JsonSerializable()
class JsonWebKeySet extends _$JsonWebKeySetSerializerMixin {

  final List<JsonWebKey> keys;

  JsonWebKeySet(this.keys);

  factory JsonWebKeySet.fromJson(Map<String,dynamic> json) =>
      _$JsonWebKeySetFromJson(json);

  JsonWebKey findKey(String kid) => keys.firstWhere((k)=>k.keyId==kid, orElse: ()=>null);
}