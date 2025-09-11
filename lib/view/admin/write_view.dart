import 'package:dear_deer_demo/controller/admin/admin_write_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/view/admin/write_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class WriteView extends StatefulWidget {
  const WriteView({super.key});

  @override
  State<WriteView> createState() => _WriteViewState();
}

class _WriteViewState extends State<WriteView> {
  final WriteController controller = Get.put(WriteController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.White,
      appBar: _appBar(),
      body: _letter(),
    );
  }

// MARK: appBar
  /// 글 쓰기 화면의 앱 바입니다.
  /// 편지지를 하나 이상 선택하지 않고 다음 버튼을 누르게 되면, 이후 화면으로 넘어가지 않습니다.
  AppBar _appBar() => AppBar(
        elevation: 0,
        backgroundColor: AppColors.White,
        scrolledUnderElevation: 0,
        title: Text("글 쓰기", style: FontStyles.H2_bold_17),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: GestureDetector(
              onTap: () {
                if (controller.selectedIndices.isEmpty) {
                  return;
                }
                Get.to(() => const WriteDetailView());
              },
              child: Text("다음", style: FontStyles.S1_reg_13),
            ),
          ),
        ],
      );

// MARK: 편지지 선택
  /// 3 열 그리드로 편지지 목록을 구성하였습니다.
  /// 편지지는 Controller.letterPapers 에서 관리하며, 선택 여부는 Controller.selectedIndices 에서 관리합니다.
  /// 선택된 편지지는 오른쪽 위에 메인 레드 컬러와 선택 순서와 함깨 표시됩니다.
  Widget _letter() => Padding(
        padding: EdgeInsets.all(16.w),
        child: GridView.builder(
          itemCount: controller.letterPapers.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 3.w,
            mainAxisSpacing: 3.h,
          ),
          itemBuilder: (context, index) {
            return Obx(() {
              final selectedIndex =
                  controller.selectedIndices.indexOf(index); // 순번
              final isSelected = selectedIndex != -1; // 선택 여부

              return GestureDetector(
                onTap: () => controller.toggleSelection(index),
                child: Stack(
                  children: [
                    Container(
                      color: controller.letterPapers[index],
                    ),
                    Positioned(
                      top: 4.h,
                      right: 5.w,
                      child: Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.mainRed
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected ? Colors.transparent : Colors.grey,
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: isSelected
                            ? Text(
                                '${selectedIndex + 1}', // 선택 순서
                                style: FontStyles.Button_bold_17.copyWith(
                                  color: AppColors.White,
                                ),
                              )
                            : const SizedBox.shrink(), // 선택 안 했을 때도 원 유지
                      ),
                    ),
                  ],
                ),
              );
            });
          },
        ),
      );
}
