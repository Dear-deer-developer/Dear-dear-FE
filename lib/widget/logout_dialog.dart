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
      barrierColor: Colors.black.withValues(alpha: 0.3),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0, // 그림자 제거
      insetPadding: EdgeInsets.zero, // 고정 폭/높이 사용
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: SizedBox(
        width: 312.w,
        height: 224.h, // ✅ 고정 사이즈
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          child: Column(
            children: [
              // 제목
              Text('로그아웃',
                  style: FontStyles.H2_bold_17, textAlign: TextAlign.center),

              SizedBox(height: 42.h),

              // 본문 (구분선 없음)
              Text(
                '편지는 계속 쌓아 두고 있을게요🥲\n또 만나요👋👋',
                style: FontStyles.B2_reg_16,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // 하단 버튼
              SizedBox(
                height: 44.h,
                child: Row(
                  children: [
                    // 뒤로
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Get.back(result: false),
                        child: Center(
                          // ✅ 중앙 정렬로 변경
                          child: Text(
                            '뒤로',
                            style: FontStyles.B2_reg_16.copyWith(
                                color: AppColors.G_05),
                          ),
                        ),
                      ),
                    ),

                    // 로그아웃
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Get.back(result: true),
                        child: Center(
                          // ✅ 중앙 정렬로 변경
                          child: Text(
                            '로그아웃',
                            style: FontStyles.B2_reg_16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
