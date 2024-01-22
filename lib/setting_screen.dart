import 'dart:convert';
import 'helper/toast_helper.dart';
import 'package:esaydroid/best_flutter_ui_templates/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}
final TextEditingController searchStringController = TextEditingController();
final TextEditingController targetTitleStringController = TextEditingController();

class _SettingScreenState extends State<SettingScreen> {
  List<dynamic> records = [];
  String? _selectedDirectory;
  @override
  void initState() {
    super.initState();
    loadData();
    _loadDirectory();
  }
  GlobalKey inputKey = GlobalKey();

  Future<String> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // 'userEmail' 키가 없는 경우 빈 문자열 반환
    return prefs.getString('userEmail') ?? '';
  }

  Future<void> _loadDirectory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedDirectory = prefs.getString('workingDirectory');
    });
  }
  Future<void> _pickDirectory() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('workingDirectory', selectedDirectory);
      setState(() {
        _selectedDirectory = selectedDirectory;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    // 화면의 너비를 가져옵니다.

    return Container(
      color: isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor:
              isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: <Widget>[
                SizedBox(height: 150),
                Row(
                  mainAxisSize: MainAxisSize.min, // Row의 크기를 자식의 크기에 맞춤
                  children: <Widget>[
                    Text(
                      '검색어와 타겟영상제목을 입력하고',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isLightMode ? Colors.black : Colors.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min, // Row의 크기를 자식의 크기에 맞춤
                  children: <Widget>[
                    Text(
                      '저장하세요',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isLightMode ? Colors.black : Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20), // 로고와 입력란 사이 간격
                searchStringInputSection(context),
                SizedBox(height: 10), // 첫 번째 열과 두 번째 열 사이 간격
                targetTitleInputSection(context),
                SizedBox(height: 70), // 첫 번
                // 세로고침 아이콘 추가
                Row(
                  mainAxisSize: MainAxisSize.min, // Row의 크기를 자식의 크기에 맞춤
                  children: <Widget>[
                    Text(
                      'List',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isLightMode ? Colors.black : Colors.white,
                      ),
                    ),
                    SizedBox(width: 40), // 텍스트와 아이콘 사이의 간격
                    IconButton(
                      icon: Icon(FontAwesomeIcons.folder),
                      onPressed: _pickDirectory,
                    ),
                    IconButton(
                      icon: Icon(FontAwesomeIcons.github),
                      onPressed: () {
                        runGitPulCommand();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.bug_report_outlined),
                      onPressed: () {
                        assembleDebug();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.bug_report),
                      onPressed: () {
                        assembleAndroidTest();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.play_arrow_sharp),
                      onPressed: () {
                        runCommand();
                      },
                    ),
                    IconButton(
                      icon: Icon(FontAwesomeIcons.stop),
                      onPressed: () {
                        stopCommand();
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        loadData(); // 세로고침 아이콘 클릭 시 loadData() 호출
                      },
                    ),
                  ],
                ),

                SizedBox(height: 10),
                titleList(context)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> deleteVideo(String id) async {
    try {
      var url = Uri.parse('https://esaydroid.softj.net/api/delete-video/$id');
      var response = await http.delete(
        url,
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        showCustomToast(context, inputKey, "삭제 성공");
        loadData(); // 데이터 갱신
      } else {
        showCustomToast(context, inputKey, "삭제 실패: ${json.decode(response.body)['error']}");
      }
    } catch (e) {
      showCustomToast(context, inputKey, "네트워크 오류: $e");
    }
  }
  Future<void> runGitPulCommand() async {
    if (_selectedDirectory == null) {
      showCustomToast(context, inputKey,"경로를 먼저 선택해주세요.");
      return;
    }
    try {

      ProcessResult result = await Process.run(
          'cmd',
          ['/c', 'gradlew', 'gitPullOriginMain'],
          workingDirectory: _selectedDirectory
      );

      if (result.exitCode == 0) {
        // 명령어 실행이 성공한 경우
        showCustomToast(context, inputKey,"성공: ${result.stdout}");
      } else {
        // 명령어 실행에 실패한 경우
        showCustomToast(context, inputKey, "실패: ${result.stderr}");
      }
    } catch (e) {
      showCustomToast(context, inputKey, '오류: $e');
    }
  }

  Future<void> runCommand() async {
    if (_selectedDirectory == null) {
      showCustomToast(context, inputKey,"경로를 먼저 선택해주세요.");
      return;
    }
    try {

      //실행전 서버의 작업 스케쥴을 등록한다.
      saveRunTask();

      var result = await Process.run(
          'cmd',
          ['/c', 'gradlew', 'runParallelTests'],
          workingDirectory: _selectedDirectory
      );
      if (result.exitCode == 0) {
        // 명령어 실행이 성공한 경우
        showCustomToast(context, inputKey,"성공: ${result.stdout}");
      } else {
        // 명령어 실행에 실패한 경우
        showCustomToast(context, inputKey, "실패: ${result.stderr}");
      }
    } catch (e) {

      showCustomToast(context, inputKey, '오류: $e');
    }
  }
  Future<void> stopCommand() async {
    if (_selectedDirectory == null) {
      showCustomToast(context, inputKey,"경로를 먼저 선택해주세요.");
      return;
    }
    try {

      var result = await Process.run(
          'cmd',
          ['/c', 'gradlew', 'stopAppOnAllDevices'],
          workingDirectory: _selectedDirectory
      );
      if (result.exitCode == 0) {
        // 명령어 실행이 성공한 경우
        showCustomToast(context, inputKey,"성공: ${result.stdout}");
      } else {
        // 명령어 실행에 실패한 경우
        showCustomToast(context, inputKey, "실패: ${result.stderr}");
      }
    } catch (e) {

      showCustomToast(context, inputKey, '오류: $e');
    }
  }
  Future<void> assembleDebug() async {
    if (_selectedDirectory == null) {
      showCustomToast(context, inputKey,"경로를 먼저 선택해주세요.");
      return;
    }
    try {

      var result = await Process.run(
          'cmd',
          ['/c', 'gradlew', 'assembleDebug'],
          workingDirectory: _selectedDirectory
      );
      if (result.exitCode == 0) {
        // 명령어 실행이 성공한 경우
        showCustomToast(context, inputKey,"성공: ${result.stdout}");
      } else {
        // 명령어 실행에 실패한 경우
        showCustomToast(context, inputKey, "실패: ${result.stderr}");
      }
    } catch (e) {

      showCustomToast(context, inputKey, '오류: $e');
    }
  }
  Future<void> assembleAndroidTest() async {
    if (_selectedDirectory == null) {
      showCustomToast(context, inputKey,"경로를 먼저 선택해주세요.");
      return;
    }
    try {

      var result = await Process.run(
          'cmd',
          ['/c', 'gradlew', 'assembleAndroidTest'],
          workingDirectory: _selectedDirectory
      );
      if (result.exitCode == 0) {
        // 명령어 실행이 성공한 경우
        showCustomToast(context, inputKey,"성공: ${result.stdout}");
      } else {
        // 명령어 실행에 실패한 경우
        showCustomToast(context, inputKey, "실패: ${result.stderr}");
      }
    } catch (e) {

      showCustomToast(context, inputKey, '오류: $e');
    }
  }
  Future<void> saveRunTask() async {
    try {
      var url = Uri.parse('https://esaydroid.softj.net/api/create-run-task');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": await getUserEmail(),
        }),
      );

      if (response.statusCode == 200) {
        showCustomToast(context, inputKey, "작업 등록 성공");
        // 데이터 저장 후 목록 갱신
      } else {
        showCustomToast(context, inputKey, "저장 실패: ${json.decode(response.body)['error']}");
      }
    } catch (e) {
      showCustomToast(context, inputKey, "네트워크 오류: $e");
    }
  }

  Widget titleList(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Expanded(
      child: Container(
        width: screenWidth * 0.8, // 전체 화면 너비의 80%로 설정
        child: ListView.builder(
          itemCount: records.length,
          itemBuilder: (context, index) {
            var record = records[index];
            var formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(record['reg_date']));
            bool isOn = record['use_status_cd'] == 1;

            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    // 제목과 검색어
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("타겟영상제목: ${record['title']}", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("검색어: ${record['keyword']}"),
                        ],
                      ),
                    ),
                    // 버튼 및 등록일
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(formattedDate, style: TextStyle(fontSize: 12)), // 등록일
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red.shade600),
                          onPressed: () {
                            deleteVideo(record['id'].toString());
                          },
                        ),
                        IconButton(
                          icon: Icon(isOn ? Icons.toggle_on : Icons.toggle_off, color: isOn ? Colors.blue[900] : Colors.grey, size: 40.0),
                          onPressed: () {
                            callJsonUriWithId(record['id'].toString());
                          },
                        ),

                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<http.Response> callJsonUriWithId(String id) async {
    var url = Uri.parse('https://esaydroid.softj.net/api/use-status-change'); // 실제 URL로 변경
    var body = json.encode({'id': id});

    try {
      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      loadData();
      return response;
    } catch (e) {
      // 네트워크 오류 또는 기타 예외 처리
      print('Error: $e');
      throw Exception('서버 요청 실패');
    }
  }
  Widget searchStringInputSection(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          key: inputKey, // GlobalKey 할당
          width: 300.0, // TextField의 너비
          child: TextField(
            controller: searchStringController,
            decoration: InputDecoration(
              labelText: '검색어',
              // border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget targetTitleInputSection(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 300.0, // TextField의 너비
          child: TextField(
            controller: targetTitleStringController,
            decoration: InputDecoration(
              labelText: '타겟영상제목',
              // border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(FontAwesomeIcons.paperPlane, color: Colors.blue[900]), // 아이콘 색상을 진한 블루로 설정
                onPressed: () {
                  // 전송 버튼 기능
                  handleSubmit();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  void handleSubmit() async {
    String userEmail = await getUserEmail();
    String targetTitle = targetTitleStringController.text;
    String searchString = searchStringController.text;

    if (targetTitle.isEmpty || searchString.isEmpty) {
      showCustomToast(context, inputKey, "모든 필드를 입력해주세요.");
      return;
    }

    saveTitle(userEmail, targetTitle, searchString);
  }
  Future<void> saveTitle(String userEmail, String targetTitle, String searchString) async {
    try {
      var url = Uri.parse('https://esaydroid.softj.net/api/save-title');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": userEmail,
          "title": targetTitle,
          "keyword": searchString,
        }),
      );

      if (response.statusCode == 200) {
        showCustomToast(context, inputKey, "저장 성공");
        // 데이터 저장 후 목록 갱신
        loadData();
      } else {
        showCustomToast(context, inputKey, "저장 실패: ${json.decode(response.body)['error']}");
      }
    } catch (e) {
      showCustomToast(context, inputKey, "네트워크 오류: $e");
    }
  }

  Future<List<dynamic>> getAllRecords(String userEmail) async {
    try {
      var url = Uri.parse('https://esaydroid.softj.net/api/get-all-records');
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"user_id": userEmail}),
        // body: json.encode({"user_id": "majorsafe4@gmail.com"}),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data != null) {
          return data;
        } else {
          throw Exception("데이터가 비어있습니다.");
        }
      } else {
        throw Exception("데이터 불러오기 실패: ${json.decode(response.body)['error']}");
      }
    } catch (e) {
      throw Exception("네트워크 오류: $e");
    }
  }
  Future<void> loadData() async {
    try {
      var fetchedRecords = await getAllRecords(await getUserEmail());

      // 먼저 use_status_cd 값이 1인 항목을 상단에 위치시킵니다.
      fetchedRecords.sort((a, b) {
        if (a['use_status_cd'] == 1 && b['use_status_cd'] != 1) {
          return -1;
        } else if (b['use_status_cd'] == 1 && a['use_status_cd'] != 1) {
          return 1;
        } else {
          // use_status_cd 값이 같은 경우, 날짜를 기준으로 내림차순 정렬
          return DateTime.parse(b['reg_date']).compareTo(DateTime.parse(a['reg_date']));
        }
      });

      setState(() {
        records = fetchedRecords;
      });
    } catch (e) {
      // 에러 처리
      // 예를 들어, 사용자에게 오류 메시지를 표시하거나 로깅을 수행할 수 있습니다.
    }
  }

}
