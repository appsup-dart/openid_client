
library openid.id_token;

import 'package:dart_jwt/dart_jwt.dart' hide OpenIdJwtClaimSet;
import 'model.dart';

class IdToken extends JsonWebSignature<MapJwtClaimSet> {

  final OpenIdJwtClaimSet openIdClaimsSet;

  IdToken._internal(
      JwsHeader header, MapJwtClaimSet claimSet, JwsSignature signature, String signingInput)
      : openIdClaimsSet = new OpenIdJwtClaimSet.fromJson(claimSet.json), super(header, claimSet, signature, signingInput);

  factory IdToken.decode(String jwtToken) {
    final base64Segs = jwtToken.split('.');
    if (base64Segs.length != 3)
      throw new ArgumentError(
          "JWS tokens must be in form '<header>.<payload>.<signature>'.\n"
              "Value: '$jwtToken' is invalid");

    final header = new JwsHeader.decode(base64Segs.first);
    var json = Base64EncodedJson.decodeToJson(base64Segs.elementAt(1));
    final claimSet = new MapJwtClaimSet.fromJson(new Map.unmodifiable(json));
    final signature = new JwsSignature.decode(base64Segs.elementAt(2));

    final signingInput = jwtToken.substring(0, jwtToken.lastIndexOf('.'));

    final IdToken jwt =
    new IdToken._internal(header, claimSet, signature, signingInput);

    return jwt;
  }

  @override
  Set<ConstraintViolation> validatePayload(
      JwtValidationContext validationContext) {
    final set = new Set();

    var claimSetValidationContext = validationContext.claimSetValidationContext;

    if (claimSetValidationContext is IdTokenValidationContext) {
      if (claimSetValidationContext.validateIssuerAndAudience) {
        if (openIdClaimsSet.issuer!=claimSetValidationContext.issuer) {
          set.add(new ConstraintViolation('Issuer does not match. Expected '
              '`${claimSetValidationContext.issuer}`, was `${openIdClaimsSet.issuer}`'));
        }
        if (!openIdClaimsSet.audience.contains(claimSetValidationContext.clientId)) {
          set.add(new ConstraintViolation('Audiences does not contain clientId.'));
        }
        if (openIdClaimsSet.audience.length>1&&openIdClaimsSet.authorizedParty==null) {
          set.add(new ConstraintViolation('No authorized party claim present.'));
        }
        if (openIdClaimsSet.authorizedParty!=null&&openIdClaimsSet.authorizedParty!=claimSetValidationContext.clientId) {
          set.add(new ConstraintViolation('Invalid authorized party claim.'));
        }
      }
      if (openIdClaimsSet.expiry!=null) {
        final now = new DateTime.now();
        final diff = now.difference(openIdClaimsSet.expiry);
        if (diff > claimSetValidationContext.expiryTolerance) {
          set.add(new ConstraintViolation(
              'JWT expired. Expiry (${openIdClaimsSet.expiry}) is more than tolerance '
                  '(${claimSetValidationContext.expiryTolerance}) before now ($now)'));
        }
      }
      if (claimSetValidationContext.nonce!=null&&claimSetValidationContext.nonce!=openIdClaimsSet.nonce) {
        set.add(new ConstraintViolation('Nonce does not match.'));
      }
    }
    return set;
  }
}


class IdTokenValidationContext extends JwtClaimSetValidationContext {

  final Uri issuer;

  final String clientId;

  final String nonce;

  final bool validateIssuerAndAudience;


  IdTokenValidationContext({this.issuer, this.clientId, this.nonce,
  Duration expiryTolerance: const Duration(seconds: 30), this.validateIssuerAndAudience: true}) :
        super(expiryTolerance: expiryTolerance);

}
