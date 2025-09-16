import 'package:web/web.dart' hide Client;

import 'package:openid_client/openid_client_browser.dart';

const keycloakUri = 'http://localhost:8080/realms/myrealm';
const scopes = ['profile'];

Future<Authenticator> getAuthenticator() async {
  var uri = Uri.parse(keycloakUri);
  var clientId = 'myclient';

  var issuer = await Issuer.discover(uri);
  var client = Client(issuer, clientId);

  return Authenticator(client, scopes: scopes);
}

Future<void> main() async {
  var authenticator = await getAuthenticator();

  var credential = await authenticator.credential;

  if (credential != null) {
    Future<void> refresh() async {
      var userData = await credential!.getUserInfo();
      document.querySelector('#name')!.textContent = userData.name!;
      document.querySelector('#email')!.textContent = userData.email!;
      document.querySelector('#issuedAt')!.textContent =
          credential!.idToken.claims.issuedAt.toIso8601String();
    }

    await refresh();
    (document.querySelector('#when-logged-in') as HTMLElement).style.display =
        'block';
    document.querySelector('#logout')!.onClick.listen((_) async {
      authenticator.logout();
    });
    document.querySelector('#refresh')!.onClick.listen((_) async {
      credential = await authenticator.trySilentRefresh();
      await refresh();
    });
  } else {
    (document.querySelector('#when-logged-out') as HTMLElement).style.display =
        'block';
    document.querySelector('#login')!.onClick.listen((_) async {
      authenticator.authorize();
    });
  }
}
