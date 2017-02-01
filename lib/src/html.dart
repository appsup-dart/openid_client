

import 'openid.dart';
import 'dart:html' hide Credential, Client;
import 'dart:async';
import 'dart:convert';

class Authenticator {

  final Flow flow;

  final Future<Credential> credential;

  Authenticator._(this.flow) : credential = _credentialFromUri(flow);

  Authenticator(Client client) : this._(new Flow.implicit(client)
  ..redirectUri = Uri.parse(window.location.href).removeFragment());

  void authorize() {
    logout();
    window.location.href = flow.authenticationUri.toString();
  }

  void logout() {
    window.localStorage.remove("openid_client:auth");
  }

  static Future<Credential> _credentialFromUri(Flow flow) async {
    var q;
    if (window.localStorage.containsKey("openid_client:auth")) {
      q = JSON.decode(window.localStorage["openid_client:auth"]);
    } else {
      var uri = new Uri(query: Uri.parse(window.location.href).fragment);
      q = uri.queryParameters;
      if (q.containsKey("access_token")||q.containsKey("code")||q.containsKey("id_token")) {
        window.location.href = Uri.parse(window.location.href).removeFragment().toString();
      }
    }
    try {
      var c = await flow.callback(q);
      window.localStorage["openid_client:auth"] = JSON.encode(q);
      return c;
    } on ArgumentError {
      return null;
    }
  }
}