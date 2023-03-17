import 'package:viddroid_flutter_desktop/util/watchable/watchable.dart';

class Watchables {
  static final Watchables _instance = Watchables._inst();

  Watchables._inst();

  factory Watchables() {
    return _instance;
  }

}
