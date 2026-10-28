import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../attendance/attendance_screen.dart';
import '../../../requests/request_detail.dart';
import '../../../requests/request_notifications.dart';
import '../widgets/dashboard_tab.dart';
import '../widgets/requests_tab.dart';
import '../widgets/payroll_tab.dart';
import '../widgets/profile_tab.dart';

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

    WidgetsBinding.instance.addObserver(this);
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
        unawaited(_refreshVisible());
      }
    });
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

  Widget _tabIcon({
    required Widget svg,
    required String label,
    int? badgeCount,
  }) {
    final content = Stack(
      alignment: Alignment.center,
      children: [
        svg,
        SizedBox(
          width: 0,
          height: 0,
          child: OverflowBox(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 0.001,
                color: Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    );

    if (badgeCount != null && badgeCount > 0) {
      return Badge.count(count: badgeCount, child: content);
    }
    return content;
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    final unreadCount = widget.workspace
        .mine('requests')
        .where((r) => r['unread'] == true)
        .length;

    final pendingApprovals = widget.workspace
        .rows('requests')
        .where((r) => r['canReview'] == true)
        .length;

    return [
      PersistentBottomNavBarItem(
        icon: _tabIcon(
          svg: SvgPicture.asset(
            'assets/icon/home-2.svg',
            colorFilter: const ColorFilter.mode(AppColors.deepTeal, BlendMode.srcIn),
          ),
          label: 'Beranda',
        ),
        inactiveIcon: _tabIcon(
          svg: SvgPicture.asset(
            'assets/icon/home-2-not-active.svg',
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
          label: 'Beranda',
        ),
        title: 'Beranda',
        textStyle: AppTextStyles.inter12MediumDeepTeal,
        activeColorPrimary: AppColors.deepTeal,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: _tabIcon(
          svg: SvgPicture.asset(
            'assets/icon/note-add-active.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(AppColors.deepTeal, BlendMode.srcIn),
          ),
          label: 'Pengajuan',
          badgeCount: unreadCount,
        ),
        inactiveIcon: _tabIcon(
          svg: SvgPicture.asset(
            'assets/icon/note-add.svg',
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
          label: 'Pengajuan',
          badgeCount: unreadCount,
        ),
        title: 'Pengajuan',
        textStyle: AppTextStyles.inter12MediumDeepTeal,
        activeColorPrimary: AppColors.deepTeal,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: _tabIcon(
          svg: SvgPicture.asset(
            'assets/icon/message-time-active-new.svg',
            width: 24,
            height: 24,
          ),
          label: 'Persetujuan',
          badgeCount: pendingApprovals,
        ),
        inactiveIcon: _tabIcon(
          svg: SvgPicture.asset(
            'assets/icon/message-time.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
          label: 'Persetujuan',
          badgeCount: pendingApprovals,
        ),
        title: 'Persetujuan',
        textStyle: AppTextStyles.inter12MediumDeepTeal,
        activeColorPrimary: AppColors.deepTeal,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: _tabIcon(
          svg: SvgPicture.asset(
            'assets/icon/empty-wallet-active.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(AppColors.deepTeal, BlendMode.srcIn),
          ),
          label: 'Slip gaji',
        ),
        inactiveIcon: _tabIcon(
          svg: SvgPicture.asset(
            'assets/icon/empty-wallet.svg',
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
          label: 'Slip gaji',
        ),
        title: 'Slip gaji',
        textStyle: AppTextStyles.inter12MediumDeepTeal,
        activeColorPrimary: AppColors.deepTeal,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: _tabIcon(
          svg: SvgPicture.asset(
            'assets/icon/profile.svg',
            colorFilter: const ColorFilter.mode(AppColors.deepTeal, BlendMode.srcIn),
          ),
          label: 'Profil',
        ),
        inactiveIcon: _tabIcon(
          svg: SvgPicture.asset(
            'assets/icon/profile-not-active.svg',
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
          label: 'Profil',
        ),
        title: 'Profil',
        textStyle: AppTextStyles.inter12MediumDeepTeal,
        activeColorPrimary: AppColors.deepTeal,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _screens(),
      items: _navBarsItems(),
      backgroundColor: Colors.white,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      stateManagement: true,
      navBarStyle: NavBarStyle.style1,
    );
  }
}
