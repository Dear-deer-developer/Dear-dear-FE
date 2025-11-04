import 'package:dear_deer_demo/model/calendar/calendar_reward.dart';
import 'package:flutter/material.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    final bodyTitle = reward.giftName == 'letter'
        ? '산타의 편지가\n선물로 도착했어요!'
        : '${_koreanName(reward.giftName)}가\n선물로 도착했어요!';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: SizedBox(
        width: 312.w,
        height: 395.h,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.only(top: 24.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      FontStyles.H2_bold_17.copyWith(color: AppColors.Black)),
              SizedBox(height: 25.h),
              Image.asset(asset,
                  width: 150.w, height: 150.h, fit: BoxFit.contain),
              SizedBox(height: 15.h),
              Text(
                bodyTitle,
                textAlign: TextAlign.center,
                style: FontStyles.H2_bold_17.copyWith(color: AppColors.Black),
              ),
              SizedBox(height: 16.h),
              Text(
                '선물함에서 확인해보세요!',
                style: FontStyles.B5_reg_13.copyWith(color: AppColors.Black),
              ),
              SizedBox(height: 30.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('닫기',
                          style: FontStyles.B2_reg_16.copyWith(
                              color: AppColors.Black)),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onGoPressed();
                      },
                      child: Text('보러 가기',
                          style: FontStyles.H3_bold_16.copyWith(
                              color: AppColors.mainRed)),
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

  String _koreanName(String? giftName) {
    switch (giftName) {
      case 'ball_1':
        return '펭귄 오너먼트';
      case 'letter':
        return '산타의 편지';
      default:
        return '오너먼트';
    }
  }
}
