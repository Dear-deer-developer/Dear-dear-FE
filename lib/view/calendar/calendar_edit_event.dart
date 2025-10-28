import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/view/calendar/calendar_category_dropdown.dart';
import 'package:dear_deer_demo/view/calendar/calendar_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:dear_deer_demo/view/calendar/calendar_modal_widget.dart';

class EditEventSheet extends StatefulWidget {
  final DateTime initialDate;
  final CalendarEvent originalEvent;

  const EditEventSheet({
    Key? key,
    required this.initialDate,
    required this.originalEvent,
  }) : super(key: key);

  @override
  State<EditEventSheet> createState() => _EditEventSheetState();
}

class _EditEventSheetState extends State<EditEventSheet> {
  late TextEditingController titleController;
  late TextEditingController memoController;
  late DateTime selectedDate;
  late String selectedCategory;
  bool showCalendar = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.originalEvent.title);
    memoController = TextEditingController(text: widget.originalEvent.memo);
    selectedDate = widget.originalEvent.date;
    selectedCategory = widget.originalEvent.category;
  }

  @override
  void dispose() {
    titleController.dispose();
    memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat("yyyy년 MM월 dd일").format(selectedDate);

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
              PreferredSize(
                preferredSize: Size.fromHeight(60.h),
                child: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  titleSpacing: 0,
                  title: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 23.w, vertical: 15.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text("취소",
                              style: FontStyles.S1_reg_13.copyWith(
                                  color: AppColors.G_05)),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (titleController.text.trim().isEmpty) return;
                            Navigator.pop(
                              context,
                              CalendarEvent(
                                id: widget.originalEvent.id,
                                title: titleController.text.trim(),
                                memo: memoController.text.trim(),
                                category: selectedCategory,
                                date: selectedDate,
                              ),
                            );
                          },
                          child: Text("수정",
                              style: FontStyles.S1_reg_13.copyWith(
                                  color: AppColors.G_05)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _titleAndMemoFields(),
                      SizedBox(height: 24.h),
                      _dateField(formattedDate),
                      SizedBox(height: 24.h),
                      _categoryField(),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      backgroundColor: AppColors.mainGreen,
                    ),
                    onPressed: () => Navigator.pop(context, 'deleted'),
                    child: Text("삭제하기",
                        style: FontStyles.Button_bold_17.copyWith(
                          color: AppColors.White,
                        )),
                  ),
                ),
              ),
            ],
          ),
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
            controller: titleController,
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
            controller: memoController,
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.G_03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () => setState(() => showCalendar = !showCalendar),
            child: Text(
              formattedDate,
              style: FontStyles.B3_bold_15.copyWith(color: AppColors.Black),
            ),
          ),
          if (showCalendar) ...[
            Padding(
              padding: EdgeInsets.only(top: 14.h),
              child: Divider(thickness: 1, color: AppColors.G_02, height: 1),
            ),
            CustomCalendarWidget(
              selectedDate: selectedDate,
              onDateSelected: (selected) {
                setState(() {
                  selectedDate = selected;
                  showCalendar = false;
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.G_03),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("카테고리",
              style: FontStyles.B3_bold_15.copyWith(color: AppColors.G_05)),
          CategoryDropdown(
            selectedCategory: selectedCategory,
            onCategorySelected: (value) {
              setState(() => selectedCategory = value);
            },
          ),
        ],
      ),
    );
  }
}
