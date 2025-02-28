import 'package:flutter/material.dart';
import 'package:viddroid/views/search_view.dart';
import 'package:viddroid/views/settings_view.dart';
import 'package:viddroid/widgets/watchables_list_widget.dart';

class MainView extends StatefulWidget {
  final String title;

  const MainView({super.key, required this.title});

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
        body: WatchablesList(List.empty()));
  }
}
