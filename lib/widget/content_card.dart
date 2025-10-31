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
    // origin에 따라 카드 디자인 분기
    switch (item.origin) {
      case MainTab.contents:
        return _buildContentsCard();
      case MainTab.event:
        return _buildEventCard();
      case MainTab.bookmark:
        // 즐겨찾기는 출처(origin)에 따라 실제 카드 재사용
        return item.origin == MainTab.contents
            ? _buildContentsCard()
            : _buildEventCard();
    }
  }

  // -----------------------------
  // 콘텐츠 추천 카드
  // -----------------------------
  Widget _buildContentsCard() {
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
          // 썸네일 + 타이틀 오버레이
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child:
                      Image.network(item.thumbnailUrl ?? '', fit: BoxFit.cover),
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
                  item.subtitle ?? '',
                  style: FontStyles.B3_reg_15.copyWith(color: AppColors.G_06),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Text('작성자: ${item.author ?? '-'}',
                        style: FontStyles.S1_reg_13.copyWith(
                            color: AppColors.G_05)),
                    const Spacer(),
                    Text('조회수: ${_compact(item.views ?? 0)}',
                        style: FontStyles.S1_reg_13.copyWith(
                            color: AppColors.G_05)),
                    SizedBox(width: 8.w),
                    Text('스크랩: ${_compact(item.scraps ?? 0)}',
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

  // -----------------------------
  // 행사 알림 카드
  // -----------------------------
  Widget _buildEventCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.G_02, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 썸네일 (포스터형)
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              bottomLeft: Radius.circular(12.r),
            ),
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Image.network(item.thumbnailUrl ?? '', fit: BoxFit.cover),
            ),
          ),
          // 오른쪽 내용
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리 태그
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.Red01,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      item.subtype,
                      style: FontStyles.S1_reg_13.copyWith(
                          color: AppColors.mainRed),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  // 제목
                  Text(
                    item.title,
                    style:
                        FontStyles.H3_bold_16.copyWith(color: AppColors.Black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  // 설명
                  Text(
                    item.subtitle ?? '',
                    style: FontStyles.B3_reg_15.copyWith(color: AppColors.G_05),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('주최: ${item.author ?? '-'}',
                          style: FontStyles.S1_reg_13.copyWith(
                              color: AppColors.G_05)),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(60.w, 30.h),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          '자세히 보기',
                          style: FontStyles.S1_reg_13.copyWith(
                              color: AppColors.mainRed),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 숫자 압축 (조회수/스크랩)
  String _compact(int n) {
    if (n >= 10000) {
      final d = (n / 10000).toStringAsFixed(1);
      return '$d만';
    }
    return n.toString();
  }
}
