import 'package:dear_deer_demo/controller/login/sign_up_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/widget/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SignUpFirst extends StatelessWidget {
  SignUpFirst({super.key});

  final SignUpController c = Get.put(SignUpController());
  final RxBool _pressed = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 24.0.w, right: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: 108.h,
                bottom: 2.h), // 글자 기본 height 값 때문에 bottom 패딩 임의로 값 수정.
            child: Text(
              '000 가입을 환영합니다:)\n사용하실 닉네임을 알려주세요!',
              style: FontStyles.H1_bold_22,
            ),
          ),
          Text(
            '다른 유저에게 공개되는 이름으로, 수정이 불가능합니다',
            style: FontStyles.S1_reg_13,
          ),
          // 닉네임 입력 창
          SizedBox(
            height: 32.h,
          ),
          _nicknameInputField(),
          const Spacer(),
          _checkButton(context),
        ],
      ),
    );
  }

  // MARK: - 닉네임 입력 필드
  Widget _nicknameInputField() {
    return Obx(() {
      final hasError = c.errorText.value != null;
      final isEmpty = c.nickname.value.isEmpty;

      final Color borderColor = hasError
          ? Colors.red
          : (isEmpty ? AppColors.G_02 : AppColors.mainGreen);

      return Container(
        width: 312.w,
        height: 48.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: borderColor, width: 1.w),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: c.nicknameCtrl,
                // onChanged: (_) {},
                maxLength: 16,
                style: FontStyles.B3_bold_15,
                textAlignVertical: TextAlignVertical.center,
                cursorColor: AppColors.mainGreen, // 커서 색상 지정
                decoration: InputDecoration(
                  hintText: '닉네임',
                  hintStyle:
                      FontStyles.B3_reg_15.copyWith(color: AppColors.G_05),
                  counterText: '',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.only(left: 16.w),
                ),
              ),
            ),
            // X 버튼 (닉네임 입력 시에만 표시)
            if (!isEmpty)
              GestureDetector(
                onTap: () {
                  c.nicknameCtrl.clear();
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 5.w),
                  child: Image.asset(
                    ImagePath.nicknameDeletdButton,
                    width: 16.w,
                    height: 16.h,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.only(right: 15.0.w),
              child: Obx(
                () => Text(
                  '${c.nickname.value.length}/16',
                  style: FontStyles.S1_reg_13.copyWith(color: AppColors.G_05),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

// MARK: - 확인하기 버튼
  Widget _checkButton(BuildContext context) {
    double bottomPadding =
        MediaQuery.of(context).viewInsets.bottom > 0 ? 16.h : 80.h;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Obx(() {
        final bool isActive = c.canSubmit.value && !c.isSubmitting.value;
        final bool isPressed = _pressed.value;
        final bool isLoading = c.isSubmitting.value;

        return CustomCheckButton(
          text: isLoading ? '처리중...' : '확인하기',
          isActive: isActive && !isLoading,
          isPressed: isPressed,
          onTap: isActive ? () => c.submit() : null, // 서버 전송
          onTapDown: () => _pressed.value = true,
          onTapUp: () => _pressed.value = false,
          onTapCancel: () => _pressed.value = false,
        );
      }),
    );
  }
}
