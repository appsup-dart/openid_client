
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart';

typedef http.Client ClientFactory();

final ClientFactory factory = ()=>new BrowserClient();
