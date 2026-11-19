import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../bloc/request_bloc.dart';
import '../bloc/request_event.dart';
import '../widgets/detail/detail_app_bar.dart';
import '../widgets/detail/detail_content_list.dart';
import '../widgets/detail/detail_decision_handler.dart';
import '../widgets/detail/detail_share_service.dart';
import '../widgets/detail/detail_sticky_bottom_bar.dart';
import '../widgets/universal_request_card/universal_request_card.dart';
import 'approvals_page.dart';
import 'request_form_page.dart';

export 'approvals_page.dart';
export '../widgets/detail/detail_formatters.dart' show requestDateLabel;

class RequestDetailScreen extends StatefulWidget {
  const RequestDetailScreen({
    super.key,
    required this.api,
    required this.request,
    this.own = false,
  });

  final ApiClient api;
  final Json request;
  final bool own;

  @override
  State<RequestDetailScreen> createState() => _RequestDetailState();
}

class _RequestDetailState extends State<RequestDetailScreen> {
  late Json request = widget.request;
  bool busy = false, _changed = false;
  String? error;
  Workspace? _workspace;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchFreshRequest();
      await markSeen();
    });
  }

  Future<void> _fetchFreshRequest({bool force = false}) async {
    try {
      final w = Workspace(await widget.api.workspace());
      final matches = w.rows('requests').where((r) => r['id'] == request['id']);
      if (matches.isNotEmpty && mounted) {
        setState(() { _workspace = w; request = matches.first; error = null; });
      } else if (force && matches.isEmpty) {
        throw ApiException('Pengajuan tidak ditemukan atau akses sudah berubah.');
      } else if (mounted) {
        setState(() => _workspace = w);
      }
    } catch (e) {
      if (force && mounted) setState(() => error = e.toString());
    }
  }

  Future<void> markSeen() async {
    final token = text(request, 'updateToken', '');
    if (!widget.own || request['unread'] != true || token.length != 64) return;
    try {
      try {
        context.read<RequestBloc>().add(
          RequestMarkSeenRequested(id: text(request, 'id'), token: token));
      } catch (_) {}
      await widget.api.post(
        '/requests/${Uri.encodeComponent(text(request, 'id'))}/seen', {'token': token});
      if (mounted) setState(() => request = {...request, 'unread': false});
    } catch (_) {}
  }

  Future<void> refresh() async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await _fetchFreshRequest(force: true);
      await markSeen();
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  List<Json> records(dynamic v) =>
      ((v as List?) ?? []).map((x) => Json.from(x as Map)).toList();

  Future<void> decide(String decision) async {
    final updated = await DetailDecisionHandler.handleDecision(
      context: context,
      api: widget.api,
      request: request,
      decision: decision,
      setBusy: (b) => setState(() => busy = b),
      setError: (e) => setState(() => error = e),
    );
    if (updated != null && mounted) {
      _changed = true;
      setState(() => request = updated);
      await _fetchFreshRequest();
    }
  }

  Future<void> share(String path, String name) async {
    setState(() { busy = true; error = null; });
    try {
      await DetailShareService.shareDocument(
        context: context, api: widget.api, request: request, path: path, name: name);
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = request, id = Uri.encodeComponent(text(r, 'id'));
    final snapshot = Json.from((r['snapshot'] as Map?) ?? {});
    final model = UniversalRequestModel.fromMap(r);
    final kindConfig = RequestCardHelper.getKindConfig(model);
    final statusConfig = RequestCardHelper.getStatusConfig(model.status, model.kind);
    final amount = number(r, 'amount'), steps = records(r['steps']);

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) => PopScope<bool>(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) Navigator.of(context).pop(_changed);
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: DetailAppBar(
            typeTitle: kindConfig.typeTitle,
            busy: busy,
            onBack: () => Navigator.of(context).pop(_changed),
            onRefresh: refresh,
          ),
          body: SafeArea(
            child: RefreshIndicator(
              color: const Color(0xFF0F766E),
              onRefresh: refresh,
              child: DetailContentList(
                api: widget.api,
                r: r,
                snapshot: snapshot,
                workspace: _workspace,
                model: model,
                kindConfig: kindConfig,
                statusConfig: statusConfig,
                amount: amount,
                hasAmount: amount > 0,
                hours: (r['hours'] as num?)?.toInt(),
                days: (r['days'] as num?)?.toInt(),
                items: records(r['items']),
                steps: steps,
                busy: busy,
                error: error,
              ),
            ),
          ),
          bottomNavigationBar: DetailStickyBottomBar(
            api: widget.api,
            r: r,
            steps: steps,
            id: id,
            own: widget.own,
            busy: busy,
            onDecide: decide,
            onShare: share,
            onFixRequest: () async {
              final nav = Navigator.of(context);
              final changed = await nav.push<bool>(
                MaterialPageRoute(
                  builder: (_) => RequestForm(api: widget.api, initialRequest: r),
                ),
              );
              if (changed == true && mounted) nav.pop(true);
            },
          ),
        ),
      ),
    );
  }
}

typedef RequestDetailPage = RequestDetailScreen;
typedef ApprovalsPage = ApprovalsScreen;
