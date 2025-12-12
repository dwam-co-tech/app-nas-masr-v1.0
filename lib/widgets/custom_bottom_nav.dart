import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:nas_masr_app/core/data/reposetory/chat_repository.dart';

class CustomBottomNav extends StatefulWidget {
  final int currentIndex;

  const CustomBottomNav({Key? key, required this.currentIndex})
      : super(key: key);

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  int _unread = 0;
  bool _loadingUnread = false;
  final ChatRepository _chatRepo = ChatRepository();
  Timer? _unreadTimer;

  @override
  void initState() {
    super.initState();
    _loadUnread();
    _unreadTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      _loadUnread();
    });
  }

  Future<void> _loadUnread() async {
    if (_loadingUnread) return;
    setState(() => _loadingUnread = true);
    try {
      final count = await _chatRepo.fetchUnreadCount();
      if (mounted) setState(() => _unread = count);
    } catch (_) {
      if (mounted) setState(() => _unread = 0);
    } finally {
      if (mounted) setState(() => _loadingUnread = false);
    }
  }

  @override
  void dispose() {
    _unreadTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: cs.surface,
      currentIndex: widget.currentIndex,
      showUnselectedLabels: true,
      selectedItemColor: cs.secondary,
      unselectedItemColor: cs.onSurface,
      onTap: (index) async {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/manage_ads');
            break;
          case 2:
            {
              context.go('/creat_ad');
            }
            break;
          case 3:
            {
              context.go('/inbox');
              _loadUnread();
            }
            break;

          case 4:
            context.go('/settings');
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: SizedBox(
            width: 26.w,
            height: 26.h,
            child: SvgPicture.asset(
              "assets/svg/home.svg",
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(
                widget.currentIndex == 0
                    ? cs.secondary // لون المختار
                    : cs.onSurface, // لون غير المختار
                BlendMode.srcIn,
              ),
            ),
          ),
          label: "الرئيسية",
        ),
        BottomNavigationBarItem(
          icon: SizedBox(
            width: 26.w,
            height: 26.h,
            child: SvgPicture.asset(
              "assets/svg/my_ad.svg",
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(
                widget.currentIndex == 1
                    ? cs.secondary // لون المختار
                    : cs.onSurface, // لون غير المختار
                BlendMode.srcIn,
              ),
            ),
          ),
          label: "إعلاناتي",
        ),
        BottomNavigationBarItem(
          icon: Center(
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary,
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.plus,
                  color: Colors.white, // لون الزائد
                  size: 18,
                ),
              ),
            ),
          ),
          label: "نشر",
        ),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: 26.w,
                height: 26.h,
                child: SvgPicture.asset(
                  "assets/svg/chat.svg",
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    widget.currentIndex == 3 ? cs.secondary : cs.onSurface,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              if (_unread > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: cs.secondary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      _unread.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
            ],
          ),
          label: " رسائل",
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.gear),
          label: "الإعدادات",
        ),
      ],
    );
  }
}
