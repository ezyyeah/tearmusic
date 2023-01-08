enum CacheType { local, remote }

class CachedItem<T> {
  final T _item;
  final CacheType _type;

  T get item => _item;
  CacheType get type => _type;

  CachedItem(T item, {CacheType type = CacheType.local})
      : _item = item,
        _type = type;
}
