import 'package:flutter/material.dart';
import 'package:viddroid/widgets/settings/base_settings_tile.dart';

import 'abstract_settings_tile.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.tiles,
    this.margin,
    required this.title,
    required this.icon,
    super.key,
  });

  final List<SimpleSettingsTile> tiles;
  final EdgeInsetsDirectional? margin;
  final Widget icon;
  final Widget title;

  @override
  Widget build(BuildContext context) {
    final bool isLastNonDescriptive = (tiles.last).description == null;
    final double scaleFactor = MediaQuery.of(context).textScaleFactor;

    return Padding(
      padding: margin ??
          EdgeInsets.only(
            top: 14.0 * scaleFactor,
            bottom: isLastNonDescriptive ? 27 * scaleFactor : 10 * scaleFactor,
            left: 16,
            right: 16,
          ),
      child: Column(
        children: [
          Padding(
              padding: EdgeInsetsDirectional.only(
                start: 18,
                bottom: 5 * scaleFactor,
              ),
              child: title),
          // TODO: Remove scrolling in the card itself, make the card expand and scrollable
          Flexible(
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 2,
              child: buildTileList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTileList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: tiles.length,
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context, int index) {
        final tile = tiles[index];

        var enableTop = false;

        if (index == 0 || (index > 0 && (tiles[index - 1]).description != null)) {
          enableTop = true;
        }

        var enableBottom = false;

        if (index == tiles.length - 1 || (index < tiles.length && (tile).description != null)) {
          enableBottom = true;
        }
        return SettingsTileAdditionalInfo(
          enableTopBorderRadius: enableTop,
          enableBottomBorderRadius: enableBottom,
          needToShowDivider: index != tiles.length - 1,
          child: tile,
        );
      },
    );
  }
}
