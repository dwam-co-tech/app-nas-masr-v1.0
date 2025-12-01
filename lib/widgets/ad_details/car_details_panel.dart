// widgets/ad_details/car_details_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CarDetailsPanel extends StatelessWidget {
  final String? make;
  final String? model;
  final Map<String, dynamic> attributes;

  const CarDetailsPanel(
      {super.key,
      required this.make,
      required this.model,
      required this.attributes});

  String _attrValue(List<String> keys) {
    for (final k in keys) {
      final v = attributes[k];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return '';
  }

  String _normalizeKilometers(String s) {
    return s.trim();
  }

  Widget _buildItem(BuildContext context, String label, String value,
      {double? valueFontSize}) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: cs.primary)),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: (valueFontSize ?? 14.sp),
                  fontWeight: FontWeight.w500,
                  color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final type = _attrValue(['body_type', 'type', 'car_type']);
    final year = _attrValue(['year']);
    final km =
        _attrValue(['mileage_range', 'kilometer', 'kilometers', 'mileage']);
    final color = _attrValue(['exterior_color', 'color']);
    final transmission = _attrValue(['transmission']);
    final fuel = _attrValue(['fuel_type']);
    final head = [make, model]
        .where((e) => (e ?? '').trim().isNotEmpty)
        .map((e) => e!.trim())
        .join(' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (head.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
            child: Text(
              head,
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface),
            ),
          ),
        SizedBox(width: 8.w),
        Row(
          children: [
            Expanded(
                child:
                    _buildItem(context, 'النوع', type.isNotEmpty ? type : '—')),
            SizedBox(width: 8.w),
            Expanded(
                child:
                    _buildItem(context, 'السنة', year.isNotEmpty ? year : '—')),
            SizedBox(width: 8.w),
            Expanded(
                child: _buildItem(
                    context, 'الكيلو متر', km.isNotEmpty ? km : '—',
                    valueFontSize: 12.sp)),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
                child: _buildItem(
                    context, 'اللون الخارجي', color.isNotEmpty ? color : '—')),
            SizedBox(width: 8.w),
            Expanded(
                child: _buildItem(context, 'الفتيس',
                    transmission.isNotEmpty ? transmission : '....')),
            SizedBox(width: 8.w),
            Expanded(
                child: _buildItem(
                    context, 'نوع الوقود', fuel.isNotEmpty ? fuel : '—')),
          ],
        ),
      ],
    );
  }
}
