import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum SettingsTileType { simpleTile, switchTile, navigationTile }

class SettingsTile extends StatefulWidget {
  const SettingsTile({
    this.leading,
    required this.title,
    this.description,
    this.onPressed,
    this.onToggle,
    this.value,
    this.initialValue,
    this.enabled = true,
    this.trailing,
    required this.tileType,
    Key? key,
  }) : super(key: key);

  final Widget? leading;
  final Widget title;
  final Widget? description;
  final Function(BuildContext context)? onPressed;
  final Function(bool value)? onToggle;
  final Widget? value;
  final bool? initialValue;
  final bool enabled;
  final Widget? trailing;
  final SettingsTileType tileType;

  @override
  State<SettingsTile> createState() => _SettingsTileState();
}

class _SettingsTileState extends State<SettingsTile> {
  bool isPressed = false;

  @override
  Widget build(BuildContext context) {
    final additionalInfo = SettingsTileAdditionalInfo.of(context);

    return IgnorePointer(
      ignoring: !widget.enabled,
      child: Column(
        children: [
          buildTitle(
            context: context,
            additionalInfo: additionalInfo,
          ),
          if (widget.description != null)
            buildDescription(
              context: context,
              additionalInfo: additionalInfo,
            ),
        ],
      ),
    );
  }

  Widget buildTitle({
    required BuildContext context,
    required SettingsTileAdditionalInfo additionalInfo,
  }) {
    Widget content = buildTileContent(context, additionalInfo);

    content = Material(
      color: Colors.transparent,
      child: content,
    );

    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: additionalInfo.enableTopBorderRadius ? const Radius.circular(12) : Radius.zero,
        bottom: additionalInfo.enableBottomBorderRadius ? const Radius.circular(12) : Radius.zero,
      ),
      child: content,
    );
  }

  Widget buildDescription({
    required BuildContext context,
    required SettingsTileAdditionalInfo additionalInfo,
  }) {
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 8 * scaleFactor,
        bottom: additionalInfo.needToShowDivider ? 24 : 8 * scaleFactor,
      ),
      decoration: const BoxDecoration(),
      child: DefaultTextStyle(
        style: const TextStyle(
          fontSize: 13,
        ),
        child: widget.description!,
      ),
    );
  }

  Widget buildTrailing({
    required BuildContext context,
  }) {
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    return Row(
      children: [
        if (widget.trailing != null) widget.trailing!,
        if (widget.tileType == SettingsTileType.switchTile)
          CupertinoSwitch(
            value: widget.initialValue ?? true,
            onChanged: widget.onToggle,
          ),
        if (widget.tileType == SettingsTileType.navigationTile && widget.value != null)
          DefaultTextStyle(
            style: const TextStyle(
              fontSize: 17,
            ),
            child: widget.value!,
          ),
        if (widget.tileType == SettingsTileType.navigationTile)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 6, end: 2),
            child: Icon(
              CupertinoIcons.chevron_forward,
              size: 18 * scaleFactor,
            ),
          ),
      ],
    );
  }

  void changePressState({bool isPressed = false}) {
    if (mounted) {
      setState(() {
        this.isPressed = isPressed;
      });
    }
  }

  Widget buildTileContent(
    BuildContext context,
    SettingsTileAdditionalInfo additionalInfo,
  ) {
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    return InkWell(
      onTap: widget.onPressed == null
          ? null
          : () {
              changePressState(isPressed: true);

              widget.onPressed!.call(context);

              Future.delayed(
                const Duration(milliseconds: 100),
                () => changePressState(isPressed: false),
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
                        buildTrailing(context: context),
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

class SettingsTileAdditionalInfo extends InheritedWidget {
  final bool needToShowDivider;
  final bool enableTopBorderRadius;
  final bool enableBottomBorderRadius;

  const SettingsTileAdditionalInfo({
    super.key,
    required this.needToShowDivider,
    required this.enableTopBorderRadius,
    required this.enableBottomBorderRadius,
    required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(SettingsTileAdditionalInfo old) => true;

  static SettingsTileAdditionalInfo of(BuildContext context) {
    final SettingsTileAdditionalInfo? result =
        context.dependOnInheritedWidgetOfExactType<SettingsTileAdditionalInfo>();

    return result ??
        const SettingsTileAdditionalInfo(
          needToShowDivider: true,
          enableBottomBorderRadius: true,
          enableTopBorderRadius: true,
          child: SizedBox(),
        );
  }
}
