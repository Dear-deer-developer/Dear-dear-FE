import 'package:dear_deer_demo/controller/admin/admin_write_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/view/admin/catagory_select_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class WriteDetailView extends StatefulWidget {
  WriteDetailView({super.key});

  @override
  State<WriteDetailView> createState() => _WriteDetailViewState();
}

class _WriteDetailViewState extends State<WriteDetailView> {
  /// 제목 입력 필드의 텍스트 컨트롤러
  /// 본문 입력 필드의 텍스트 컨트롤러
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    /// 텍스트 필드 내용이 변경될 땜다ㅏ 상태를 갱신하여 버튼을 활성화하도록 설정하였습니다.
    _titleController.addListener(_updateState);
    _contentController.addListener(_updateState);
  }

  /// 상태 갱신 함수
  void _updateState() {
    setState(() {});
  }

  /// 위젯이 없어지게 된다면 컨트롤러가 해제됩니다.
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// 제목과 본문이 모두 빈 문자열인지 아닌지 확인하는 함수
  bool get isAllFilled =>
      _titleController.text.trim().isNotEmpty &&
      _contentController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.White,
      appBar: _appBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _photo(),
                    _context(),
                  ],
                ),
              ),
            ),
            _button(),
          ],
        ),
      ),
    );
  }

// MARK: AppBar
  AppBar _appBar() => AppBar(
        elevation: 0,
        backgroundColor: AppColors.White,
        scrolledUnderElevation: 0,
        title: Text("글 쓰기", style: FontStyles.H1_bold_17),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: GestureDetector(
              onTap: () {
                print("임시 저장되었습니다.");
              },
              child: Text("임시저장", style: FontStyles.S1_reg_13),
            ),
          ),
        ],
      );

// MARK: 사진
  Widget _photo() => Padding(
        padding: EdgeInsets.only(top: 16.h, bottom: 34.h),
        child: Container(
          width: double.infinity,
          height: 356.h,
          color: Colors.grey,
        ),
      );

// MARK: 편지 입력
  Widget _context() => Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 24.w),
              child: TextField(
                controller: _titleController,
                style: FontStyles.H1_bold_22.copyWith(
                  color: AppColors.Black,
                ),
                decoration: InputDecoration(
                  hintText: "제목",
                  hintStyle: FontStyles.H1_bold_22.copyWith(
                    color: AppColors.G_05,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(
            indent: 24.w,
            endIndent: 24.w,
            height: 1.h,
            color: AppColors.G_03,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 24.w, right: 24.w),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: 300.h,
                ),
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: FontStyles.B1_reg_16.copyWith(
                    color: AppColors.Black,
                  ),
                  decoration: InputDecoration(
                    hintText: "본문 내용을 입력하세요.",
                    hintStyle: FontStyles.B1_reg_16.copyWith(
                      color: AppColors.G_05,
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      );

// MARK: 버튼
  /// 카테고리 선택 버튼입니다.
  /// 버튼은 제목과 본문이 모두 입력되어있을 때만 활성화됩니다.
  /// 버튼을 누르면 카테고리 선택 화면으로 이동하게 됩니다.
  Widget _button() => Padding(
        padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 24.h),
        child: GestureDetector(
          onTap: isAllFilled
              ? () {
                  Get.to(() => CategorySelectView());
                }
              : null,
          child: Container(
            width: double.infinity,
            height: 48.h,
            decoration: BoxDecoration(
              color: isAllFilled ? AppColors.mainGreen : AppColors.Green01,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              "카테고리 선택",
              style: FontStyles.Button_bold_17.copyWith(
                color: isAllFilled ? Colors.white : AppColors.Green02,
              ),
            ),
          ),
        ),
      );
}
