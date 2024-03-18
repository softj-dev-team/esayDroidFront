import 'dart:io';
import 'package:esaydroid/helper/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:esaydroid/models/Task.dart';
import 'package:logger/logger.dart';

class AdbShellCommand {
  @override
  void initState() {
  }
  var logger = Logger(
    printer: PrettyPrinter(),
  );

  var loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );


  Future<void> runAdbShellMultiDevices( List<Map<String, dynamic>> devices,String? selectedDirectory,BuildContext context) async {
    if (devices.isEmpty) {
      customToast(context, "장치를 먼저 선택해주세요.");
      return;
    }
    for (var device in devices) {
      String deviceId = device['deviceId'] as String;

      try {
        var result = await Process.run(
          'adb',
          ['-s', deviceId, 'shell', 'input', 'keyevent', 'KEYCODE_HOME'],
          workingDirectory: selectedDirectory,
        );

        logger.d('runAdbShellMultiDevices Success: ${result.stdout}');
      } on ProcessException catch (e) {
        logger.e('Error running adb command on $deviceId', error: e, stackTrace: StackTrace.current); throw e;
      } catch (e, stackTrace) {
        logger.e('Unexpected error: $e', error: e, stackTrace: stackTrace); throw e;
      }
    }
  }
  Future<List<String>> runTaskAdbShellMultiDevices(List<String> devices, String? selectedDirectory, BuildContext context) async {
    List<String> results = []; // 작업 결과를 저장할 리스트

    // Future.wait를 사용하여 모든 디바이스에 대한 작업을 병렬로 실행
    await Future.wait(devices.map((device) async {
      try {
        // APK 파일 설치
        var installResult = await Process.run('adb', ['-s', device, 'install', '-r', './app/build/outputs/apk/debug/app-debug.apk'], workingDirectory: selectedDirectory);
        if (installResult.exitCode != 0) throw Exception('Installation failed');

        // 테스트 APK 파일 설치
        var installTestResult = await Process.run('adb', ['-s', device, 'install', '-r', './app/build/outputs/apk/androidTest/debug/app-debug-androidTest.apk'], workingDirectory: selectedDirectory);
        if (installTestResult.exitCode != 0) throw Exception('Test APK installation failed');

        // 테스트 실행
        var testResult = await Process.run('adb', ['-s', device, 'shell', 'am', 'instrument', '-w', '-e', 'class', 'com.example.uiautomator.uiAutoMator', 'com.example.uiautomator.test/androidx.test.runner.AndroidJUnitRunner'], workingDirectory: selectedDirectory);
        if (testResult.exitCode != 0) throw Exception('Tests failed');

        results.add("Success on device $device");
      } on ProcessException catch (e) {
        results.add('Error running adb command on $device: ${e.message}');
      } catch (e) {
        results.add('Unexpected error on device $device: $e');
      }
    }));

    return results; // 작업 결과를 포함한 리스트 반환
  }
}