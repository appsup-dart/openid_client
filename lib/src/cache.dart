library openid_client.openid;

import 'model.dart';

final Map<Uri,JsonWebKeySet> _keySetCache = {};

// used for testing
JsonWebKeySet addKeySetToCache(Uri uri, JsonWebKeySet set) => _keySetCache[uri] = set;

JsonWebKeySet findKeySetFromCache(Uri uri) => _keySetCache[uri];