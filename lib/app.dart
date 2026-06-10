import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'auth/auth_cubit.dart';
import 'di/app_dependencies.dart';
import 'routing/app_router.dart';

class AdminApp extends StatefulWidget {
  const AdminApp({super.key, required this.deps});

  final AppDependencies deps;

  @override
  State<AdminApp> createState() => _AdminAppState();
}

class _AdminAppState extends State<AdminApp> {
  late final AuthCubit _auth = AuthCubit();
  late final GoRouter _router = buildRouter(_auth);

  // Pin the bundled Roboto family so text renders without a runtime CDN fetch
  // (see fonts in pubspec.yaml). The shared theme leaves the family default.
  static final ThemeData _theme = AppTheme.dark.copyWith(
    textTheme: AppTheme.dark.textTheme.apply(fontFamily: 'Roboto'),
    primaryTextTheme: AppTheme.dark.primaryTextTheme.apply(fontFamily: 'Roboto'),
  );

  @override
  void dispose() {
    _auth.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ProductAdminRepository>.value(
            value: widget.deps.products),
        RepositoryProvider<DevelopersRepository>.value(
            value: widget.deps.developers),
        RepositoryProvider<ApprovalsRepository>.value(
            value: widget.deps.approvals),
        RepositoryProvider<OrgAnalyticsRepository>.value(
            value: widget.deps.orgAnalytics),
      ],
      child: BlocProvider<AuthCubit>.value(
        value: _auth,
        child: MaterialApp.router(
          title: 'Developer Portal — Admin',
          debugShowCheckedModeBanner: false,
          theme: _theme,
          routerConfig: _router,
        ),
      ),
    );
  }
}
