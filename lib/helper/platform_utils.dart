// platform_utils.dart
bool isPlatformWindows() {
  // 웹 환경에서는 Platform API 사용을 피하고 항상 false 반환
  return false;
}