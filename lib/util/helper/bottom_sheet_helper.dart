import 'package:flutter/material.dart';

/// 떠있는 BottomNavigationBar(플로팅 네비)를 가리지 않기 위해
/// 하단 여백을 자동으로 계산해주는 공통 헬퍼
const double kFloatingNavHeight = 60; // 네비게이션 바 실제 높이에 맞춰 조정
const double kNavGap = 8; // 시트와 네비 사이 여백

Future<T?> showSheetAboveNav<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool useRootNavigator = true,
  ShapeBorder shape = const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  ),
  Color? backgroundColor = Colors.transparent,
}) {
  final safeBottom = MediaQuery.of(context).padding.bottom;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useRootNavigator: useRootNavigator,
    backgroundColor: backgroundColor,
    shape: shape,
    builder: (_) => Container(
      margin: EdgeInsets.only(
        bottom: kFloatingNavHeight + safeBottom + kNavGap,
      ),
      child: builder(_),
    ),
  );
}
