import 'dart:collection';

/// Simple LRU Cache implementation for Dart
class LruCache<K, V> {
  final int capacity;
  final LinkedHashMap<K, V> _cache = LinkedHashMap<K, V>();

  LruCache({required this.capacity});

  bool containsKey(K key) => _cache.containsKey(key);

  V? get(K key) {
    if (!_cache.containsKey(key)) return null;
    // Move to end (most recently used)
    final value = _cache.remove(key);
    _cache[key] = value as V;
    return value;
  }

  void set(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= capacity) {
      // Remove least recently used (first item)
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  void clear() => _cache.clear();

  int get length => _cache.length;
}
