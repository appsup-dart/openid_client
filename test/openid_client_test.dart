// Copyright (c) 2017, rbellens. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:openid_client/openid_client.dart';
import 'package:test/test.dart';
import 'package:logging/logging.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

File _file(String path) {
  return File('${Directory.current.path.endsWith('test') ? '' : 'test/'}$path');
}

Future<dynamic> _readJson(String path) async =>
    json.decode(await _file(path).readAsString());

class _CountingClient extends http.BaseClient {
  final FutureOr<http.StreamedResponse> Function(http.BaseRequest request) _send;

  int sendCount = 0;

  _CountingClient(this._send);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    sendCount++;
    return await _send(request);
  }
}

http.StreamedResponse _jsonResponse(
    http.BaseRequest request, int status, Map<String, dynamic> jsonBody) {
  var body = utf8.encode(json.encode(jsonBody));
  return http.StreamedResponse(Stream.value(body), status,
      request: request,
      headers: const {
        'content-type': 'application/json',
      });
}

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(print);

  group('Discovery', () {
    test('Google', () async {
      var issuer = await Issuer.discover(Issuer.google);
      expect(issuer.metadata.issuer, Issuer.google);
      expect(issuer.metadata.scopesSupported, contains('openid'));
    });

    test('Facebook', () async {
      var issuer = await Issuer.discover(Issuer.facebook);
      expect(issuer.metadata.issuer, Issuer.facebook);
    });

    test('Microsoft v2', () async {
      var url = Uri.parse('https://login.microsoftonline.com/common/v2.0/');
      var issuer = await Issuer.discover(url);
      expect(issuer.metadata.issuer.host, url.host);
    });
  });

  group('IdToken', () {
    test('validate mock id token', () async {
      var configJson = await _readJson('mock/openid-configuration.json');
      var jwksContent = File(configJson['jwks_uri']).readAsStringSync();
      configJson['jwks_uri'] = Uri.dataFromString(jwksContent).toString();
      var issuer = Issuer(OpenIdProviderMetadata.fromJson(configJson));

      var client = Client(issuer, 'openid_client');
      var credential = client.createCredential(
          idToken:
              'eyJhbGciOiJSUzI1NiIsImtpZCI6InRlc3QxMjM0In0.eyJpc3MiOiJodHRwczovL29wZW5pZF9jbGllbnQuYXBwc3VwLmJlIiwiYXVkIjoib3BlbmlkX2NsaWVudCIsImF1dGhfdGltZSI6MTUxNjc5Mjc0OCwidXNlcl9pZCI6InhvMW5FNTAxd1BXRzFWUVlsMlJnbnFXaTdKZDIiLCJzdWIiOiJ4bzFuRTUwMXdQV0cxVlFZbDJSZ25xV2k3SmQyIiwiaWF0IjoxNTIyNjE2MDU1LCJleHAiOjE1MjI2MTk2NTV9.weRqNkFvrcgZ1TAZe0gLw7hKXAcEysntcdUJhLfiokFcApte2bMqnIGYxVINaBxc4Cvy1zwY7esBD8KKe7I2Xno57xN1Onbp5r_1Hj-hXM5ommGzLjcZOqGvmjHX_apoOnKhs2YJD06NBaaBE4Z2p7WudhQFBpfVmyH2fBaPFhpjAIoEy2-M3OsyqeXWBcIww7aMgpgK55_k98X5QdeGpVwXbIW4jZd7jXt5Kbr22NyvXQTQcg-omYw3EQ1zvONkRssX9P9MZThfGETNVNy2YHXBKDCo47vcZZhbF2ospe8W8VYdG0LFRBspyqorerlDun3oFWNB0llmYldfwuMAx64G8-SfevxrZjqVhaSOiWtvX_UcHI1puIVQC9kCI6rhU5jm6kqcEaOp5ge1hKctQejKXJnXPQcJ3OeA5-pojvibN_DksSkZhs006Fy6p_osAusSaKJzMYX7IYlJaF_SaaIe0VEhq0e1oWsuGyZYQROxedvQxTLuaE1BUn5SKhBO8YBWt9cHT1NbN2XeAU3PMHQ-lcz3NgSllR5AX0xQuwqMYGXbeQagiYdRDQKdYWYIEuayLCbmC3PsSR0KUVmgRBXxWipJMDRNWNxwqqNq4xdJpcI0NvCp1nnM1DHkVjV8mxAg7ItiBnIdDHZtkkVJ6mdqi7hGiXjJRdoCJDkvzfs');

      expect(await credential.validateToken(validateExpiry: false).toList(),
          isEmpty);
    }, onPlatform: {'browser': Skip()});
  });

  group('Credential.getTokenResponse', () {
    test(
        'failing refresh with only one caller does not produce unhandled zone errors and preserves stack trace',
        () async {
      final errors = <Object>[];

      await runZonedGuarded(() async {
        final httpClient = _CountingClient((request) async {
          throw const SocketException('network down');
        });

        final issuer = Issuer(OpenIdProviderMetadata.fromJson({
          'issuer': 'https://issuer.example',
          'token_endpoint': 'https://issuer.example/token',
          'authorization_endpoint': 'https://issuer.example/auth',
          'jwks_uri': 'https://issuer.example/jwks',
          'response_types_supported': ['code'],
          'token_endpoint_auth_methods_supported': ['client_secret_post'],
        }));

        final client = Client(issuer, 'client-id', httpClient: httpClient);
        final credential = client.createCredential(
          accessToken: 'expired',
          refreshToken: 'refresh-token',
          expiresAt: DateTime.fromMillisecondsSinceEpoch(0),
        );

        try {
          await credential.getTokenResponse();
          fail('Expected getTokenResponse to throw');
        } catch (e, st) {
          expect(e, isA<SocketException>());
          expect(st.toString().trim(), isNotEmpty);
        }

        // Give the event loop a chance to surface any unhandled async errors.
        await Future<void>.delayed(Duration.zero);
      }, (error, stack) {
        errors.add(error);
      });

      expect(errors, isEmpty);
    });

    test('concurrent calls share one in-flight refresh and only one HTTP call',
        () async {
      final httpClient = _CountingClient((request) async {
        // Force some overlap between the two callers.
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return _jsonResponse(request, 200, {
          'access_token': 'new-access',
          'token_type': 'bearer',
          'expires_in': 3600,
          'refresh_token': 'refresh-token',
        });
      });

      final issuer = Issuer(OpenIdProviderMetadata.fromJson({
        'issuer': 'https://issuer.example',
        'token_endpoint': 'https://issuer.example/token',
        'authorization_endpoint': 'https://issuer.example/auth',
        'jwks_uri': 'https://issuer.example/jwks',
        'response_types_supported': ['code'],
        'token_endpoint_auth_methods_supported': ['client_secret_post'],
      }));

      final client = Client(issuer, 'client-id', httpClient: httpClient);
      final credential = client.createCredential(
        accessToken: 'expired',
        refreshToken: 'refresh-token',
        expiresAt: DateTime.fromMillisecondsSinceEpoch(0),
      );

      final f1 = credential.getTokenResponse();
      final f2 = credential.getTokenResponse();

      final results = await Future.wait([f1, f2]);

      expect(results[0].accessToken, 'new-access');
      expect(results[1].accessToken, 'new-access');
      expect(httpClient.sendCount, 1);
    });
  });
}
