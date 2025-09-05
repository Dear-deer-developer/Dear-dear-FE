import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomCheckButton extends StatelessWidget {
  final String text;
  final bool isActive;
  final bool isPressed;
  final VoidCallback? onTap;
  final VoidCallback? onTapDown;
  final VoidCallback? onTapUp;
  final VoidCallback? onTapCancel;

  const CustomCheckButton({
    super.key,
    required this.text,
    this.isActive = true,
    this.isPressed = false,
    this.onTap,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
  });

  @override
  Widget build(BuildContext context) {
    // 색상, 폰트 설정
    Color backgroundColor;
    TextStyle fontStyle;

    if (!isActive) {
      backgroundColor = AppColors.Green01; // 입력 전
      fontStyle = FontStyles.Button_bold_17.copyWith(color: AppColors.Green02);
    } else if (isPressed) {
      backgroundColor = AppColors.Green03; // 눌림 상태
      fontStyle = FontStyles.Button_bold_17.copyWith(color: AppColors.Black);
    } else {
      backgroundColor = AppColors.mainGreen; // 기본 상태
      fontStyle = FontStyles.Button_bold_17.copyWith(color: AppColors.White);
    }

    return GestureDetector(
      onTapDown: (_) => onTapDown?.call(),
      onTapUp: (_) => onTapUp?.call(),
      onTapCancel: onTapCancel,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        width: 312.w,
        height: 48.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          text,
          style: fontStyle,
        ),
      ),
    );
  }
}
