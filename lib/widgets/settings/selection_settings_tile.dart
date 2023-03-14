import 'package:flutter/material.dart';

import '../../util/capsules/option_item.dart';

class SelectionSettingsTile extends StatefulWidget {
  final Widget title;
  final Widget? description;
  final Widget? leading;
  final Widget? trailing;

  final List<OptionItem> items;
  final Function()? onTap;

  const SelectionSettingsTile(
      {Key? key,
      required this.items,
      this.onTap,
      required this.title,
      this.description,
      this.leading,
      this.trailing})
      : super(key: key);

  @override
  State<SelectionSettingsTile> createState() => _SelectionSettingsTileState();
}

class _SelectionSettingsTileState extends State<SelectionSettingsTile> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        //TODO: Shape & custom expansion tile
        leading: widget.leading,
        trailing: widget.trailing,
        title: const Text('null'),
        subtitle: widget.description,

        children: widget.items
            .map((e) => InkWell(
                  onTap: e.onTap,
                  child: ListTile(
                    title: Text(e.title),
                    leading: Icon(e.iconData),
                  ),
                ))
            .toList(),
      ),
    );
  }
}
