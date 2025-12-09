import 'package:flutter/material.dart';
import '../utils/neumorphic_decoration.dart';
import '../utils/app_style.dart';

class NeumorphicTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final Widget? suffix;

  const NeumorphicTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: Neu.convex,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        obscureText: obscure,
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
