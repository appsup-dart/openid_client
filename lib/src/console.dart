import 'openid.dart';
import 'dart:async';
import 'dart:io';

class ConsoleAuthenticator {
  final Flow flow;

  ConsoleAuthenticator(Client client, {int port: 3000})
      : flow = new Flow.authorizationCode(client)
          ..redirectUri = Uri.parse("http://localhost:$port/cb");

  Future<Credential> authorize() async {
    HttpServer requestServer = await HttpServer.bind(
        InternetAddress.LOOPBACK_IP_V4, flow.redirectUri.port);

    _runBrowser(flow.authenticationUri.toString());
    var request = await requestServer.first;

    request.response.statusCode = 200;
    request.response.headers.set("Content-type", "text/html");
    request.response.writeln("<script>window.close();</script>");
    request.response.close();
    var result = request.requestedUri.queryParameters;

    return flow.callback(result);
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
