import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:nas_masr_app/core/data/providers/favorites_provider.dart';
import 'package:nas_masr_app/core/data/reposetory/favorites_repository.dart';
import 'package:nas_masr_app/widgets/ad_card_widget.dart/favorite_card_widget.dart';

class FavoritesScreen extends StatelessWidget {
  final String? initialSlug;
  const FavoritesScreen({super.key, this.initialSlug});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    final isLand = MediaQuery.of(context).orientation == Orientation.landscape;
    final cs = Theme.of(context).colorScheme;

    return ChangeNotifierProvider(
      create: (context) => FavoritesProvider(
        repository: FavoritesRepository(),
        initialSlug: initialSlug,
      ),
      child: Consumer<FavoritesProvider>(
        builder: (context, prov, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: cs.onSurface),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  Padding(
                    
                    padding: const EdgeInsets.only(left: 12),
                    child: InkWell(
                      onTap: () => context.pushNamed('notifications'),
                      child: Icon(Icons.notifications_rounded,
                          color: cs.onSurface, size: isLand ? 15.sp : 30.sp),
                    ),
                  ),
                ],
                title: Text('المفضلة', style: TextStyle(color: cs.onSurface)),
              ),
              body: prov.loading
                  ? const Center(child: CircularProgressIndicator())
                  : SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Builder(builder: (context) {
                                      final allSelected =
                                          prov.selectedSlug == null ||
                                              prov.selectedSlug!.isEmpty;
                                      return ChoiceChip(
                                        label: Text(
                                          'الكل',
                                          style: TextStyle(
                                            color: allSelected
                                                ? Colors.white
                                                : cs.onSurface,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        selected: allSelected,
                                        onSelected: (_) =>
                                            prov.selectCategory(null),
                                        selectedColor: cs.primary,
                                        backgroundColor: Colors.white,
                                        side: BorderSide(
                                            color:
                                                cs.onSurface.withOpacity(0.12)),
                                        labelPadding: EdgeInsets.symmetric(
                                            horizontal: 15.w, vertical: 1.h),
                                      );
                                    }),
                                    SizedBox(width: 8.w),
                                    ...prov.categories.entries.map((e) {
                                      final selected =
                                          prov.selectedSlug == e.key;
                                      return Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            end: 8.w),
                                        child: ChoiceChip(
                                          label: Text(
                                            e.value,
                                            style: TextStyle(
                                              color: selected
                                                  ? Colors.white
                                                  : cs.onSurface,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          selected: selected,
                                          onSelected: (_) =>
                                              prov.selectCategory(e.key),
                                          selectedColor: cs.primary,
                                          backgroundColor: Colors.white,
                                          side: BorderSide(
                                              color: cs.onSurface
                                                  .withOpacity(0.12)),
                                          labelPadding: EdgeInsets.symmetric(
                                              horizontal: 15.w, vertical: 1.h),
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                            ),
                           
                            if (prov.items.isEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 40.h),
                                child: Center(
                                  child: Text(
                                    'قائمة المفضلة فارغة — أضف الإعلانات التي تعجبك لتظهر هنا',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: cs.onSurface.withOpacity(0.7),
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              )
                            else
                              ...prov.items
                                  .map((ad) => FavoriteCardWidget(
                                        ad: ad,
                                        onTap: () {
                                          context
                                              .pushNamed('ad_details', extra: {
                                            'categorySlug': ad.categorySlug,
                                            'categoryName': ad.categoryName,
                                            'adId': ad.id.toString(),
                                          });
                                        },
                                      ))
                                  .toList(),
                            SizedBox(height: 20.h),
                          ],
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
