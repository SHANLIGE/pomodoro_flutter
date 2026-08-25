import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'app_shell.dart';
import 'theme.dart';
import 'widgets/pixel_box.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const options = WindowOptions(
    size: Size(1440, 1024),
    minimumSize: Size(920, 600),
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

  runApp(const MoriTaimuApp());
}

class MoriTaimuApp extends StatelessWidget {
  const MoriTaimuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mori Taimu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        colorScheme: ColorScheme.fromSeed(seedColor: green),
        scrollbarTheme: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(line),
          thickness: WidgetStateProperty.all(8),
          radius: Radius.zero,
        ),
      ),
      // Recorta la ventana con la silueta escalonada en vez de curvas.
      home: const ClipPath(
        clipper: PixelClipper(unit: 4),
        child: AppShell(),
      ),
    );
  }
}