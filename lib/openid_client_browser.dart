import 'dart:async';
import 'dart:html' hide Credential, Client;

import 'openid_client.dart';

export 'openid_client.dart';

/// A wrapper around [Flow] that handles the browser-specific parts of
/// authentication.
///
/// The constructor takes a [Client] and a list of scopes. It then
/// creates a [Flow] and uses it to generate an authentication URI.
///
/// The [authorize] method redirects the browser to the authentication URI.
///
/// The [logout] method redirects the browser to the logout URI.
///
/// The [credential] property returns a [Future] that completes with a
/// [Credential] after the user has signed in and the browser is redirected to
/// the app. Otherwise, it completes with `null`.
///
/// The state is not persisted in the browser, so the user will have to sign in
/// again after a page refresh. If you want to persist the state, you'll have to
/// store and restore the credential yourself. You can listen to the
/// [Credential.onTokenChanged] event to be notified when the credential changes.
class Authenticator {
  /// The [Flow] used for authentication.
  ///
  /// This will be a flow of type [FlowType.implicit].
  final Flow flow;

  /// A [Future] that completes with a [Credential] after the user has signed in
  /// and the browser is redirected to the app. Otherwise, it completes with
  /// `null`.
  final Future<Credential?> credential;

  Authenticator._(this.flow) : credential = _credentialFromUri(flow);

  Authenticator(Client client,
      {Iterable<String> scopes = const [],
      String? prompt,
      String? codeVerifier,
      Map<String, String>? additionalParameters})
      : this._(Flow.authorizationCodeWithPKCE(client,
            state: window.localStorage['openid_client:state'],
            prompt: prompt,
            codeVerifier: codeVerifier,
            additionalParameters: additionalParameters)
          ..scopes.addAll(scopes)
          ..redirectUri = Uri.parse(window.location.href).removeFragment());

  /// Redirects the browser to the authentication URI.
  void authorize() {
    window.localStorage['openid_client:state'] = flow.state;
    window.location.href = flow.authenticationUri.toString();
  }

  /// Redirects the browser to the logout URI.
  void logout() async {
    var c = await credential;
    if (c == null) return;
    var uri = c.generateLogoutUrl(
        redirectUri: Uri.parse(window.location.href).removeFragment());
    if (uri != null) {
      window.location.href = uri.toString();
    }
  }

  static Future<Credential?> _credentialFromUri(Flow flow) async {
    var uri = Uri.parse(window.location.href);
    var iframe = uri.queryParameters['iframe'] != null;
    uri = Uri(query: uri.fragment);
    var q = uri.queryParameters;
    if (q.containsKey('access_token') ||
        q.containsKey('code') ||
        q.containsKey('id_token')) {
      window.history.replaceState(
          '', '', Uri.parse(window.location.href).removeFragment().toString());
      window.localStorage.remove('openid_client:state');

      var c = await flow.callback(q.cast());
      if (iframe) window.parent!.postMessage(c.response, '*');
      return c;
    }
    return null;
  }

  /// Tries to refresh the access token silently in a hidden iframe.
  ///
  /// The implicit flow does not support refresh tokens. This method uses a
  /// hidden iframe to try to get a new access token without the user having to
  /// sign in again. It returns a [Future] that completes with a [Credential]
  /// when the iframe receives a response from the authorization server. The
  /// future will timeout after [timeout] if the iframe does not receive a
  /// response.
  Future<Credential> trySilentRefresh(
      {Duration timeout = const Duration(seconds: 20)}) async {
    var iframe = IFrameElement();
    var url = flow.authenticationUri;
    window.localStorage['openid_client:state'] = flow.state;
    iframe.src = url.replace(queryParameters: {
      ...url.queryParameters,
      'prompt': 'none',
      'redirect_uri': flow.redirectUri.replace(queryParameters: {
        ...flow.redirectUri.queryParameters,
        'iframe': 'true',
      }).toString(),
    }).toString();
    iframe.style.display = 'none';
    document.body!.append(iframe);
    var event = await window.onMessage.first.timeout(timeout).whenComplete(() {
      iframe.remove();
    });
    if (event.data is Map) {
      var current = await credential;
      if (current == null) {
        return flow.client.createCredential(
          accessToken: event.data['access_token'],
          expiresAt: event.data['expires_at'] == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(
                  int.parse(event.data['expires_at'].toString()) * 1000),
          refreshToken: event.data['refresh_token'],
          expiresIn: event.data['expires_in'] == null
              ? null
              : Duration(
                  seconds: int.parse(event.data['expires_in'].toString())),
          tokenType: event.data['token_type'],
          idToken: event.data['id_token'],
        );
      } else {
        return current..updateToken((event.data as Map).cast());
      }
    } else {
      throw Exception('${event.data}');
    }
  }
}
