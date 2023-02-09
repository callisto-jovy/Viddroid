///Taken from: Alex Ritt (https://stackoverflow.com/questions/73214483/how-to-extend-dart-sockets-broadcaststream-buffer-size-of-1024-bytes)
///(Thank you so much, this is the generic approach)
/// This was created since the native [reduce] says:
/// > When this stream is done, the returned future is completed with the value at that time.
///
/// The problem is that socket connections does not emits the [done] event after
/// each message but after the socket disconnection.
///
/// So here is a implementation that combines [reduce] and [takeWhile].
extension ReduceWhile<T> on Stream<T> {
  Future<T> reduceWhile({
    required T Function(T previous, T element) combine,
    required bool Function(T) combineWhile,
    T? initialValue,
  }) async {
    T initial = initialValue ?? await first;

    await for (T element in this) {
      initial = combine(initial, element);
      if (!combineWhile(initial)) break;
    }

    return initial;
  }
}
