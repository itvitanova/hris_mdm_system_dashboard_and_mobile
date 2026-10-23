import 'package:flutter/material.dart';
import 'core/api_client.dart';
import 'core/workspace.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';
import 'features/attendance/face_enrollment_screen.dart';
import 'shared/widgets.dart';

class HrisApp extends StatefulWidget {
  const HrisApp({super.key, required this.api});
  final ApiClient api;
  @override
  State<HrisApp> createState() => _HrisAppState();
}

class _HrisAppState extends State<HrisApp> {
  final navigator = GlobalKey<NavigatorState>();
  bool booting = true, signedIn = false;
  String? startupError;
  @override
  void initState() {
    super.initState();
    widget.api.onUnauthorized = () {
      navigator.currentState?.popUntil((route) => route.isFirst);
      if (mounted) setState(() => signedIn = false);
    };
    restore();
  }

  @override
  void dispose() {
    widget.api.onUnauthorized = null;
    super.dispose();
  }

  Future<void> restore() async {
    setState(() {
      booting = true;
      startupError = null;
    });
    try {
      signedIn = await widget.api.restore();
    } catch (_) {
      startupError = 'Penyimpanan sesi tidak dapat dibuka. Silakan coba lagi.';
    }
    if (mounted) setState(() => booting = false);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'MDM HR',
    navigatorKey: navigator,
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: brand, primary: brand),
      scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F7FB),
        foregroundColor: Color(0xFF142541),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDCE3EE)),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ),
    home: booting
        ? const Scaffold(body: Center(child: CircularProgressIndicator()))
        : startupError != null
        ? Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(startupError!),
                  TextButton(
                    onPressed: restore,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          )
        : signedIn
        ? WorkspaceLoader(
            api: widget.api,
            onLogout: () => setState(() => signedIn = false),
          )
        : LoginScreen(
            api: widget.api,
            onLogin: () => setState(() => signedIn = true),
          ),
  );
}

class WorkspaceLoader extends StatefulWidget {
  const WorkspaceLoader({super.key, required this.api, required this.onLogout});
  final ApiClient api;
  final VoidCallback onLogout;
  @override
  State<WorkspaceLoader> createState() => _WorkspaceLoaderState();
}

class _WorkspaceLoaderState extends State<WorkspaceLoader> {
  Workspace? data;
  String? error;
  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    try {
      final next = Workspace(await widget.api.workspace());
      if (mounted) {
        setState(() {
          data = next;
          error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString());
        if (data != null) notify(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) => data != null
      ? data!.employee['faceEnrolled'] != true
            ? FaceEnrollmentScreen(
                api: widget.api,
                workspace: data!,
                onRefresh: refresh,
                onLogout: widget.onLogout,
              )
            : HomeScreen(
                api: widget.api,
                workspace: data!,
                onRefresh: refresh,
                onLogout: widget.onLogout,
              )
      : Scaffold(
          appBar: AppBar(title: const Text('MDM HR')),
          body: Center(
            child: error == null
                ? const CircularProgressIndicator()
                : Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: refresh,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
          ),
        );
}
