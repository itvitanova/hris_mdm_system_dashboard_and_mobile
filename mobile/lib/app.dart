import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'features/root/presentation/pages/root_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/api_client.dart';
import 'core/di/injection_container.dart';
import 'core/workspace.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/home/presentation/bloc/workspace_bloc.dart';
import 'features/attendance/face_enrollment_screen.dart';
import 'features/attendance/presentation/bloc/attendance_bloc.dart';
import 'features/requests/presentation/bloc/request_bloc.dart';
import 'features/payroll/presentation/bloc/payroll_bloc.dart';
import 'shared/widgets.dart';
import 'shared/theme.dart';

class HrisApp extends StatefulWidget {
  const HrisApp({super.key, required this.api});
  final ApiClient api;

  @override
  State<HrisApp> createState() => _HrisAppState();
}

class _HrisAppState extends State<HrisApp> {
  final navigator = GlobalKey<NavigatorState>();
  late final AuthBloc _authBloc;
  late final WorkspaceBloc _workspaceBloc;
  late final AttendanceBloc _attendanceBloc;
  late final RequestBloc _requestBloc;
  late final PayrollBloc _payrollBloc;

  @override
  void initState() {
    super.initState();
    if (!sl.isRegistered<ApiClient>()) {
      initDependencies(customApiClient: widget.api);
    }
    _authBloc = sl<AuthBloc>()..add(const AuthCheckRequested());
    _workspaceBloc = sl<WorkspaceBloc>();
    _attendanceBloc = sl<AttendanceBloc>();
    _requestBloc = sl<RequestBloc>();
    _payrollBloc = sl<PayrollBloc>();

    widget.api.onUnauthorized = () {
      navigator.currentState?.popUntil((route) => route.isFirst);
      if (_authBloc.state is Authenticated) {
        _authBloc.add(const AuthLogoutRequested());
      }
    };
  }

  @override
  void dispose() {
    widget.api.onUnauthorized = null;
    _authBloc.close();
    _workspaceBloc.close();
    _attendanceBloc.close();
    _requestBloc.close();
    _payrollBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider<AuthBloc>.value(value: _authBloc),
      BlocProvider<WorkspaceBloc>.value(value: _workspaceBloc),
      BlocProvider<AttendanceBloc>.value(value: _attendanceBloc),
      BlocProvider<RequestBloc>.value(value: _requestBloc),
      BlocProvider<PayrollBloc>.value(value: _payrollBloc),
    ],
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) => MaterialApp(
      title: 'MDM HR',
      navigatorKey: navigator,
      debugShowCheckedModeBanner: false,
      theme: hrisTheme(),
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthBooting || state is AuthInitial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (state is Unauthenticated && state.message != null) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message!),
                    TextButton(
                      onPressed: () =>
                          context.read<AuthBloc>().add(const AuthCheckRequested()),
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is Authenticated) {
            return WorkspaceLoader(
              key: const ValueKey('workspace_loader'),
              api: widget.api,
              onLogout: () =>
                  context.read<AuthBloc>().add(const AuthLogoutRequested()),
            );
          }

          return LoginScreen(
            key: const ValueKey('login_screen'),
            api: widget.api,
            onLogin: () =>
                context.read<AuthBloc>().add(const AuthCheckRequested()),
          );
        },
      ),
    ),
    ),
  );
}

class WorkspaceLoader extends StatefulWidget {
  const WorkspaceLoader({
    super.key,
    required this.api,
    required this.onLogout,
  });

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
          : RootPage(
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
