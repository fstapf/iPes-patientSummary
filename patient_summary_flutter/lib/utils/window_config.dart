import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// Configuração de janela apenas para desktop
Future<void> configureWindow() async {
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1920, 1080),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setTitle('SPDATA SGH - PatientSummary - iPes');
    await windowManager.maximize();
    await windowManager.show();
    await windowManager.focus();
  });
}
