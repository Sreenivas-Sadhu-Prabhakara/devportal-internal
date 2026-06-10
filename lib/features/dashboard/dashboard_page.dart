import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../utils/format.dart';
import '../../widgets/content_area.dart';
import '../../widgets/page_header.dart';
import 'dashboard_cubit.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.status == DashboardStatus.loading) {
          return const SizedBox(
              height: 600, child: Center(child: CircularProgressIndicator()));
        }
        if (state.status == DashboardStatus.error || state.analytics == null) {
          return _error(state.error);
        }
        final a = state.analytics!;
        final statusTotal =
            a.statusBreakdown.fold<double>(0, (s, p) => s + p.value);
        return ContentArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Operations',
                subtitle: 'Org-wide health across all API products and apps.',
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                      child: MetricTile(
                          label: 'API calls (14d)',
                          value: formatCompact(a.totalCalls),
                          icon: Icons.show_chart_rounded,
                          delta: '+9.3%')),
                  const SizedBox(width: 16),
                  Expanded(
                      child: MetricTile(
                          label: 'Active apps',
                          value: '${a.activeApps}',
                          icon: Icons.apps_rounded,
                          delta: '+4')),
                  const SizedBox(width: 16),
                  Expanded(
                      child: MetricTile(
                          label: 'Developers',
                          value: '${a.totalDevelopers}',
                          icon: Icons.people_alt_rounded,
                          delta: '+2')),
                  const SizedBox(width: 16),
                  Expanded(
                      child: MetricTile(
                          label: 'Error rate',
                          value: '${a.errorRatePct.toStringAsFixed(2)}%',
                          icon: Icons.error_outline_rounded,
                          deltaPositive: false,
                          delta: '+0.1%')),
                ],
              ),
              const SizedBox(height: 16),
              _PendingCard(count: state.pendingApprovals),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: _panel(
                      context,
                      'Org traffic — last 14 days',
                      MiniAreaChart(
                          values: a.traffic.map((p) => p.value).toList(),
                          height: 200),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: _panel(
                      context,
                      'Status codes',
                      Column(
                        children: [
                          for (final s in a.statusBreakdown)
                            StatBar(
                              label: s.label,
                              fraction:
                                  statusTotal == 0 ? 0 : s.value / statusTotal,
                              trailing: formatCompact(s.value),
                              color: s.label.startsWith('2')
                                  ? AppColors.success
                                  : s.label.startsWith('4')
                                      ? AppColors.warn
                                      : AppColors.danger,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _TopList(title: 'Top products', items: a.topProducts)),
                  const SizedBox(width: 16),
                  Expanded(child: _TopList(title: 'Top apps', items: a.topApps)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _panel(BuildContext context, String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _error(String message) => SizedBox(
        height: 500,
        child: Center(
          child: Text('Failed to load dashboard\n$message',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textFaint)),
        ),
      );
}

class _PendingCard extends StatelessWidget {
  const _PendingCard({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final has = count > 0;
    return GestureDetector(
      onTap: () => context.go('/approvals'),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: has
                ? AppColors.warn.withValues(alpha: 0.1)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
                color: has
                    ? AppColors.warn.withValues(alpha: 0.4)
                    : AppColors.line),
          ),
          child: Row(
            children: [
              Icon(has ? Icons.fact_check_rounded : Icons.check_circle_rounded,
                  color: has ? AppColors.warn : AppColors.success, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  has
                      ? '$count app ${count == 1 ? 'request is' : 'requests are'} awaiting approval'
                      : 'No pending approvals',
                  style: const TextStyle(
                      color: AppColors.textHi,
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const Text('Review',
                  style: TextStyle(
                      color: AppColors.textMid, fontWeight: FontWeight.w600)),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textMid),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopList extends StatelessWidget {
  const _TopList({required this.title, required this.items});
  final String title;
  final List<TopItem> items;

  @override
  Widget build(BuildContext context) {
    final max = items.isEmpty
        ? 1
        : items.map((e) => e.calls).reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          for (final item in items)
            StatBar(
              label: '',
              fraction: item.calls / max,
              trailing: formatCompact(item.calls),
              color: AppColors.accent,
            ).withName(item.name),
        ],
      ),
    );
  }
}

/// Small helper to render a named row above a StatBar (keeps StatBar generic).
extension on Widget {
  Widget withName(String name) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 2),
              child: Text(name,
                  style: const TextStyle(
                      color: AppColors.textMid,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600)),
            ),
            this,
          ],
        ),
      );
}
