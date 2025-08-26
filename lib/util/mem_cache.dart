class MemCache {
  static final Map<MemCacheKey, dynamic> _map = {};

  static put(MemCacheKey key, dynamic value) {
    _map[key] = value;
  }

  static dynamic get(MemCacheKey key) {
    return _map[key];
  }

  static contains(MemCacheKey key) {
    return _map[key] == null;
  }

  static remove(MemCacheKey key) {
    return _map.remove(key);
  }

  static void clear() {
    _map.clear();
  }
}

enum MemCacheKey {
  firebaseAuthIdToken,
  deardeerUserJson,
}
