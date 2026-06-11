import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'logic/i18n.dart';
import 'logic/store.dart';
import 'overlay/overlay_app.dart';
import 'screens/home_screen.dart';
import 'screens/other_screens.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const ConsentLensApp());
}

/// Entry point for the popup engine, started by OverlayController (Kotlin)
/// inside a TYPE_APPLICATION_OVERLAY window.
@pragma('vm:entry-point')
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OverlayApp());
}

class ConsentLensApp extends StatelessWidget {
  const ConsentLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ConsentLens',
      debugShowCheckedModeBanner: false,
      theme: consentLensTheme(),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  int _currentIndex = 0;
  String _lang = 'en';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadLang();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _loadLang();
  }

  Future<void> _loadLang() async {
    final lang = await Store.language();
    if (mounted && lang != _lang) setState(() => _lang = lang);
  }

  void _onLanguageChanged(String lang) => setState(() => _lang = lang);

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        lang: _lang,
        onNavigateToPermissions: () => setState(() => _currentIndex = 1),
      ),
      PermissionsScreen(lang: _lang),
      HistoryScreen(lang: _lang),
      SettingsScreen(lang: _lang, onLanguageChanged: _onLanguageChanged),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE8E8E8))),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.security_rounded),
              label: S.protect.of(_lang),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.lock_rounded),
              label: S.permissions.of(_lang),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.history_rounded),
              label: S.history.of(_lang),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_rounded),
              label: S.settings.of(_lang),
            ),
          ],
        ),
      ),
    );
  }
}
