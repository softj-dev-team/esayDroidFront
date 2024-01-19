import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey emailInputKey = GlobalKey();
  final TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 배경색을 흰색으로 설정
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/logo.png', width: 320.0, height: 320.0),
            SizedBox(height: 20), // 로고와 입력란 사이 간격
            emailInputSection(context), // 이메일 입력란과 전송 버튼을 포함한 섹션
            SizedBox(height: 10), // 첫 번째 열과 두 번째 열 사이 간격
            authCodeInputSection(context), // 인증코드 입력란
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
          border: OutlineInputBorder(),
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

            decoration: InputDecoration(
              labelText: '인증코드',
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.verified_user, color: Colors.blue[800]), // 아이콘 색상을 진한 블루로 설정
                onPressed: () {
                  // 전송 버튼 기능
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
  void sendEmail() async {
    String email = emailController.text; // 입력된 이메일 가져오기
    var url = Uri.parse('https://esaydroid.softj.net/api/send-verification-email');
    var response = await http.post(
      url,
      headers: {

        "Content-Type": "application/json",

      },
      body: json.encode({"email": email}),
    );

    if (response.statusCode == 200) {
        showCustomToast(context,emailInputKey,"이메일 전송 성공: ${json.decode(response.body)['message']}");
    } else {
        showCustomToast(context,emailInputKey,"이메일 전송 실패: ${json.decode(response.body)['error']}");

    }
  }
  void showCustomToast(BuildContext context, GlobalKey widgetKey,String message) {
    final renderBox = widgetKey.currentContext
        ?.findRenderObject() as RenderBox?;
    final widgetPosition = renderBox?.localToGlobal(Offset.zero);
    if (widgetPosition != null) {
      final overlay = Overlay.of(context);
      final overlayEntry = OverlayEntry(
        builder: (context) =>
            Positioned(
              top: widgetPosition.dy - 70, // 위젯 위 20px
              left: MediaQuery.of(context).size.width * 0.1,
              right: MediaQuery.of(context).size.width * 0.1,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(message, style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
      );


      overlay?.insert(overlayEntry);

      // 토스트 지속 시간 설정
      Future.delayed(Duration(seconds: 4), () => overlayEntry.remove());
    }
  }

}
