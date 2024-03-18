import 'dart:convert';
import 'package:esaydroid/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'helper/toast_helper.dart'; // LoginPage를 import합니다.
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<SignUpPage> createState() => _SignUpPage();
}

class _SignUpPage extends State<SignUpPage> {
  GlobalKey emailInputKey = GlobalKey();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController authCodeController = TextEditingController();
  bool _isLoading = false; // 로딩 상태 변수
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // 로딩 중 인디케이터 표시
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/logo.png',
                width: 320.0, height: 320.0
            ),
            SizedBox(height: 20), // 로고와 입력란 사이 간격
            emailInputSection(context), // 이메일 입력란과 전송 버튼을 포함한 섹션
            SizedBox(height: 10), // 첫 번째 열과 두 번째 열 사이 간격
            authCodeInputSection(context), // 인증코드 입력란
            SizedBox(height: 20), // 첫 번째 열과 두 번째 열 사이 간격
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                ),
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Text(
                    'Login',
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

  @override
  void dispose() {
    // 컨트롤러를 위젯이 제거될 때 정리
    emailController.dispose();
    super.dispose();
  }

  Widget emailInputSection(BuildContext context) {
    return Container(
      key: emailInputKey, // GlobalKey 할당
      width: 300.0, // TextField의 너비
      child: TextField(
        controller: emailController,
        decoration: InputDecoration(
          labelText: '이메일',
          // border: OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: Icon(Icons.send, color: Colors.blue[800]), // 아이콘 색상을 진한 블루로 설정
            onPressed: () {
              // 전송 버튼 기능
              sendEmail(); // 여기에서 sendEmail 함수 호출
            },
          ),
        ),
      ),
    );
  }

  Widget authCodeInputSection(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 300.0, // TextField의 너비
          child: TextField(
            controller: authCodeController,
            decoration: InputDecoration(
              labelText: '인증코드',
              // border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.verified_user, color: Colors.blue[800]), // 아이콘 색상을 진한 블루로 설정
                onPressed: () {
                  // 전송 버튼 기능
                  sendAuthCode();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
  void sendAuthCode() async {

    if (emailController.text.isEmpty || authCodeController.text.isEmpty) {
      showCustomToast(context, emailInputKey, "이메일과 인증코드를 모두 입력해주세요.");
      return;
    }

    var url = Uri.parse('FlutterConfig.get('api_host');/api/user-register');
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: json.encode({
        "email": emailController.text,
        "authCode": authCodeController.text
      }),
    );

    var responseData = json.decode(response.body);
    if (response.statusCode == 200) {
      showCustomToast(context, emailInputKey, responseData['message']);
    } else if (response.statusCode==500) {
      showCustomToast(context, emailInputKey, responseData['error']);
    } else {
      showCustomToast(context, emailInputKey, "인증 실패");
    }
  }
  void sendEmail() async {
    try {
      if (emailController.text.isEmpty) {
        showCustomToast(context, emailInputKey, "이메일을 입력해주세요.");
        return;
      }

      String email = emailController.text; // 입력된 이메일 가져오기
      var url = Uri.parse('FlutterConfig.get('api_host');/api/send-verification-email');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"email": email}),
      );
      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        showCustomToast(context, emailInputKey, responseData['message']);
      } else if (response.statusCode==500) {
        showCustomToast(context, emailInputKey, responseData['error']);
      } else {
        showCustomToast(context, emailInputKey, "이메일 전송 실패");
      }
    } catch (e) {
      // 네트워크 요청 중 에러 처리
      showCustomToast(context, emailInputKey, "네트워크 오류가 발생했습니다.");
    }
  }

}