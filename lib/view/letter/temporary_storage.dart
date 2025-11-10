import 'package:dear_deer_demo/controller/post/temporay_storage_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/view/letter/write_letter_screen.dart';
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
                Expanded(child: _list()), // ✅ 스크롤 지원
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
          style: FontStyles.H2_bold_17,
        ),
      );

  /// 상단: 총 개수 + 삭제/확인 버튼
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
                style: FontStyles.B3_reg_15.copyWith(color: Colors.black),
                children: [
                  const TextSpan(text: "총 "),
                  TextSpan(
                    text: "$count",
                    style: FontStyles.B3_bold_15.copyWith(
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

  /// 편지 리스트
  Widget _list() => Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Obx(() {
          if (controller.items.isEmpty) {
            return const Center(child: Text("임시 저장된 편지가 없습니다."));
          }

          return ListView.separated(
            itemCount: controller.items.length,
            separatorBuilder: (_, __) =>
                const Divider(color: AppColors.G_02, thickness: 1),
            itemBuilder: (context, index) {
              final item = controller.items[index];
              final id = item['id'] as int?;
              final content = item['content'] ?? '';
              final displayTitle = item['displayTitle'] ?? '';
              final formattedTime = item['formattedTime'] ?? '';

              // 여기서 각 item을 Obx로 감싼다.
              return Obx(() {
                final isSelected = controller.selectedItems.contains(id);

                return GestureDetector(
                  onTap: controller.isDeleteMode.value
                      ? () {
                          if (id != null) controller.toggleItemSelection(id);
                        }
                      : () {
                          Get.to(
                            () => WriteLetterScreen(letterData: item),
                          );
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(displayTitle, style: FontStyles.B4_bold_14),
                              const SizedBox(height: 4),
                              Text(content, style: FontStyles.S3_reg_10),
                              const SizedBox(height: 2),
                              Text(
                                formattedTime,
                                style: FontStyles.S3_reg_10.copyWith(
                                    color: AppColors.G_04),
                              ),
                            ],
                          ),
                        ),
                        if (controller.isDeleteMode.value)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, top: 4),
                            child: Container(
                              width: 24.w,
                              height: 24.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.mainRed
                                      : AppColors.G_03,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 12.w,
                                        height: 12.h,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.mainRed,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              });
            },
          );
        }),
      );
}
