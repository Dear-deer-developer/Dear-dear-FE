import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dear_deer_demo/widget/custom_button.dart';
import 'package:dear_deer_demo/controller/post/post_controller.dart';

class SelectLetterPaperScreen extends StatefulWidget {
  const SelectLetterPaperScreen({super.key});

  @override
  State<SelectLetterPaperScreen> createState() =>
      _SelectLetterPaperScreenState();
}

class _SelectLetterPaperScreenState extends State<SelectLetterPaperScreen> {
  int? selectedIndex;
  final PostController controller = Get.find(); // 컨트롤러 가져오기
  final List<Color> letterPapers = List.generate(6, (_) => Colors.grey[300]!);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: _appBar(),
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 360.w, // Figma 기준 화면 고정
            child: Column(
              children: [
                Expanded(child: _letterGrid()),
                SelectLetterButton(
                  isEnabled: selectedIndex != null,
                  onPressed: () => controller.goToWriteLetter(),
                  buttonText: "이 편지지로 선택하기", // 원하는 텍스트로 변경 가능
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //MARK: -
  ///
  AppBar _appBar() => AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleSpacing: 0,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "편지지 고르기",
            style: FontStyles.H1_bold_17,
            textAlign: TextAlign.left,
          ),
        ),
      );

  // MARK:-
  Widget _letterGrid() => Center(
        child: SizedBox(
          width: 312.w,
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: letterPapers.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.w,
              childAspectRatio: 148 / 208,
            ),
            itemBuilder: (context, index) {
              final isSelected = selectedIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Container(
                  width: 148.w,
                  height: 208.h,
                  decoration: BoxDecoration(
                    color: letterPapers[index],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.red : Colors.transparent,
                      width: 3.w,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
}
