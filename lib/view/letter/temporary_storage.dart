import 'package:dear_deer_demo/controller/post/temporay_storage_controller.dart';

import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/view/%08letter/letter_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class TemporaryStorage extends StatelessWidget {
  TemporaryStorage({super.key});

  final controller = Get.put(TemporaryStorageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _amount(),
                _list(),
              ],
            )),
      ),
    );
  }

  AppBar _appBar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          '임시 보관함',
          style: FontStyles.H1_bold_17,
        ),
      );

  Widget _amount() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            final count = controller.isDeleteMode.value
                ? controller.selectedItems.length
                : controller.items.length;

            final text = controller.isDeleteMode.value ? "개 선택됨" : "개";

            return RichText(
              text: TextSpan(
                style: FontStyles.B1_bold_15.copyWith(color: Colors.black),
                children: [
                  const TextSpan(text: "총 "),
                  TextSpan(
                    text: "$count",
                    style: FontStyles.B1_bold_15.copyWith(
                        color: AppColors.mainRed),
                  ),
                  TextSpan(text: " $text"),
                ],
              ),
            );
          }),
          GestureDetector(
            onTap: () {
              if (controller.isDeleteMode.value) {
                controller.confirmDelete();
              } else {
                controller.toggleDeleteMode();
              }
            },
            child: Text(
              controller.isDeleteMode.value ? "확인" : "삭제",
              style: FontStyles.S1_reg_13,
            ),
          ),
        ],
      );

  Widget _list() => Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Obx(() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(controller.itemCount, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 📦 텍스트 묶음
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Dear. 닉네임", style: FontStyles.B1_bold_14),
                              Text(
                                "작성하던 편지 내용 한줄. 작성하던 편지 내용 한줄. 작성하던",
                                style: FontStyles.S1_reg_10,
                              ),
                              Text(
                                "마지막 저장 : 2025. 11. 28. 23: 45",
                                style: FontStyles.S1_reg_10,
                              ),
                            ],
                          ),
                        ),

                        if (controller.isDeleteMode.value)
                          GestureDetector(
                            onTap: () => controller
                                .toggleItemSelection(controller.items[index]),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0, top: 4),
                              child: Container(
                                width: 24.w,
                                height: 24.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: controller.selectedItems
                                            .contains(controller.items[index])
                                        ? AppColors.mainRed
                                        : AppColors.G_03,
                                    width: 2,
                                  ),
                                  color: Colors.transparent, // 바깥 원은 투명하게 유지
                                ),
                                child: controller.selectedItems
                                        .contains(controller.items[index])
                                    ? Center(
                                        child: Container(
                                          width: 16.w, // 바깥 원보다 작게
                                          height: 16.h,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors
                                                .mainRed, // 내부 작은 원만 주황색
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(
                      color: AppColors.G_02,
                      thickness: 1,
                      height: 1,
                    ),
                  ],
                ),
              );
            }),
          );
        }),
      );
}
