import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/notification_provider.dart';
import '../../core/locale.dart';
import '../../config/theme.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _getIconForType(String type) {
    switch (type) {
      case 'market':
        return Icons.trending_up;
      case 'feature':
        return Icons.new_releases;
      case 'weather':
        return Icons.cloud;
      case 'alert':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'market':
        return Colors.blue;
      case 'feature':
        return Colors.purple;
      case 'weather':
        return Colors.orange;
      case 'alert':
        return Colors.red;
      default:
        return AppTheme.primaryGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEnglish = !Provider.of<AppLocale>(context).isKannada;
    final textStyle = isEnglish ? const TextStyle() : GoogleFonts.notoSansKannada();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppLocale.t(context, 'notifications'),
          style: textStyle.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Provider.of<NotificationProvider>(context, listen: false).markAllAsRead();
            },
            child: Text(
              AppLocale.t(context, 'mark_all_read'),
              style: textStyle.copyWith(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (provider.notifications.isEmpty) {
            return Center(
              child: Text(
                AppLocale.t(context, 'no_notifications'),
                style: textStyle.copyWith(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            itemCount: provider.notifications.length,
            itemBuilder: (context, index) {
              final item = provider.notifications[index];
              final isRead = item.isRead;

              return GestureDetector(
                onTap: () {
                  provider.markAsRead(item.id);
                  // In a real app, navigating based on type could happen here
                },
                child: Container(
                  color: isRead ? Colors.transparent : AppTheme.primaryGreen.withOpacity(0.05),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _getColorForType(item.type).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_getIconForType(item.type), color: _getColorForType(item.type)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: textStyle.copyWith(
                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                fontSize: 16,
                                color: isRead ? Colors.black87 : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.message,
                              style: textStyle.copyWith(
                                color: Colors.grey.shade700,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              DateFormat('MMM d, h:mm a').format(item.timestamp),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(top: 8),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
