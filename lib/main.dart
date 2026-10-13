import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'l10n/translations.dart';

void main() {
  runApp(const SmartHomeApp());
}

class SmartHomeApp extends StatefulWidget {
  const SmartHomeApp({super.key});

  @override
  State<SmartHomeApp> createState() => _SmartHomeAppState();
}

class _SmartHomeAppState extends State<SmartHomeApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF007BFF),
        scaffoldBackgroundColor: const Color(0xFFF0F4F8),
        fontFamily: 'Segoe UI',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007BFF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Color(0xFF007BFF)),
          titleTextStyle: TextStyle(
            color: Color(0xFF007BFF),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      locale: Translations.currentLocale,
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const ResponsiveWrapper(
        child: HomeScreen(),
      ),
    );
  }
}

/// 🎯 Wrapper لجعل التطبيق يتكيف مع أي حجم شاشة
class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  const ResponsiveWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // على الشاشات الكبيرة (تابلت، ديسكتوب) نخلي التطبيق في وسط الشاشة
        // بعرض أقصى 600 بكسل (زي الموبايل)
        if (constraints.maxWidth > 600) {
          return Container(
            color: const Color(0xFFE2E8F0),
            child: Center(
              child: Container(
                width: 600,
                height: constraints.maxHeight,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: child,
                ),
              ),
            ),
          );
        }
        // على الموبايل، املأ الشاشة
        return child;
      },
    );
  }
}