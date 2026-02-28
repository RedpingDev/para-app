import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // flutterfire configure 실행 후 자동 생성
import 'core/theme/app_theme.dart';
import 'providers/para_providers.dart';
import 'features/auth/login_screen.dart';
import 'shared/layouts/main_layout.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/projects/projects_screen.dart';
import 'features/areas/areas_screen.dart';
import 'features/resources/resources_screen.dart';
import 'features/archive/archive_screen.dart';
import 'features/inbox/inbox_screen.dart';
import 'features/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── Firebase 초기화 ─────────────────────
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ── Window Manager 설정 (Desktop only) ──
  try {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(1280, 800),
      minimumSize: Size(900, 600),
      center: true,
      title: 'PARA Management System',
      titleBarStyle: TitleBarStyle.normal,
    );
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  } catch (_) {
    // 웹 환경에서는 window_manager 미사용
  }

  runApp(const ProviderScope(child: ParaApp()));
}

class ParaApp extends ConsumerWidget {
  const ParaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeModeProvider);
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'PARA Management System',
      debugShowCheckedModeBanner: false,
      theme: LightTheme.theme,
      darkTheme: DarkTheme.theme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: authState.when(
        data: (user) => user != null
            ? MainLayout(
                pages: const [
                  DashboardScreen(),
                  ProjectsScreen(),
                  AreasScreen(),
                  ResourcesScreen(),
                  ArchiveScreen(),
                  InboxScreen(),
                  SettingsScreen(),
                ],
              )
            : const LoginScreen(),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, __) => const LoginScreen(),
      ),
    );
  }
}
