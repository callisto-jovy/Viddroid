import 'dart:io';

import 'package:flutter/material.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:media_kit/media_kit.dart';
import 'package:viddroid/android_tv/main_view_android.dart';
import 'package:viddroid/util/custom_scroll_behaviour.dart';
import 'package:viddroid/util/setting/settings.dart';
import 'package:viddroid/util/watchable/watchables.dart';
import 'package:viddroid/views/main_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await Settings().init();
  await Watchables().init();
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
      home: Platform.isAndroid
          ? const AndroidMainView(title: 'Viddroid')
          : const MainView(title: 'Viddroid'),
    );
  }
}
