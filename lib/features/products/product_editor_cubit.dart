import 'package:devportal_shared/devportal_shared.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum EditorStatus { loading, ready, saving, saved, error }

class EditorState extends Equatable {
  const EditorState({
    this.status = EditorStatus.loading,
    this.existing,
    this.error = '',
  });

  final EditorStatus status;
  final ApiProduct? existing; // null when creating
  final String error;

  bool get isEditing => existing != null;

  EditorState copyWith({EditorStatus? status, ApiProduct? existing, String? error}) {
    return EditorState(
      status: status ?? this.status,
      existing: existing ?? this.existing,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, existing, error];
}

class ProductEditorCubit extends Cubit<EditorState> {
  ProductEditorCubit(this._repo) : super(const EditorState());

  final ProductAdminRepository _repo;

  Future<void> start(String? id) async {
    if (id == null) {
      emit(const EditorState(status: EditorStatus.ready));
      return;
    }
    emit(const EditorState(status: EditorStatus.loading));
    try {
      emit(EditorState(status: EditorStatus.ready, existing: await _repo.get(id)));
    } catch (e) {
      emit(EditorState(status: EditorStatus.error, error: '$e'));
    }
  }

  Future<void> save(ApiProduct draft) async {
    emit(state.copyWith(status: EditorStatus.saving));
    try {
      await _repo.save(draft);
      emit(state.copyWith(status: EditorStatus.saved));
    } catch (e) {
      emit(state.copyWith(status: EditorStatus.error, error: '$e'));
    }
  }
}
