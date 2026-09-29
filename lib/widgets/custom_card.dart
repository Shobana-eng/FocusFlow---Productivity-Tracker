// lib/widgets/custom_card.dart

import 'package:flutter/material.dart';
import 'package:student_productivity_tracker/themes/app_theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? color;
  final double elevation;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderRadius = 20,
    this.color,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: elevation,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color ?? AppTheme.card,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white10,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}