import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:toko_plastik_rizky/core/theme/theme.dart';
import 'package:toko_plastik_rizky/presentation/dashboard/dashboard_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toko_plastik_rizky/core/l10n/l10n.dart';

void main() {
  runApp(const ProviderScope(child: TokoPlastikRizkyApp()));
}

class TokoPlastikRizkyApp extends StatelessWidget {
  const TokoPlastikRizkyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Toko Plastik Rizky',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id', 'ID')],
  home: const DashboardPage(),
    );
  }
}
