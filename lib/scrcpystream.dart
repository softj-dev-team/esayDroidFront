import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scrcpy Stream Display',
      home: ScrcpyScreen(),
    );
  }
}

class ScrcpyScreen extends StatefulWidget {
  @override
  _ScrcpyScreenState createState() => _ScrcpyScreenState();
}

class _ScrcpyScreenState extends State<ScrcpyScreen> {
  late Stream<String> scrcpyStream;

  @override
  void initState() {
    super.initState();
    scrcpyStream = startScrcpy();
  }

  Stream<String> startScrcpy() async* {
    // 여기에 Scrcpy를 시작하는 로직 추가
    var process = await Process.start('scrcpy', [
      '-s', 'emulator-5556',
      // '-m', '740', // 최대 크기를 1024 픽셀로 제한
      '--window-width', '280', // 창 폭을 800으로 설정
      // '--window-height', '600', // 창 높이를 600으로 설정
    ]);

    // stdout을 스트림으로 변환
    yield* process.stdout.transform(utf8.decoder);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scrcpy Stream Display'),
      ),
      body: StreamBuilder<String>(
        stream: scrcpyStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Scrcpy 출력 데이터를 화면에 표시하는 로직
            return Center(child: Text(snapshot.data!));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
