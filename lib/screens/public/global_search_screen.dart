import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:nas_masr_app/core/data/providers/global_search_provider.dart';
import 'package:nas_masr_app/core/data/reposetory/global_search_repository.dart';
import 'package:nas_masr_app/core/data/models/global_search_result.dart';
import 'package:go_router/go_router.dart';
import 'package:nas_masr_app/widgets/custom_bottom_nav.dart';
import 'package:nas_masr_app/widgets/notifications_badge_icon.dart';

class GlobalSearchScreen extends StatefulWidget {
  final String initialKeyword;
  const GlobalSearchScreen({super.key, required this.initialKeyword});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialKeyword);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLand = MediaQuery.of(context).orientation == Orientation.landscape;
    final cs = Theme.of(context).colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ChangeNotifierProvider(
        create: (_) => GlobalSearchProvider(
          repository: GlobalSearchRepository(),
        )..search(widget.initialKeyword.trim()),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
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
            actions: [
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: InkWell(
                  onTap: () => context.pushNamed('notifications'),
                  child: NotificationsBadgeIcon(isLand: isLand),
                ),
              ),
            ],
            title: Text('البحث',
                style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700)),
          ),
          bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
          body: Consumer<GlobalSearchProvider>(
            builder: (context, prov, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _SearchInput(
                      controller: _controller,
                      onSubmit: (kw) => prov.search(kw.trim()),
                    ),
                  ),
                  Expanded(
                    child: _ResultsList(
                      loading: prov.loading,
                      error: prov.error,
                      result: prov.result,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;
  const _SearchInput({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final inputBorder = const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
    ).copyWith(
      borderSide: BorderSide(color: cs.surface, width: 1.0),
    );
    return Material(
      elevation: 4.0,
      shadowColor: const Color.fromRGBO(0, 0, 0, 0.25),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
      child: TextField(
        controller: controller,
        textDirection: TextDirection.rtl,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmit,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
          border: inputBorder,
          enabledBorder: inputBorder,
          focusedBorder: inputBorder.copyWith(
            borderSide: BorderSide(color: cs.primary, width: 2.0),
          ),
          filled: true,
          fillColor: cs.surface,
          hintText: 'اكتب كلمة البحث...',
          prefixIcon: Icon(Icons.search, color: cs.onSurface.withOpacity(0.55)),
          hintStyle: TextStyle(color: cs.onSurface.withOpacity(0.55)),
        ),
      ),
    );
  }
}

class _ResultsList extends StatelessWidget {
  final bool loading;
  final String? error;
  final GlobalSearchResult? result;
  const _ResultsList(
      {required this.loading, required this.error, required this.result});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text('خطأ: $error'));
    }
    final cats = result?.categories ?? const <GlobalSearchCategory>[];
    if (cats.isEmpty) {
      return const Center(child: Text('لا توجد نتائج'));
    }
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: cats.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (context, i) {
        final c = cats[i];
        return InkWell(
          onTap: () {
            context.pushNamed('filtered_ads', extra: {
              'categorySlug': c.categorySlug,
              'categoryName': c.categoryName,
              'currentFilters': {'q': (result?.keyword ?? '').trim()},
            });
          },
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: cs.primary.withOpacity(0.15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: cs.primary),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(result?.keyword ?? '',
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface)),
                      SizedBox(height: 4.h),
                      Text('القسم: ${c.categoryName}',
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: cs.onSurface.withOpacity(0.8))),
                    ],
                  ),
                ),
                Text('عدد الإعلانات ${c.count}',
                    style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: cs.primary)),
              ],
            ),
          ),
        );
      },
    );
  }
}
