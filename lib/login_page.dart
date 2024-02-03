import 'dart:convert';
import 'package:esaydroid/setting_screen.dart';
import 'package:esaydroid/sign_up_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'helper/toast_helper.dart';
import 'package:http/http.dart' as http;
import 'package:esaydroid/best_flutter_ui_templates/app_theme.dart';
import 'main.dart';
import 'navigation_home_screen.dart';
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}
final TextEditingController emailController = TextEditingController(text: "dev@softj.net");
final TextEditingController passwordController = TextEditingController(text: "!1qazsoftj");
class _LoginPageState extends State<LoginPage> {
  GlobalKey inputKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:AppTheme.nearlyWhite,
        appBar: AppBar(
        title: Text(''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/logo.png', width: 320.0, height: 320.0),
            SizedBox(height: 20), // 로고와 입력란 사이 간격
            emailInputSection(context),
            SizedBox(height: 10), // 첫 번째 열과 두 번째 열 사이 간격
            passwordInputSection(context),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  // width: 300.0, // 버튼의 가로 사이즈를 최대로 설정
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue[900], // 버튼의 배경색을 진한 블루로 설정
                      onPrimary: Colors.white, // 버튼의 텍스트 색상을 흰색으로 설정
                    ),
                    onPressed: _login,
                    child: Text('로그인'),
                  ),
                ),
                SizedBox(width: 20),
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignUpPage(title: '회원가입',)));
                  },
                  child: Text(
                    'Sing up',
                    style: TextStyle(decoration: TextDecoration.none, color: Colors.blue.shade900),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget emailInputSection(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          key: inputKey, // GlobalKey 할당
          width: 300.0, // TextField의 너비
          child: TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: '이메일',
              // border: OutlineInputBorder(),

            ),
          ),
        ),
      ],
    );
  }
  Widget passwordInputSection(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 300.0, // TextField의 너비
          child: TextField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: '비밀번호',
              // border: OutlineInputBorder(),

            ),
          ),
        ),
      ],
    );
  }
  // 로그인 버튼 클릭 시 호출될 함수
  void _login() async {
    String email = emailController.text;
    String password = passwordController.text;

    // 이메일과 비밀번호 유효성 검사
    if (email.isEmpty || password.isEmpty) {
      showCustomToast(context, inputKey, "이메일과 비밀번호를 모두 입력해주세요.");
      return;
    }

    try {
      var url = Uri.parse('https://esaydroid.softj.net/api/login');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"email": email, "password": password}),
      );

      // 응답 처리
      if (response.statusCode == 200) {
        // 로그인 성공: 다음 화면으로 네비게이션
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userEmail', email);

        // 메인 페이지로 네비게이션
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NavigationHomeScreen()));
      } else if (response.statusCode == 500) {
        // 서버 에러: 에러 메시지 표시
        var responseData = json.decode(response.body);
        showCustomToast(context, inputKey, responseData['error']);
      } else {
        // 그 외의 에러: 기본 에러 메시지 표시
        showCustomToast(context, inputKey, "로그인 실패");
      }
    } catch (e) {
      // 네트워크 오류 또는 기타 예외 처리
      showCustomToast(context, inputKey, "로그인 중 오류가 발생했습니다: $e");
    }
  }
}
