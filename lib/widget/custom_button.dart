import 'package:flutter/material.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SelectLetterButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onPressed;
  final String buttonText; // 추가: 버튼 텍스트 파라미터

  const SelectLetterButton({
    super.key,
    required this.isEnabled,
    required this.onPressed,
    required this.buttonText, // 추가
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 0.h),
      child: SizedBox(
        width: 312.w,
        height: 48.h,
        child: ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (states) {
                if (states.contains(WidgetState.disabled)) {
                  return AppColors.Green01;
                }
                return AppColors.mainGreen;
              },
            ),
            foregroundColor: WidgetStateProperty.resolveWith<Color>(
              (states) {
                if (states.contains(WidgetState.disabled)) {
                  return AppColors.Green02;
                }
                return AppColors.White;
              },
            ),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            elevation: WidgetStateProperty.all(0),
          ),
          child: Text(
            buttonText, // 변경: 파라미터로 받은 텍스트 사용
            style: FontStyles.Button_bold_17,
          ),
        ),
      ),
    );
  }
}
