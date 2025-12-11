import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppStyle {
  static const title = TextStyle(
    color: AppColors.text,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const subtitle = TextStyle(
    color: AppColors.text,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const normal = TextStyle(
    color: AppColors.text,
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );

  static const smallGray = TextStyle(
    color: AppColors.gray,
    fontSize: 13,
    fontWeight: FontWeight.w400,
  );

  static const button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const link = TextStyle(
    fontSize: 15,
    decoration: TextDecoration.underline,
    color: AppColors.gray,
  );

}
