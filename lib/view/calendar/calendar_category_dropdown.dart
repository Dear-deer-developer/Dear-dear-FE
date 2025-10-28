// lib/view/calendar/calendar_category_dropdown.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/view/calendar/calendar_category_meta.dart';

class CategoryDropdown extends StatefulWidget {
  final String selectedCategory; // 라벨(String)
  final ValueChanged<String> onCategorySelected; // 라벨(String)

  const CategoryDropdown({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  final double popupWidth = 184.w;
  final double popupHeight = 170.h;

  @override
  Widget build(BuildContext context) {
    final labels = CalendarCategoryMeta.labels;

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: AppColors.G_03, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      child: PopupMenuButton<String>(
        onSelected: widget.onCategorySelected,
        constraints:
            BoxConstraints(minWidth: popupWidth.w, maxWidth: popupWidth.w),
        itemBuilder: (context) {
          final items = <PopupMenuEntry<String>>[];
          for (int i = 0; i < labels.length; i++) {
            final label = labels[i];
            items.add(
              PopupMenuItem<String>(
                value: label,
                height: 40.h,
                padding: EdgeInsets.zero,
                child: SizedBox(
                  width: 184.w,
                  height: 40.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 22.w),
                        child: Text(label, style: FontStyles.B4_reg_14),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 5.w),
                        child: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: CalendarCategoryMeta.colorByLabel(label),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
            if (i < labels.length - 1) {
              items.add(
                PopupMenuItem<String>(
                  enabled: false,
                  height: 1,
                  padding: EdgeInsets.zero,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(height: 1, color: AppColors.G_03),
                  ),
                ),
              );
            }
          }
          return items;
        },
        child: Row(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color:
                    CalendarCategoryMeta.colorByLabel(widget.selectedCategory),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            Text(widget.selectedCategory, style: FontStyles.B3_bold_15),
            Icon(Icons.arrow_drop_down, color: AppColors.G_05),
          ],
        ),
      ),
    );
  }
}
