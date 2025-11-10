import 'dart:io';
import 'package:dear_deer_demo/service/post/letter_send_service.dart';
import 'package:dear_deer_demo/service/post/s3_service.dart';
import 'package:dear_deer_demo/view/letter/letter_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/widget/custom_button.dart';
import 'package:dear_deer_demo/service/auth_service.dart';
import 'select_recipient.dart';
import 'package:image_picker/image_picker.dart';

class WriteLetterScreen extends StatefulWidget {
  const WriteLetterScreen({super.key});

  @override
  State<WriteLetterScreen> createState() => _WriteLetterScreenState();
}

class _WriteLetterScreenState extends State<WriteLetterScreen> {
  final authService = Get.find<AuthService>();
  final s3Service = S3Service();

  String? _recipientName;
  String? _recipientBoxNumber;
  int? _recipientId;

  File? _selectedImage;
  String? _uploadedImageKey;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _textController = TextEditingController();
  final TextEditingController _senderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final nickname = authService.user.value?.nickname ?? '';
    _senderController.text = nickname;

    final args = Get.arguments ?? {};
    if (args['isEditing'] == true) {
      _textController.text = args['content'] ?? '';
      _recipientId = args['receiverId'];
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _senderController.dispose();
    super.dispose();
  }

  /// 갤러리에서 이미지 선택 후 S3 업로드까지 실행
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final file = File(image.path);
    setState(() => _selectedImage = file);

    final filename = file.path.split('/').last;
    final ext = filename.split('.').last.toLowerCase();
    final contentType = 'image/$ext';

    try {
      // Presigned URL 요청
      final presigned = await s3Service.getLetterPresignedUrl(
        filename: filename,
        contentType: contentType,
      );

      if (presigned == null || presigned['url'] == null) {
        Get.snackbar('업로드 실패', '이미지 업로드용 URL 발급에 실패했습니다.');
        return;
      }

      final uploadUrl = presigned['url'];
      final key = presigned['key'];

      // 실제 이미지 업로드
      final bytes = await file.readAsBytes();
      final success = await s3Service.uploadToS3(uploadUrl, bytes, contentType);

      if (success) {
        setState(() => _uploadedImageKey = key);
        Get.snackbar('업로드 완료', '이미지가 성공적으로 업로드되었습니다.');
        print('S3 업로드 성공: key=$key');
      } else {
        Get.snackbar('업로드 실패', 'S3 업로드 중 문제가 발생했습니다.');
      }
    } catch (e) {
      print('S3 업로드 오류: $e');
      Get.snackbar('오류', '이미지 업로드 중 오류가 발생했습니다.');
    }
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

  // MARK: - 앱바
  AppBar _appBar() => AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text("편지 쓰기", style: FontStyles.H2_bold_17),
        actions: [
          TextButton(
            onPressed: () async {
              final arguments = Get.arguments ?? {};
              final selectedPaper = arguments['selectedPaper'];
              final paperId = selectedPaper?['index'] != null
                  ? selectedPaper['index'] + 1
                  : 1;

              // ✅ receiverId 추가
              final success = await LetterService.saveDraft(
                _textController.text,
                paperId: paperId,
                receiverId: _recipientId,
              );

              if (success) _showSaveToast(context);
            },
            child: const Text(
              "임시저장",
              style: TextStyle(color: Colors.black, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("닫기",
                style: TextStyle(color: Colors.black, fontSize: 13)),
          ),
        ],
      );

  // MARK: - 받는 사람
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
                  _recipientId = int.tryParse(selectedFriend['id'].toString());
                });
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 20.h, left: 24.w, right: 24.w),
          child: Text(
            "내용",
            style: FontStyles.B4_bold_14.copyWith(color: AppColors.Black),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 330.h, maxHeight: 600.h),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColors.G_02, width: 1),
              bottom: BorderSide(color: AppColors.G_02, width: 1),
            ),
          ),
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 20.h),
          child: Stack(
            children: [
              // 스크롤 가능한 본문
              Padding(
                padding: EdgeInsets.only(bottom: 40.h),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                          hintStyle: FontStyles.L2_reg_18.copyWith(
                              color: AppColors.G_06),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child:
                        Icon(Icons.image, size: 26.sp, color: AppColors.G_05),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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

  // MARK: - 전송 버튼 (imageKey 전달 추가)
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

          final arguments = {
            'senderName': _senderController.text,
            'content': _textController.text,
            'selectedPaper': selectedPaper,
            'recipientName': _recipientName,
            'receiverId': _recipientId,
            'paperId': paperId,
            'selectedImage': _selectedImage,
            'imageKey': _uploadedImageKey, // ✅ S3 key 전달
          };

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
