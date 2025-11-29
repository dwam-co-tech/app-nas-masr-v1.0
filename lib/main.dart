import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nas_masr_app/core/data/providers/home_provider.dart';
import 'package:nas_masr_app/core/data/reposetory/home_repository.dart';
import 'package:nas_masr_app/core/theming/colors.dart';
import 'package:provider/provider.dart';
import 'package:nas_masr_app/core/data/providers/auth_provider.dart';
import 'package:nas_masr_app/core/data/reposetory/auth_repository.dart';
import 'package:nas_masr_app/core/data/web_services/api_services.dart';
import 'package:nas_masr_app/core/data/providers/profile_provider.dart';
import 'package:nas_masr_app/core/data/reposetory/profile_repository.dart';
import 'screens/splash_screen.dart';
import 'core/router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Transparent status bar background
    statusBarIconBrightness: Brightness.dark, // Android icons (clock/battery) in white
    statusBarBrightness: Brightness.dark, // iOS: light (white) content
  ));
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            repository: AuthRepository(apiService: ApiService()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => HomeProvider(
            repository: HomeRepository(api: ApiService()),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            repository: ProfileRepository(api: ApiService()),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

   @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375,812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => MaterialApp.router(
        title: 'ناس مصر',
        theme: ThemeData(
          // اعتماد مخطط ألوان ColorScheme لضمان اتساق بصري أفضل
          colorScheme: const ColorScheme.light(
            primary: ColorManager.primaryColor,
            secondary: ColorManager.secondaryColor,
            surface: Colors.white,
            onSurface: ColorManager.primary_font_color,
            onPrimary: Colors.white,
          ),
          // الحفاظ على الخصائص الحالية لضمان عدم تغيّر السلوك القائم
          primaryColor: ColorManager.primaryColor,
          hintColor: ColorManager.secondaryColor,
          scaffoldBackgroundColor: Colors.white,
          
          // ضبط الخط افتراضياً (لن يؤثر إن لم يكن الخط متاحاً ضمن الأصول)
          
          
          
          fontFamily: 'Tajawal',
         
          textTheme: TextTheme(
            titleLarge: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF024950),
            ),
            bodyMedium: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF024950),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF7F7F7),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E3E5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E3E5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: ColorManager.primaryColor, width: 1.4),
            ),
            hintStyle: const TextStyle(color: Color(0xFF9AA0A6)),
            labelStyle: const TextStyle(color: Color(0xFF5F6368)),
          ),
          useMaterial3: false,
        ),
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.router,
        builder: (context, child) {
          return MediaQuery.withClampedTextScaling(
            minScaleFactor: 1.0,
            maxScaleFactor: 1.0,
            child: child!,
          );
        }
      ),
    );
  }
}