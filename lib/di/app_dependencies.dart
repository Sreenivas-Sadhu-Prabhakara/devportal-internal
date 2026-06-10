import 'package:devportal_shared/devportal_shared.dart';

/// Composition root for the internal portal. Single repository instances so
/// in-session mutations (create product, approve request) persist across
/// navigation. `--dart-define=DATA_SOURCE=live` is wired in Phase 4.
class AppDependencies {
  AppDependencies({
    required this.products,
    required this.developers,
    required this.approvals,
    required this.orgAnalytics,
    required this.dataSource,
  });

  final ProductAdminRepository products;
  final DevelopersRepository developers;
  final ApprovalsRepository approvals;
  final OrgAnalyticsRepository orgAnalytics;
  final String dataSource;

  static const _source =
      String.fromEnvironment('DATA_SOURCE', defaultValue: 'mock');

  factory AppDependencies.bootstrap() {
    switch (_source) {
      // case 'live': // TODO(phase-4): Drupal-backed admin repositories.
      default:
        return AppDependencies(
          products: MockProductAdminRepository(),
          developers: MockDevelopersRepository(),
          approvals: MockApprovalsRepository(),
          orgAnalytics: MockOrgAnalyticsRepository(),
          dataSource: 'mock',
        );
    }
  }
}
