/// Connectivity service to detect online/offline state.
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  StreamSubscription<ConnectivityResult>? _subscription;

  ConnectivityService() {
    _checkInitial();
    _subscription = Connectivity().onConnectivityChanged.listen(_update);
  }

  Future<void> _checkInitial() async {
    final result = await Connectivity().checkConnectivity();
    _update(result);
  }

  void _update(ConnectivityResult result) {
    final online = result != ConnectivityResult.none;
    if (_isOnline != online) {
      _isOnline = online;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
