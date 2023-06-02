import 'package:flutter/material.dart';

import '../util/watchable/watchable.dart';

class WatchablesList extends StatelessWidget {
  final List<Watchable> _list;

  const WatchablesList(this._list, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //TODO: Watchable list
    final Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height / 1.2,
      width: size.width,
      child: GridView.count(
        primary: false,
        padding: const EdgeInsets.all(20),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: 4,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.teal[400],
            child: const Text('This main page is work in progress. Bookmarked media will be displayed here.'),
          ),
        ],
      ),
    );
  }
}
