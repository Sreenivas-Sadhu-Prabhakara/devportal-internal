import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../widgets/admin_table.dart';
import '../../widgets/content_area.dart';
import '../../widgets/page_header.dart';
import 'developers_cubit.dart';

class DevelopersPage extends StatelessWidget {
  const DevelopersPage({super.key});

  static (String, BadgeTone) status(DeveloperStatus s) => switch (s) {
        DeveloperStatus.active => ('Active', BadgeTone.success),
        DeveloperStatus.pending => ('Pending', BadgeTone.warn),
        DeveloperStatus.blocked => ('Blocked', BadgeTone.danger),
      };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DevelopersCubit, DevelopersState>(
      builder: (context, state) {
        return ContentArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PageHeader(
                title: 'Developers',
                subtitle: 'Everyone registered to consume the platform APIs.',
              ),
              const SizedBox(height: 28),
              if (state.status == DevelopersStatus.loading)
                const SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator()))
              else
                AdminTable(
                  columns: const [
                    AdminColumn('Developer', flex: 3),
                    AdminColumn('Company', flex: 2),
                    AdminColumn('Status', flex: 2),
                    AdminColumn('Apps', flex: 1, alignEnd: true),
                    AdminColumn('Joined', flex: 2, alignEnd: true),
                  ],
                  rows: [
                    for (final d in state.developers)
                      AdminRowData(cells: [
                        _person(d),
                        Text(d.company,
                            style: const TextStyle(
                                color: AppColors.textMid, fontSize: 13.5)),
                        _statusCell(d.status),
                        Text('${d.appCount}',
                            style: const TextStyle(
                                color: AppColors.textMid,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600)),
                        Text(d.joinedAt,
                            style: const TextStyle(
                                color: AppColors.textFaint, fontSize: 13)),
                      ]),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _person(Developer d) {
    final initials =
        '${d.firstName.isNotEmpty ? d.firstName[0] : ''}${d.lastName.isNotEmpty ? d.lastName[0] : ''}';
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.surfaceHover,
          child: Text(initials.toUpperCase(),
              style: const TextStyle(
                  color: AppColors.textMid,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(d.fullName,
                  style: const TextStyle(
                      color: AppColors.textHi,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
              Text(d.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.textFaint, fontSize: 12.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusCell(DeveloperStatus s) {
    final (label, tone) = status(s);
    return Align(
      alignment: Alignment.centerLeft,
      child: StatusBadge(label, tone: tone),
    );
  }
}
