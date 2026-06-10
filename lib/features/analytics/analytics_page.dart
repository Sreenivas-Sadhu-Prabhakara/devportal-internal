import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/format.dart';
import '../../widgets/content_area.dart';
import '../../widgets/page_header.dart';
import 'analytics_cubit.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsCubit, OrgAnalyticsState>(
      builder: (context, state) {
        if (state.status == OrgAnalyticsStatus.loading) {
          return const SizedBox(
              height: 600, child: Center(child: CircularProgressIndicator()));
        }
        if (state.analytics == null) {
          return const SizedBox(
              height: 400,
              child: Center(child: Text('No analytics available')));
        }
        final a = state.analytics!;
        final statusTotal =
            a.statusBreakdown.fold<double>(0, (s, p) => s + p.value);
        return ContentArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Analytics',
                subtitle: 'Traffic, reliability and adoption across the platform.',
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                      child: MetricTile(
                          label: 'Total calls',
                          value: formatInt(a.totalCalls),
                          icon: Icons.stacked_line_chart_rounded)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: MetricTile(
                          label: 'Avg latency',
                          value: '${a.avgLatencyMs.round()} ms',
                          icon: Icons.bolt_rounded)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: MetricTile(
                          label: 'Error rate',
                          value: '${a.errorRatePct.toStringAsFixed(2)}%',
                          icon: Icons.error_outline_rounded,
                          deltaPositive: false)),
                  const SizedBox(width: 16),
                  Expanded(
                      child: MetricTile(
                          label: 'Active apps',
                          value: '${a.activeApps}',
                          icon: Icons.apps_rounded)),
                ],
              ),
              const SizedBox(height: 20),
              _panel(
                context,
                'Calls per day — last 14 days',
                MiniAreaChart(
                    values: a.traffic.map((p) => p.value).toList(), height: 240),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
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
                  const SizedBox(width: 16),
                  Expanded(child: _topPanel(context, 'Top products', a.topProducts)),
                  const SizedBox(width: 16),
                  Expanded(child: _topPanel(context, 'Top apps', a.topApps)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _panel(BuildContext context, String title, Widget child) => Container(
        width: double.infinity,
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

  Widget _topPanel(BuildContext context, String title, List<TopItem> items) {
    final max = items.isEmpty
        ? 1
        : items.map((e) => e.calls).reduce((a, b) => a > b ? a : b);
    return _panel(
      context,
      title,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items) ...[
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 2),
              child: Text(item.name,
                  style: const TextStyle(
                      color: AppColors.textMid,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
            StatBar(
              label: '',
              fraction: item.calls / max,
              trailing: formatCompact(item.calls),
              color: AppColors.accent,
            ),
          ],
        ],
      ),
    );
  }
}
