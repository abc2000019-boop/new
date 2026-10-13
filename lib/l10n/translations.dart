import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Translations {
  static Locale currentLocale = const Locale('ar');

  static final Map<String, Map<String, String>> _data = {
    'ar': {
      'appTitle': 'Smart Home',
      'myDevices': 'أجهزتي',
      'addDevice': 'إضافة جهاز جديد',
      'deviceName': 'اسم الجهاز (mDNS)',
      'wifiName': 'شبكة الواي فاي',
      'wifiPass': 'باسورد الشبكة',
      'adminUser': 'يوزر الأدمن',
      'adminPass': 'باسورد الأدمن',
      'cancel': 'إلغاء',
      'add': 'إضافة',
      'save': 'حفظ',
      'back': 'رجوع',
      'masterToggle': 'تشغيل / إيقاف الكل',
      'deleteDevice': 'حذف هذا الجهاز',
      'relayNames': 'أسماء الريلايات',
      'deviceSettings': 'إعدادات الجهاز',
      'oldPass': 'كلمة السر القديمة',
      'newPass': 'كلمة السر الجديدة',
      'change': 'تغيير',
      'dangerZone': 'منطقة الخطر',
      'scheduleTitle': 'الجدولة الأسبوعية',
      'logTitle': 'السجل',
      'refresh': 'تحديث',
      'otaTitle': 'تحديث النظام (OTA)',
      'chooseFile': 'اختر ملف .bin',
      'upload': 'رفع',
      'navHome': 'الرئيسية',
      'navSettings': 'الإعدادات',
      'navSchedule': 'الجدولة',
      'navLog': 'السجل',
      'navOta': 'OTA',
      'noDevices': 'لا توجد أجهزة. اضغط + لإضافة جهاز.',
      'online': 'متصل',
      'offline': 'غير متصل',
      'connecting': 'جاري الاتصال...',
      'deleted': 'تم الحذف',
      'saved': 'تم الحفظ',
      'added': 'تمت الإضافة',
      'requiredFields': 'املأ كل الحقول',
      'on': 'مشغل',
      'off': 'مغلق',
      'relayN': 'ريلاي',
      'scanWifi': 'بحث عن الشبكات',
      'manualWifi': 'شبكة مخفية؟ اكتب الاسم يدوياً',
      'advanced': 'إعدادات متقدمة (اختياري)',
      'useStaticIP': 'استخدام IP ثابت (احتياطي)',
      'fallbackIp': 'IP الاحتياطي',
      'loginSuccess': 'تم تسجيل الدخول',
      'loginFailed': 'فشل تسجيل الدخول',
    },
    'en': {
      'appTitle': 'Smart Home',
      'myDevices': 'My Devices',
      'addDevice': 'Add New Device',
      'deviceName': 'Device Name (mDNS)',
      'wifiName': 'WiFi Network',
      'wifiPass': 'WiFi Password',
      'adminUser': 'Admin User',
      'adminPass': 'Admin Password',
      'cancel': 'Cancel',
      'add': 'Add',
      'save': 'Save',
      'back': 'Back',
      'masterToggle': 'Toggle All',
      'deleteDevice': 'Delete This Device',
      'relayNames': 'Relay Names',
      'deviceSettings': 'Device Settings',
      'oldPass': 'Old Password',
      'newPass': 'New Password',
      'change': 'Change',
      'dangerZone': 'Danger Zone',
      'scheduleTitle': 'Weekly Schedule',
      'logTitle': 'Log',
      'refresh': 'Refresh',
      'otaTitle': 'OTA Update',
      'chooseFile': 'Choose .bin file',
      'upload': 'Upload',
      'navHome': 'Home',
      'navSettings': 'Settings',
      'navSchedule': 'Schedule',
      'navLog': 'Log',
      'navOta': 'OTA',
      'noDevices': 'No devices. Tap + to add.',
      'online': 'Online',
      'offline': 'Offline',
      'connecting': 'Connecting...',
      'deleted': 'Deleted',
      'saved': 'Saved',
      'added': 'Added',
      'requiredFields': 'Fill all fields',
      'on': 'ON',
      'off': 'OFF',
      'relayN': 'Relay',
      'scanWifi': 'Scan WiFi',
      'manualWifi': 'Hidden network? Enter name manually',
      'advanced': 'Advanced (Optional)',
      'useStaticIP': 'Use static IP (fallback)',
      'fallbackIp': 'Fallback IP',
      'loginSuccess': 'Login OK',
      'loginFailed': 'Login Failed',
    },
  };

  static String t(String key) {
    return _data[currentLocale.languageCode]?[key] ?? key;
  }

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('lang') ?? 'ar';
    currentLocale = Locale(lang);
  }

  static Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang', lang);
    currentLocale = Locale(lang);
  }
}