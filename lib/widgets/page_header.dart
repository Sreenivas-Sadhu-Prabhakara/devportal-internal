import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.displaySmall),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(subtitle!,
                    style: const TextStyle(
                        color: AppColors.textLo, fontSize: 16)),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 24), trailing!],
      ],
    );
  }
}
