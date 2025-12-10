import 'package:flutter/material.dart';
import '../utils/neumorphic_decoration.dart';
import '../utils/app_style.dart';

class NeumorphicTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final Widget? suffix;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;

  const NeumorphicTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.suffix,
    this.textInputAction, // Tambahkan ini
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Neu.convex,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppStyle.smallGray,
          border: InputBorder.none,
          suffixIcon: suffix,
        ),
      ),
    );
  }
}
