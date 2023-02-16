import 'package:flutter/cupertino.dart';

/// Taken from: https://github.com/fluttercommunity/chewie/blob/master/lib/src/models/option_item.dart
/// The chewie project is licensed unter the MIT license.
/// All credit goes to the authors.
///
class OptionItem {
  OptionItem({
    required this.onTap,
    required this.iconData,
    required this.title,
    this.subtitle,
  });

  Function()? onTap;
  IconData iconData;
  String title;
  String? subtitle;

  OptionItem copyWith({
    Function()? onTap,
    IconData? iconData,
    String? title,
    String? subtitle,
  }) {
    return OptionItem(
      onTap: onTap ?? this.onTap,
      iconData: iconData ?? this.iconData,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
    );
  }

  @override
  String toString() =>
      'OptionItem(onTap: $onTap, iconData: $iconData, title: $title, subtitle: $subtitle)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OptionItem &&
        other.onTap == onTap &&
        other.iconData == iconData &&
        other.title == title &&
        other.subtitle == subtitle;
  }

  @override
  int get hashCode => onTap.hashCode ^ iconData.hashCode ^ title.hashCode ^ subtitle.hashCode;
}
