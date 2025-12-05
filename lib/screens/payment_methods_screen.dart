import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nas_masr_app/widgets/custom_bottom_nav.dart';
import 'package:provider/provider.dart';
import 'package:nas_masr_app/core/data/providers/plan_prices_provider.dart';
import 'package:nas_masr_app/core/data/reposetory/plan_prices_repository.dart';
import 'package:nas_masr_app/core/data/providers/payment_provider.dart';
import 'package:nas_masr_app/core/data/reposetory/payment_repository.dart';
import 'package:go_router/go_router.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final String? categorySlug;
  final String? planType;
  final int? listingId;
  final int? initialPrice;
  const PaymentMethodsScreen(
      {super.key,
      this.categorySlug,
      this.planType,
      this.listingId,
      this.initialPrice});
  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _method = 'instapay';
  bool _didLoad = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) =>
                PlanPricesProvider(repository: PlanPricesRepository())),
        ChangeNotifierProvider(
            create: (_) => PaymentProvider(repository: PaymentRepository())),
      ],
      child: Consumer2<PlanPricesProvider, PaymentProvider>(
        builder: (context, prov, payProv, _) {
          if (!_didLoad &&
              widget.initialPrice == null &&
              (widget.categorySlug ?? '').isNotEmpty) {
            _didLoad = true;
            Future.microtask(() => prov.load(widget.categorySlug!));
          }

          int? displayedPrice = widget.initialPrice;
          if (displayedPrice == null && prov.prices != null) {
            final p = prov.prices!;
            final plan = (widget.planType ?? '').toLowerCase();
            if (plan == 'featured') {
              displayedPrice = p.featuredAdPrice ?? p.priceFeatured;
            } else if (plan == 'standard') {
              displayedPrice = p.standardAdPrice ?? p.priceStandard;
            }
          }

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              bottomNavigationBar: const CustomBottomNav(currentIndex: 1),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: Text('طرق الدفع',
                    style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface)),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: cs.onSurface),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                ),
              ),
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _MethodTile(
                      title: 'انستا باي',
                      selected: _method == 'instapay',
                      onTap: () => setState(() => _method = 'instapay'),
                    ),
                    SizedBox(height: 18.h),
                    _MethodTile(
                      title: 'المحافظ الإلكترونية',
                      selected: _method == 'wallet',
                      onTap: () => setState(() => _method = 'wallet'),
                    ),
                    SizedBox(height: 50.h),
                    Text('تفاصيل الدفع',
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black)),
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('السعر',
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: cs.onSurface)),
                          ),
                          Text(
                            displayedPrice == null
                                ? '—'
                                : 'ج ${displayedPrice}',
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: cs.secondary),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 160.h),
                    ElevatedButton(
                      onPressed: (displayedPrice == null || payProv.loading)
                          ? null
                          : () async {
                              final method = _method;
                              bool ok = false;
                              if ((widget.listingId ?? 0) > 0) {
                                ok = await payProv.payListing(
                                    listingId: widget.listingId!,
                                    paymentMethod: method);
                              } else if ((widget.categorySlug ?? '')
                                      .isNotEmpty &&
                                  (widget.planType ?? '').isNotEmpty) {
                                ok = await payProv.subscribePlan(
                                    categorySlug: widget.categorySlug!,
                                    planType: widget.planType!,
                                    paymentMethod: method);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('بيانات الدفع غير مكتملة')));
                                return;
                              }
                              if (!ok) {
                                final msg = payProv.error ?? 'فشل العملية';
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(content: Text(msg)));
                                return;
                              }
                              final rec = payProv.receipt ?? {};
                              int? amount;
                              String? datetime;
                              bool isSub = payProv.type == 'subscription';
                              if (!isSub) {
                                final a = rec['amount'] ?? rec['price'];
                                if (a is int) {
                                  amount = a;
                                } else if (a != null) {
                                  amount = int.tryParse(a.toString());
                                }
                                datetime = rec['paid_at']?.toString();
                              } else {
                                final sub =
                                    rec['subscription'] is Map<String, dynamic>
                                        ? rec['subscription']
                                            as Map<String, dynamic>
                                        : {};
                                final a = sub['ad_price'] ?? sub['price'];
                                if (a is int) {
                                  amount = a;
                                } else if (a is String) {
                                  amount = int.tryParse(a.split('.').first);
                                } else if (a != null) {
                                  amount = int.tryParse(a.toString());
                                }
                                datetime = sub['subscribed_at']?.toString();
                              }
                              context.push('/payment/success', extra: {
                                'amount': amount,
                                'datetime': datetime,
                                'subscription': isSub,
                              });
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: Colors.white,
                        fixedSize: Size.fromHeight(46.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: const Text('تأكيد الدفع'),
                    ),
                    SizedBox(height: 60.h),
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

class _MethodTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;
  const _MethodTile(
      {required this.title, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(right: 0.w),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 18.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border(right: BorderSide(color: cs.primary, width: 4.w)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 5,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: cs.secondary,
                    size: 20),
                SizedBox(width: 8.w),
                Expanded(
                    child: Text(title,
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface))),
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF14876F), Color(0xFF03464A)],
                  ).createShader(bounds),
                  blendMode: BlendMode.srcIn,
                  child: const Icon(Icons.arrow_forward_ios,
                      color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 16.w,
            right: 9.w,
            child: Container(
              height: 1.h,
              decoration: BoxDecoration(
                color: cs.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  topRight: Radius.circular(16.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
