import 'package:dpad_container/dpad_container.dart';
import 'package:flutter/material.dart';
import 'package:viddroid/views/search_view.dart';
import 'package:viddroid/views/settings_view.dart';
import 'package:viddroid/widgets/watchables_list_widget.dart';

class AndroidMainView extends StatefulWidget {
  final String title;

  const AndroidMainView({Key? key, required this.title}) : super(key: key);

  @override
  State<AndroidMainView> createState() => _AndroidMainViewState();
}

class _AndroidMainViewState extends State<AndroidMainView> {
  List<Widget> _buildButtons() {
    return [
      DpadContainer(
        onClick: () => _pushRoute(const SearchView()),
        onFocus: (isFocused) {},
        child:  IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {},
          tooltip: 'Search for media.',
        ),
      ),
      DpadContainer(
        onClick: () => _pushRoute(const SettingsView()),
        onFocus: (isFocused) {},
        child: IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {},
          tooltip: 'Settings.',
        ),
      ),
    ];
  }

  void _pushRoute(final StatefulWidget route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => route,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: _buildButtons(),
        ),
        body: WatchablesList(List.empty()));
  }
}
