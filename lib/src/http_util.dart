import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:logging/logging.dart';
// ignore: URI_DOES_NOT_EXIST
import 'http_util/browser.dart'
// ignore: URI_DOES_NOT_EXIST
    if (dart.library.io) 'http_util/io.dart'
// ignore: URI_DOES_NOT_EXIST
    if (dart.library.html) 'http_util/browser.dart';

final _logger = new Logger("openid_client");

typedef http.Client ClientFactory();

Future get(dynamic url, {Map<String, String> headers}) async {
  return _processResponse(
      await _withClient((client) => client.get(url, headers: headers)));
}

Future post(dynamic url,
    {Map<String, String> headers, body, Encoding encoding}) async {
  return _processResponse(await _withClient((client) =>
      client.post(url, headers: headers, body: body, encoding: encoding)));
}

_processResponse(http.Response response) {
  _logger.fine(
      "${response.request.method} ${response.request.url}: ${response.body}");
  return json.decode(response.body);
}

Future<T> _withClient<T>(Future<T> fn(http.Client client)) async {
  var client = factory();
  try {
    return await fn(client);
  } finally {
    client.close();
  }
}
