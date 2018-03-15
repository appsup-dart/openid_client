// Copyright (c) 2017, rbellens. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:openid_client/openid_client.dart';
import 'package:openid_client/src/html.dart';
import 'dart:html' hide Client, Credential;
import 'dart:convert';
import 'package:angular2/platform/browser.dart';
import 'package:angular2/core.dart';

main() async {

  bootstrap(AppComponent);

}

@Component(selector: 'my-app', templateUrl: 'app_component.html')
class AppComponent {
  List<Uri> issuers = Issuer.knownIssuers.toList();

  Issuer selectedIssuer;

  Map<String,List<String>> allClients = {};

  List<String> clients = [];

  Client selectedClient;

  Authenticator authenticator;

  Credential credential;

  UserInfo userinfo;

  AppComponent() {
    allClients = JSON.decode(window.localStorage["openid_clients"] ?? "{}");

    () async {
      if (window.localStorage.containsKey("issuer")) {
        await select(window.localStorage["issuer"]);
        if (selectedIssuer!=null) {
          if (window.localStorage.containsKey("client_id")) {
            selectClient(window.localStorage["client_id"]);
          }
        }
      }
    }();
    print("clients $allClients");
  }

  select(v) async {
    print("select $v");
    window.localStorage["issuer"] = v;
    this.selectedClient = null;
    this.clients = [];
    this.selectedIssuer = await Issuer.discover(Uri.parse(v));
    this.clients = allClients[selectedIssuer.metadata.issuer.toString()] ??= [];
  }

  selectClient(String v) async {
    print("select client $v");
    if (!clients.contains(v)) {
      clients.add(v);
      window.localStorage["openid_clients"] = JSON.encode(allClients);
    }
    window.localStorage["client_id"] = v;
    selectedClient = new Client(selectedIssuer, v);
    authenticator = new Authenticator(selectedClient);
    credential = null;
    userinfo = null;
    credential = await authenticator.credential;
    print("select client $credential");
    userinfo = await credential.getUserInfo();
    print("userinfo $userinfo");
    print(userinfo.toJson());
  }

  login() {
    authenticator.authorize();
  }

  logout() {
    userinfo = null;
    authenticator.logout();
  }
}

