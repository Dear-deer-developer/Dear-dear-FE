import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/service/post/report_service.dart';
import 'package:dear_deer_demo/view/letter/report_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportScreen extends StatelessWidget {
  final int letterId;
  final int senderId;

  const ReportScreen({
    super.key,
    required this.letterId,
    required this.senderId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          '신고하기',
          style: FontStyles.H2_bold_17,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text('어떤 문제가 있나요?', style: FontStyles.H3_bold_16),
            const SizedBox(height: 20),
            _reportReason('의심스럽거나 스팸입니다.', 'SPAM_AND_PHISHING'),
            _reportReason('성적인 불쾌감을 주는 편지입니다.', 'SEXUAL_CONTENT'),
            _reportReason('자해 또는 자살 의도를 표현하고 있습니다.', 'SELF_HARM'),
            _reportReason('불법촬영물 등 신고', 'ILLEGAL_CONTENT'),
            _reportReason('가학적이거나 유해한 내용입니다.', 'HARMFUL_CONTENT'),
            _reportReason('욕설·비방·혐오표현이 담겨있습니다.', 'ABUSIVE_LANGUAGE'),
          ],
        ),
      ),
    );
  }

  Widget _reportReason(String text, String reason) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        text,
        style: FontStyles.B3_reg_15,
      ),
      onTap: () {
        Get.to(() => ReportDetailScreen(
              letterId: letterId,
              senderId: senderId,
              reason: reason,
              reasonLabel: text,
            ));
      },
    );
  }
}
