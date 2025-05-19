import 'package:dear_deer_demo/controller/login/sign_up_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/main.dart';
import 'package:dear_deer_demo/widget/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SignUpFirst extends StatelessWidget {
  SignUpFirst({super.key});

  final SignUpController signUpController = Get.put(SignUpController());
  final TextEditingController _textController = TextEditingController();

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
              //  기존 방법
              // style: TextStyle(
              //     fontFamily: 'KakaoSmallSansBold',
              //     fontSize: 22.sp,
              //     fontWeight: FontWeight.bold),
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
      Color borderColor = signUpController.nickname.value.isEmpty
          ? AppColors.G_02
          : AppColors.mainGreen;

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
                controller: _textController,
                onChanged: (value) => signUpController.updateNickname(value),
                maxLength: 5,
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
            if (signUpController.nickname.value.isNotEmpty)
              GestureDetector(
                onTap: () {
                  // 닉네임 상태와 TextField 값 초기화
                  signUpController.updateNickname('');
                  _textController.clear(); // 텍스트 필드 값 초기화
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
                  '${signUpController.nickname.value.length}/5',
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
    // 키보드가 올라와 있으면 패딩을 16으로 설정
    double bottomPadding =
        MediaQuery.of(context).viewInsets.bottom > 0 ? 16.h : 80.h;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Obx(
        () {
          // 활성화 여부 확인
          bool isActive = signUpController.nickname.value.isNotEmpty;
          bool isPressed = signUpController.isPressed.value;

          return CustomCheckButton(
            text: '확인하기',
            isActive: isActive,
            isPressed: isPressed,
            onTap: isActive
                ? () => logger
                    .i(signUpController.nickname.value) // 입력된 닉네임 logger로 확인
                : null,
            onTapDown: () => signUpController.setPressed(true),
            onTapUp: () => signUpController.setPressed(false),
            onTapCancel: () => signUpController.setPressed(false),
          );
        },
      ),
    );
  }
}
