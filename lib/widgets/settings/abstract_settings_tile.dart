import 'package:flutter/material.dart';

mixin SettingsTile {

  Widget buildSetting(final BuildContext context,
      {required SettingsTileAdditionalInfo additionalInfo,
      required bool enabled,
      Widget? description,
      required Widget titleContent}) {
    return IgnorePointer(
      ignoring: !enabled,
      child: Column(
        children: [
          _buildTitle(context: context, additionalInfo: additionalInfo, titleContent: titleContent),
          if (description != null)
            _buildDescription(
                context: context, additionalInfo: additionalInfo, description: description),
        ],
      ),
    );
  }

  Widget _buildDescription(
      {required BuildContext context,
      required SettingsTileAdditionalInfo additionalInfo,
      required Widget description}) {
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
      child: description,
    );
  }

  Widget _buildTitle(
      {required BuildContext context,
      required SettingsTileAdditionalInfo additionalInfo,
      required Widget titleContent}) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(
        top: additionalInfo.enableTopBorderRadius ? const Radius.circular(12) : Radius.zero,
        bottom: additionalInfo.enableBottomBorderRadius ? const Radius.circular(12) : Radius.zero,
      ),
      child: Material(
        color: Colors.transparent,
        child: titleContent,
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
  bool updateShouldNotify(SettingsTileAdditionalInfo oldWidget) => true;

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
