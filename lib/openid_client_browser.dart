import 'openid_client.dart';
import 'dart:html' hide Credential, Client;
import 'dart:async';
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
      {Iterable<String> scopes = const [], String? device})
      : this._(Flow.implicit(client,
            device: device, state: window.localStorage['openid_client:state'])
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
    var uri = Uri(query: Uri.parse(window.location.href).fragment);
    var q = uri.queryParameters;
    if (q.containsKey('access_token') ||
        q.containsKey('code') ||
        q.containsKey('id_token')) {
      window.history.replaceState(
          '', '', Uri.parse(window.location.href).removeFragment().toString());
      window.localStorage.remove('openid_client:state');
      return await flow.callback(q.cast());
    }
    return null;
  }
}
