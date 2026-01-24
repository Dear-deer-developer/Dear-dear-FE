import 'package:dear_deer_demo/controller/login/auth_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/view/login/sign_up_agreement.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LoginMain extends StatefulWidget {
  const LoginMain({super.key});

  @override
  State<LoginMain> createState() => _LoginMainState();
}

class _LoginMainState extends State<LoginMain> {
  // ✅ 로그인 화면 진입 시 AuthController가 반드시 존재하도록 보장
  late final AuthController controller;

  // ✅ "static" 제거: 화면 재진입 시 상태 꼬임 방지
  final RxString _email = ''.obs;
  final RxString _pw = ''.obs;

  final RxBool _canSubmit = false.obs;
  final RxBool _pwVisible = false.obs;
  final RxBool _loading = false.obs;

  // 서버 응답 에러(아이디/비밀번호 불일치 등)만 노출
  final RxnString _loginError = RxnString();

  @override
  void initState() {
    super.initState();

    // ✅ 이미 있으면 가져오고, 없으면 생성
    controller = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    // ✅ 화면 열릴 때 입력값/에러 초기화(원하면 유지해도 됨)
    controller.loginEmailCtrl.text = '';
    controller.loginPwCtrl.text = '';
    _email.value = '';
    _pw.value = '';
    _loginError.value = null;
    _recalcSubmit();
  }

  @override
  void dispose() {
    // Rx 자체는 GetX가 자동 정리해주진 않아서, close 해주는 게 안전
    _email.close();
    _pw.close();
    _canSubmit.close();
    _pwVisible.close();
    _loading.close();
    _loginError.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: _body(),
        ),
      ),
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
                  SizedBox(height: 24.h),

                  // MARK: - 로그인 입력
                  _idField(),
                  SizedBox(height: 8.h),
                  _passwordField(),
                  SizedBox(height: 24.h),
                  _loginButton(),
                  SizedBox(height: 24.h),
                  _helperLinks(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // MARK: 아이디 입력 필드
  Widget _idField() {
    return Container(
      width: 312.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.G_02, width: 1.w),
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          TextField(
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
              hintStyle: FontStyles.B3_reg_15.copyWith(color: AppColors.G_05),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.only(left: 16.w, right: 48.w),
            ),
          ),

          // X 삭제 버튼
          Positioned(
            right: 0.w,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                controller.loginEmailCtrl.clear();
                _email.value = '';
                _recalcSubmit();
              },
              child: Image.asset(
                ImagePath.textDeleteIcon,
                width: 48.w,
                height: 48.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MARK: 비밀번호 입력 필드
  Widget _passwordField() {
    return Obx(() {
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
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                TextField(
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
                    contentPadding: EdgeInsets.only(left: 16.w, right: 48.w),
                  ),
                ),

                // 눈 아이콘
                Positioned(
                  right: 48.w,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => _pwVisible.value = !_pwVisible.value,
                    child: SizedBox(
                      width: 18.w,
                      height: 18.h,
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
                ),

                // X 삭제 버튼
                Positioned(
                  right: 0.w,
                  top: 0,
                  bottom: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      controller.loginPwCtrl.clear();
                      _pw.value = '';
                      _recalcSubmit();
                    },
                    child: SizedBox(
                      width: 48.w,
                      height: 48.h,
                      child: Center(
                        child: Image.asset(
                          ImagePath.textDeleteIcon,
                          width: 48.w,
                          height: 48.h,
                        ),
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

  // MARK: 로그인 버튼
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
            color: enabled ? AppColors.mainGreen : AppColors.Green01,
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
                    color: enabled ? Colors.white : AppColors.Green02,
                  ),
                ),
        ),
      );
    });
  }

  // MARK: 비밀번호, 아이디 찾기, 회원가입
  Widget _helperLinks() {
    return SizedBox(
      width: 238.w,
      height: 14.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _link('비밀번호 찾기', () {}),
          _link('아이디 찾기', () {}),
          _link('회원가입', () {
            Get.to(() => SignUpAgreement());
          }),
        ],
      ),
    );
  }

  Widget _link(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(text, style: FontStyles.S2_reg_12),
    );
  }

  void _recalcSubmit() {
    _canSubmit.value = _email.isNotEmpty && _pw.isNotEmpty;
  }

  Future<void> _onSubmit() async {
    _loading.value = true;
    _loginError.value = null;

    try {
      await controller.login();
    } catch (e) {
      _loginError.value = '일시적인 오류가 발생했어요. 잠시 후 다시 시도해주세요.';
    } finally {
      _loading.value = false;
    }
  }
}
