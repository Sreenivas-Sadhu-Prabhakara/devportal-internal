import 'package:devportal_shared/devportal_shared.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ApprovalsStatus { loading, ready, error }

class ApprovalsState extends Equatable {
  const ApprovalsState({
    this.status = ApprovalsStatus.loading,
    this.requests = const [],
    this.busyId = '',
    this.lastDecision = '',
    this.error = '',
  });

  final ApprovalsStatus status;
  final List<ApprovalRequest> requests;
  final String busyId; // request currently being decided
  final String lastDecision; // snackbar message
  final String error;

  ApprovalsState copyWith({
    ApprovalsStatus? status,
    List<ApprovalRequest>? requests,
    String? busyId,
    String? lastDecision,
    String? error,
  }) {
    return ApprovalsState(
      status: status ?? this.status,
      requests: requests ?? this.requests,
      busyId: busyId ?? this.busyId,
      lastDecision: lastDecision ?? this.lastDecision,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, requests, busyId, lastDecision, error];
}

class ApprovalsCubit extends Cubit<ApprovalsState> {
  ApprovalsCubit(this._repo) : super(const ApprovalsState());

  final ApprovalsRepository _repo;

  Future<void> load() async {
    emit(const ApprovalsState());
    try {
      emit(ApprovalsState(
          status: ApprovalsStatus.ready, requests: await _repo.pending()));
    } catch (e) {
      emit(ApprovalsState(status: ApprovalsStatus.error, error: '$e'));
    }
  }

  Future<void> decide(ApprovalRequest req, {required bool approve}) async {
    emit(state.copyWith(busyId: req.id));
    await _repo.decide(req.id, approve: approve);
    final remaining = await _repo.pending();
    emit(state.copyWith(
      requests: remaining,
      busyId: '',
      lastDecision:
          '${approve ? 'Approved' : 'Rejected'} “${req.appName}” for ${req.developerName}',
    ));
  }
}
