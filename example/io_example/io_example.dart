import 'package:openid_client/openid_client_io.dart';

const keycloakUri = 'http://localhost:8080/realms/myrealm';
const scopes = ['profile'];

Future<Credential> authenticate() async {
  var uri = Uri.parse(keycloakUri);
  var clientId = 'myclient';

  var issuer = await Issuer.discover(uri);
  var client = Client(issuer, clientId);

  var authenticator = Authenticator(client, scopes: scopes);

  return authenticator.authorize();
}

Future<void> main() async {
  var credential = await authenticate();

  var userInfo = await credential.getUserInfo();

  print('Hello ${userInfo.name}!');
  print('Your email is ${userInfo.email}!');
}
