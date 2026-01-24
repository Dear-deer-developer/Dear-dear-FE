import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/view/letter/post.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportCompleted extends StatefulWidget {
  const ReportCompleted({super.key});

  @override
  State<ReportCompleted> createState() => _ReportCompletedState();
}

class _ReportCompletedState extends State<ReportCompleted> {
  bool _isBlocked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: _appBar(),
      body: Stack(
        children: [
          /// 내용 영역
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _middle(),
                const Spacer(),
                _block(),
                const SizedBox(height: 100),
              ],
            ),
          ),

          /// 하단 버튼
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: _button(),
          ),
        ],
      ),
    );
  }

  // MARK: AppBar
  AppBar _appBar() => AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "신고하기",
          style: FontStyles.H2_bold_17,
        ),
      );

  // MARK: Middle Text
  Widget _middle() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "알려 주셔서 감사합니다.",
            style: FontStyles.H3_bold_16,
          ),
          const SizedBox(height: 16),
          Text(
            "감사합니다. 보내주신 의견은 더 나은 디어디어를 위해 빠른 시일내에 검토하겠습니다.",
            style: FontStyles.B2_reg_16,
          ),
          const SizedBox(height: 32),
          Text(
            "검토 후 조치가 필요한 사용자라면 이용이 제한되고, 그 사용자가 작성한 모든 편지도 삭제됩니다.",
            style: FontStyles.B2_reg_16,
          ),
        ],
      );

  // MARK: Button
  Widget _button() => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            // TODO: _isBlocked 값으로 차단 API 연동 가능
            Get.offAll(() => PostMain());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mainGreen,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            '확인',
            style: FontStyles.Button_bold_17.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      );

  // MARK: Block Checkbox
  Widget _block() => GestureDetector(
        onTap: () {
          setState(() {
            _isBlocked = !_isBlocked;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: _isBlocked ? AppColors.mainGreen : AppColors.G_05,
                borderRadius: BorderRadius.circular(4),
              ),
              child: _isBlocked
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              "신고한 사용자 차단하기",
              style: FontStyles.B2_reg_16,
            ),
          ],
        ),
      );
}
