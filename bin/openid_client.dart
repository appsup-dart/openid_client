import 'dart:async';

import 'package:openid_client/openid_client_io.dart';
import 'package:args/command_runner.dart';
import 'dart:convert';
import 'dart:io';

class IssuersCommand extends Command {
  @override
  final name = 'issuers';
  @override
  final description = 'Do something with issuers';

  IssuersCommand() {
    addSubcommand(ListIssuersCommand());
    addSubcommand(DiscoverIssuerCommand());
  }
}

class ListIssuersCommand extends Command {
  @override
  final name = 'list';
  @override
  final description = 'Lists the known issuers';

  @override
  void run() async {
    var issuers = (_configOptions!['issuers'] ?? {}).keys.toSet()
      ..addAll(Issuer.knownIssuers.map((v) => v.toString()));

    issuers.forEach(print);
  }
}

class DiscoverIssuerCommand extends CommandWithRestArguments {
  @override
  final name = 'discover';
  @override
  final description =
      'Discovers the metadata of an issuer and adds it to the list of known issuers';

  Uri get uri => Uri.parse(argResults!.rest[0]);

  DiscoverIssuerCommand() {
    restArguments.add('issuer_url');
  }

  @override
  Future<Issuer> run() async {
    checkRestArguments();
    var issuer = await Issuer.discover(uri);
    print(toJson(issuer.metadata));
    Map issuers = _configOptions!['issuers'] ??= {};
    if (!issuers.containsKey(uri.toString())) {
      issuers[uri.toString()] = {};
      _saveConfig();
    }
    return issuer;
  }
}

class ClientsCommand extends Command {
  @override
  final name = 'clients';
  @override
  final description = 'Do something with clients';

  ClientsCommand() {
    addSubcommand(ListClientsCommand());
    addSubcommand(ConfigureClientCommand());
    addSubcommand(RemoveClientCommand());
    addSubcommand(AuthClientCommand());
  }
}

class ListClientsCommand extends Command {
  @override
  final name = 'list';
  @override
  final description = 'Lists the configured clients';

  @override
  void run() async {
    List clients = _configOptions!['clients'] ??= [];

    clients
        .map((c) => '${c['issuer']}\t${c['client_id']}\t${c['client_secret']}')
        .forEach(print);
  }
}

class ConfigureClientCommand extends CommandWithRestArguments {
  @override
  final name = 'configure';
  @override
  final description = 'Configure a client';

  ConfigureClientCommand() {
    restArguments.addAll(['issuer_url', 'client_id']);
    argParser.addOption('secret', help: 'the client secret');
  }

  Uri get issuer => Uri.parse(argResults!.rest[0]);

  String get clientId => argResults!.rest[1];

  String? get secret => argResults!['secret'];

  @override
  Future<Client?> run() async {
    checkRestArguments();
    List clients = _configOptions!['clients'] ??= [];
    var client = clients.firstWhere(
        (v) => v['issuer'] == issuer.toString() && v['client_id'] == clientId,
        orElse: () => null);
    if (client == null) {
      client = {'issuer': issuer.toString(), 'client_id': clientId};
      clients.add(client);
    }
    if (client['client_secret'] != null &&
        client['client_secret'] != secret &&
        secret != null) {
      stderr.writeln('Client with other secret already exists.');
      return null;
    }
    if (secret != null) {
      client['client_secret'] = secret;
    }
    _saveConfig();
    return Client(await Issuer.discover(issuer), client['client_id'],
        clientSecret: client['client_secret']);
  }
}

class RemoveClientCommand extends CommandWithRestArguments {
  @override
  final name = 'remove';
  @override
  final description = 'Remove a configured client';

  RemoveClientCommand() {
    restArguments.addAll(['issuer_url', 'client_id']);
  }

  Uri get issuer => Uri.parse(argResults!.rest[0]);

  String get clientId => argResults!.rest[1];

  @override
  void run() async {
    checkRestArguments();
    List clients = _configOptions!['clients'] ??= [];
    var client = clients.firstWhere(
        (v) => v['issuer'] == issuer.toString() && v['client_id'] == clientId,
        orElse: () => null);
    clients.remove(client);
    _saveConfig();
  }
}

class AuthClientCommand extends CommandWithRestArguments {
  @override
  final name = 'auth';
  @override
  final description = 'Authenticate with a client';

  Uri get issuer => Uri.parse(argResults!.rest[0]);

  String get clientId => argResults!.rest[1];

  String? get secret => argResults!['secret'];
  int get port => int.parse(argResults!['port']);

  Iterable<String> get scopes => argResults!['scopes'] ?? const [];

  AuthClientCommand() {
    restArguments.addAll(['issuer_url', 'client_id']);
    argParser.addOption('secret', help: 'the client secret');
    argParser.addOption('port',
        defaultsTo: '3000', help: 'port var redirect uri');
    argParser.addMultiOption('scopes', help: 'the scopes', defaultsTo: []);
  }

  @override
  void run() async {
    checkRestArguments();
    var client = await runner.run([
      'clients',
      'configure',
      issuer.toString(),
      clientId,
      if (secret != null) ...['--secret', secret!]
    ]);
    var a = Authenticator(client, port: port, scopes: scopes);
    var c = await a.authorize();
    print(c.idToken.toCompactSerialization());
    print(toJson(await c.getUserInfo()));
  }
}

class TokensCommand extends Command {
  @override
  final name = 'tokens';
  @override
  final description = 'Do something with openid tokens';

  TokensCommand() {
    addSubcommand(ValidateTokenCommand());
  }
}

class ValidateTokenCommand extends CommandWithRestArguments {
  @override
  final name = 'validate';
  @override
  final description = 'Validates the token';

  ValidateTokenCommand() {
    restArguments.add('token');
    argParser
      ..addOption('issuer', help: 'the issuer')
      ..addOption('client-id', help: 'the client id')
      ..addOption('secret', help: 'the client secret');
  }
  String get token => argResults!.rest[0];

  String? get issuer => argResults!['issuer'];
  String? get clientId => argResults!['client-id'];
  String? get secret => argResults!['secret'];

  @override
  void run() async {
    Uri? issuer;
    String? clientId;
    try {
      var client = await Client.forIdToken(token);
      issuer = client.issuer.metadata.issuer;
      if (this.issuer != null) issuer = Uri.parse(this.issuer!);
      clientId = this.clientId ?? client.clientId;
    } catch (e) {
      // ignore
    }

    if (issuer == null) {
      stderr.writeln('Could not determine issuer from token.');
      return null;
    }
    if (clientId == null) {
      stderr.writeln('Could not determine client from token.');
      return null;
    }

    var client = await runner.run([
      'clients',
      'configure',
      issuer.toString(),
      clientId,
      if (secret != null) ...['--secret', secret!]
    ]);

    var c = client.createCredential(idToken: token);

    print(toJson(c.idToken.claims));
    var violations = await c.validateToken().toList();
    if (violations.isNotEmpty) {
      print('');
      stderr.writeln('Token is not valid, because of these violations: ');
      for (var f in violations) {
        stderr.writeln('\t$f');
      }
    } else {
      print('Token is valid');
    }
  }
}

abstract class CommandWithRestArguments<T> extends Command<T> {
  final List<String> restArguments = [];

  @override
  String get invocation {
    var parents = [name];
    for (var command = parent; command != null; command = command.parent) {
      parents.add(command.name);
    }
    parents.add(runner.executableName);

    var invocation = parents.reversed.join(' ');
    return '$invocation [arguments] ${restArguments.map((v) => '<$v>').join(' ')}';
  }

  void checkRestArguments() {
    if (argResults!.rest.length != restArguments.length) {
      usageException('Missing arguments');
    }
  }
}

String toJson(v) => const JsonEncoder.withIndent(' ').convert(v);

File get _configFile {
  if (Platform.isWindows) {
    return File([Platform.environment['APPDATA'], 'OpenIdClient', 'config.json']
        .join(Platform.pathSeparator));
  }
  return File([Platform.environment['HOME'], '.openid_client', 'config.json']
      .join(Platform.pathSeparator));
}

final Map<String, dynamic>? _configOptions = () {
  var f = _configFile;
  if (f.existsSync()) {
    return json.decode(f.readAsStringSync());
  }
  return <String, dynamic>{};
}();

void _saveConfig() {
  var f = _configFile;
  f.createSync(recursive: true);
  f.writeAsStringSync(toJson(_configOptions));
}

final runner = CommandRunner('openid_client', 'tool for working with openid')
  ..addCommand(IssuersCommand())
  ..addCommand(ClientsCommand())
  ..addCommand(TokensCommand());

void main(List<String> args) async {
  runner.argParser.addFlag('verbose', help: 'display more information');

  try {
    await runner.run(args);
  } catch (e, tr) {
    print(e);
    if (runner.argParser.parse(args)['verbose']) {
      print(tr);
    }
  }
}
