import 'dart:io';
import 'package:dear_deer_demo/service/post/letter_send_service.dart';
import 'package:dear_deer_demo/view/letter/letter_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/widget/custom_button.dart';

import 'select_recipient.dart';
import 'package:image_picker/image_picker.dart';

class WriteLetterScreen extends StatefulWidget {
  const WriteLetterScreen({super.key});

  @override
  State<WriteLetterScreen> createState() => _WriteLetterScreenState();
}

class _WriteLetterScreenState extends State<WriteLetterScreen> {
  // MARK: - State
  String? _recipientName;
  String? _recipientBoxNumber;
  int? _recipientId;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  final TextEditingController _textController = TextEditingController();
  final TextEditingController _senderController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _senderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments ?? {};
    final selectedPaper = arguments['selectedPaper'];

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
              _submitButton(selectedPaper),
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
        title: Text("편지 쓰기", style: FontStyles.H2_bold_17),
        actions: [
          TextButton(
            onPressed: _textController.text.isNotEmpty
                ? () async {
                    final arguments = Get.arguments ?? {};
                    final selectedPaper = arguments['selectedPaper'];
                    final paperId = selectedPaper?['index'] != null
                        ? selectedPaper['index'] + 1
                        : 1;

                    final success = await LetterService.saveDraft(
                      _textController.text,
                      paperId: paperId,
                    );
                    if (success) _showSaveToast(context);
                  }
                : null,
            child: const Text("임시저장",
                style: TextStyle(color: Colors.black, fontSize: 13)),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("닫기",
                style: TextStyle(color: Colors.black, fontSize: 13)),
          ),
        ],
      );

  // MARK: - 받는 사람 선택 섹션
  Widget _receiverSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("받는 사람",
              style: FontStyles.B4_bold_14.copyWith(color: AppColors.Black)),
          SizedBox(height: 4.h),
          GestureDetector(
            onTap: () async {
              final selectedFriend =
                  await Get.to(() => const SelectRecipient());

              if (selectedFriend != null) {
                setState(() {
                  _recipientName = selectedFriend['name'];
                  _recipientBoxNumber = selectedFriend['number'];
                  _recipientId = selectedFriend['id'];
                });
                print('🎯 선택된 친구 id=${_recipientId}, name=$_recipientName');
              }
            },
            child: Container(
              width: 312.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.G_02, width: 1),
              ),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: _recipientName != null
                  ? Row(
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: const BoxDecoration(
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
                            Text("Dear. $_recipientName",
                                style: FontStyles.L2_reg_18.copyWith(
                                    color: AppColors.Black)),
                            Text("사서함번호: ${_recipientBoxNumber ?? '-'}",
                                style: FontStyles.S2_reg_12.copyWith(
                                    color: AppColors.G_06)),
                          ],
                        ),
                      ],
                    )
                  : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - 내용 입력
  Widget _contentSection() {
    return Padding(
      padding: EdgeInsets.only(top: 20.h, left: 24.w, right: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("내용",
              style: FontStyles.B4_bold_14.copyWith(color: AppColors.Black)),
          SizedBox(height: 8.h),
          Container(
            width: 360.w,
            constraints: BoxConstraints(minHeight: 330.h, maxHeight: 600.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.G_02, width: 1),
            ),
            padding: EdgeInsets.fromLTRB(24.w, 15.h, 24.w, 50.h),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  if (_selectedImage != null) ...[
                    _imageBox(),
                    SizedBox(height: 8.h),
                  ],
                  TextField(
                    controller: _textController,
                    maxLines: null,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "내용을 입력해주세요.",
                      hintStyle:
                          FontStyles.L2_reg_18.copyWith(color: AppColors.G_06),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageBox() => Stack(
        children: [
          Container(
            width: 312.w,
            height: 184.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.r),
              image: DecorationImage(
                image: FileImage(_selectedImage!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 10.h,
            right: 10.w,
            child: GestureDetector(
              onTap: () => setState(() => _selectedImage = null),
              child: Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      );

  // MARK: - 보내는 사람 입력
  Widget _senderSection() {
    return Padding(
      padding: EdgeInsets.only(top: 20.h, left: 24.w, right: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("보내는 사람",
              style: FontStyles.B4_bold_14.copyWith(color: AppColors.Black)),
          SizedBox(height: 4.h),
          Container(
            width: 312.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.G_02, width: 1),
            ),
            child: TextField(
              controller: _senderController,
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - 전송 버튼
  Widget _submitButton(dynamic selectedPaper) {
    return Padding(
      padding: EdgeInsets.only(top: 20.h),
      child: SelectLetterButton(
        isEnabled: _textController.text.isNotEmpty &&
            _senderController.text.isNotEmpty &&
            _recipientId != null,
        onPressed: () {
          final paperId =
              selectedPaper?['index'] != null ? selectedPaper['index'] + 1 : 1;

          if (_recipientId == null) {
            Get.snackbar("오류", "받는 사람을 선택해주세요.");
            return;
          }

          final arguments = {
            'senderName': _senderController.text,
            'content': _textController.text,
            'selectedPaper': selectedPaper,
            'recipientName': _recipientName,
            'receiverId': _recipientId,
            'paperId': paperId,
            'selectedImage': _selectedImage,
          };

          print('LetterPreview 이동 인자: $arguments');

          Get.to(() => const LetterPreview(), arguments: arguments);
        },
        buttonText: "편지 확인 후 전송하기",
      ),
    );
  }

  Widget _topPadding() => SizedBox(height: 10.h);
  Widget _bottomPadding() => SizedBox(height: 20.h);

  void _showSaveToast(BuildContext context) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100.h,
        left: 0,
        right: 0,
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            width: 312.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: AppColors.G_06,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: 24.w,
                  height: 24.h,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8CC08C),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
                SizedBox(width: 12.w),
                const Text(
                  "임시저장이 완료되었어요",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(milliseconds: 1800), () => entry.remove());
  }
}
