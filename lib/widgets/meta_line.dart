import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MetaLine extends StatelessWidget {
  const MetaLine({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 8),
        Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.5)),
      ],
    );
  }
}
