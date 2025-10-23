import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';

class CategoryDropdown extends StatefulWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const CategoryDropdown({
    Key? key,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  static const List<String> categories = [
    "약속",
    "팝업",
    "티켓팅&예약",
    "기타",
  ];

  static final Map<String, Color> categoryColors = {
    "약속": Colors.red,
    "팝업": Colors.green,
    "티켓팅&예약": Colors.yellow,
    "기타": Colors.black,
  };

  @override
  State<CategoryDropdown> createState() => _CategoryDropdownState();
}

class _CategoryDropdownState extends State<CategoryDropdown> {
  final double popupWidth = 184.w;
  final double popupHeight = 170.h;

  @override
  Widget build(BuildContext context) {
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
        constraints: BoxConstraints(
          minWidth: popupWidth.w,
          maxWidth: popupWidth.w,
        ),
        itemBuilder: (context) {
          final double itemHeight = 40.h;
          final double dividerHeight = 1.0;
          final items = <PopupMenuEntry<String>>[];
          for (int i = 0; i < CategoryDropdown.categories.length; i++) {
            final cat = CategoryDropdown.categories[i];
            items.add(
              PopupMenuItem<String>(
                value: cat,
                height: itemHeight,
                padding: EdgeInsets.zero,
                child: SizedBox(
                  width: 184.w,
                  height: itemHeight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 22.w),
                        child: Text(cat, style: FontStyles.B1_reg_14),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 5.w),
                        child: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: CategoryDropdown.categoryColors[cat],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
            if (i < CategoryDropdown.categories.length - 1) {
              items.add(
                PopupMenuItem<String>(
                  enabled: false,
                  height: dividerHeight,
                  padding: EdgeInsets.zero,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      height: dividerHeight,
                      color: AppColors.G_03,
                    ),
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
                color: CategoryDropdown.categoryColors[widget.selectedCategory],
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 8.w),
            Text(widget.selectedCategory, style: FontStyles.B1_bold_15),
            Icon(Icons.arrow_drop_down, color: AppColors.G_05),
          ],
        ),
      ),
    );
  }
}
