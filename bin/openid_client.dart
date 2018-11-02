import 'package:openid_client/openid_client_io.dart';
import 'package:args/command_runner.dart';
import 'dart:convert';
import 'dart:io';

class IssuersCommand extends Command {
  final name = "issuers";
  final description = "Do something with issuers";

  IssuersCommand() {
    addSubcommand(new ListIssuersCommand());
    addSubcommand(new DiscoverIssuerCommand());
  }
}

class ListIssuersCommand extends Command {
  final name = "list";
  final description = "Lists the known issuers";

  run() async {
    var issuers = (_configOptions["issuers"] ?? {}).keys.toSet()
      ..addAll(Issuer.knownIssuers.map((v) => v.toString()));

    issuers.forEach(print);
  }
}

class DiscoverIssuerCommand extends CommandWithRestArguments {
  final name = "discover";
  final description =
      "Discovers the metadata of an issuer and adds it to the list of known issuers";

  Uri get uri => Uri.parse(argResults.rest[0]);

  DiscoverIssuerCommand() {
    restArguments..add("issuer_url");
  }

  run() async {
    checkRestArguments();
    var issuer = await Issuer.discover(uri);
    print(toJson(issuer.metadata));
    Map issuers = _configOptions["issuers"] ??= {};
    if (!issuers.containsKey(uri.toString())) {
      issuers[uri.toString()] = {};
      _saveConfig();
    }
    return issuer;
  }
}

class ClientsCommand extends Command {
  final name = "clients";
  final description = "Do something with clients";

  ClientsCommand() {
    addSubcommand(new ListClientsCommand());
    addSubcommand(new ConfigureClientCommand());
    addSubcommand(new RemoveClientCommand());
    addSubcommand(new AuthClientCommand());
  }
}

class ListClientsCommand extends Command {
  final name = "list";
  final description = "Lists the configured clients";

  run() async {
    List clients = _configOptions["clients"] ??= [];

    clients
        .map((c) => "${c["issuer"]}\t${c["client_id"]}\t${c["client_secret"]}")
        .forEach(print);
  }
}

class ConfigureClientCommand extends CommandWithRestArguments {
  final name = "configure";
  final description = "Configure a new client";

  ConfigureClientCommand() {
    restArguments..addAll(["issuer_url", "client_id"]);
    argParser.addOption("secret", help: "the client secret");
  }

  Uri get issuer => Uri.parse(argResults.rest[0]);

  String get clientId => argResults.rest[1];

  String get secret => argResults["secret"];

  run() async {
    checkRestArguments();
    List clients = _configOptions["clients"] ??= [];
    var client = clients.firstWhere(
        (v) => v["issuer"] == issuer.toString() && v["client_id"] == clientId,
        orElse: () => null);
    if (client == null) {
      if (await Issuer.discover(issuer) == null) {
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
}

class RemoveClientCommand extends CommandWithRestArguments {
  final name = "remove";
  final description = "Remove a configured client";

  ConfigureClientCommand() {
    restArguments..addAll(["issuer_url", "client_id"]);
  }

  Uri get issuer => Uri.parse(argResults.rest[0]);

  String get clientId => argResults.rest[1];

  run() async {
    checkRestArguments();
    List clients = _configOptions["clients"] ??= [];
    var client = clients.firstWhere(
        (v) => v["issuer"] == issuer.toString() && v["client_id"] == clientId,
        orElse: () => null);
    clients.remove(client);
    _saveConfig();
  }
}

class AuthClientCommand extends CommandWithRestArguments {
  final name = "auth";
  final description = "Authenticate with a client";

  Uri get issuer => Uri.parse(argResults.rest[0]);

  String get clientId => argResults.rest[1];

  String get secret => argResults["secret"];
  int get port => int.parse(argResults["port"]);

  Iterable<String> get scopes => argResults["scopes"];

  AuthClientCommand() {
    restArguments..addAll(["issuer_url", "client_id"]);
    argParser.addOption("secret", help: "the client secret");
    argParser.addOption("port",
        defaultsTo: "3000", help: "port var redirect uri");
    argParser.addMultiOption("scopes", help: "the scopes", defaultsTo: []);
  }

  run() async {
    checkRestArguments();
    var client = await runner.run([
      "clients",
      "configure",
      issuer.toString(),
      clientId
    ]..addAll(secret == null ? [] : ["--secret", secret]));
    var a = new Authenticator(client, port: port, scopes: scopes);
    var c = await a.authorize();
    print(c.idToken.toCompactSerialization());
    print(toJson(await c.getUserInfo()));
  }
}

class TokensCommand extends Command {
  final name = "tokens";
  final description = "Do something with openid tokens";

  TokensCommand() {
    addSubcommand(new ValidateTokenCommand());
  }
}

class ValidateTokenCommand extends CommandWithRestArguments {
  final name = "validate";
  final description = "Validates the token";

  ValidateTokenCommand() {
    restArguments.add("token");
    argParser
      ..addOption("issuer", help: "the issuer")
      ..addOption("client-id", help: "the client id")
      ..addOption("secret", help: "the client secret");
  }
  String get token => argResults.rest[0];

  String get issuer => argResults["issuer"];
  String get clientId => argResults["client-id"];
  String get secret => argResults["secret"];

  run() async {
    Uri issuer;
    String clientId;
    try {
      Client client = await Client.forIdToken(token);
      issuer = client.issuer.metadata.issuer;
      if (this.issuer != null) issuer = Uri.parse(this.issuer);
      clientId = this.clientId ?? client.clientId;
    } catch (e) {}

    if (issuer == null) {
      stderr.writeln("Could not determine issuer from token.");
      return null;
    }
    if (clientId == null) {
      stderr.writeln("Could not determine client from token.");
      return null;
    }

    Client client = await runner.run([
      "clients",
      "configure",
      issuer.toString(),
      clientId
    ]..addAll(secret == null ? [] : ["--secret", secret]));

    var c = await client.createCredential(idToken: token);

    print(toJson(c.idToken.claims));
    var violations = await c.validateToken().toList();
    if (violations.isNotEmpty) {
      print("");
      stderr.writeln("Token is not valid, because of these violations: ");
      for (var f in violations) {
        stderr.writeln("\t${f}");
      }
    } else {
      print("Token is valid");
    }
  }
}

abstract class CommandWithRestArguments<T> extends Command<T> {
  final List<String> restArguments = [];

  String get invocation {
    var parents = [name];
    for (var command = parent; command != null; command = command.parent) {
      parents.add(command.name);
    }
    parents.add(runner.executableName);

    var invocation = parents.reversed.join(" ");
    return "$invocation [arguments] ${restArguments.map((v) => "<$v>").join(" ")}";
  }

  void checkRestArguments() {
    if (argResults.rest.length != restArguments.length) {
      this.usageException("Missing arguments");
    }
  }
}

String toJson(v) => const JsonEncoder.withIndent(" ").convert(v);

File get _configFile {
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

final Map<String, dynamic> _configOptions = () {
  var f = _configFile;
  if (f.existsSync()) {
    return json.decode(f.readAsStringSync());
  }
  return {};
}();

void _saveConfig() {
  var f = _configFile;
  f.createSync(recursive: true);
  f.writeAsStringSync(toJson(_configOptions));
}

final runner =
    new CommandRunner("openid_client", "tool for working with openid")
      ..addCommand(new IssuersCommand())
      ..addCommand(new ClientsCommand())
      ..addCommand(new TokensCommand());

main(List<String> args) async {
  runner.argParser.addFlag("verbose", help: "display more information");

  try {
    return await runner.run(args);
  } catch (e, tr) {
    print(e);
    if (runner.argParser.parse(args)["verbose"]) {
      print(tr);
    }
  }
}
