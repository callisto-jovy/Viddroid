import 'package:flutter/material.dart';
import 'package:viddroid_flutter_desktop/widgets/settings/settings_tile.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    required this.tiles,
    required this.margin,
    required this.title,
    Key? key,
  }) : super(key: key);

  final List<SettingsTile> tiles;
  final EdgeInsetsDirectional? margin;
  final Widget? title;

  @override
  Widget build(BuildContext context) {
    final isLastNonDescriptive = (tiles.last).description == null;
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    return Padding(
      padding: margin ??
          EdgeInsets.only(
            top: 14.0 * scaleFactor,
            bottom: isLastNonDescriptive ? 27 * scaleFactor : 10 * scaleFactor,
            left: 16,
            right: 16,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
                padding: EdgeInsetsDirectional.only(
                  start: 18,
                  bottom: 5 * scaleFactor,
                ),
                child: title),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 2,
            child: buildTileList(),
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
      physics: const NeverScrollableScrollPhysics(),
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