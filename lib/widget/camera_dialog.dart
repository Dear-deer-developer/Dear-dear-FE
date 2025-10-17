import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum ProfileImageAction { pickFromAlbum, useDefault }

class CameraDialog extends StatelessWidget {
  const CameraDialog({super.key});

  // ✅ 정적 show 함수 — 다이얼로그를 호출하는 진입 메서드
  static Future<ProfileImageAction?> show(BuildContext context) {
    return showDialog<ProfileImageAction>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => const CameraDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r), // 다이얼로그 모서리 둥글기
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 312.w, maxHeight: 94.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 앨범에서 선택
            _DialogItem(
              label: '앨범에서 선택',
              onTap: () =>
                  Navigator.of(context).pop(ProfileImageAction.pickFromAlbum),
              isTop: true,
            ),
            // 구분선
            Container(height: 1.h, color: AppColors.G_02),
            // 기본 이미지
            _DialogItem(
              label: '기본 이미지',
              onTap: () =>
                  Navigator.of(context).pop(ProfileImageAction.useDefault),
              isBottom: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogItem extends StatelessWidget {
  final String label; // 표시할 텍스트
  final VoidCallback onTap; // 클릭 시 동작
  final bool isTop; // 상단 버튼 여부 (모서리 둥글게)
  final bool isBottom; // 하단 버튼 여부 (모서리 둥글게)

  const _DialogItem({
    required this.label,
    required this.onTap,
    this.isTop = false,
    this.isBottom = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        // 둥근 모서리 클릭 영역
        borderRadius: BorderRadius.only(
          topLeft: isTop ? Radius.circular(8.r) : Radius.zero,
          topRight: isTop ? Radius.circular(8.r) : Radius.zero,
          bottomLeft: isBottom ? Radius.circular(8.r) : Radius.zero,
          bottomRight: isBottom ? Radius.circular(8.r) : Radius.zero,
        ),
        onTap: onTap,
        child: Container(
          height: 46.h,
          alignment: Alignment.center,
          child: Text(
            label,
            style: FontStyles.B2_reg_16,
          ),
        ),
      ),
    );
  }
}
