import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:viddroid_flutter_desktop/views/search_view.dart';
import 'package:viddroid_flutter_desktop/watchable/watchables.dart';
import 'package:viddroid_flutter_desktop/widgets/watchables_list_widget.dart';

class MainView extends StatefulWidget {
  final String title;

  const MainView({Key? key, required this.title}) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchView(),
              ),
            ),
            icon: const Icon(Icons.search_sharp),
            tooltip: 'Search for media.',
          )
        ],
      ),
      body: Column(
        children: [WatchablesList(Watchables().watchables)],
      ),
    );
  }
}
