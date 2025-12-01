import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:nas_masr_app/core/data/providers/notifications_provider.dart';
import 'package:nas_masr_app/core/data/reposetory/notifications_repository.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inHours >= 1) return '${diff.inHours}h ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m ago';
    return '${diff.inSeconds}s ago';
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    final isLand = MediaQuery.of(context).orientation == Orientation.landscape;
    final cs = Theme.of(context).colorScheme;

    return ChangeNotifierProvider(
      create: (_) =>
          NotificationsProvider(repository: NotificationsRepository()),
      child: Consumer<NotificationsProvider>(
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
                    child: Icon(Icons.notifications_rounded,
                        color: cs.onSurface, size: isLand ? 15.sp : 30.sp),
                  ),
                ],
                title: Text('الإشعارات', style: TextStyle(color: cs.onSurface)),
              ),
              body: prov.loading
                  ? const Center(child: CircularProgressIndicator())
                  : SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 8.h),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => prov.select(null),
                                        child: Column(
                                          children: [
                                            Text(
                                              'الكل',
                                              style: TextStyle(
                                                color: (prov.selected ?? '') ==
                                                            '' ||
                                                        prov.selected == null
                                                    ? cs.primary
                                                    : cs.onSurface,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(height: 6.h),
                                            Container(
                                              height: 2.h,
                                              color:
                                                  (prov.selected ?? '') == '' ||
                                                          prov.selected == null
                                                      ? cs.primary
                                                      : Colors.transparent,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => prov.select('customers'),
                                        child: Column(
                                          children: [
                                            Text(
                                              'العملاء',
                                              style: TextStyle(
                                                color: (prov.selected ?? '') ==
                                                        'customers'
                                                    ? cs.primary
                                                    : cs.onSurface,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 6.h),
                                            Container(
                                              height: 2.h,
                                              color: (prov.selected ?? '') ==
                                                      'customers'
                                                  ? cs.primary
                                                  : Colors.transparent,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => prov.select('admin'),
                                        child: Column(
                                          children: [
                                            Text(
                                              'الإدارة',
                                              style: TextStyle(
                                                color: (prov.selected ?? '') ==
                                                        'admin'
                                                    ? cs.primary
                                                    : cs.onSurface,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 6.h),
                                            Container(
                                              height: 2.h,
                                              color: (prov.selected ?? '') ==
                                                      'admin'
                                                  ? cs.primary
                                                  : Colors.transparent,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: prov.items.length,
                              itemBuilder: (context, index) {
                                final n = prov.items[index];
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 6.h),
                                  child: Card(
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.r)),
                                    child: Padding(
                                      padding: EdgeInsets.all(10.w),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 36.w,
                                            height: 36.w,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(18.w),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.06),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                                Icons.notifications_rounded,
                                                color: cs.primary,
                                                size: 20.sp),
                                          ),
                                          SizedBox(width: 10.w),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        n.title,
                                                        style: TextStyle(
                                                            fontSize: 16.sp,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600),
                                                      ),
                                                    ),
                                                    Text(_timeAgo(n.createdAt),
                                                        style: TextStyle(
                                                            color: const Color
                                                                .fromRGBO(1, 22,
                                                                24, 0.45),
                                                            fontSize: 12.sp)),
                                                  ],
                                                ),
                                                SizedBox(height: 4.h),
                                                Text(
                                                  n.body,
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: cs.onSurface),
                                                ),
                                                SizedBox(height: 8.h),
                                                Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 12.w,
                                                            vertical: 6.h),
                                                    decoration: BoxDecoration(
                                                      color: cs.primary,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.r),
                                                    ),
                                                    child: Text(
                                                      n.category == 'admin'
                                                          ? 'تحدث مع الإدارة'
                                                          : 'محادثة مع العميل',
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
