import 'package:flutter/material.dart';
import 'package:viddroid_flutter_desktop/views/search_view.dart';
import 'package:viddroid_flutter_desktop/views/settings_view.dart';
import 'package:viddroid_flutter_desktop/widgets/watchables_list_widget.dart';

import '../util/watchable/watchables.dart';

class MainView extends StatefulWidget {
  final String title;

  const MainView({Key? key, required this.title}) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  List<Widget> _buildButtons() {
    return [
      IconButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SearchView(),
          ),
        ),
        icon: const Icon(Icons.search_sharp),
        tooltip: 'Search for media.',
      ),
      IconButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingsView(),
          ),
        ),
        icon: const Icon(Icons.settings),
        tooltip: 'Settings.',
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: _buildButtons(),
      ),
      body: Column(
        children: [WatchablesList(Watchables().watchables)],
      ),
    );
  }
}
