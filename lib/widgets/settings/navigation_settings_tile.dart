import 'package:flutter/cupertino.dart';

class NavigationSettingsTile extends StatelessWidget {
  final Widget? value;

  const NavigationSettingsTile({super.key, this.value});

  @override
  Widget build(BuildContext context) {
    final scaleFactor = MediaQuery.of(context).textScaleFactor;

    return Row(
      children: [
        if (value != null)
          DefaultTextStyle(
            style: const TextStyle(
              fontSize: 17,
            ),
            child: value!,
          ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 6, end: 2),
          child: Icon(
            CupertinoIcons.chevron_forward,
            size: 18 * scaleFactor,
          ),
        )
      ],
    );
  }
}
