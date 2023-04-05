import 'dart:collection';

import 'package:localstore/localstore.dart';

class Watchables {
  static final Watchables _instance = Watchables._ctor();

  Watchables._ctor();

  factory Watchables() {
    return _instance;
  }

  static const String timestampsKey = 'timestamps';

  /// Map of all the timestamps. This map is actually written to disk.
  Map<String, dynamic> timestamps = HashMap();

  late CollectionRef collectionRef;

  /// Initializes all the values asynchronously
  Future<void> init() async {
    final Localstore db = Localstore.instance;
    collectionRef = db.collection('watchables');

    timestamps = (await collectionRef.doc(timestampsKey).get()) ?? HashMap();

    //TODO: Saved watchables
  }

  void saveTimestamp(final String hash, final Duration duration) {
    timestamps[hash] = duration.inSeconds;
    // Save to disk
    collectionRef.doc(timestampsKey).set(timestamps);
  }

  Duration? getTimestamp(final String hash) {
    int? seconds = timestamps[hash];
    if (seconds == null) {
      return null;
    }
    return Duration(seconds: seconds);
  }
}
