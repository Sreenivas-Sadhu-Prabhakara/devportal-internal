import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/content_area.dart';
import '../../widgets/page_header.dart';
import 'approvals_cubit.dart';

class ApprovalsPage extends StatelessWidget {
  const ApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ApprovalsCubit, ApprovalsState>(
      listenWhen: (p, c) => p.lastDecision != c.lastDecision && c.lastDecision.isNotEmpty,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.surfaceRaised,
            content: Text(state.lastDecision),
          ),
        );
      },
      builder: (context, state) {
        return ContentArea(
          maxWidth: 980,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Approval queue',
                subtitle:
                    'App registrations against restricted (partner/internal) products await review here.',
              ),
              const SizedBox(height: 28),
              if (state.status == ApprovalsStatus.loading)
                const SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator()))
              else if (state.requests.isEmpty)
                _empty(context)
              else
                for (final req in state.requests)
                  _RequestCard(
                    req: req,
                    busy: state.busyId == req.id,
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _empty(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 72),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 40, color: AppColors.success),
          const SizedBox(height: 16),
          Text('Queue is clear',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('No app requests are waiting for review.',
              style: TextStyle(color: AppColors.textLo)),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.req, required this.busy});
  final ApprovalRequest req;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.warn.withValues(alpha: 0.16),
                ),
                child: const Icon(Icons.apps_rounded,
                    color: AppColors.warn, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(req.appName,
                        style: const TextStyle(
                            color: AppColors.textHi,
                            fontSize: 16,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text('${req.developerName} · ${req.developerEmail}',
                        style: const TextStyle(
                            color: AppColors.textFaint, fontSize: 13)),
                  ],
                ),
              ),
              Text('Requested ${req.requestedAt}',
                  style: const TextStyle(
                      color: AppColors.textFaint, fontSize: 12.5)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in req.products)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Text(p,
                      style: const TextStyle(
                          color: AppColors.textMid,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600)),
                ),
            ],
          ),
          if (req.note.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(req.note,
                style: const TextStyle(
                    color: AppColors.textLo, fontSize: 14, height: 1.5)),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              FilledButton.icon(
                onPressed: busy
                    ? null
                    : () => context
                        .read<ApprovalsCubit>()
                        .decide(req, approve: true),
                icon: busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check_rounded, size: 18),
                label: const Text('Approve & issue keys'),
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: busy
                    ? null
                    : () => context
                        .read<ApprovalsCubit>()
                        .decide(req, approve: false),
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Reject'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
