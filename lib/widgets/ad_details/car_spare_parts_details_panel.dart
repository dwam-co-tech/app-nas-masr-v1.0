// widgets/ad_details/car_spare_parts_details_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CarSparePartsDetailsPanel extends StatelessWidget {
  final Map<String, dynamic> attributes;
  final String? mainSection;
  final String? subSection;
  const CarSparePartsDetailsPanel(
      {super.key, required this.attributes, this.mainSection, this.subSection});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final subSec =
        ((subSection ?? attributes['sub_section'] ?? attributes['sub_category'])
                ?.toString()) ??
            '';
    final mainSec = ((mainSection ??
                attributes['main_section'] ??
                attributes['main_category'])
            ?.toString()) ??
        '';
    final make =
        (attributes['make'] ?? attributes['car_make'])?.toString() ?? '';
    final model =
        (attributes['model'] ?? attributes['car_model'])?.toString() ?? '';

    final makeModel = [make, model].where((e) => e.isNotEmpty).join('  ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (subSec.isNotEmpty)
          Text(
            subSec,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),

        if (mainSec.isNotEmpty)
          Text(
            mainSec,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),

        // Make - Model
        if (makeModel.isNotEmpty)
          Text(
            makeModel,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Color.fromRGBO(1, 22, 24, 0.45),
            ),
          ),
      ],
    );
  }
}
