import 'package:devportal_shared/devportal_shared.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum DashboardStatus { loading, ready, error }

class DashboardState extends Equatable {
  const DashboardState({
    this.status = DashboardStatus.loading,
    this.analytics,
    this.pendingApprovals = 0,
    this.error = '',
  });

  final DashboardStatus status;
  final OrgAnalytics? analytics;
  final int pendingApprovals;
  final String error;

  @override
  List<Object?> get props => [status, analytics, pendingApprovals, error];
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._analytics, this._approvals)
      : super(const DashboardState());

  final OrgAnalyticsRepository _analytics;
  final ApprovalsRepository _approvals;

  Future<void> load() async {
    emit(const DashboardState());
    try {
      final analytics = await _analytics.get();
      final pending = await _approvals.pending();
      emit(DashboardState(
        status: DashboardStatus.ready,
        analytics: analytics,
        pendingApprovals: pending.length,
      ));
    } catch (e) {
      emit(DashboardState(status: DashboardStatus.error, error: '$e'));
    }
  }
}
