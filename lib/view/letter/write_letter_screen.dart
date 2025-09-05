import 'package:dear_deer_demo/view/letter/letter_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/widget/custom_button.dart';
import 'package:dear_deer_demo/view/letter/letter_preview.dart';
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
              _submitButton(),
              _bottomPadding(),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: - 상단 앱바

  /// 상단 앱바를 반환합니다.
  /// "편지 쓰기" 타이틀을 왼쪽 정렬로 표시합니다.
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
            style: FontStyles.H1_bold_17,
            textAlign: TextAlign.left,
          ),
        ),
      );

  // MARK: - 상단 여백

  /// 상단에 여백을 추가하는 위젯입니다.
  Widget _topPadding() => SizedBox(height: 10.h);

  // MARK: - 받는 사람 섹션

  /// 받는 사람 입력 섹션을 반환합니다.
  /// 사용자는 이 영역을 터치하여 받는 사람을 선택할 수 있습니다.
  Widget _receiverSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 받는 사람 라벨
          Text(
            "받는 사람",
            style: FontStyles.B4_bold_14.copyWith(color: AppColors.Black),
          ),
          SizedBox(height: 4.h),
          // 받는 사람 입력 필드
          GestureDetector(
            onTap: () async {
              final selectedName = await Get.to(() => const SelectRecipient());
              if (selectedName != null) {
                setState(() {
                  _recipientName = selectedName;
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
            ),
          )
        ],
      ),
    );
  }

  // MARK: - 내용 입력 섹션

  /// 편지 내용 입력 섹션을 반환합니다.
  /// 사용자는 이 영역에서 편지 내용을 입력하고, 이미지를 추가할 수 있습니다.
  Widget _contentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        // 내용 라벨
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            "내용",
            style: FontStyles.B4_bold_14.copyWith(color: AppColors.Black),
          ),
        ),
        SizedBox(height: 4.h),
        // 내용 입력 컨테이너
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

  /// 이미지 첨부 시 표시되는 이미지 박스입니다.
  /// 사용자가 이미지를 추가하면 이 영역에 이미지가 표시됩니다.
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

  /// 편지 내용을 입력하는 필드입니다.
  /// 최대 500자까지 입력 가능하며, 500자를 초과하면 자동으로 잘립니다.
  Widget _contentField() => Container(
        constraints: BoxConstraints(minHeight: 250.h),
        child: TextField(
          controller: _textController,
          maxLines: null,
          onChanged: (value) {
            // 500자 초과 시 자동으로 잘라줌
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
            hintText: "내용을 입력해주세요.",
            hintStyle: FontStyles.L1_reg_16.copyWith(color: AppColors.G_06),
          ),
        ),
      );

// MARK: - 이미지 아이콘 버튼

  /// 이미지 첨부 버튼입니다.
  /// 이미지가 추가된 경우 다른 아이콘으로 변경되고, 버튼은 비활성화됩니다.
  Widget _imageIconButton() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: _showImageBox
          // 이미지가 추가된 경우: 회색 아이콘 + 비활성화
          ? Image.asset(
              ImagePath.imageIconDisabled, // 이미지 추가된 후 보여줄 비활성화 아이콘
              width: 20.w,
              height: 20.h,
              color: AppColors.G_04, // 비활성화 느낌 주는 회색
            )
          // 이미지가 없는 경우: 활성화된 버튼
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

  /// 보내는 사람 입력 섹션을 반환합니다.
  /// 사용자는 이 영역에서 보내는 사람 이름을 입력할 수 있습니다.
  Widget _senderSection() {
    return Column(
      children: [
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 보내는 사람 라벨
              Text(
                "보내는 사람",
                style: FontStyles.B4_bold_14.copyWith(color: AppColors.Black),
              ),
              SizedBox(height: 4.h),
              // 보내는 사람 입력 필드
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

  /// '편지 확인 후 전송하기' 버튼입니다.
  /// 내용과 보내는 사람이 모두 입력되어야 활성화됩니다.
  /// 버튼을 누르면 편지 미리보기 화면으로 이동합니다.
  Widget _submitButton() {
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
              },
            );
          },
          buttonText: "편지 확인 후 전송하기",
        ),
      ],
    );
  }

  // MARK: - 하단 여백

  /// 하단에 여백을 추가하는 위젯입니다.
  Widget _bottomPadding() => SizedBox(height: 20.h);
}
