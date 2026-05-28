import 'package:flutter/material.dart';
import 'package:spendly/shared/themes/app_theme.dart';

class MainCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? borderRadius;
  final double? margin;

  const MainCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: margin ?? 16),
      child: Material(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(borderRadius ?? 32),
        elevation: 0,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(borderRadius ?? 32),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.06)),
            boxShadow: [
              BoxShadow(
                color: AppColors.navShadow,
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: padding ?? const EdgeInsets.all(20),
          child: child,
        ),
      ),
    );
  }
}
