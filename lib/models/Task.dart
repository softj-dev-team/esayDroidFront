import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
class Task {
  String id;
  String keyword;
  String title;
  List<String> devices;
  bool running;
  DateTime createdAt;
  bool isLoading; // 비동기 작업 실행 중 상태를 나타내는 속성 추가
  bool? success; // 성공 여부 (null: 실행 전, true: 성공, false: 실패)
  Task({
    required this.id,
    required this.keyword,
    required this.title,
    required this.devices,
    this.running = true,
    this.isLoading = false, // 기본값은 false로 설정
    this.success,
  }) : createdAt = DateTime.now();
  // createdAt 날짜를 포매팅하여 반환하는 메소드
  String getFormattedDate() {
    return DateFormat('yy.MM.dd HH:mm:ss').format(createdAt);
  }
}