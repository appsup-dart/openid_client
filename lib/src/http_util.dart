import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../openid_client.dart';

export 'package:http/http.dart' show Client;

final _logger = Logger('openid_client');

typedef ClientFactory = http.Client Function();

Future get(dynamic url,
    {Map<String, String> headers, @required http.Client client}) async {
  return _processResponse(
      await _withClient((client) => client.get(url, headers: headers), client));
}

Future post(dynamic url,
    {Map<String, String> headers,
    body,
    Encoding encoding,
    @required http.Client client}) async {
  return _processResponse(await _withClient(
      (client) =>
          client.post(url, headers: headers, body: body, encoding: encoding),
      client));
}

dynamic _processResponse(http.Response response) {
  _logger.fine(
      '${response.request.method} ${response.request.url}: ${response.body}');
  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw HttpRequestException(
        statusCode: response.statusCode, body: json.decode(response.body));
  }
  return json.decode(response.body);
}

Future<T> _withClient<T>(Future<T> Function(http.Client client) fn,
    [http.Client client0]) async {
  var client = client0 ?? http.Client();
  try {
    return await fn(client);
  } finally {
    if (client != client0) client.close();
  }
}

class AuthorizedClient extends http.BaseClient {
  final http.Client baseClient;

  final Credential credential;

  AuthorizedClient(this.baseClient, this.credential);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    var token = await credential.getTokenResponse();
    if (token.tokenType != null && token.tokenType.toLowerCase() != 'bearer') {
      throw UnsupportedError('Unknown token type: ${token.tokenType}');
    }

    request.headers['Authorization'] = 'Bearer ${token.accessToken}';

    return baseClient.send(request);
  }
}

class HttpRequestException implements Exception {
  final int/*!*/ statusCode;

  final dynamic body;

  HttpRequestException({this.statusCode, this.body});
}
