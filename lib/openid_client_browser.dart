import 'openid_client.dart';
import 'dart:html' hide Credential, Client;
import 'dart:async';
export 'openid_client.dart';

class Authenticator {
  final Flow flow;

  final Future<Credential?> credential;

  Authenticator._(this.flow) : credential = _credentialFromUri(flow);

  Authenticator(Client client,
      {Iterable<String> scopes = const [], String? device})
      : this._(Flow.implicit(client,
            device: device, state: window.localStorage['openid_client:state'])
          ..scopes.addAll(scopes)
          ..redirectUri = Uri.parse(window.location.href).removeFragment());

  void authorize() {
    window.localStorage['openid_client:state'] = flow.state;
    window.location.href = flow.authenticationUri.toString();
  }

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
