import 'package:dear_deer_demo/model/calendar/calendar_reward.dart';
import 'package:flutter/material.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dear_deer_demo/data/calendar/reward_name_mapper.dart';

class RewardArrivedDialog extends StatelessWidget {
  const RewardArrivedDialog({
    super.key,
    required this.reward,
    required this.assetFor,
    required this.onGoPressed,
  });

  final CalendarReward reward;
  final String Function(String? giftName) assetFor;
  final VoidCallback onGoPressed;

  @override
  Widget build(BuildContext context) {
    final asset = assetFor(reward.giftName);
    final title = '선물 도착!';
    final giftDisplayName = rewardNameFor(reward.giftName);
    final particle = _hasFinalConsonant(giftDisplayName) ? '이' : '가';
    final bodyTitle = '$giftDisplayName$particle\n선물로 도착했어요!';
    return Dialog(
      backgroundColor: Colors.transparent, // 외곽 투명
      insetPadding: EdgeInsets.zero, // 여백 제거
      child: SizedBox(
        width: 312.w,
        height: 395.h,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // 배경 흰색
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.only(top: 24.h), // 상단 패딩만 24
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // 제목
              Text(
                title,
                style: FontStyles.H2_bold_17.copyWith(color: AppColors.Black),
              ),
              SizedBox(height: 25.h),

              // 이미지
              Image.asset(
                asset,
                width: 150.w,
                height: 150.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 15.h),

              // 본문 텍스트
              Text(
                bodyTitle,
                textAlign: TextAlign.center,
                style: FontStyles.H2_bold_17.copyWith(color: AppColors.Black),
              ),
              SizedBox(height: 16.h),

              // 안내 문구
              Text(
                '선물함에서 확인해보세요!',
                style: FontStyles.B5_reg_13.copyWith(color: AppColors.Black),
              ),
              SizedBox(height: 30.h),

              // 버튼 영역
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        '닫기',
                        style: FontStyles.B2_reg_16.copyWith(
                          color: AppColors.Black,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // onGoPressed();
                      },
                      child: Text(
                        '보러 가기',
                        style: FontStyles.H3_bold_16.copyWith(
                          color: AppColors.mainRed,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasFinalConsonant(String text) {
    if (text.isEmpty) return false;
    final lastChar = text.codeUnitAt(text.length - 1);
    if (lastChar < 0xAC00 || lastChar > 0xD7A3) return false; // 한글 아니면 false
    final localIndex = (lastChar - 0xAC00) % 28;
    return localIndex != 0; // 종성이 있으면 true
  }
}
