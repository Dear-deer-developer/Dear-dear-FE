import 'package:dear_deer_demo/controller/post/select_recipient_controller.dart';
import 'package:dear_deer_demo/view/letter/letter_preview.dart';
import 'package:dear_deer_demo/view/letter/select_letter_paper_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/widget/custom_button.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'select_recipient.dart';

/// 편지 작성 화면입니다.
/// 사용자는 이 화면에서 받는 사람, 편지 내용, 보내는 사람을 입력하고,
/// 이미지를 첨부할 수 있습니다.
/// 모든 필수 입력이 완료되면 '편지 확인 후 전송하기' 버튼이 활성화됩니다.
class WriteLetterScreen extends StatefulWidget {
  const WriteLetterScreen({super.key});

  @override
  State<WriteLetterScreen> createState() => _WriteLetterScreenState();
}

class _WriteLetterScreenState extends State<WriteLetterScreen> {
  // MARK: - State
  String? _recipientName;
  String? _recipientBoxNumber;

  /// 이미지 박스 표시 여부를 관리하는 상태 변수입니다.
  bool _showImageBox = false;
  // 편지 내용 입력을 위한 컨트롤러입니다.
  final TextEditingController _textController = TextEditingController();
  // 보내는 사람 입력을 위한 컨트롤러입니다.
  final TextEditingController _senderController = TextEditingController();

  @override
  void dispose() {
    // 컨트롤러 해제
    _textController.dispose();
    _senderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments ?? {};
    final selectedPaper = arguments['selectedPaper']; // ✅ 선택한 편지지 정보 받기

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: _appBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _topPadding(),
              _receiverSection(),
              _contentSection(),
              _senderSection(),
              _submitButton(selectedPaper), // ✅ 여기서 selectedPaper 전달
              _bottomPadding(),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: - 상단 앱바

  AppBar _appBar() => AppBar(
          backgroundColor: AppColors.bgColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          titleSpacing: 0,
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "편지 쓰기",
              style: FontStyles.H2_bold_17,
              textAlign: TextAlign.left,
            ),
          ),
          actions: [
            // 임시저장 버튼
            TextButton(
              onPressed: _textController.text.isNotEmpty
                  ? () {
                      Get.snackbar("임시저장", "편지가 임시저장되었습니다.");
                    }
                  : null,
              child: Text(
                "임시저장",
                style: FontStyles.S1_reg_13.copyWith(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                "닫기",
                style: FontStyles.S1_reg_13.copyWith(color: Colors.black),
              ),
            ),
          ]);

  // MARK: - 상단 여백
  Widget _topPadding() => SizedBox(height: 10.h);

  // MARK: - 받는 사람 섹션
  Widget _receiverSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "받는 사람",
            style: FontStyles.B4_bold_14.copyWith(color: AppColors.Black),
          ),
          SizedBox(height: 4.h),
          GestureDetector(
              onTap: () async {
                final selectedFriend =
                    await Get.to(() => const SelectRecipient());

                if (selectedFriend != null) {
                  setState(() {
                    _recipientName = selectedFriend['name'];
                    _recipientBoxNumber = selectedFriend['number'];
                  });
                }
              },
              child: Container(
                  width: 312.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: AppColors.G_02,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(horizontal: 14.w),
                  child: _recipientName != null
                      ? Row(
                          children: [
                            Container(
                              width: 40.w,
                              height: 40.h,
                              decoration: BoxDecoration(
                                color: AppColors.G_01,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person,
                                  color: AppColors.G_04, size: 28),
                            ),
                            SizedBox(width: 12.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "dear. ${_recipientName ?? _recipientName}",
                                  style: FontStyles.L2_reg_18.copyWith(
                                      color: AppColors.Black),
                                ),
                                Text(
                                  "사서함번호 : ${_recipientBoxNumber ?? '-'}",
                                  style: FontStyles.S2_reg_12.copyWith(
                                      color: AppColors.G_06),
                                ),
                              ],
                            ),
                          ],
                        )
                      : const SizedBox())),
        ],
      ),
    );
  }

  // MARK: - 내용 입력 섹션
  Widget _contentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            "내용",
            style: FontStyles.B4_bold_14.copyWith(color: AppColors.Black),
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          width: 360.w,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColors.G_02, width: 1),
              bottom: BorderSide(color: AppColors.G_02, width: 1),
            ),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 15.h, 24.w, 15.h),
              child: Column(
                children: [
                  if (_showImageBox) _imageBox(),
                  _contentField(),
                  _imageIconButton(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // MARK: - 이미지 박스
  Widget _imageBox() => Stack(
        children: [
          Container(
            width: 312.w,
            height: 184.h,
            margin: EdgeInsets.only(bottom: 8.h),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(5.r),
            ),
          ),
          Positioned(
            top: 11.h,
            right: 11.w,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showImageBox = false;
                });
              },
              child: Container(
                width: 18.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 12.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  // MARK: - 내용 입력 필드
  Widget _contentField() => Container(
        constraints: BoxConstraints(minHeight: 250.h),
        child: TextField(
          controller: _textController,
          maxLines: null,
          onChanged: (value) {
            if (value.length > 500) {
              _textController.value = TextEditingValue(
                text: value.substring(0, 500),
                selection: const TextSelection.collapsed(offset: 500),
              );
            }
            setState(() {});
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 20),
            hintText: "내용을 입력해 주세요.",
            hintStyle: FontStyles.L2_reg_18.copyWith(color: AppColors.G_06),
          ),
        ),
      );

  // MARK: - 이미지 아이콘 버튼
  Widget _imageIconButton() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: _showImageBox
          ? Image.asset(
              ImagePath.imageIconDisabled,
              width: 20.w,
              height: 20.h,
              color: AppColors.G_04,
            )
          : GestureDetector(
              onTap: () {
                setState(() {
                  _showImageBox = true;
                });
              },
              child: Image.asset(
                ImagePath.imageIcon,
                width: 20.w,
                height: 20.h,
              ),
            ),
    );
  }

  // MARK: - 보내는 사람 섹션
  Widget _senderSection() {
    return Column(
      children: [
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "보내는 사람",
                style: FontStyles.B4_bold_14.copyWith(color: AppColors.Black),
              ),
              SizedBox(height: 4.h),
              Container(
                width: 312.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.G_02,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _senderController,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // MARK: - 전송 버튼
  Widget _submitButton(dynamic selectedPaper) {
    return Column(
      children: [
        SizedBox(height: 20.h),
        SelectLetterButton(
          isEnabled: _textController.text.isNotEmpty &&
              _senderController.text.isNotEmpty,
          onPressed: () {
            Get.to(
              () => const LetterPreview(),
              arguments: {
                'senderName': _senderController.text,
                'content': _textController.text,
                'selectedPaper': selectedPaper,
                'recipientName': _recipientName,
                'recipientNumber': _recipientBoxNumber,
              },
            );
          },
          buttonText: "편지 확인 후 전송하기",
        ),
      ],
    );
  }

  // MARK: - 하단 여백
  Widget _bottomPadding() => SizedBox(height: 20.h);
}
