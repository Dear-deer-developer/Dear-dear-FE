import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dear_deer_demo/widget/custom_button.dart';
import 'package:dear_deer_demo/controller/post/post_controller.dart';

/// 편지지 선택 화면입니다.
/// 사용자는 이 화면에서 원하는 편지지를 선택할 수 있으며,
/// 선택한 후 '이 편지지로 선택하기' 버튼을 통해 다음 단계로 이동할 수 있습니다.
class SelectLetterPaperScreen extends StatefulWidget {
  const SelectLetterPaperScreen({super.key});

  @override
  State<SelectLetterPaperScreen> createState() =>
      _SelectLetterPaperScreenState();
}

class _SelectLetterPaperScreenState extends State<SelectLetterPaperScreen> {
  // MARK: - State
  /// 선택된 편지지의 인덱스를 저장하는 상태 변수입니다.
  int? selectedIndex;
  // 우체국 관련 비즈니스 로직을 담당하는 컨트롤러입니다.
  final PostController controller = Get.find();
  // 편지지 색상 리스트입니다. (임시로 회색 6개 생성)
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
                _selectButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MARK: - 앱바

  /// 상단 앱바를 반환합니다.
  /// "편지지 고르기" 타이틀을 왼쪽 정렬로 표시합니다.
  AppBar _appBar() => AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleSpacing: 0,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "편지지 고르기",
            style: FontStyles.H2_bold_17,
            textAlign: TextAlign.left,
          ),
        ),
      );

  // MARK: - 편지지 그리드

  /// 편지지 선택 그리드를 반환합니다.
  /// 사용자는 이 그리드에서 원하는 편지지를 선택할 수 있습니다.
  Widget _letterGrid() => Center(
        child: SizedBox(
          width: 312.w,
          child: GridView.builder(
            shrinkWrap: true,
            itemCount: letterPapers.length,
            gridDelegate: _gridDelegate(),
            itemBuilder: (context, index) => _letterPaperItem(index),
          ),
        ),
      );

  // MARK: - 그리드 레이아웃 설정

  /// 그리드의 레이아웃을 설정하는 델리게이트를 반환합니다.
  /// 2열로 구성되며, 각 아이템의 크기와 간격을 지정합니다.
  SliverGridDelegateWithFixedCrossAxisCount _gridDelegate() =>
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.w,
        childAspectRatio: 148 / 208,
      );

  // MARK: - 편지지 아이템

  /// 개별 편지지 아이템을 반환합니다.
  /// 사용자가 아이템을 터치하면 선택 상태가 토글되며, 선택된 아이템은 빨간색 테두리로 표시됩니다.
  Widget _letterPaperItem(int index) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        // 사용자가 편지지를 선택하면 상태를 업데이트합니다.
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
  }

  // MARK: - 선택 버튼

  /// '이 편지지로 선택하기' 버튼을 반환합니다.
  /// 편지지가 선택되어야 활성화되며, 버튼을 누르면 다음 단계로 이동합니다.
  Widget _selectButton() => SelectLetterButton(
        isEnabled: selectedIndex != null,
        onPressed: () => controller.goToWriteLetter(),
        buttonText: "이 편지지로 선택하기", // 원하는 텍스트로 변경 가능
      );
}
