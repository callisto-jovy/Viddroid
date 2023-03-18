import 'package:flutter/material.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:viddroid_flutter_desktop/util/custom_scroll_behaviour.dart';
import 'package:viddroid_flutter_desktop/util/setting/settings.dart';
import 'package:viddroid_flutter_desktop/views/main_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Settings().init();
  await localNotifier.setup(
    appName: 'Viddroid',
    // The parameter shortcutPolicy only works on Windows
    shortcutPolicy: ShortcutPolicy.requireCreate,
  );
  runApp(const MyApp());
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
        colorSchemeSeed: Colors.blueGrey,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.blueGrey,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      scrollBehavior: CustomScrollBehaviour(),
      home: const MainView(title: 'Viddroid'),
    );
  }
}
