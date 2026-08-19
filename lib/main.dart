import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:google_fonts/google_fonts.dart';

import 'theme.dart';
import 'pomodoro_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const options = WindowOptions(
    size: Size(650, 750),
    minimumSize: Size(420, 560),
    center: true,
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
  );

  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.setAsFrameless();
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const PomodoroApp());
}

class PomodoroApp extends StatelessWidget {
  const PomodoroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodoro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.manropeTextTheme(),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(seedColor: secondaryColor),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(scrollbarColor),
          thickness: WidgetStateProperty.all(8),
          radius: const Radius.circular(4),
        ),
      ),
      home: const ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(windowRadius)),
        child: PomodoroPage(),
      ),
    );
  }
}
