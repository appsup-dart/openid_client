// Copyright (c) 2017, rbellens. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:openid_client/openid_client_browser.dart';
import 'dart:html' hide Client, Credential;
import 'dart:convert';
import 'package:angular/angular.dart';

import 'main.template.dart' as self;

@GenerateInjector([])
final InjectorFactory injector = self.injector$Injector;

void main() {
  runApp(self.AppComponentNgFactory, createInjector: injector);
}

@Component(selector: 'my-app', templateUrl: 'app_component.html', directives: [
  NgFor,
  NgIf,
])
class AppComponent {
  List<Uri> issuers = Issuer.knownIssuers.toList();

  Issuer selectedIssuer;

  Map<String, List<String>> allClients = {};

  List<String> clients = [];

  Client selectedClient;

  Authenticator authenticator;

  Credential credential;

  UserInfo userinfo;

  AppComponent() {
    var map = json.decode(window.localStorage["openid_clients"] ?? "{}") as Map;
    allClients = new Map.fromIterables(
        map.keys, map.values.map((v) => (v as List).cast<String>()));

    () async {
      if (window.localStorage.containsKey("issuer")) {
        await select(window.localStorage["issuer"]);
        if (selectedIssuer != null) {
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
      window.localStorage["openid_clients"] = json.encode(allClients);
    }
    window.localStorage["client_id"] = v;
    selectedClient = new Client(selectedIssuer, v);
    authenticator = new Authenticator(selectedClient);
    credential = null;
    userinfo = null;
    credential = await authenticator.credential;
    if (credential == null) return;
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
