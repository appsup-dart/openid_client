import 'openid_client.dart';
import 'dart:html' hide Credential, Client;
import 'dart:async';
import 'dart:convert';
export 'openid_client.dart';

class Authenticator {
  final Flow flow;

  final Future<Credential?> credential;

  Authenticator._(this.flow) : credential = _credentialFromUri(flow);

  Authenticator(Client client, {Iterable<String> scopes = const []})
      : this._(Flow.implicit(client,
            state: window.localStorage['openid_client:state'])
          ..scopes.addAll(scopes)
          ..redirectUri = Uri.parse(window.location.href).removeFragment());

  void authorize() {
    _forgetCredentials();
    window.localStorage['openid_client:state'] = flow.state;
    window.location.href = flow.authenticationUri.toString();
  }

  void logout() async {
    _forgetCredentials();
    var c = await credential;
    if (c == null) return;
    var uri = c.generateLogoutUrl(
        redirectUri: Uri.parse(window.location.href).removeFragment());
    if (uri != null) {
      window.location.href = uri.toString();
    }
  }

  void _forgetCredentials() {
    window.localStorage.remove('openid_client:state');
    window.localStorage.remove('openid_client:auth');
  }

  static Future<Credential?> _credentialFromUri(Flow flow) async {
    Map? q;
    if (window.localStorage.containsKey('openid_client:auth')) {
      q = json.decode(window.localStorage['openid_client:auth']!);
    } else {
      var uri = Uri(query: Uri.parse(window.location.href).fragment);
      q = uri.queryParameters;
      if (q.containsKey('access_token') ||
          q.containsKey('code') ||
          q.containsKey('id_token')) {
        window.localStorage['openid_client:auth'] = json.encode(q);
        window.location.href =
            Uri.parse(window.location.href).removeFragment().toString();
      }
    }
    if (q!.containsKey('access_token') ||
        q.containsKey('code') ||
        q.containsKey('id_token')) {
      return await flow.callback(q.cast());
    }
    return null;
  }
}
