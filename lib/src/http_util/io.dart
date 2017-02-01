
import 'package:http/http.dart' as http;

typedef http.Client ClientFactory();

final ClientFactory factory = ()=>new http.Client();
