import 'package:flutter/material.dart';

/// Left-aligned, width-capped, padded content region for admin pages.
class ContentArea extends StatelessWidget {
  const ContentArea({super.key, required this.child, this.maxWidth = 1320});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(40, 36, 40, 64),
            child: child,
          ),
        ),
      ),
    );
  }
}
