import 'package:openid_client/openid_client.dart';
import 'package:openid_client/openid_client_browser.dart' as browser;

Future<Credential> authenticate(Client client,
    {List<String> scopes = const []}) async {
  var authenticator = browser.Authenticator(client, scopes: scopes);

  authenticator.authorize();

  throw Exception('Will never reach here');
}

Future<Credential?> getRedirectResult(Client client,
    {List<String> scopes = const []}) async {
  var authenticator = browser.Authenticator(client, scopes: scopes);

  var c = await authenticator.credential;

  return c;
}
