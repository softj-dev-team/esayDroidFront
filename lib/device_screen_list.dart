import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class DeviceIdScreen extends StatefulWidget {
  @override
  _DeviceIdScreenState createState() => _DeviceIdScreenState();
}

class _DeviceIdScreenState extends State<DeviceIdScreen> {
  String deviceId = "디바이스 ID를 가져오는 중...";

  @override
  void initState() {
    super.initState();
    fetchDeviceId();
  }

  Future<void> fetchDeviceId() async {
    // adb 명령어를 실행하여 ANDROID_ID를 가져옵니다.
    var result = await Process.run(
      'adb',
      ['shell', 'settings', 'get', 'secure', 'android_id'],
    );

    // 결과에서 디바이스 ID를 추출하여 상태를 업데이트합니다.
    setState(() {
      deviceId = result.stdout.trim(); // 출력의 공백을 제거합니다.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ADB Device ID"),
      ),
      body: Center(
        child: Text(deviceId),
      ),
    );
  }
}