import 'package:flutter/material.dart';

class Helper {
  Future<dynamic> showScaffoldMessenger({
    required BuildContext context,
    required String message,
    Duration? duration,
    Color? bgColor,
  }) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration ?? const Duration(seconds: 2),
        backgroundColor: bgColor ?? Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        content: Text(message, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
