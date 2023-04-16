import 'package:flutter/material.dart';
import 'package:viddroid/util/capsules/option_item.dart';
import 'package:viddroid/widgets/settings/abstract_settings_tile.dart';
import 'package:viddroid/widgets/settings/navigation_settings_tile.dart';
import 'package:viddroid/widgets/settings/selection_settings_tile.dart';
import 'package:viddroid/widgets/settings/switch_settings_tile.dart';

enum SettingsTileType { simpleTile, switchTile, navigationTile, selectionTile, inputTile }

class SimpleSettingsTile extends StatefulWidget {
  const SimpleSettingsTile({
    this.leading,
    required this.title,
    this.description,
    this.onPressed,
    this.onToggle,
    this.value,
    this.toggled,
    this.enabled = true,
    this.trailing,
    this.optionItems,
    this.onSubmitted,
    this.formFieldHint,
    this.initialValue,
    required this.tileType,
    Key? key,
  }) : super(key: key);

  final Widget title;
  final Widget? description;
  final Widget? leading;
  final Widget? trailing;
  final Widget? value;

  final String? formFieldHint;
  final String? initialValue;

  final List<OptionItem>? optionItems;

  final Function(BuildContext context)? onPressed;
  final Function(bool value)? onToggle;
  final Function(String? value)? onSubmitted;

  final bool? toggled;
  final bool enabled;
  final SettingsTileType tileType;

  @override
  State<SimpleSettingsTile> createState() => _SimpleSettingsTileState();
}

class _SimpleSettingsTileState extends State<SimpleSettingsTile> with SettingsTile {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final additionalInfo = SettingsTileAdditionalInfo.of(context);
    if (widget.tileType == SettingsTileType.selectionTile) {
      return SelectionSettingsTile(
        items: widget.optionItems ?? List.empty(),
        onTap: widget.onPressed != null ? widget.onPressed!(context) : null,
        title: widget.title,
        trailing: widget.trailing,
        description: widget.description,
        leading: widget.leading,
      );
    } else if (widget.tileType == SettingsTileType.inputTile) {
      //TODO: Add validator & move the description to the bottom
      return Column(
        children: [
          buildSetting(context,
              additionalInfo: additionalInfo,
              enabled: widget.enabled,
              description: widget.description,
              titleContent: _buildTileContent(context, additionalInfo)),
          TextFormField(
            enabled: widget.enabled,
            initialValue: widget.initialValue,
            onFieldSubmitted: widget.onSubmitted,
            decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                hintText: widget.formFieldHint,
                contentPadding: const EdgeInsets.only(left: 18, bottom: 11, top: 11, right: 15)),
          ),
        ],
      );
    } else {
      return buildSetting(context,
          additionalInfo: additionalInfo,
          enabled: widget.enabled,
          description: widget.description,
          titleContent: _buildTileContent(context, additionalInfo));
    }
  }

  Widget _buildTrailing({
    required BuildContext context,
  }) {
    return Row(
      children: [
        if (widget.trailing != null) widget.trailing!,
        if (widget.tileType == SettingsTileType.switchTile)
          SwitchSettingsTile(toggled: widget.toggled, onToggle: widget.onToggle),
        if (widget.tileType == SettingsTileType.navigationTile)
          NavigationSettingsTile(
            value: widget.value,
          ),
      ],
    );
  }

  void _changePressState({bool isPressed = false}) {
    if (mounted) {
      setState(() {
        this.isPressed = isPressed;
      });
    }
  }

  Widget _buildTileContent(
    final BuildContext context,
    final SettingsTileAdditionalInfo additionalInfo,
  ) {
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    return InkWell(
      onTap: widget.onPressed == null
          ? null
          : () {
              _changePressState(isPressed: true);

              widget.onPressed!.call(context);

              Future.delayed(
                const Duration(milliseconds: 100),
                () => _changePressState(isPressed: false),
              );
            },
      child: Container(
        padding: const EdgeInsetsDirectional.only(start: 18),
        child: Row(
          children: [
            if (widget.leading != null)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 12.0),
                child: IconTheme.merge(
                  data: const IconThemeData(),
                  child: widget.leading!,
                ),
              ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                              padding: EdgeInsetsDirectional.only(
                                top: 12.5 * scaleFactor,
                                bottom: 12.5 * scaleFactor,
                              ),
                              child: widget.title),
                        ),
                        _buildTrailing(context: context),
                      ],
                    ),
                  ),
                  if (widget.description == null && additionalInfo.needToShowDivider)
                    const Divider(
                      height: 0,
                      thickness: 0.7,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
