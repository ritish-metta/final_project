import 'dart:ui';
import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String title;
  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;

  const InputField({
    super.key,
    required this.title,
    required this.hintText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.7,
      height: 70,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color.fromARGB(93, 24, 24, 27),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 1),
          Expanded(
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(51, 157, 192, 230),
                    borderRadius: const BorderRadius.all(Radius.circular(50)),
                    border: Border.all(color: const Color.fromARGB(201, 30, 11, 234), width: 0.9),
                  ),
                  child: TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    obscureText: obscureText,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: hintText,
                      hintStyle: const TextStyle(color: Color.fromARGB(93, 57, 13, 236)),
                      contentPadding:
                          const EdgeInsets.only(left: 10, bottom: 10),
                    ),
                    style: const TextStyle(color: Colors.black), 
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
