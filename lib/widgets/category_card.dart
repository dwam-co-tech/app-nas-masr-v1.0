import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nas_masr_app/core/data/models/category_home.dart';
// Use Theme.of(context) colorScheme/textTheme instead of ColorManager
import 'package:cached_network_image/cached_network_image.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback? onTap;
  const CategoryCard({super.key, required this.category, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Material(
      elevation: 4.0,
      shadowColor: const Color.fromRGBO(0, 0, 0, 0.25).withOpacity(.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFEFF2F5)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // مساحة صورة مرنة تمنع أي overflow عمودي
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.h),
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: category.iconUrl,
                        imageBuilder: (context, imageProvider) => SizedBox(
                          width: 70.w,
                          height: 80.w,
                          child: Image(
                            image: imageProvider,
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                          ),
                        ),
                        placeholder: (context, url) => SizedBox(
                          width: 44.w,
                          height: 44.w,
                          child: Center(
                            child: SizedBox(
                              width: 16.sp,
                              height: 16.sp,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.image_not_supported_outlined,
                          size: 26.sp,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  category.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: tt.bodyMedium?.copyWith(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 12.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
