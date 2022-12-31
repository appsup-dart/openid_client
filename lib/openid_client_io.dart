library openid_client.io;

import 'dart:async';
import 'dart:io';
import 'dart:developer';

import 'openid_client.dart';

export 'openid_client.dart';

/// A wrapper around [Flow] that handles authentication in a non-web environment.
///
/// This authenticator uses a local http server to listen for the redirect from
/// the authorization server. The server is started when the [authorize] method
/// is called and stopped when the [cancel] method is called or when the
/// authentication flow is completed.
///
/// Some authorization servers might not allow to redirect to a local http
/// server. In that case, you should capture the authentication response in a
/// different way and pass it to the [processResult] method.
class Authenticator {
  /// The [Flow] used for authentication.
  final Flow flow;

  final Function(String url) urlLancher;

  /// The port used by the local http server.
  final int port;

  /// The html content to display when the authentication flow is completed.
  ///
  /// If this is null, the [redirectMessage] will be displayed instead.
  final String? htmlPage;

  /// The text message to display when the authentication flow is completed.
  ///
  /// If [htmlPage] is not null, this will be ignored.
  final String? redirectMessage;

  /// Creates an authenticator that uses the given [flow].
  Authenticator.fromFlow(
    this.flow, {
    Function(String url)? urlLancher,
    String? redirectMessage,
    this.htmlPage,
  })  : assert(
          htmlPage != null ? redirectMessage == null : true,
          'You can only use one variable htmlPage (give entire html) or redirectMessage (only string message)',
        ),
        redirectMessage = redirectMessage ?? 'You can now close this window',
        port = flow.redirectUri.port,
        urlLancher = urlLancher ?? _runBrowser;

  /// Creates an authenticator that uses a [Flow.authorizationCodeWithPKCE] flow
  /// when [redirectUri] is null and a [Flow.authorizationCode] flow otherwise.
  Authenticator(
    Client client, {
    this.port = 3000,
    this.urlLancher = _runBrowser,
    Iterable<String> scopes = const [],
    Uri? redirectUri,
    String? redirectMessage,
    String? prompt,
    this.htmlPage,
  })  : assert(
          htmlPage != null ? redirectMessage == null : true,
          'You can only use one variable htmlPage (give entire html) or redirectMessage (only string message)',
        ),
        redirectMessage = redirectMessage ?? 'You can now close this window',
        flow = redirectUri == null
            ? Flow.authorizationCodeWithPKCE(client, prompt: prompt)
            : Flow.authorizationCode(client, prompt: prompt)
          ..scopes.addAll(scopes)
          ..redirectUri = redirectUri ?? Uri.parse('http://localhost:$port/');

  /// Starts the authentication flow.
  ///
  /// This method will start a local http server and open the authorization
  /// server's authentication page in a browser.
  ///
  /// The server will be stopped when the [cancel] method is called or when the
  /// authentication flow is completed.
  Future<Credential> authorize() async {
    var state = flow.authenticationUri.queryParameters['state']!;

    _requestsByState[state] = Completer();
    await _startServer(port, htmlPage, redirectMessage);
    urlLancher(flow.authenticationUri.toString());

    var response = await _requestsByState[state]!.future;

    return flow.callback(response);
  }

  /// Cancels the authentication flow.
  ///
  /// This method will stop the local http server and complete the [authorize]
  /// method with an error.
  ///
  /// This method should be called when the user cancels the authentication flow
  /// in the browser.
  Future<void> cancel() async {
    final state = flow.authenticationUri.queryParameters['state'];
    _requestsByState[state!]?.completeError(Exception('Flow was cancelled'));
    final server = await _requestServers.remove(port);
    await server?.close();
  }

  static final Map<int, Future<HttpServer>> _requestServers = {};
  static final Map<String, Completer<Map<String, String>>> _requestsByState =
      {};

  static Future<HttpServer> _startServer(
      int port, String? htmlPage, String? redirectMessage) {
    return _requestServers[port] ??=
        (HttpServer.bind(InternetAddress.anyIPv4, port)
          ..then((requestServer) async {
            log('Server started at port $port');
            await for (var request in requestServer) {
              request.response.statusCode = 200;
              if (redirectMessage != null) {
                request.response.headers.contentType = ContentType.html;
                request.response.writeln(htmlPage ??
                    '<html>'
                        '<h1>$redirectMessage</h1>'
                        '<script>window.close();</script>'
                        '</html>');
              }
              await request.response.close();
              var result = request.requestedUri.queryParameters;

              if (!result.containsKey('state')) continue;
              await processResult(result);
            }

            await _requestServers.remove(port);
          }));
  }

  /// Processes the result from an authentication flow.
  ///
  /// You can call this manually if you are redirected to the app by an external
  /// browser.
  ///
  /// This method will complete the [authorize] method with the result of the
  /// authentication flow.
  static Future<void> processResult(Map<String, String> result) async {
    var r = _requestsByState.remove(result['state']);
    r?.complete(result);

    if (_requestsByState.isEmpty) {
      for (var s in _requestServers.values) {
        await (await s).close();
      }
      _requestServers.clear();
    }
  }
}

void _runBrowser(String url) {
  switch (Platform.operatingSystem) {
    case 'linux':
      Process.run('x-www-browser', [url]);
      break;
    case 'macos':
      Process.run('open', [url]);
      break;
    case 'windows':
      Process.run('explorer', [url]);
      break;
    default:
      throw UnsupportedError(
          'Unsupported platform: ${Platform.operatingSystem}');
  }
}

extension FlowX on Flow {
  Future<Credential> authorize({Function(String url)? urlLauncher}) {
    return Authenticator.fromFlow(this, urlLancher: urlLauncher).authorize();
  }
}
