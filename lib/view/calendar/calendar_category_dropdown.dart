import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/view/calendar/calendar_category_meta.dart';

/// 작은 이중 화살표 (ᐱᐯ 느낌)
class TinyChevron extends StatelessWidget {
  const TinyChevron({super.key, this.color});
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).iconTheme.color;
    return const SizedBox(
      width: 16,
      height: 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(top: 0, child: Icon(Icons.keyboard_arrow_up_rounded)),
          Positioned(bottom: 0, child: Icon(Icons.keyboard_arrow_down_rounded)),
        ],
      ),
    );
  }
}

class CategoryDropdown extends StatefulWidget {
  final String selectedCategory; // 라벨(String)
  final ValueChanged<String> onCategorySelected;

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
        constraints: BoxConstraints(
          minWidth: popupWidth,
          maxWidth: popupWidth,
        ),
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
                  width: popupWidth,
                  height: 40.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 22.w),
                        child: Text(label, style: FontStyles.B4_reg_14),
                      ),
                      const Spacer(),
                      Padding(
                        padding: EdgeInsets.only(right: 25.w),
                        child: Container(
                          width: 7.7.w,
                          height: 7.7.w,
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

        // 필드에 보여줄 오른쪽(선택된 값 + 점 + 이중 화살표)
        child: Row(
          // mainAxisSize: MainAxisSize.min,
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
            SizedBox(width: 4.w),
            Icon(Icons.unfold_more_rounded, size: 20, color: AppColors.Black),
          ],
        ),
      ),
    );
  }
}
