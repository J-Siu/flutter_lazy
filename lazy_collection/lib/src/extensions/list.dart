/// ### Lazy extension for [List]
extension LazyExtList<T> on List<T> {
  /// Auto skip [add] if [v] is `null`
  void lazyAdd(T? v) {
    if (v != null) add(v);
  }

  /// Auto skip [add] if [v] is `null`
  /// - alias of [lazyAdd]
  void addLazy(T? v) => lazyAdd(v);
}
