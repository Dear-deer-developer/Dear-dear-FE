import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/model/content_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContentCard extends StatelessWidget {
  final ContentItem item;
  const ContentCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 썸네일
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Image.network(item.thumbnailUrl, fit: BoxFit.cover),
                ),
                // 그라데이션 오버레이
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.55),
                        ],
                      ),
                    ),
                  ),
                ),
                // 타이틀
                Positioned(
                  left: 12.w,
                  right: 12.w,
                  bottom: 12.h,
                  child: Text(
                    item.title,
                    style: FontStyles.H2_bold_17.copyWith(color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // 본문
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.subtitle,
                  style: FontStyles.B3_reg_15.copyWith(color: AppColors.G_06),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Text('작성자: ${item.author}',
                        style: FontStyles.S1_reg_13.copyWith(
                            color: AppColors.G_05)),
                    const Spacer(),
                    Text('조회수: ${_compact(item.views)}',
                        style: FontStyles.S1_reg_13.copyWith(
                            color: AppColors.G_05)),
                    SizedBox(width: 8.w),
                    Text('스크랩: ${_compact(item.scraps)}',
                        style: FontStyles.S1_reg_13.copyWith(
                            color: AppColors.G_05)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _compact(int n) {
    if (n >= 10000) {
      final d = (n / 10000).toStringAsFixed(1);
      return '$d만';
    }
    return n.toString();
  }
}
