import 'package:devportal_shared/devportal_shared.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum DevelopersStatus { loading, ready, error }

class DevelopersState extends Equatable {
  const DevelopersState({
    this.status = DevelopersStatus.loading,
    this.developers = const [],
    this.error = '',
  });

  final DevelopersStatus status;
  final List<Developer> developers;
  final String error;

  @override
  List<Object?> get props => [status, developers, error];
}

class DevelopersCubit extends Cubit<DevelopersState> {
  DevelopersCubit(this._repo) : super(const DevelopersState());

  final DevelopersRepository _repo;

  Future<void> load() async {
    emit(const DevelopersState());
    try {
      emit(DevelopersState(
          status: DevelopersStatus.ready, developers: await _repo.list()));
    } catch (e) {
      emit(DevelopersState(status: DevelopersStatus.error, error: '$e'));
    }
  }
}
