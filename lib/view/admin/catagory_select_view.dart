import 'package:dear_deer_demo/controller/admin/admin_letter_category_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CategorySelectView extends StatelessWidget {
  final CategoryController controller = Get.put(CategoryController());

  CategorySelectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.White,
      appBar: _appBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _category()),
            _uploadButton(context),
          ],
        ),
      ),
    );
  }

  AppBar _appBar() => AppBar(
        backgroundColor: AppColors.White,
        title: Text(
          "글 쓰기 (카테고리 선택)",
          style: FontStyles.H1_bold_17,
        ),
      );

  Widget _category() => SingleChildScrollView(
        child: Column(
          children: [
            // 콘텐츠 추천
            _sectionHeader("콘텐츠 추천"),
            _selectableItem("영화 · 드라마", 0),
            _selectableItem("음악", 1),
            _selectableItem("카페 음료", 2, bottomPadding: 23.h),

            // 행사 알림
            _sectionHeader("행사 알림"),
            _selectableItem("티켓팅 · 예약", 3),
            _selectableItem("팝업", 4),
            _selectableItem("축제", 5),
          ],
        ),
      );

  Widget _sectionHeader(String title) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: 24.w, top: 20.h, bottom: 8.h),
          child: Text(
            title,
            style: FontStyles.H1_bold_16,
          ),
        ),
      );

  Widget _selectableItem(String text, int index, {double bottomPadding = 8.0}) {
    return Obx(() {
      final isSelected = controller.selectedIndices.contains(index);

      return GestureDetector(
        onTap: () {
          controller.toggleSelection(index);
        },
        child: Padding(
          padding:
              EdgeInsets.only(left: 24.w, right: 24.w, bottom: bottomPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style:
                    isSelected ? FontStyles.B1_bold_15 : FontStyles.B1_reg_15,
              ),
              if (isSelected)
                Icon(
                  Icons.check,
                  color: AppColors.Black,
                  size: 20.w,
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _uploadButton(BuildContext context) => Padding(
        padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 24.h),
        child: GestureDetector(
          onTap: () => _Diaglog(context),
          child: Container(
            width: double.infinity,
            height: 48.h,
            decoration: BoxDecoration(
              color: AppColors.mainGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              "업로드",
              style: FontStyles.Button_bold_17.copyWith(
                color: AppColors.White,
              ),
            ),
          ),
        ),
      );

  void _Diaglog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 310.w,
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("확인", style: FontStyles.H1_bold_17),
              SizedBox(height: 16.h),
              Text(
                "다른 관리자와 함께\n숨긴 글에서 공개글로 전환하세요.",
                style: FontStyles.B1_reg_16,
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: EdgeInsets.only(top: 45.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Text("뒤로",
                          style: FontStyles.B1_reg_16.copyWith(
                              color: AppColors.G_05)),
                    ),
                    SizedBox(width: 120.w),
                    GestureDetector(
                      onTap: () {
                        // 업로드 처리
                        Get.back();
                      },
                      child: Text("확인", style: FontStyles.B1_reg_16),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
