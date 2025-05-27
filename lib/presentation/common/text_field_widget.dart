import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final IconData icon;

  const TextFieldInput({
    super.key,
    required this.textEditingController,
    this.isPass = false,
    required this.hintText,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: TextField(
        style: const TextStyle(fontSize: 20),
        obscureText: isPass,
        controller: textEditingController,
        decoration: InputDecoration(
          prefixIcon: Icon(
            icon,
            color: Colors.black54,
          ),
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.black45,
            fontSize: 18,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
            borderRadius: BorderRadius.circular(30),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
            borderRadius: BorderRadius.circular(30),
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
            borderRadius: BorderRadius.circular(30),
          ),
          filled: true,
          fillColor: const Color.fromARGB(255, 255, 255, 255),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}
