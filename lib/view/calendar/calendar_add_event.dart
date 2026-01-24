import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/view/calendar/calendar_category_dropdown.dart';
import 'package:dear_deer_demo/view/calendar/calendar_modal_widget.dart';

class AddEventResult {
  final DateTime date;
  final String title;
  final String memo;
  final String uiCategory;
  AddEventResult({
    required this.date,
    required this.title,
    required this.memo,
    required this.uiCategory,
  });
}

class AddEvent extends StatefulWidget {
  final DateTime initialDate;
  const AddEvent({Key? key, required this.initialDate}) : super(key: key);

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final _titleController = TextEditingController();
  final _memoController = TextEditingController();

  late DateTime _selectedDate;
  String _selectedCategory = "기타";
  bool _showCalendar = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final memo = _memoController.text.trim();

    Navigator.pop(
      context,
      AddEventResult(
        date: _selectedDate,
        title: title,
        memo: memo,
        uiCategory: _selectedCategory,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat("yyyy년 MM월 dd일").format(_selectedDate);

    return SizedBox(
      height: 620.h,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            color: AppColors.bgColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _appBar(),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _titleAndMemoFields(),
                      _dateField(formattedDate),
                      _categoryField(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _appBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 23.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Text("취소",
                  style: FontStyles.S1_reg_13.copyWith(color: AppColors.G_05)),
            ),
            GestureDetector(
              onTap: _submit,
              child: Text(
                "확인",
                style: FontStyles.S1_reg_13.copyWith(color: AppColors.G_05),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _titleAndMemoFields() {
    return Container(
      height: 96.h,
      margin: EdgeInsets.only(top: 15.h),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.G_03, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            style: FontStyles.B3_bold_15,
            decoration: InputDecoration(
              hintText: '제목',
              hintStyle: FontStyles.B3_bold_15.copyWith(color: AppColors.G_04),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Divider(thickness: 1, color: AppColors.G_02, height: 1),
          ),
          TextField(
            controller: _memoController,
            style: FontStyles.B3_bold_15,
            decoration: InputDecoration(
              hintText: '메모',
              hintStyle: FontStyles.B3_bold_15.copyWith(color: AppColors.G_04),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateField(String formattedDate) {
    return Container(
      margin: EdgeInsets.only(top: 24.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.G_03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 헤더(날짜 + 화살표)
          InkWell(
            onTap: () => setState(() => _showCalendar = !_showCalendar),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: FontStyles.B3_bold_15.copyWith(color: AppColors.Black),
                ),
                // 펼침 아이콘 (열릴 때 회전)
                AnimatedRotation(
                  turns: _showCalendar ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: const Icon(Icons.expand_more, color: AppColors.G_05),
                ),
              ],
            ),
          ),

          if (_showCalendar) ...[
            Padding(
              padding: EdgeInsets.only(top: 14.h),
              child: Divider(thickness: 1, color: AppColors.G_02, height: 1),
            ),
            CustomCalendarWidget(
              selectedDate: _selectedDate,
              onDateSelected: (selected) {
                setState(() {
                  _selectedDate = selected;
                  _showCalendar = false;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _categoryField() {
    return Container(
      height: 48.h,
      margin: EdgeInsets.only(top: 24.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.G_03),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "카테고리",
            style: FontStyles.B3_bold_15.copyWith(color: AppColors.G_05),
          ),
          CategoryDropdown(
            selectedCategory: _selectedCategory,
            onCategorySelected: (value) {
              setState(() => _selectedCategory = value);
            },
          ),
        ],
      ),
    );
  }
}
