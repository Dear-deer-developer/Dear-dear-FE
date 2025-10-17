import 'package:dear_deer_demo/controller/login/auth_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/widget/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class JwtSignUp extends GetView<AuthController> {
  const JwtSignUp({super.key});

  // 뷰 로컬 상태 (UX용)
  static final RxString _nickname = ''.obs;
  static final RxString _email = ''.obs;
  static final RxString _pw = ''.obs;

  static final RxnString _errorText = RxnString(); // 닉네임
  static final RxnString _emailError = RxnString(); // 이메일
  static final RxnString _pwError = RxnString(); // 비밀번호

  static final RxBool _canSubmit = false.obs;
  static final RxBool _pressed = false.obs;
  static final RxBool _pwVisible = false.obs;

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
              '000 가입을 환영합니다:)',
              style: FontStyles.H1_bold_22,
            ),
          ),
          Text(
            '다른 유저에게 공개되는 이름으로, 수정이 불가능합니다',
            style: FontStyles.S1_reg_13,
          ),
          // ID 입력
          _inputId(),
          // Password 입력
          SizedBox(
            height: 32.h,
          ),
          _inputPassword(),
          SizedBox(
            height: 32.h,
          ),
          // Check Password
          // _checkPassword(),
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

// -------------------- 내부 검증 & 유틸 --------------------
  bool _isValidEmail(String v) {
    final emailReg =
        RegExp(r'^[A-Za-z0-9._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$');
    return emailReg.hasMatch(v);
  }

  String? _validatePw(String v) {
    // 예시 정책: 8~20자, 영문/숫자 2종 이상
    if (v.length < 8 || v.length > 20) return '비밀번호는 8~20자';
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(v);
    final hasDigit = RegExp(r'\d').hasMatch(v);
    if (!(hasLetter && hasDigit)) return '영문과 숫자,특수기호를 포함';
    return null;
  }

  void _recalcSubmit() {
    final nicknameOk = _nickname.isNotEmpty && _errorText.value == null;
    final emailOk = _email.isNotEmpty && _emailError.value == null;
    final pwOk = _pw.isNotEmpty && _pwError.value == null;
    _canSubmit.value = nicknameOk && emailOk && pwOk;
  }

  // MARK: - 닉네임 입력 필드
  Widget _nicknameInputField() {
    return Obx(() {
      final hasError = _errorText.value != null;
      final isEmpty = _nickname.value.isEmpty;

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
                controller: controller.signNicknameCtrl,

                onChanged: (v) {
                  // ★★★ 핵심 수정
                  _nickname.value = v;
                  if (v.trim().isEmpty) {
                    _errorText.value = null; // 비어있을 땐 에러 미표시
                  } else if (v.length < 2) {
                    _errorText.value = '닉네임은 2자 이상';
                  } else {
                    _errorText.value = null;
                  }
                  _recalcSubmit(); // ★★★ 활성화 재계산
                },

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
                  controller.signNicknameCtrl.clear();
                  _nickname.value = '';
                  _errorText.value = null;
                  _canSubmit.value = false;
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
                  '${_nickname.value.length}/16',
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
        final bool isActive = _canSubmit.value && !controller.isLoading.value;
        final bool isPressed = _pressed.value;
        final bool isLoading = controller.isLoading.value;

        return CustomCheckButton(
          text: isLoading ? '처리중...' : '확인하기',
          isActive: isActive && !isLoading,
          isPressed: isPressed,
          onTap: isActive ? controller.register : null,
        );
      }),
    );
  }

  // MARK: 임시 아이디 입력
  Widget _inputId() {
    return Obx(() {
      final hasError = _emailError.value != null;
      final isEmpty = _email.value.isEmpty;

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
                controller: controller.signEmailCtrl, // AuthController에 추가 필요
                keyboardType: TextInputType.emailAddress,
                onChanged: (v) {
                  _email.value = v.trim();
                  if (_email.value.isEmpty) {
                    _emailError.value = null; // 비어있을 땐 회색 보더 유지
                  } else if (!_isValidEmail(_email.value)) {
                    _emailError.value = '올바른 이메일 형식 아님';
                  } else {
                    _emailError.value = null;
                  }
                  _recalcSubmit();
                },
                style: FontStyles.B3_bold_15,
                textAlignVertical: TextAlignVertical.center,
                cursorColor: AppColors.mainGreen,
                decoration: InputDecoration(
                  hintText: '아이디(이메일)',
                  hintStyle:
                      FontStyles.B3_reg_15.copyWith(color: AppColors.G_05),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.only(left: 16.w),
                ),
              ),
            ),
            if (!isEmpty)
              GestureDetector(
                onTap: () {
                  controller.signEmailCtrl.clear();
                  _email.value = '';
                  _emailError.value = null;
                  _recalcSubmit();
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
            SizedBox(width: 15.w), // 닉네임처럼 오른쪽 패딩 공간 유지
          ],
        ),
      );
    });
  }

  Widget _inputPassword() {
    return Obx(() {
      final hasError = _pwError.value != null;
      final isEmpty = _pw.value.isEmpty;

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
                controller: controller.signPwCtrl, // AuthController에 추가 필요
                obscureText: !_pwVisible.value,
                onChanged: (v) {
                  _pw.value = v;
                  _pwError.value = _validatePw(v);
                  // 비밀번호 확인도 함께 재평가
                  _recalcSubmit();
                },
                style: FontStyles.B3_bold_15,
                textAlignVertical: TextAlignVertical.center,
                cursorColor: AppColors.mainGreen,
                decoration: InputDecoration(
                  hintText: '비밀번호 (8~20자, 영문+숫자+특수기호)',
                  hintStyle:
                      FontStyles.B3_reg_15.copyWith(color: AppColors.G_05),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.only(left: 16.w),
                ),
              ),
            ),
            // 보기/숨김 토글
            GestureDetector(
              onTap: () => _pwVisible.value = !_pwVisible.value,
              child: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Icon(
                  _pwVisible.value ? Icons.visibility : Icons.visibility_off,
                  size: 18.sp,
                  color: AppColors.G_05,
                ),
              ),
            ),
            if (!isEmpty)
              GestureDetector(
                onTap: () {
                  controller.signPwCtrl.clear();
                  _pw.value = '';
                  _pwError.value = null;
                  _recalcSubmit();
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
            SizedBox(width: 10.w),
          ],
        ),
      );
    });
  }

  // Widget _checkPassword() {
  //   return Obx(() {
  //     final hasError = _pw2Error.value != null;
  //     final isEmpty = _pw2.value.isEmpty;

  //     final Color borderColor = hasError
  //         ? Colors.red
  //         : (isEmpty ? AppColors.G_02 : AppColors.mainGreen);

  //     return Container(
  //       width: 312.w,
  //       height: 48.h,
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(8.r),
  //         border: Border.all(color: borderColor, width: 1.w),
  //       ),
  //       child: Row(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           Expanded(
  //             child: TextField(
  //               controller:
  //                   controller.signPwConfirmCtrl, // AuthController에 추가 필요
  //               obscureText: !_pw2Visible.value,
  //               onChanged: (v) {
  //                 _pw2.value = v;
  //                 if (v.isEmpty) {
  //                   _pw2Error.value = null; // 비어있을 땐 회색 보더 유지
  //                 } else {
  //                   _pw2Error.value = (v == _pw.value) ? null : '비밀번호가 일치하지 않음';
  //                 }
  //                 _recalcSubmit();
  //               },
  //               style: FontStyles.B3_bold_15,
  //               textAlignVertical: TextAlignVertical.center,
  //               cursorColor: AppColors.mainGreen,
  //               decoration: InputDecoration(
  //                 hintText: '비밀번호 확인',
  //                 hintStyle:
  //                     FontStyles.B3_reg_15.copyWith(color: AppColors.G_05),
  //                 border: InputBorder.none,
  //                 isDense: true,
  //                 contentPadding: EdgeInsets.only(left: 16.w),
  //               ),
  //             ),
  //           ),
  //           // 보기/숨김 토글
  //           GestureDetector(
  //             onTap: () => _pw2Visible.value = !_pw2Visible.value,
  //             child: Padding(
  //               padding: EdgeInsets.only(right: 8.w),
  //               child: Icon(
  //                 _pw2Visible.value ? Icons.visibility : Icons.visibility_off,
  //                 size: 18.sp,
  //                 color: AppColors.G_05,
  //               ),
  //             ),
  //           ),
  //           if (!isEmpty)
  //             GestureDetector(
  //               onTap: () {
  //                 controller.signPwConfirmCtrl.clear();
  //                 _pw2.value = '';
  //                 _pw2Error.value = null;
  //                 _recalcSubmit();
  //               },
  //               child: Padding(
  //                 padding: EdgeInsets.only(right: 5.w),
  //                 child: Image.asset(
  //                   ImagePath.nicknameDeletdButton,
  //                   width: 16.w,
  //                   height: 16.h,
  //                 ),
  //               ),
  //             ),
  //           SizedBox(width: 10.w),
  //         ],
  //       ),
  //     );
  //   });
  // }
}
