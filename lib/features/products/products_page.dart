import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../utils/format.dart';
import '../../widgets/admin_table.dart';
import '../../widgets/content_area.dart';
import '../../widgets/page_header.dart';
import 'products_cubit.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  static (String, BadgeTone) visibility(ProductVisibility v) => switch (v) {
        ProductVisibility.public => ('Public', BadgeTone.success),
        ProductVisibility.partner => ('Partner', BadgeTone.warn),
        ProductVisibility.internal => ('Internal', BadgeTone.info),
      };

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductsCubit, ProductsState>(
      builder: (context, state) {
        return ContentArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PageHeader(
                title: 'API products',
                subtitle: 'Publish and manage the products developers consume.',
                trailing: FilledButton.icon(
                  onPressed: () => context.go('/products/new'),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('New product'),
                ),
              ),
              const SizedBox(height: 28),
              if (state.status == ProductsStatus.loading)
                const SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator()))
              else
                AdminTable(
                  columns: const [
                    AdminColumn('Product', flex: 4),
                    AdminColumn('Category', flex: 2),
                    AdminColumn('Version', flex: 1),
                    AdminColumn('Visibility', flex: 2),
                    AdminColumn('Quota / mo', flex: 2, alignEnd: true),
                  ],
                  rows: [
                    for (final p in state.products)
                      AdminRowData(
                        onTap: () => context.go('/products/${p.id}'),
                        cells: [
                          _nameCell(p),
                          Text(p.category,
                              style: const TextStyle(
                                  color: AppColors.textMid, fontSize: 13.5)),
                          Text(p.version,
                              style: const TextStyle(
                                  color: AppColors.textMid, fontSize: 13.5)),
                          _visCell(p.visibility),
                          Text(formatInt(p.quotaLimit),
                              style: const TextStyle(
                                  color: AppColors.textMid,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _nameCell(ApiProduct p) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.categoryColor(p.colorIndex),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.name,
                  style: const TextStyle(
                      color: AppColors.textHi,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(p.tagline,
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

  Widget _visCell(ProductVisibility v) {
    final (label, tone) = visibility(v);
    return Align(
      alignment: Alignment.centerLeft,
      child: StatusBadge(label, tone: tone),
    );
  }
}
