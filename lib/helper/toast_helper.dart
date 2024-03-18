import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
void customToast(BuildContext context, String message) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 20, // 상태 바 바로 아래, 여백 20
      left: MediaQuery.of(context).size.width * 0.1,
      right: MediaQuery.of(context).size.width * 0.1,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Colors.red.shade500,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            message,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );

  overlay?.insert(overlayEntry);

  // 토스트 지속 시간 설정
  Future.delayed(Duration(seconds: 4), () => overlayEntry.remove());
}