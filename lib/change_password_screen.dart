import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'global_config.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  Future<void> changePassword() async {
    var url = Uri.parse('${GlobalConfig.apiHost}/api/change-password');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'email': _emailController.text,
        'currentPassword': _currentPasswordController.text,
        'newPassword': _newPasswordController.text,
      }),
    );

    if (response.statusCode == 200) {
      // 비밀번호 변경 성공
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('비밀번호가 성공적으로 변경되었습니다.')));
    } else {
      // 오류 처리
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('비밀번호 변경에 실패하였습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('비밀번호 변경'),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: '이메일'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력해주세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _currentPasswordController,
                decoration: InputDecoration(labelText: '현재 비밀번호'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '현재 비밀번호를 입력해주세요.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(labelText: '새 비밀번호'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '새 비밀번호를 입력해주세요.';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    changePassword();
                  }
                },
                child: Text('비밀번호 변경'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
