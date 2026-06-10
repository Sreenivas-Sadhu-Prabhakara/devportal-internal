import 'package:devportal_shared/devportal_shared.dart';
import 'package:flutter/material.dart';

class AdminColumn {
  const AdminColumn(this.label, {this.flex = 1, this.alignEnd = false});
  final String label;
  final int flex;
  final bool alignEnd;
}

class AdminRowData {
  const AdminRowData({required this.cells, this.onTap});
  final List<Widget> cells;
  final VoidCallback? onTap;
}

/// A lightweight, cinematic data table (header + hoverable rows).
class AdminTable extends StatelessWidget {
  const AdminTable({super.key, required this.columns, required this.rows});

  final List<AdminColumn> columns;
  final List<AdminRowData> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          // header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.surfaceRaised,
              borderRadius:
                  BorderRadius.vertical(top: Radius.circular(AppRadii.md)),
            ),
            child: Row(
              children: [
                for (final c in columns)
                  Expanded(
                    flex: c.flex,
                    child: Align(
                      alignment:
                          c.alignEnd ? Alignment.centerRight : Alignment.centerLeft,
                      child: Text(
                        c.label.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.textFaint,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          for (var i = 0; i < rows.length; i++)
            _Row(
              columns: columns,
              data: rows[i],
              isLast: i == rows.length - 1,
            ),
        ],
      ),
    );
  }
}

class _Row extends StatefulWidget {
  const _Row({required this.columns, required this.data, required this.isLast});
  final List<AdminColumn> columns;
  final AdminRowData data;
  final bool isLast;

  @override
  State<_Row> createState() => _RowState();
}

class _RowState extends State<_Row> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.data.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.data.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: _hover && widget.data.onTap != null
                ? AppColors.surfaceHover
                : Colors.transparent,
            border: widget.isLast
                ? null
                : const Border(bottom: BorderSide(color: AppColors.line)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.columns.length; i++)
                Expanded(
                  flex: widget.columns[i].flex,
                  child: Align(
                    alignment: widget.columns[i].alignEnd
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: i < widget.data.cells.length
                        ? widget.data.cells[i]
                        : const SizedBox.shrink(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
