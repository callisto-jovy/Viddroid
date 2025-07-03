import 'package:flutter/material.dart';
import 'package:viddroid/widgets/cards/general_card.dart';

import '../../util/watchable/watchable.dart';

class WatchableCard extends StatelessWidget {
  final Watchable _watchable;

  const WatchableCard(this._watchable, {super.key});

  @override
  Widget build(BuildContext context) {
    return GeneralPurposeCard(title: _watchable.title!, onTap: () => null);
  }
}
