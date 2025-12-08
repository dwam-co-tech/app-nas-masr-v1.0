import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:nas_masr_app/core/data/providers/notifications_provider.dart';
import 'package:nas_masr_app/core/data/reposetory/notifications_repository.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _fmtDate(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat('dd/MM/yyyy').format(dt);
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
            textDirection: ui.TextDirection.rtl,
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
                                        onTap: () => prov.select('view'),
                                        child: Column(
                                          children: [
                                            Text(
                                              'العملاء',
                                              style: TextStyle(
                                                color: (prov.selected ?? '') ==
                                                        'view'
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
                                                      'view'
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
                                SizedBox(height: 5.h),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 250),
                                  child: prov.unreadCount > 0
                                      ? Container(
                                          key: const ValueKey('unread_banner'),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12.w, vertical: 8.h),
                                          decoration: BoxDecoration(
                                            color: cs.primary.withOpacity(0.08),
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  'لديك ${prov.unreadCount} إشعار غير مقروء',
                                                  style: TextStyle(
                                                    color: cs.onSurface,
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              TextButton.icon(
                                                onPressed: () =>
                                                    prov.markAllRead(),
                                                icon: Icon(
                                                  Icons.mark_email_read,
                                                  color: cs.primary,
                                                  size: 18.sp,
                                                ),
                                                label: Text(
                                                  'قراءة الكل',
                                                  style: TextStyle(
                                                    color: cs.primary,
                                                    fontSize: 13.sp,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: prov.displayedItems.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 24.w),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.notifications_off,
                                              color: cs.onSurface
                                                  .withOpacity(0.35),
                                              size: 36.sp),
                                          SizedBox(height: 10.h),
                                          Text(
                                            'ليس لديك أي إشعارات',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color:
                                                  cs.onSurface.withOpacity(0.7),
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: prov.displayedItems.length +
                                        (prov.hasMore ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index >= prov.displayedItems.length) {
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16.w, vertical: 2.h),
                                          child: OutlinedButton(
                                            onPressed: prov.loadingMore
                                                ? null
                                                : () => prov.loadMore(),
                                            style: OutlinedButton.styleFrom(
                                              side:
                                                  BorderSide(color: cs.primary),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16.w,
                                                  vertical: 10.h),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.r)),
                                            ),
                                            child: prov.loadingMore
                                                ? SizedBox(
                                                    height: 18.h,
                                                    width: 18.h,
                                                    child:
                                                        const CircularProgressIndicator(
                                                            strokeWidth: 2))
                                                : Text('عرض مزيد من الإشعارات',
                                                    style: TextStyle(
                                                        color: cs.primary,
                                                        fontSize: 14.sp)),
                                          ),
                                        );
                                      }
                                      final n = prov.displayedItems[index];
                                      return Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12.w, vertical: 3.h),
                                        child: InkWell(
                                          onTap: () => prov.markItemRead(n.id),
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          child: Card(
                                            elevation: 1,
                                            color: n.isRead
                                                ? Theme.of(context).cardColor
                                                : cs.primary.withOpacity(0.08),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.r)),
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
                                                          BorderRadius.circular(
                                                              18.w),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black
                                                              .withOpacity(
                                                                  0.06),
                                                          blurRadius: 6,
                                                          offset: const Offset(
                                                              0, 2),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Icon(
                                                        Icons
                                                            .notifications_rounded,
                                                        color: cs.primary,
                                                        size: 20.sp),
                                                  ),
                                                  SizedBox(width: 10.w),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                n.title,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16.sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              ),
                                                            ),
                                                            Text(
                                                                _fmtDate(n
                                                                    .createdAt),
                                                                style: TextStyle(
                                                                    color: const Color
                                                                        .fromRGBO(
                                                                        1,
                                                                        22,
                                                                        24,
                                                                        0.45),
                                                                    fontSize:
                                                                        12.sp)),
                                                          ],
                                                        ),
                                                        SizedBox(height: 4.h),
                                                        Text(
                                                          n.body,
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontSize: 14.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  cs.onSurface),
                                                        ),
                                                        SizedBox(height: 8.h),
                                                        Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        12.w,
                                                                    vertical:
                                                                        6.h),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: cs.primary,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20.r),
                                                            ),
                                                            child: Text(
                                                              (n.type) == 'view'
                                                                  ? 'محادثة مع العميل'
                                                                  : 'تحدث مع الإدارة',
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .white),
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
