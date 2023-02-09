import 'package:flutter/material.dart';
import 'package:viddroid_flutter_desktop/watchable/watchable.dart';
import 'package:viddroid_flutter_desktop/widgets/cards/general_card.dart';

class WatchableCard extends StatelessWidget {
  final Watchable _watchable;

  const WatchableCard(this._watchable, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GeneralPurposeCard(title: _watchable.title!, onTap: () => null);
  }
}
