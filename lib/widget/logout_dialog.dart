import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// 피그마 디자인 기반 로그아웃 다이얼로그 위젯
class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  /// 다이얼로그 실행 (결과값 true → 로그아웃 실행)
  static Future<bool> show() async {
    final result = await Get.dialog<bool>(
      const LogoutDialog(),
      barrierDismissible: true, // 바깥 탭 시 닫힘
      barrierColor: Colors.black.withOpacity(0.4),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 36.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // MARK: - 타이틀
            Text(
              '로그아웃',
              style: FontStyles.H3_bold_16,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),

            // MARK: - 본문 문구
            Text(
              '편지는 계속 쌓아 두고 있을게요🥲\n또 만나요👋',
              style: FontStyles.B3_reg_15.copyWith(color: AppColors.G_05),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),

            // MARK: - 구분선
            Divider(height: 1.h, color: AppColors.G_01),
            SizedBox(height: 8.h),

            // MARK: - 버튼 영역
            Row(
              children: [
                Expanded(
                  child: _GhostButton(
                    label: '뒤로',
                    onTap: () => Get.back(result: false),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _PrimaryButton(
                    label: '로그아웃',
                    onTap: () => Get.back(result: true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// MARK: - 내부 버튼 위젯들 ------------------------------

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.mainGreen,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: FontStyles.B2_reg_16.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GhostButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 44.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.G_02, width: 1.w),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: FontStyles.B2_reg_16.copyWith(color: AppColors.G_05),
        ),
      ),
    );
  }
}
