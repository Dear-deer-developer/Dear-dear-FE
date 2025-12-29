import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/service/post/report_service.dart';
import 'package:dear_deer_demo/view/letter/report_completed.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportDetailScreen extends StatefulWidget {
  final int letterId;
  final int senderId;
  final String reason;
  final String reasonLabel;

  const ReportDetailScreen({
    super.key,
    required this.letterId,
    required this.senderId,
    required this.reason,
    required this.reasonLabel,
  });

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  int _textLength = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _textLength = _controller.text.length;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isButtonEnabled => _textLength > 0;

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
        title: Text('신고하기', style: FontStyles.H2_bold_17),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.reasonLabel, style: FontStyles.B3_reg_15),
            const SizedBox(height: 12),

            /// 입력 박스
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _controller,
                maxLength: 300,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: '신고 내용을 입력해 주세요. (최대 300자)',
                  border: InputBorder.none,
                  counterText: '',
                ),
                style: FontStyles.B3_reg_15,
              ),
            ),

            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$_textLength/300',
                style: FontStyles.S1_reg_13.copyWith(
                  color: const Color(0xFF9E9E9E),
                ),
              ),
            ),

            const Spacer(),

            /// 신고하기 버튼
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isButtonEnabled ? _submitReport : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _isButtonEnabled ? AppColors.mainGreen : AppColors.G_01,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  '신고하기',
                  style: FontStyles.Button_bold_17.copyWith(
                    color: _isButtonEnabled
                        ? Colors.white
                        : const Color(0xFFB0B0B0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    final service = ReportService();

    final success = await service.createReport(
      reportedUserId: widget.senderId,
      letterId: widget.letterId,
      reason: widget.reason,
      content: _controller.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Get.offAll(() => ReportCompleted());
    } else {
      Get.snackbar('오류', '신고 중 문제가 발생했습니다.');
    }
  }
}
