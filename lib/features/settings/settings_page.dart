import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';

import '../../widgets/content_area.dart';
import '../../widgets/page_header.dart';

/// Settings stub — governance/policy controls land in a later phase.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentArea(
      maxWidth: 880,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: 'Settings',
            subtitle: 'Platform configuration and governance policy.',
          ),
          const SizedBox(height: 28),
          _section('Approval policy', [
            _toggleRow('Auto-approve public products', true),
            _toggleRow('Require review for partner products', true),
            _toggleRow('Require review for internal products', true),
          ]),
          const SizedBox(height: 16),
          _section('Identity', [
            _infoRow('Provider', 'ForgeRock (OIDC) — wired in Phase 4'),
            _infoRow('Internal access', 'Corporate SSO'),
          ]),
          const SizedBox(height: 16),
          _section('Monetization', [
            _infoRow('Status', 'Planned (later phase)'),
            _infoRow('Billing', 'Not enabled'),
          ]),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.canvasAlt,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(color: AppColors.line),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.textFaint),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'These controls are illustrative in the mock. They become live policy '
                    'when the Drupal/Apigee backend is connected.',
                    style: TextStyle(color: AppColors.textFaint, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
            child: Text(title,
                style: const TextStyle(
                    color: AppColors.textHi,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
          ),
          for (var i = 0; i < rows.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: rows[i],
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _toggleRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.textMid, fontSize: 14))),
          // Static (illustrative) switch.
          Container(
            width: 40,
            height: 22,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: value ? AppColors.accent : AppColors.surfaceHover,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Align(
              alignment:
                  value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: AppColors.textMid, fontSize: 14))),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textFaint, fontSize: 13.5)),
        ],
      ),
    );
  }
}
