import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNav extends StatefulWidget {
  final int currentIndex;

  const CustomBottomNav({Key? key, required this.currentIndex}) : super(key: key);

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {

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
          case 3:
            {
            //  context.push('/favorite');
            }

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
          icon: SizedBox(
            width: 26.w,
            height: 26.h,
            child: SvgPicture.asset(
              "assets/svg/chat.svg",
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(
                widget.currentIndex == 3
                    ? cs.secondary // لون المختار
                    : cs.onSurface, // لون غير المختار
                BlendMode.srcIn,
              ),
            ),
          ),
          label:" رسائل",
        ),
        BottomNavigationBarItem(
          icon: FaIcon(FontAwesomeIcons.gear),
          label:"الإعدادات",
        ),
      ],
    );
  }
}
