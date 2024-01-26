import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: MyGridView(
          onSelectedDevicesChanged: (List<String> devices) {
            // Do nothing or handle the selected devices
          },
        ),
      ),
    );
  }
}

class MyGridView extends StatefulWidget {
  final Function(List<String>) onSelectedDevicesChanged; // 콜백 함수 선언
  MyGridView({Key? key, required this.onSelectedDevicesChanged}) : super(key: key);

  @override
  _MyGridViewState createState() => _MyGridViewState();
}

class _MyGridViewState extends State<MyGridView> {

  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  bool _isHoveringPopup = false;
  void _showPopup(BuildContext context, Offset position, String deviceId) {
    _overlayEntry?.remove();
    _overlayEntry = _createOverlayEntry(context, position, deviceId);
    Overlay.of(context)?.insert(_overlayEntry!);
  }

  void _hidePopup() {
    if (!_isHoveringPopup) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  OverlayEntry _createOverlayEntry(BuildContext context, Offset position, String deviceId) {
    final double itemHeight = 0; // 가정한 그리드 아이템의 높이

    return OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy + itemHeight, // 아이템 아래에 표시
        // width: 200,
        // height: 60,
        child: MouseRegion(
          onEnter: (_) => _isHoveringPopup = true,
          onExit: (_) {
            _isHoveringPopup = false;
            _hidePopup();
          },
          child: Material(
            elevation: 4.0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0), // 여기에 padding을 추가합니다.
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[

                  IconButton(
                    icon: Icon(Icons.phone_android),
                    onPressed: () {
                      // 실행할 함수
                      runScrcpy(deviceId);
                    },
                  ),
                  Text(deviceId),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  List<bool> isActive = [];
  List<String> devices = [];
  int startSwipeIndex = -1;
  int currentSwipeIndex = -1;

  @override
  void initState() {
    super.initState();
    fetchDevices();
  }

  void fetchDevices() async {
    var result = await Process.run('adb', ['devices']);
    if (result.exitCode == 0) {
      List<String> lines = result.stdout.toString().split('\n');
      for (var line in lines) {
        if (line.contains('device') && !line.contains('List of devices')) {
          devices.add(line.split('\t')[0]);
        }
      }
      setState(() {
        isActive = List.generate(devices.length, (index) => false);
      });
    }
  }
  bool isAllSelected = false; // 전체 선택 상태 추적

  void toggleSelectAll() {
    if (isAllSelected) {
      deselectAll();
    } else {
      selectAll();
    }
  }

  void selectAll() {
    setState(() {
      for (int i = 0; i < isActive.length; i++) {
        isActive[i] = true;
      }
      isAllSelected = true; // 전체 선택 상태 업데이트
      _logSelectedElements();
    });
  }

  void deselectAll() {
    setState(() {
      for (int i = 0; i < isActive.length; i++) {
        isActive[i] = false;
      }
      isAllSelected = false; // 전체 선택 상태 업데이트
      _logSelectedElements();
    });
  }
// Method to run scrcpy with the selected device ID
  void runScrcpy(String deviceId) async {

    var result = await Process.run('scrcpy', [
      '-s', deviceId,
      '-m', '740', // 최대 크기를 1024 픽셀로 제한
      '--window-width', '360', // 창 폭을 800으로 설정
      // '--window-height', '600', // 창 높이를 600으로 설정
    ]);
    // Handle the result of the command
    if (result.exitCode != 0) {
      print('Error running scrcpy: ${result.stderr}');
    }
  }
  // 디바이스 목록을 새로고침하는 함수
  void refreshDeviceList() {
    setState(() {
      devices.clear(); // 기존 디바이스 목록을 지웁니다.
      fetchDevices(); // 디바이스 목록을 다시 가져옵니다.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                FontAwesomeIcons.checkDouble,
                color: isAllSelected ? Colors.red : null, // 색상 변경
                // size: 24.0, // 아이콘 크기 설정
              ),
              onPressed: toggleSelectAll,// 클릭 시 수행할 동작
              tooltip: '전체선택', // 툴팁 메시지 추가
            ),
            IconButton(
              icon: Icon(Icons.refresh), // 새로 고침 아이콘
              onPressed: refreshDeviceList, // 클릭 시 refreshDeviceList 함수 호출
              tooltip: '목록세로고침', // 툴팁 메시지 추가
            ),
          ],
        ),
        Container(
          width: 300,
          height: 300,
          padding: EdgeInsets.all(8.0),
          child: GestureDetector(
            onPanStart: (details) {
              int index = _getIndex(details.localPosition);
              if (index != -1) {
                setState(() {
                  startSwipeIndex = index;
                  currentSwipeIndex = index;
                  isActive[index] = !isActive[index];
                  _logSelectedElements();
                });
              }
            },
            onPanUpdate: (details) {
              int index = _getIndex(details.localPosition);
              if (index != -1 && index != currentSwipeIndex) {
                setState(() {
                  currentSwipeIndex = index;
                  if (index > startSwipeIndex) {
                    for (int i = startSwipeIndex; i <= index; i++) {
                      isActive[i] = true;
                    }
                  } else {
                    for (int i = startSwipeIndex; i >= index; i--) {
                      isActive[i] = false;
                    }
                  }
                  _logSelectedElements();
                });
              }
            },
            onPanEnd: (details) {
              setState(() {
                startSwipeIndex = -1;
                currentSwipeIndex = -1;
              });
            },
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
              ),
              itemCount: devices.length,
              itemBuilder: (context, index) {

                return MouseRegion(
                  onEnter: (event) => _showPopup(context, event.position, devices[index]),
                  onExit: (event) => _hidePopup(),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isActive[index] ? Colors.white : Colors.grey, // 조건부 색상 변경
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: isActive[index] ? Colors.blue.shade900 : Colors.grey[200],
                      border: Border.all(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ),

      ],
    );
  }

  int _getIndex(Offset localPosition) {
    double width = 300 / 10;
    double height = width;
    int row = localPosition.dy ~/ height;
    int col = localPosition.dx ~/ width;
    int index = row * 10 + col;
    if (index < 0 || index >= devices.length) {
      return -1;
    }
    return index;
  }

  void _logSelectedElements() {
    List<String> selectedDevices = [];
    for (int i = 0; i < isActive.length; i++) {
      if (isActive[i]) {
        selectedDevices.add(devices.isNotEmpty ? devices[i] : 'Device ${i + 1}');
      }
    }
    print('Selected devices: $selectedDevices');
    widget.onSelectedDevicesChanged(selectedDevices);
  }
}
