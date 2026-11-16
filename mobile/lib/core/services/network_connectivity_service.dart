import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkConnectivityService {
  NetworkConnectivityService({
    String? lookupHost,
    this.checkInterval = const Duration(seconds: 25),
  }) : _lookupHost = lookupHost ?? 'google.com';

  final String _lookupHost;
  final Duration checkInterval;

  final ValueNotifier<bool> isOnlineNotifier = ValueNotifier<bool>(true);
  bool get isOnline => isOnlineNotifier.value;

  Timer? _timer;
  bool _isChecking = false;

  void startMonitoring() {
    _timer?.cancel();
    checkConnection();
    _timer = Timer.periodic(checkInterval, (_) => checkConnection());
  }

  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
  }

  Future<bool> checkConnection() async {
    if (_isChecking) return isOnline;
    _isChecking = true;
    try {
      final result = await InternetAddress.lookup(_lookupHost)
          .timeout(const Duration(seconds: 4));
      final connected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (isOnlineNotifier.value != connected) {
        isOnlineNotifier.value = connected;
      }
      return connected;
    } catch (_) {
      if (isOnlineNotifier.value != false) {
        isOnlineNotifier.value = false;
      }
      return false;
    } finally {
      _isChecking = false;
    }
  }

  void setOnline(bool online) {
    if (isOnlineNotifier.value != online) {
      isOnlineNotifier.value = online;
    }
  }

  void dispose() {
    stopMonitoring();
    isOnlineNotifier.dispose();
  }
}
