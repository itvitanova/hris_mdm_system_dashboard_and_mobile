import 'dart:async';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import '../../../attendance/presentation/pages/attendance_page.dart';
import '../../../requests/presentation/pages/request_detail_page.dart';
import '../../../requests/presentation/pages/request_notifications_page.dart';
import '../widgets/dashboard_tab.dart';
import '../widgets/language_swap_button.dart';
import '../widgets/payroll_tab.dart';
import '../widgets/profile_tab.dart';
import '../widgets/requests_tab.dart';
import '../widgets/root_nav_bar_items.dart';

class RootPage extends StatefulWidget {
  const RootPage({
    super.key,
    required this.api,
    required this.workspace,
    required this.onRefresh,
    required this.onLogout,
  });

  final ApiClient api;
  final Workspace workspace;
  final Future<void> Function() onRefresh;
  final VoidCallback onLogout;

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with WidgetsBindingObserver {
  late final PersistentTabController _controller;
  bool _refreshing = false;
  Timer? _refreshTimer;

  Workspace get w => widget.workspace;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
    AppLanguageController.instance.addListener(_handleLanguageChange);

    WidgetsBinding.instance.addObserver(this);
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        unawaited(_refreshVisible());
      }
    });
  }

  void _handleLanguageChange() {
    if (mounted) setState(() {});
  }

  Future<void> _refreshVisible() async {
    if (!mounted || _refreshing) return;
    _refreshing = true;
    try {
      await widget.onRefresh();
    } finally {
      _refreshing = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshVisible());
    }
  }

  @override
  void dispose() {
    AppLanguageController.instance.removeListener(_handleLanguageChange);
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  Future<void> open(Widget screen) async {
    final changed = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(builder: (_) => screen),
    );
    if (mounted &&
        (changed == true ||
            screen is AttendanceScreen ||
            screen is ApprovalsScreen ||
            screen is RequestDetailScreen ||
            screen is RequestNotificationsScreen)) {
      await widget.onRefresh();
    }
  }

  List<Widget> _screens() => [
    DashboardTab(
      api: widget.api,
      workspace: widget.workspace,
      onRefresh: widget.onRefresh,
      open: open,
    ),
    RequestsTab(
      api: widget.api,
      workspace: widget.workspace,
      onRefresh: widget.onRefresh,
      open: open,
    ),
    ApprovalsScreen(
      api: widget.api,
    ),
    PayrollTab(
      api: widget.api,
      workspace: widget.workspace,
      onRefresh: widget.onRefresh,
      open: open,
    ),
    ProfileTab(
      api: widget.api,
      workspace: widget.workspace,
      onRefresh: widget.onRefresh,
      onLogout: widget.onLogout,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _screens(),
      items: RootNavBarItems.build(workspace: widget.workspace),
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      navBarStyle: NavBarStyle.style1,
    );
  }
}
