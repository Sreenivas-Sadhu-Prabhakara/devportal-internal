# devportal-internal

The **internal** developer portal — the API team's admin console (Flutter Web).
Produce + administer: publish API products, manage developers, work the approval
queue, and watch org-wide analytics. Phase-2 **clickable mock** on in-memory data.

Cinematic dark theme · **left-rail admin shell** · **Bloc/Cubit + clean
architecture** · `go_router`. Reuses the [`devportal_shared`](../devportal-flutter-shared)
design system + domain + data layer.

## Run it

```bash
flutter pub get
flutter run -d chrome
```

**Login:** `admin` / `passWORD1234#` (hardcoded for the mock — stands in for the
ForgeRock OIDC / corporate-SSO gate used in production). The login screen has a
**Fill** button.

## What's clickable

- **Operations dashboard** — KPIs, org traffic chart, status-code mix, top
  products/apps, and a pending-approvals card.
- **Products** — table of API products (BIAN Payment Initiation/Order/Execution
  + others); **create** a new product or **edit** one — changes show in the list
  immediately.
- **Developers** — registered developers with status and app counts.
- **Approvals** — queue of app registrations against restricted (partner/
  internal) products; **Approve** or **Reject** updates the queue and the
  dashboard's pending count.
- **Analytics** — fuller org analytics.
- **Settings** — illustrative governance/identity/monetization policy.

## Structure

```
lib/
  main.dart · app.dart            Composition root + MaterialApp.router
  di/        app_dependencies.dart   Single repo instances (mutations persist)
  routing/   app_router.dart, admin_shell.dart, go_router_refresh.dart
  auth/      AuthCubit (hardcoded creds) + login gate
  features/  dashboard · products (+editor) · developers · approvals · analytics · settings
  widgets/   AdminTable · PageHeader · ContentArea
```

## Verify

```bash
flutter analyze   # clean
flutter test      # login gate + dashboard smoke tests
flutter build web # compiles
```
