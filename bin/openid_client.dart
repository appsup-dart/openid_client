import 'package:unscripted/unscripted.dart';
import 'package:openid_client/openid_client.dart';
import 'package:openid_client/src/console.dart';
import 'dart:convert';
import 'dart:io';

main(arguments) => new Script(OpenIdClientCLI).execute(arguments);

String toJson(v) => const JsonEncoder.withIndent(" ").convert(v);

class OpenIdClientCLI {
  final Map<String, dynamic> configOptions;

  @Command()
  OpenIdClientCLI() : configOptions = _loadConfig();

  static File get _configFile {
    if (Platform.isWindows)
      return new File([
        Platform.environment["APPDATA"],
        "OpenIdClient",
        "config.json"
      ].join(Platform.pathSeparator));
    return new File([
      Platform.environment["HOME"],
      ".openid_client",
      "config.json"
    ].join(Platform.pathSeparator));
  }

  static Map<String, dynamic> _loadConfig() {
    var f = _configFile;
    if (f.existsSync()) {
      return JSON.decode(f.readAsStringSync());
    }
    return {};
  }

  void _saveConfig() {
    var f = _configFile;
    f.createSync(recursive: true);
    f.writeAsStringSync(toJson(configOptions));
  }

  @SubCommand()
  issuersList() async {
    var issuers = (configOptions["issuers"] ?? {}).keys.toSet()
      ..addAll(Issuer.knownIssuers);

    issuers.forEach(print);
  }

  @SubCommand()
  issuersDiscover(Uri uri) async {
    try {
      var issuer = await Issuer.discover(uri);
      print(toJson(issuer.metadata));
      Map issuers = configOptions["issuers"] ??= {};
      if (!issuers.containsKey(uri.toString())) {
        issuers[uri.toString()] = {};
        _saveConfig();
      }
      return issuer;
    } catch (e) {
      stderr.writeln("Could not discover issuer: $e");
    }
  }

  @SubCommand()
  clientsList() async {
    List clients = configOptions["clients"] ??= [];

    clients
        .map((c) => "${c["issuer"]}\t${c["client_id"]}\t${c["client_secret"]}")
        .forEach(print);
  }

  @SubCommand()
  clientsAdd(Uri issuer, String clientId, {@Option() String secret}) async {
    List clients = configOptions["clients"] ??= [];
    var client = clients.firstWhere(
        (v) => v["issuer"] == issuer.toString() && v["client_id"] == clientId,
        orElse: () => null);
    if (client == null) {
      if (await issuersDiscover(issuer) == null) {
        return null;
      }
      client = {"issuer": issuer.toString(), "client_id": clientId};
      clients.add(client);
    }
    if (client["client_secret"] != null &&
        client["client_secret"] != secret &&
        secret != null) {
      stderr.writeln("Client with other secret already exists.");
      return null;
    }
    if (secret != null) {
      client["client_secret"] = secret;
    }
    _saveConfig();
    return new Client(await Issuer.discover(issuer), client["client_id"],
        client["client_secret"]);
  }

  @SubCommand()
  clientsRemove(Uri issuer, String clientId) async {
    List clients = configOptions["clients"] ??= [];
    var client = clients.firstWhere(
        (v) => v["issuer"] == issuer.toString() && v["client_id"] == clientId,
        orElse: () => null);
    clients.remove(client);
    _saveConfig();
  }

  @SubCommand()
  clientsAuth(Uri issuer, String clientId,
      {String secret, int port: 3000}) async {
    var client = await clientsAdd(issuer, clientId, secret: secret);
    var a = new ConsoleAuthenticator(client, port: port);
    var c = await a.authorize();
    print(toJson(await c.getUserInfo()));
  }

  @SubCommand()
  tokensValidate(String token,
      {Uri issuer, String clientId, String clientSecret}) async {
    try {
      Client client = await Client.forIdToken(token);
      issuer ??= client.issuer.metadata.issuer;
      clientId ??= client.clientId;
    } catch (e) {}

    if (issuer == null) {
      stderr.writeln("Could not determine issuer from token.");
      return null;
    }
    if (clientId == null) {
      stderr.writeln("Could not determine client from token.");
      return null;
    }

    Client client = await clientsAdd(issuer, clientId, secret: clientSecret);

    var c = await client.createCredential(idToken: token);

    print(toJson(c.idToken.payload));
    var violations = await c.validateToken();
    if (violations.isNotEmpty) {
      print("");
      stderr.writeln("Token is not valid, because of these violations: ");
      for (var f in violations) {
        stderr.writeln("\t${f.message}");
      }
    }
  }
}
