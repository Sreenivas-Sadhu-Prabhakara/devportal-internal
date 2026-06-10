import 'package:devportal_shared/devportal_shared.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum OrgAnalyticsStatus { loading, ready, error }

class OrgAnalyticsState extends Equatable {
  const OrgAnalyticsState({
    this.status = OrgAnalyticsStatus.loading,
    this.analytics,
    this.error = '',
  });

  final OrgAnalyticsStatus status;
  final OrgAnalytics? analytics;
  final String error;

  @override
  List<Object?> get props => [status, analytics, error];
}

class AnalyticsCubit extends Cubit<OrgAnalyticsState> {
  AnalyticsCubit(this._repo) : super(const OrgAnalyticsState());

  final OrgAnalyticsRepository _repo;

  Future<void> load() async {
    emit(const OrgAnalyticsState());
    try {
      emit(OrgAnalyticsState(
          status: OrgAnalyticsStatus.ready, analytics: await _repo.get()));
    } catch (e) {
      emit(OrgAnalyticsState(status: OrgAnalyticsStatus.error, error: '$e'));
    }
  }
}
