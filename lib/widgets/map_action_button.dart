import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MapActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final EdgeInsetsGeometry? padding;

  const MapActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.textColor,
    this.icon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.secondary;
    final t = textColor ?? Colors.white;
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8.r),
      color: c,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: padding ?? EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: t, size: 18.sp),
                SizedBox(width: 6.w),
              ],
              Text(
                label,
                style: TextStyle(color: t, fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}