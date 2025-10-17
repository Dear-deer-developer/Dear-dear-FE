import 'package:dear_deer_demo/controller/login/auth_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LoginMain extends GetView<AuthController> {
  const LoginMain({super.key});

  // --- 로컬 상태 ---
  // --- 로컬 상태 (디자인 요구에 맞춰 단순화) ---
  static final RxString _email = ''.obs;
  static final RxString _pw = ''.obs;

  static final RxBool _canSubmit = false.obs;
  static final RxBool _pwVisible = false.obs;
  static final RxBool _loading = false.obs;

  // 서버 응답 에러(아이디/비밀번호 불일치 등)만 노출
  static final RxnString _loginError = RxnString();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _body()),
    );
  }

  Widget _body() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 81.h),
              child: Column(
                children: [
                  // MARK: - 아이콘
                  Image.asset(
                    ImagePath.loginIcon,
                    width: 120.w,
                    height: 120.h,
                  ),
                  SizedBox(
                    height: 24.h,
                  ),
                  // MARK: - 로그인 필드
                  _idField(),
                  SizedBox(
                    height: 8.h,
                  ),
                  _passwordField(),

                  SizedBox(height: 16.h),
                  _loginButton(),

                  SizedBox(height: 12.h),
                  _helperLinks(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _idField() {
    return Obx(() {
      final isEmpty = _email.value.isEmpty;
      return Container(
        width: 312.w,
        height: 48.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.G_02, width: 1.w),
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
                  _recalcSubmit();
                },
                style: FontStyles.B3_bold_15,
                textAlignVertical: TextAlignVertical.center,
                cursorColor: AppColors.mainGreen,
                decoration: InputDecoration(
                  hintText: '아이디',
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

  Widget _passwordField() {
    return Obx(() {
      final isEmpty = _pw.value.isEmpty;
      final hasError = _loginError.value != null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 312.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.G_02, width: 1.w),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.loginPwCtrl,
                    obscureText: !_pwVisible.value,
                    onChanged: (v) {
                      _pw.value = v;
                      if (_loginError.value != null) _loginError.value = null;
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
                // 눈 아이콘
                GestureDetector(
                  onTap: () => _pwVisible.value = !_pwVisible.value,
                  child: SizedBox(
                    width: 40.w,
                    height: 40.h,
                    child: Center(
                      child: Image.asset(
                        _pwVisible.value
                            ? ImagePath.eyeOffIcon
                            : ImagePath.eyeOnIcon,
                        width: 18.w,
                        height: 18.h,
                      ),
                    ),
                  ),
                ),
                // X 삭제 아이콘
                if (!isEmpty)
                  GestureDetector(
                    onTap: () {
                      controller.loginPwCtrl.clear();
                      _pw.value = '';
                      _recalcSubmit();
                    },
                    child: SizedBox(
                      width: 40.w,
                      height: 40.h,
                      child: Center(
                        child: Image.asset(
                          ImagePath.textDeleteIcon,
                          width: 16.w,
                          height: 16.h,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (hasError) ...[
            SizedBox(height: 6.h),
            Text(
              _loginError.value!,
              style: FontStyles.S1_reg_13.copyWith(color: AppColors.mainRed),
            ),
          ],
        ],
      );
    });
  }

  Widget _loginButton() {
    return Obx(() {
      final enabled = _canSubmit.value && !_loading.value;
      return GestureDetector(
        onTap: enabled ? _onSubmit : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 312.w,
          height: 48.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled ? AppColors.mainGreen : AppColors.G_01,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: _loading.value
              ? SizedBox(
                  width: 18.w,
                  height: 18.w,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  '로그인',
                  style: FontStyles.Button_bold_17.copyWith(
                    color: enabled ? Colors.white : AppColors.G_02,
                  ),
                ),
        ),
      );
    });
  }

  Widget _helperLinks() {
    return SizedBox(
      width: 312.w,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _link('비밀번호 찾기', () {
            // TODO: 라우팅 연결
          }),
          _link('아이디 찾기', () {
            // TODO: 라우팅 연결
          }),
          _link('회원가입', () {
            // TODO: Get.to(() => JwtSignUp());
          }),
        ],
      ),
    );
  }

  Widget _link(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: FontStyles.S1_reg_13.copyWith(color: AppColors.G_05),
      ),
    );
  }

  // -------------------- 내부 검증 & 유틸 --------------------
  void _recalcSubmit() {
    _canSubmit.value = _email.isNotEmpty && _pw.isNotEmpty;
  }

  Future<void> _onSubmit() async {
    _loading.value = true;
    _loginError.value = null;

    try {
      await controller.login(); // ← 여기로 변경!
    } catch (e) {
      _loginError.value = '일시적인 오류가 발생했어요. 잠시 후 다시 시도해주세요.';
    } finally {
      _loading.value = false;
    }
  }
}
