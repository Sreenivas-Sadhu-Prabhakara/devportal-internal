import 'package:flutter_bloc/flutter_bloc.dart';

import 'auth_state.dart';

/// Hardcoded demo credentials. In production the internal portal sits behind
/// corporate SSO (ForgeRock OIDC) — this fixed check stands in for the mock.
const String kAdminUsername = 'admin';
const String kAdminPassword = 'passWORD1234#';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState());

  Future<void> signIn(String username, String password) async {
    emit(state.copyWith(signingIn: true, error: ''));
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (username.trim() == kAdminUsername && password == kAdminPassword) {
      emit(AuthState(signedIn: true, username: username.trim()));
    } else {
      emit(const AuthState(
        signedIn: false,
        signingIn: false,
        error: 'Invalid username or password.',
      ));
    }
  }

  void signOut() => emit(const AuthState());
}
