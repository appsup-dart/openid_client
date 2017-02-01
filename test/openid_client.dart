// Copyright (c) 2017, rbellens. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:openid_client/openid_client.dart';
import 'package:test/test.dart';
import 'package:logging/logging.dart';
import 'dart:io';
import 'dart:convert';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  var secrets = JSON.decode(new File("test/secrets.json").readAsStringSync());

  group('Discovery', () {
    test('Google', () async {
      var issuer = await Issuer.discover(Issuer.google);
      expect(issuer.metadata.issuer, Issuer.google);
      expect(issuer.metadata.scopesSupported, contains("openid"));
    });

    test('Facebook', () async {
      var issuer = await Issuer.discover(Issuer.facebook);
      expect(issuer.metadata.issuer, Issuer.facebook);
    });
  });

  group('IdToken', () {

    for (var n in secrets["idTokens"].keys) {
      test(n, () async {
        var v = secrets["idTokens"][n];

        var issuer = await Issuer.discover(Uri.parse(v["issuer"]));
        var client = new Client(issuer, v["client_id"], v["client_secret"]);
        var credential = client.createCredential(idToken: v["id_token"]);

        expect(await credential.validateToken(validateExpiry: false), isEmpty);
      });
    }

  });
}
