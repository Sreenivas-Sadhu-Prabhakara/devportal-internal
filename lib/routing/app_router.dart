import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_cubit.dart';
import '../auth/login_page.dart';
import '../features/analytics/analytics_cubit.dart';
import '../features/analytics/analytics_page.dart';
import '../features/approvals/approvals_cubit.dart';
import '../features/approvals/approvals_page.dart';
import '../features/dashboard/dashboard_cubit.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/developers/developers_cubit.dart';
import '../features/developers/developers_page.dart';
import '../features/products/product_editor_cubit.dart';
import '../features/products/product_editor_page.dart';
import '../features/products/products_cubit.dart';
import '../features/products/products_page.dart';
import '../features/settings/settings_page.dart';
import 'admin_shell.dart';
import 'go_router_refresh.dart';

GoRouter buildRouter(AuthCubit auth) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(auth.stream),
    redirect: (context, state) {
      final signedIn = auth.state.signedIn;
      final loggingIn = state.matchedLocation == '/login';
      if (!signedIn && !loggingIn) return '/login';
      if (signedIn && loggingIn) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => BlocProvider(
              create: (ctx) => DashboardCubit(
                ctx.read<OrgAnalyticsRepository>(),
                ctx.read<ApprovalsRepository>(),
              )..load(),
              child: const DashboardPage(),
            ),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) => BlocProvider(
              create: (ctx) =>
                  ProductsCubit(ctx.read<ProductAdminRepository>())..load(),
              child: const ProductsPage(),
            ),
          ),
          GoRoute(
            path: '/products/new',
            builder: (context, state) => BlocProvider(
              create: (ctx) =>
                  ProductEditorCubit(ctx.read<ProductAdminRepository>())
                    ..start(null),
              child: const ProductEditorPage(),
            ),
          ),
          GoRoute(
            path: '/products/:id',
            builder: (context, state) => BlocProvider(
              create: (ctx) =>
                  ProductEditorCubit(ctx.read<ProductAdminRepository>())
                    ..start(state.pathParameters['id']),
              child: const ProductEditorPage(),
            ),
          ),
          GoRoute(
            path: '/developers',
            builder: (context, state) => BlocProvider(
              create: (ctx) =>
                  DevelopersCubit(ctx.read<DevelopersRepository>())..load(),
              child: const DevelopersPage(),
            ),
          ),
          GoRoute(
            path: '/approvals',
            builder: (context, state) => BlocProvider(
              create: (ctx) =>
                  ApprovalsCubit(ctx.read<ApprovalsRepository>())..load(),
              child: const ApprovalsPage(),
            ),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => BlocProvider(
              create: (ctx) =>
                  AnalyticsCubit(ctx.read<OrgAnalyticsRepository>())..load(),
              child: const AnalyticsPage(),
            ),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
}
