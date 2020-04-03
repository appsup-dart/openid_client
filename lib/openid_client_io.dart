library openid_client.io;

import 'openid_client.dart';
import 'dart:async';
import 'dart:io';

export 'openid_client.dart';

class Authenticator {
  final Flow flow;

  final Function(String url) urlLancher;

  final int port;

  Authenticator(Client client,
      {this.port: 3000,
      this.urlLancher: _runBrowser,
      Iterable<String> scopes: const [],
      Uri redirectUri})
      : flow = redirectUri == null
            ? new Flow.authorizationCodeWithPKCE(client)
            : new Flow.authorizationCode(client)
          ..scopes.addAll(scopes)
          ..redirectUri = redirectUri ?? Uri.parse("http://localhost:$port/cb");

  Future<Credential> authorize() async {
    var state = flow.authenticationUri.queryParameters["state"];

    _requestsByState[state] = new Completer();
    await _startServer(port);
    urlLancher(flow.authenticationUri.toString());

    var response = await _requestsByState[state].future;

    return flow.callback(response);
  }

  static Map<int, Future<HttpServer>> _requestServers = {};
  static Map<String, Completer<Map<String, String>>> _requestsByState = {};

  static Future<HttpServer> _startServer(int port) async {
    return _requestServers[port] ??=
        (HttpServer.bind(InternetAddress.loopbackIPv4, port)
          ..then((requestServer) async {
            await for (var request in requestServer) {
              request.response.statusCode = 200;
              request.response.headers.set("Content-type", "text/html");
              request.response.writeln(
                  "<html>"
                    "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"
                    "<body>"
                      "<div style='width: 100%; text-align: center; font-family: Arial, Helvetica, sans-serif'>"
                        "<img src='https://webdevolutions.blob.core.windows.net/images/mail/3.0.0/Common/devolutions-logo-blue.png' width='100%' alt='Devolutions'/>"
                        "<span style='font-size: 10vw'>Success!</span>"
                        "<div style='background-color:#d3f5e0; border-left: 10px solid #49fc8e'>"
                          "<p style='padding: 10px; color:#616161; font-size: 6vw'>You can now close this page!</p>"
                        "</div>"
                      "</div>"
                    "</body>"
                  "</html>"
              );
              request.response.close();
              var result = request.requestedUri.queryParameters;

              if (!result.containsKey("state")) continue;
              var r = _requestsByState.remove(result["state"]);
              r.complete(result);
              if (_requestsByState.isEmpty) {
                for (var s in _requestServers.values) {
                  (await s).close();
                }
                _requestServers.clear();
              }
            }

            _requestServers.remove(port);
          }));
  }
}

void _runBrowser(String url) {
  switch (Platform.operatingSystem) {
    case "linux":
      Process.run("x-www-browser", [url]);
      break;
    case "macos":
      Process.run("open", [url]);
      break;
    case "windows":
      Process.run("explorer", [url]);
      break;
    default:
      throw new UnsupportedError(
          "Unsupported platform: ${Platform.operatingSystem}");
      break;
  }
}
