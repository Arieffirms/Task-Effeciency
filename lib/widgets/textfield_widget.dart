import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  const TextFieldWidget({
    super.key,
    required this.hintText,
    required this.maxLines,
    required this.txtcontroller,
    required this.txtInputAction,
  });

  final String hintText;
  final int maxLines;
  final TextEditingController txtcontroller;
  final TextInputAction txtInputAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: const BorderRadius.all(
            Radius.circular(8),
          )),
      child: TextField(
        controller: txtcontroller,
        cursorColor: Colors.black,
        cursorHeight: 20,
        decoration: InputDecoration(
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hintText,
        ),
        maxLines: maxLines,
        textInputAction: txtInputAction,
      ),
    );
  }
}
