/// Offline banner shown at the top of screens when there's no internet.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/connectivity_service.dart';
import '../config/theme.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (_, connectivity, __) {
        if (connectivity.isOnline) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: AppTheme.warning,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 16, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'You are offline — showing cached data',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      },
    );
  }
}
