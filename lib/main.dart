import 'package:flutter/material.dart';
import 'package:viddroid_flutter_desktop/util/custom_scroll_behaviour.dart';
import 'package:viddroid_flutter_desktop/views/main_view.dart';
import 'package:viddroid_flutter_desktop/watchable/watchables.dart';

void main() {
  Watchables().init().then((value) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viddroid Desktop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.amber,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.amber,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      scrollBehavior: CustomScrollBehaviour(),
      home: const MainView(title: 'Viddroid'),
    );
  }
}
