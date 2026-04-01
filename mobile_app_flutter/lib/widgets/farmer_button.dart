/// Large, farmer-friendly button with icon, label, and optional subtitle.
import 'package:flutter/material.dart';
import '../config/theme.dart';

class FarmerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;
  final bool isLarge;

  const FarmerButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.subtitle,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isLarge ? 20 : 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(isLarge ? 20 : 16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isLarge ? 16 : 12),
              decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: isLarge ? 32 : 26),
            ),
            SizedBox(height: isLarge ? 14 : 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isLarge ? 14 : 11,
                fontWeight: FontWeight.w600,
                color: color,
                height: 1.3,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: AppTheme.textHint),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
