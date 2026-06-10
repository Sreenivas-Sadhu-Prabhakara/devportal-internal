import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  const AuthState({
    this.signedIn = false,
    this.signingIn = false,
    this.error = '',
    this.username = '',
  });

  final bool signedIn;
  final bool signingIn;
  final String error;
  final String username;

  AuthState copyWith({
    bool? signedIn,
    bool? signingIn,
    String? error,
    String? username,
  }) {
    return AuthState(
      signedIn: signedIn ?? this.signedIn,
      signingIn: signingIn ?? this.signingIn,
      error: error ?? this.error,
      username: username ?? this.username,
    );
  }

  @override
  List<Object?> get props => [signedIn, signingIn, error, username];
}
