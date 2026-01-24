import 'package:dear_deer_demo/controller/login/auth_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/widget/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class JwtLogin extends GetView<AuthController> {
  const JwtLogin({super.key});

  // --- 로컬 상태 ---
  static final RxString _email = ''.obs;
  static final RxString _pw = ''.obs;

  static final RxnString _emailError = RxnString();
  static final RxnString _pwError = RxnString();

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
      padding: EdgeInsets.only(left: 24.w, right: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: EdgeInsets.only(top: 108.h, bottom: 2.h),
            child: Text('다시 만나서 반가워요 :)', style: FontStyles.H1_bold_22),
          ),
          Text('이메일과 비밀번호를 입력해주세요', style: FontStyles.S1_reg_13),

          // 이메일
          SizedBox(height: 24.h),
          _inputEmail(),

          // 비밀번호
          SizedBox(height: 32.h),
          _inputPassword(),

          const Spacer(),

          // 확인 버튼
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
    // 회원가입과 동일 정책을 가정 (필요 시 단순히 not empty로 완화 가능)
    if (v.length < 6) return '비밀번호는 6자 이상';
    return null;
  }

  void _recalcSubmit() {
    final emailOk = _email.isNotEmpty && _emailError.value == null;
    final pwOk = _pw.isNotEmpty && _pwError.value == null;
    _canSubmit.value = emailOk && pwOk;
  }

  // -------------------- 위젯 --------------------
  Widget _inputEmail() {
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
                controller: controller.loginEmailCtrl,
                keyboardType: TextInputType.emailAddress,
                onChanged: (v) {
                  _email.value = v.trim();
                  if (_email.value.isEmpty) {
                    _emailError.value = null; // 비어있으면 회색 보더 유지
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
                  controller.loginEmailCtrl.clear();
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
            SizedBox(width: 15.w),
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
                controller: controller.loginPwCtrl,
                obscureText: !_pwVisible.value,
                onChanged: (v) {
                  _pw.value = v;
                  _pwError.value = _validatePw(v);
                  _recalcSubmit();
                },
                style: FontStyles.B3_bold_15,
                textAlignVertical: TextAlignVertical.center,
                cursorColor: AppColors.mainGreen,
                decoration: InputDecoration(
                  hintText: '비밀번호',
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
                  controller.loginPwCtrl.clear();
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

  Widget _checkButton(BuildContext context) {
    final bottomPadding =
        MediaQuery.of(context).viewInsets.bottom > 0 ? 16.h : 80.h;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Obx(() {
        final bool isActive = _canSubmit.value && !controller.isLoading.value;
        final bool isPressed = _pressed.value;
        final bool isLoading = controller.isLoading.value;

        return CustomCheckButton(
          text: isLoading ? '처리중...' : '로그인',
          isActive: isActive && !isLoading,
          isPressed: isPressed,
          onTap: isActive ? controller.login : null,
          onTapDown: () => _pressed.value = true,
          onTapUp: () => _pressed.value = false,
          onTapCancel: () => _pressed.value = false,
        );
      }),
    );
  }
}
