import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_cubit.dart';
import '../auth/auth_state.dart';

class _NavItem {
  const _NavItem(this.label, this.icon, this.path);
  final String label;
  final IconData icon;
  final String path;
}

const _items = <_NavItem>[
  _NavItem('Dashboard', Icons.dashboard_rounded, '/'),
  _NavItem('Products', Icons.category_rounded, '/products'),
  _NavItem('Developers', Icons.people_alt_rounded, '/developers'),
  _NavItem('Approvals', Icons.fact_check_rounded, '/approvals'),
  _NavItem('Analytics', Icons.insights_rounded, '/analytics'),
  _NavItem('Settings', Icons.settings_rounded, '/settings'),
];

/// Persistent left-rail admin chrome.
class AdminShell extends StatelessWidget {
  const AdminShell({super.key, required this.child});

  final Widget child;

  bool _isActive(String location, String path) {
    if (path == '/') return location == '/';
    return location == path || location.startsWith('$path/');
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Sidebar
          Container(
            width: 252,
            decoration: const BoxDecoration(
              color: AppColors.canvasAlt,
              border: Border(right: BorderSide(color: AppColors.line)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
                  child: Row(
                    children: [
                      const PortalMark(size: 30),
                      const SizedBox(width: 11),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DEVPORTAL',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                      fontSize: 15)),
                          const Text('Admin console',
                              style: TextStyle(
                                  color: AppColors.accentSoft,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.line),
                const SizedBox(height: 12),
                for (final item in _items)
                  _RailTile(
                    item: item,
                    active: _isActive(location, item.path),
                  ),
                const Spacer(),
                const Divider(height: 1, color: AppColors.line),
                const _AdminFooter(),
              ],
            ),
          ),
          // Content (each page scrolls via ContentArea)
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _RailTile extends StatefulWidget {
  const _RailTile({required this.item, required this.active});
  final _NavItem item;
  final bool active;

  @override
  State<_RailTile> createState() => _RailTileState();
}

class _RailTileState extends State<_RailTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => context.go(widget.item.path),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: active
                ? AppColors.accent.withValues(alpha: 0.14)
                : _hover
                    ? AppColors.surfaceHover
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(
              color: active
                  ? AppColors.accent.withValues(alpha: 0.45)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(widget.item.icon,
                  size: 19,
                  color: active ? AppColors.accentSoft : AppColors.textLo),
              const SizedBox(width: 12),
              Text(
                widget.item.label,
                style: TextStyle(
                  color: active ? AppColors.textHi : AppColors.textMid,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminFooter extends StatelessWidget {
  const _AdminFooter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, auth) {
        return Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.accent,
                child: Icon(Icons.shield_rounded, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(auth.username.isEmpty ? 'admin' : auth.username,
                        style: const TextStyle(
                            color: AppColors.textHi,
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    const Text('API team',
                        style: TextStyle(
                            color: AppColors.textFaint, fontSize: 11)),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Sign out',
                visualDensity: VisualDensity.compact,
                onPressed: () => context.read<AuthCubit>().signOut(),
                icon: const Icon(Icons.logout_rounded,
                    size: 17, color: AppColors.textFaint),
              ),
            ],
          ),
        );
      },
    );
  }
}
