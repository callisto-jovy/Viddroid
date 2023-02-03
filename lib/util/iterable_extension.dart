extension ReduceWhile<T> on Iterable<T> {
  T reduceWhile({
    required T Function(T previous, T element) combine,
    required bool Function(T) combineWhile,
    T? initialValue,
  }) {
    T initial = initialValue ?? first;

    for (T element in this) {
      initial = combine(initial, element);
      if (!combineWhile(initial)) break;
    }

    return initial;
  }
}

//Taken from: https://stackoverflow.com/a/63277386
extension Unique<E, Id> on List<E> {
  List<E> unique([Id Function(E element)? id, bool inplace = true]) {
    final ids = <dynamic>{};
    var list = inplace ? this : List<E>.from(this);
    final List<E> copy = List.from(list);
    copy.retainWhere((x) => ids.add(id != null ? id(x) : x as Id));

    return copy;
  }
}
