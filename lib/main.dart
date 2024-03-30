import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'best_flutter_ui_templates/app_theme.dart';
import 'global_config.dart';
import 'navigation_home_screen.dart';
import 'login_page.dart'; // LoginPage를 import합니다.

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  await dotenv.load(fileName: ".env");    // 2번코드
  GlobalConfig.initialize(); // GlobalConfig 초기화
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  // 생성자에서 isLoggedIn을 받도록 수정
  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);
  // const MyApp({super.key});
  final bool isLoggedIn; // isLoggedIn을 멤버 변수로 추가
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness:
        !kIsWeb && Platform.isAndroid ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: AppTheme.textTheme,
        platform: TargetPlatform.iOS,
      ),
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? NavigationHomeScreen(): LoginPage(),
      // home: NavigationHomeScreen(),
      // home: SettingScreen(),
    );
  }
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}


