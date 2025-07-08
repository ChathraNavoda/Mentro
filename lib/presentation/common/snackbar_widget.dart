import 'package:flutter/material.dart';
import 'package:mentro/main.dart'; // import where you declared scaffoldMessengerKey

showSnackBar(BuildContext context, String content) {
  scaffoldMessengerKey.currentState?.showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}
