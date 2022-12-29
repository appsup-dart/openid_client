[:heart: sponsor](https://github.com/sponsors/rbellens)


# openid_client

[![Build Status](https://travis-ci.org/appsup-dart/openid_client.svg?branch=master)](https://travis-ci.org/appsup-dart/openid_client)

Library for working with OpenID Connect and implementing clients.

It currently supports these features:

* discover OpenID Provider metadata
* parsing and validating id tokens
* basic tools for implementing implicit and authorization code flow
* authentication for command line tools


Besides authentication providers that support OpenID Connect, this 
library can also work with other authentication providers supporting
oauth2, like Facebook. For these providers, some features (e.g. discovery and id tokens) 
will not work. You should define the metadata for those providers manually, except
for Facebook, which is predefined in the library.



## Usage

Below are some examples of how to use the library. For more examples, see the [`example` folder](example/example.md). It contains full examples of how to use the library with a keycloak server in a flutter, command line and browser application.

A simple usage example:

```dart
import 'package:openid_client/openid_client.dart';

main() async {

  // print a list of known issuers
  print(Issuer.knownIssuers);

  // discover the metadata of the google OP
  var issuer = await Issuer.discover(Issuer.google);
  
  // create a client
  var client = new Client(issuer, "client_id", "client_secret");
  
  // create a credential object from authorization code
  var c = client.createCredential(code: "some received authorization code");

  // or from an access token
  c = client.createCredential(accessToken: "some received access token");

  // or from an id token
  c = client.createCredential(idToken: "some id token");      

  // get userinfo
  var info = await c.getUserInfo();
  print(info.name);
  
  // get claims from id token if present
  print(c.idToken?.claims?.name);
  
  // create an implicit authentication flow
  var f = new Flow.implicit(client);
  
  // or an explicit flow
  f = new Flow.authorizationCode(client);
  
  // set the redirect uri
  f.redirectUri = Uri.parse("http://localhost");
  
  // do something with the authentication url
  print(f.authenticationUrl);
  
  // handle the result and get a credential object
  c = await f.callback({
    "code": "some code",
  });
  
  // validate an id token
  var violations = await c.validateToken();
}

```
    
### Usage example on flutter

```dart
// import the io version
import 'package:openid_client/openid_client_io.dart';
// use url launcher package 
import 'package:url_launcher/url_launcher.dart';

authenticate(Uri uri, String clientId, List<String> scopes) async {   
    
    // create the client
    var issuer = await Issuer.discover(uri);
    var client = new Client(issuer, clientId);
    
    // create a function to open a browser with an url
    urlLauncher(String url) async {
        if (await canLaunch(url)) {
          await launch(url, forceWebView: true);
        } else {
          throw 'Could not launch $url';
        }
    }
    
    // create an authenticator
    var authenticator = new Authenticator(client,
        scopes: scopes,
        port: 4000, urlLancher: urlLauncher);
    
    // starts the authentication
    var c = await authenticator.authorize();
    
    // close the webview when finished
    closeWebView();
    
    // return the user info
    return await c.getUserInfo();

}
```

### Usage example on command line 

```dart
// import the io version
import 'package:openid_client/openid_client_io.dart';

authenticate(Uri uri, String clientId, List<String> scopes) async {   
    
    // create the client
    var issuer = await Issuer.discover(uri);
    var client = new Client(issuer, clientId);
    
    // create an authenticator
    var authenticator = new Authenticator(client,
        scopes: scopes,
        port: 4000);
    
    // starts the authentication
    var c = await authenticator.authorize(); // this will open a browser
    
    // return the user info
    return await c.getUserInfo();
}
```

### Usage example in browser

```dart
// import the browser version
import 'package:openid_client/openid_client_browser.dart';

authenticate(Uri uri, String clientId, List<String> scopes) async {   
    
    // create the client
    var issuer = await Issuer.discover(uri);
    var client = new Client(issuer, clientId);
    
    // create an authenticator
    var authenticator = new Authenticator(client, scopes: scopes);
    
    // get the credential
    var c = await authenticator.credential;
    
    if (c==null) {
      // starts the authentication
      authenticator.authorize(); // this will redirect the browser
    } else {
      // return the user info
      return await c.getUserInfo();
    }
}
```



    
## Command line tool

### Install

    pub global activate openid_client
    

### Usage

Show a list of known OpenID providers:
 
    openid_client issuers list
    
Discover and show the metadata of an OP:

    openid_client issusers discover https://www.example.com

Show a list of known clients:

    openid_client clients list
    
Add a client:

    openid_client clients configure --secret optional_secret https://some.issuer.com client_id
     
Remove a client:
    
    openid_client clients remove https://some.issuer.com client_id

Authenticate with a client:

    openid_client clients auth --secret optional_secret https://some.issuer.com client_id
    
Show the content of an id token and validate it: 

    openid_client tokens validate eyJhbGciOiJSUzI1NiIsImtpZCI6ImE2YzJjNmQ0ZTZkYTFmOWJjMTdmYzhkMzExMzNiOTJmMDdlOTgxMTkifQ.eyJpc3MiOiJodHRwczovL2FjY291bnRzLmdvb2dsZS5jb20iLCJpYXQiOjE0ODU4ODQyNzcsImV4cCI6MTQ4NTg4Nzg3NywiYXRfaGFzaCI6Ik9nWUlZRzM1WXB6RmVvRlZBeWd1VUEiLCJhdWQiOiI1ODExNTUxMDQ5NDMtcnBqazBzanZucDFrZ2FkYzV0Mm5pOXFvYWt0ZGpzMjEuYXBwcy5nb29nbGV1c2VyY29udGVudC5jb20iLCJzdWIiOiIxMTI2NzgyNTk2NzYyMTE3MDcxNDgiLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiYXpwIjoiNTgxMTU1MTA0OTQzLXJwamswc2p2bnAxa2dhZGM1dDJuaTlxb2FrdGRqczIxLmFwcHMuZ29vZ2xldXNlcmNvbnRlbnQuY29tIiwiZW1haWwiOiJyaWsuYmVsbGVuc0BnbWFpbC5jb20iLCJuYW1lIjoiUmlrIEJlbGxlbnMiLCJwaWN0dXJlIjoiaHR0cHM6Ly9saDUuZ29vZ2xldXNlcmNvbnRlbnQuY29tLy1lRmpwUXFfUTZWUS9BQUFBQUFBQUFBSS9BQUFBQUFBQUFCUS9md1U0alVicTJ5US9zOTYtYy9waG90by5qcGciLCJnaXZlbl9uYW1lIjoiUmlrIiwiZmFtaWx5X25hbWUiOiJCZWxsZW5zIiwibG9jYWxlIjoibmwifQ.TlXzuNLdd5hX-bzMrwBaclcE8z4So2wFJAZ_H7hGz8YA4lCxHV8iON8yuJ1PdXGuOOkDXScj4qSPK80IZ_J29Uf2azCH83djpjyP4McB_dG4zXkUSFGFTHiNnqmvFbMmL-91A74teAr1ZHDx5-so2bHs16_c8immj2YM5GqlN4FG_IFCqRZ-7jEn9m_SjBXpb_NahiDB-bk47npmM9GIWq4OhV4e4tpFO1XY7H4fDHoiBhkc1nrbUjiqTH3VOJVQNp6FjiO2ErR7UWWnSKX6PMFDJ-U-QSsC8gu0PtuIa1ZUXvTAdX5vKt_fsKijbiT0xUUq8xJATaDh8-aBsNKpqQ

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/appsup-dart/openid_client/issues

## Sponsor

Creating and maintaining this package takes a lot of time. If you like the result, please consider to [:heart: sponsor](https://github.com/sponsors/rbellens). 
With your support, I will be able to further improve and support this project.
Also, check out my other dart packages at [pub.dev](https://pub.dev/packages?q=publisher%3Aappsup.be).

