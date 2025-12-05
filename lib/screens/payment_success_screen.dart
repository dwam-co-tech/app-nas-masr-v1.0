import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;

class PaymentSuccessScreen extends StatelessWidget {
  final int? amount;
  final String? datetime;
  final bool isSubscription;
  const PaymentSuccessScreen(
      {super.key, this.amount, this.datetime, this.isSubscription = false});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const localeCode = 'ar';
    String dateStr = '';
    String timeStr = '';
    if (datetime != null && datetime!.isNotEmpty) {
      final parsed = DateTime.tryParse(datetime!);
      if (parsed != null) {
        final local = parsed.toLocal();
        dateStr = intl.DateFormat('d MMMM yyyy', localeCode).format(local);
        timeStr = intl.DateFormat('h:mm a', localeCode).format(local);
      }
    }
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.2, -1.0),
                end: Alignment(0.0, 0.0),
                colors: [Color(0xFFFFFFFF), Color(0xFF1BB28F)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: Icon(Icons.close, color: cs.onSurface),
                            onPressed: () {
                              if (context.canPop()) {
                                context.pop();
                              } else {
                                context.go('/home');
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16.r),
                                  child: Image.asset(
                                    'assets/images/Subtract.png',
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 16.h),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset('assets/svg/sucsess.svg',
                                          width: 64.w, height: 64.w),
                                      SizedBox(height: 12.h),
                                      Text('تم الدفع بنجاح',
                                          style: TextStyle(
                                              fontSize: 24.sp,
                                              fontWeight: FontWeight.w700,
                                              color: cs.onSurface),
                                          textAlign: TextAlign.center),
                                      SizedBox(height: 12.h),
                                      Text('المبلغ',
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w400,
                                              color: Color.fromRGBO(
                                                  16, 24, 40, 1))),
                                      SizedBox(height: 6.h),
                                      Text(
                                          amount == null ? '—' : '${amount} ج ',
                                          style: TextStyle(
                                              fontSize: 25.sp,
                                              fontWeight: FontWeight.w700,
                                              color: cs.onSurface)),
                                      SizedBox(height: 12.h),
                                      (dateStr.isNotEmpty && timeStr.isNotEmpty)
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(timeStr,
                                                    style: TextStyle(
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Color.fromRGBO(
                                                            16, 24, 40, 0.38))),
                                                SizedBox(width: 8.w),
                                                Text('—',
                                                    style: TextStyle(
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Color.fromRGBO(
                                                            16, 24, 40, 0.38))),
                                                SizedBox(width: 8.w),
                                                 Text(dateStr,
                                                    style: TextStyle(
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        color: Color.fromRGBO(
                                                            16, 24, 40, 0.38))),
                                               
                                              ],
                                            )
                                          : Text(datetime ?? '',
                                              style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.w400,
                                                  color: Color.fromRGBO(
                                                      16, 24, 40, 0.38))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.r),
                      topRight: Radius.circular(16.r),
                    ),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3)),
                    ],
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: ElevatedButton(
                    onPressed: () {
                      if (isSubscription) {
                        context.go('/packages/subscribe');
                      } 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: Colors.white,
                      fixedSize: Size.fromHeight(46.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: Text('الرجوع للباقات'),
                  ),
                ),
                SizedBox(height: 45.h),
              ],
            ),
          ),
        ));
  }
}
