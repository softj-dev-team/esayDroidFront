import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'helper/toast_helper.dart';
import 'package:esaydroid/best_flutter_ui_templates/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'helper/platform_utils.dart' if (dart.library.io) 'helper/platform_utils_io.dart';
import 'device_list.dart'; // device_list.dart에서 MyGridView를 가져옵니다.
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'models/Task.dart';
import 'package:logger/logger.dart';
import 'models/AdbShellCommand.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}
final TextEditingController searchStringController = TextEditingController();
final TextEditingController targetTitleStringController = TextEditingController();

class _SettingScreenState extends State<SettingScreen> {
  // Creating an instance of AdbShellCommand
  AdbShellCommand adbShellCommand = AdbShellCommand();

  var logger = Logger(
    printer: PrettyPrinter(),
  );

  var loggerNoStack = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  List<dynamic> records = [];
  String? _selectedDirectory;

  List<String> selectedDevices = []; // 선택된 장치 목록 저장

  //콜백
  void onDevicesSelected(List<String> devices) {
    setState(() {
      selectedDevices = devices;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
    _loadDirectory();
  }

  GlobalKey inputKey = GlobalKey();
  // GlobalKey를 선언하여 IconButton의 위치와 크기를 추적합니다.
  GlobalKey _menuKey = GlobalKey();
  // 팝업 메뉴를 표시하는 함수
  void _showPopupMenu(BuildContext context) async {
    // GlobalKey를 사용하여 IconButton의 위치와 크기를 가져옵니다.
    final RenderBox renderBox = _menuKey.currentContext?.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height,
        offset.dx,
        offset.dy,
      ), // IconButton 하단에 팝업 메뉴를 위치시킵니다.
      items: [
        PopupMenuItem<String>(
            child: ListTile(
              leading: Icon(FontAwesomeIcons.folder),
              title: Text('디렉토리 선택'),
              onTap: () {
                _pickDirectory();
                Navigator.pop(context);
              },
            ),
            value: 'directory'),
        PopupMenuItem<String>(
            child: ListTile(
              leading: Icon(FontAwesomeIcons.github),
              title: Text('업데이트'),
              onTap: () {
                runGitPulCommand();
                Navigator.pop(context);
              },
            ),
            value: 'gitPull'),
        PopupMenuItem<String>(
          child: ListTile(
            leading: Icon(Icons.bug_report_outlined),
            title: Text('Main Apk 생성'),
            onTap: () {
              assembleDebug();
              Navigator.pop(context);
            },
          ),
        ),
        PopupMenuItem<String>(
          child: ListTile(
            leading: Icon(Icons.bug_report),
            title: Text('Test Apk 생성'),
            onTap: () {
              assembleAndroidTest();
              Navigator.pop(context);
            },
          ),
        ),
        // ... 추가 버튼 ...
      ],
      elevation: 8.0,
      color: Colors.white,
    );
  }
  bool isSwitchedInitPlay = false;
  bool isSwitchedSearchFilter = false;
  String useRandomPlay ="Y";
  String useFilter ="Y";

  void toggleuseRandomPlayButton() {
    setState(() {
      if (useRandomPlay == "Y") {
        useRandomPlay = "N";
      } else {
        useRandomPlay = "Y";
      }
    });
  }
  void toggleuseFilterPlayButton() {
    setState(() {
      if (useFilter == "Y") {
        useFilter = "N";
      } else {
        useFilter = "Y";
      }
    });
  }
// List<Map<String, dynamic>> runningTasks = []; // 실행 중인 작업 스케쥴 리스트
  List<Task> runningTasks = [];
  // 작업 ID를 저장할 리스트를 정의합니다.
  List<String> createdTaskIds = [];


  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    // 화면의 너비를 가져옵니다.
    double screenWidth = MediaQuery.of(context).size.width; // 화면의 전체 너비
    return Scaffold(
      body: Row(
        children: <Widget>[
          if (isPlatformWindows()) ...[
            Container(
              width: screenWidth * 0.3, // 화면 너비의 30%
              child: Column(
                children: <Widget>[
                  SizedBox(height: 80),

                  MyGridView(
                    onSelectedDevicesChanged: onDevicesSelected, // 콜백 함수 전달
                    selectedDirectory: _selectedDirectory,

                  ),
                  Expanded(child: runningTasksList()),
                  // 실행 중인 작업 스케쥴 리스트를 표시하는 위젯// MyGridView 추가
                ],
              ),
            ),
          ],
          Expanded(
            // 나머지 공간을 차지하는 위젯
            child: Column(
              children: <Widget>[
                SizedBox(height: 80),
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
                SizedBox(height: 10), // 로고와 입력란 사이 간격
                searchStringInputSection(context),
                SizedBox(height: 10), // 첫 번째 열과 두 번째 열 사이 간격
                targetTitleInputSection(context),
                SizedBox(height: 20), // 첫 번
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
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        loadData(); // 세로고침 아이콘 클릭 시 loadData() 호출
                      },
                      tooltip: '리스트 세로고침',
                    ),
                    if (isPlatformWindows()) ...[
                      IconButton(
                        icon: Icon(FontAwesomeIcons.shuffle),
                        color: useRandomPlay == "Y"
                            ? Colors.red.shade600
                            : Colors.grey, // 색상 변경
                        onPressed: toggleuseRandomPlayButton,
                        tooltip: '동영상 램덤 플레이', // 툴팁 메시지 추가
                      ),
                      IconButton(
                        icon: Icon(FontAwesomeIcons.listCheck),
                        color: useFilter == "Y"
                            ? Colors.red.shade600
                            : Colors.grey, // 색상 변경
                        onPressed: toggleuseFilterPlayButton,
                        tooltip: '검색 필터 사용',
                      ),
                      IconButton(
                        icon: Icon(Icons.play_arrow_sharp),
                        onPressed: () {
                          runCommand();
                        },
                        tooltip: '작업시작',
                      ),
                      IconButton(
                        icon: Icon(FontAwesomeIcons.stop),
                        onPressed: () {
                          stopCommand();
                        },
                        tooltip: '전체정지',
                      ),
                      IconButton(
                        key: _menuKey,
                        icon: Icon(FontAwesomeIcons.gear),
                        onPressed: () {
                          _showPopupMenu(context);
                        },
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 10),
                titleList(context),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget titleList(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // 화면의 전체 너비
    return Expanded(
      child: Container(
        width: 600.0,
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
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
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  // 새로운 리스트 카드 위젯을 추가하는 부분
  Widget runningTasksList() {
    // 좌우 패딩 값 설정
    double horizontalPadding = 16.0;

    return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: ListView.builder(
          itemCount: runningTasks.length,
          itemBuilder: (context, index) {
            var task = runningTasks[index];
            return Card(
              child: ListTile(
                title: Text("${task.keyword}"),
                subtitle: Text("${task.getFormattedDate()}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    task.isLoading
                        ? CircularProgressIndicator() // 로딩 인디케이터
                        : IconButton(
                      icon: Icon(Icons.stop),
                      onPressed: () => stopTask(task.devices.cast<String>(), task.id),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
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
  Future<void> stopTask(List<dynamic> devicesDynamic,String taskId) async {
    // 작업 정지 전 해당 taskId의 isLoading을 true로 설정
    var taskIndex = runningTasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      setState(() {
        runningTasks[taskIndex].isLoading = true;
      });
    }
    String deviceListString = devicesDynamic.join(',');
    var result = await Process.run(
        'cmd',
        ['/c', 'gradlew', 'stopAppOnSpecifiedDevices', '-PdeviceList=$deviceListString'],
        // ['/c', 'gradlew', 'runParallelTestsForInstall', '-PdeviceList=$deviceListString'],
        workingDirectory: _selectedDirectory
    );
    if (result.exitCode == 0) {
      showCustomToast(context, inputKey, "성공: ${result.stdout}");
      setState(() {
        runningTasks.removeWhere((task) => task.id == taskId);
      });

    }else{
      showCustomToast(context, inputKey, "실패: ${result.stderr}");
    }
  }
  Future<void> deleteVideo(String id) async {
    try {
      var url = Uri.parse('FlutterConfig.get('api_host');/api/delete-video/$id');
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
      print('Error: $e');
      showCustomToast(context, inputKey, '오류: $e');
    }
  }
  Future<void> initTasks() async {
    List<dynamic> allRecords = await getAllRecords(await getUserEmail());
    var activeRecords = allRecords.where((record) => record['use_status_cd'] == 1).toList();
    // 초기화 전에 이전 작업 ID들을 비웁니다.
    createdTaskIds.clear();
    for (var record in activeRecords) {
      createdTaskIds.add(
        await addTask(
          record["keyword"],
          record["title"],
          List.from(selectedDevices),
          true, // 비동기 작업 실행 중임을 나타냄
        )
      );
    }
  }
  Future<String> addTask(String keyword, String title, List<String> devices, isLoading) async {
    var newTask = Task(
      id: Uuid().v4(),
      keyword: keyword,
      title: title,
      devices: devices,
      isLoading : isLoading,
    );

    // 새로운 작업을 리스트에 추가
    runningTasks.add(newTask);

    // 생성 시간 기준으로 오름차순 정렬
    runningTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // 상태 업데이트
    setState(() {

    });
    return newTask.id; // 생성된 작업의 ID를 반환
  }
  Future<void> runCommand() async {
    if (_selectedDirectory == null) {
      showCustomToast(context, inputKey,"경로를 먼저 선택해주세요.");
      return;
    }
    if (selectedDevices.isEmpty) {
      showCustomToast(context, inputKey, "장치를 먼저 선택해주세요.");
      return;
    }
    logger.d('test');
    // 선택된 장치 목록을 콤마로 구분된 문자열로 변환
    String deviceListString = selectedDevices.join(',');

    try {
      await initTasks(); // 모든 레코드 로딩 및 작업 생성

      var result = await Process.run(
          'cmd',
          ['/c', 'gradlew', 'runParallelTestsForInstallGetDevices', '-PdeviceList=$deviceListString'],
          // ['/c', 'gradlew', 'runParallelTestsForInstall', '-PdeviceList=$deviceListString'],
          workingDirectory: _selectedDirectory,
          // runInShell: true
      ).timeout(Duration(seconds: 5)); // 5초 후 타임아웃
      if (result.exitCode == 0) {
        // 성공: isLoading을 false로 설정하여 UI 업데이트, createdTaskIds에 있는 task만 업데이트
        for (var taskId in createdTaskIds) {
          var taskIndex = runningTasks.indexWhere((task) => task.id == taskId);
          if (taskIndex != -1) {
            runningTasks[taskIndex].isLoading = false;
          }
        }
        showCustomToast(context, inputKey, "성공: ${result.stdout}");
        await saveRunTask(); // 스케쥴 등록
        setState(() {});
      } else {
        // 명령어 실행에 실패한 경우
        showCustomToast(context, inputKey, "실패: ${result.stderr}");
        logger.d("실패: ${result.stderr}");
        runningTasks.removeWhere((task) => createdTaskIds.contains(task.id));
      }
    } on TimeoutException catch (_) {
      // List<String> results  = await adbShellCommand.runTaskAdbShellMultiDevices(selectedDevices, _selectedDirectory, context);
      // logger.d('test');
      // if(results.length > 0){
      for (var taskId in createdTaskIds) {
        var taskIndex = runningTasks.indexWhere((task) => task.id == taskId);
        if (taskIndex != -1) {
          runningTasks[taskIndex].isLoading = false;
        }
      }
      await saveRunTask(); // 스케쥴 등록
      setState(() {});
    } catch (e) {
      logger.d('오류: $e');
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
        setState(() {
          runningTasks.clear(); // 모든 작업을 리스트에서 삭제
        });
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
      var url = Uri.parse('FlutterConfig.get('api_host');/api/create-run-task');
      var response = await http.post(
        url,

        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "email": await getUserEmail(),
          "use_random_play":useRandomPlay,
          "use_filter":useFilter,
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        showCustomToast(context, inputKey, "${data}");
        // 데이터 저장 후 목록 갱신
      } else {
        showCustomToast(context, inputKey, "저장 실패: ${json.decode(response.body)['error']}");
      }
    } catch (e) {
      showCustomToast(context, inputKey, "네트워크 오류: $e");
    }
  }
  Future<http.Response> callJsonUriWithId(String id) async {
    var url = Uri.parse('FlutterConfig.get('api_host');/api/use-status-change'); // 실제 URL로 변경
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
      var url = Uri.parse('FlutterConfig.get('api_host');/api/save-title');
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
      var url = Uri.parse('FlutterConfig.get('api_host');/api/get-all-records');
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
}
