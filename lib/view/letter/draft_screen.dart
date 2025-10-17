import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/app_color.dart';

/// 임시보관함 화면
/// 사용자는 저장된 임시 편지들을 확인하고, 삭제 모드에서 여러 편지를 선택하여 삭제할 수 있습니다.
class DraftsScreen extends StatefulWidget {
  const DraftsScreen({super.key});

  @override
  State<DraftsScreen> createState() => _DraftsScreenState();
}

class _DraftsScreenState extends State<DraftsScreen> {
  // MARK: - 상태 변수

  /// 임시 저장된 편지 목록 (예시 데이터)
  List<Map<String, String>> drafts = [
    {
      'nickname': '닉네임',
      'preview': '작성하던 편지 내용 한줄. 작성하던 편지 내용 한줄. 작성하던',
      'date': '2025. 11. 28. 23:45',
    },
    {
      'nickname': '닉네임',
      'preview': '작성하던 편지 내용 한줄. 작성하던 편지 내용 한줄. 작성하던',
      'date': '2025. 11. 28. 23:45',
    },
    {
      'nickname': '닉네임',
      'preview': '작성하던 편지 내용 한줄. 작성하던 편지 내용 한줄. 작성하던',
      'date': '2025. 11. 28. 23:45',
    },
  ];

  /// 삭제 모드 활성화 여부
  bool isSelectMode = false;

  /// 삭제 모드에서 선택된 편지들의 인덱스 집합
  Set<int> selectedIndexes = {};

  // MARK: - 빌드 메소드

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopSummary(),
              Expanded(child: _buildDraftList()),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: - 앱바

  /// 화면 상단 앱바를 구성합니다.
  AppBar _buildAppBar() => AppBar(
        backgroundColor: AppColors.bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: Text(
          "임시보관함",
          style: FontStyles.H2_bold_17,
        ),
      );

  // MARK: - 상단 요약 영역

  /// 상단에 현재 편지 개수 또는 선택된 편지 개수를 표시하며,
  /// 삭제 모드 진입/완료 토글 버튼을 제공합니다.
  Widget _buildTopSummary() => Padding(
        padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
        child: Row(
          children: [
            isSelectMode ? _buildSelectedCountText() : _buildTotalCountText(),
            const Spacer(),
            _buildDeleteToggleButton(),
          ],
        ),
      );

  /// 삭제 모드가 아닐 때 보여줄 총 편지 개수 텍스트
  Widget _buildTotalCountText() => Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "총 ",
              style: FontStyles.B3_bold_15.copyWith(color: AppColors.Black),
            ),
            TextSpan(
              text: "${drafts.length}",
              style: FontStyles.B3_bold_15.copyWith(color: AppColors.mainRed),
            ),
            TextSpan(
              text: "개",
              style: FontStyles.B3_bold_15.copyWith(color: AppColors.Black),
            ),
          ],
        ),
      );

  /// 삭제 모드일 때 보여줄 선택된 편지 개수 텍스트
  Widget _buildSelectedCountText() => Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "총 ",
              style: FontStyles.B3_bold_15.copyWith(color: AppColors.Black),
            ),
            TextSpan(
              text: "${selectedIndexes.length}",
              style: FontStyles.B3_bold_15.copyWith(color: AppColors.mainRed),
            ),
            TextSpan(
              text: "개 선택됨",
              style: FontStyles.B3_bold_15.copyWith(color: AppColors.Black),
            ),
          ],
        ),
      );

  /// 삭제 모드 진입/완료 토글 버튼
  Widget _buildDeleteToggleButton() => GestureDetector(
        onTap: () {
          setState(() {
            if (isSelectMode) {
              // 완료: 선택된 편지 삭제
              drafts = drafts
                  .asMap()
                  .entries
                  .where((entry) => !selectedIndexes.contains(entry.key))
                  .map((entry) => entry.value)
                  .toList();
              selectedIndexes.clear();
              isSelectMode = false;
            } else {
              // 삭제 모드 진입
              isSelectMode = true;
            }
          });
        },
        child: Text(
          isSelectMode ? "완료" : "삭제",
          style: FontStyles.S1_reg_13.copyWith(color: AppColors.Black),
        ),
      );

  // MARK: - 임시 편지 리스트

  /// 임시 편지 목록을 리스트뷰로 출력합니다.
  /// 삭제 모드일 때는 각 아이템에 체크박스가 표시됩니다.
  Widget _buildDraftList() {
    return ListView.separated(
      itemCount: drafts.length,
      separatorBuilder: (_, __) => const Divider(
        color: AppColors.G_02,
        height: 1,
        thickness: 1,
      ),
      itemBuilder: (context, index) {
        final draft = drafts[index];
        final isSelected = selectedIndexes.contains(index);
        return _buildDraftItem(draft, index, isSelected);
      },
    );
  }

  // MARK: - 임시 편지 아이템

  /// 임시 편지 하나를 표시하는 위젯입니다.
  /// 삭제 모드일 때는 체크박스가 표시되고, 탭하여 선택/해제할 수 있습니다.
  Widget _buildDraftItem(
      Map<String, String> draft, int index, bool isSelected) {
    return InkWell(
      onTap: isSelectMode
          ? () {
              setState(() {
                if (isSelected) {
                  selectedIndexes.remove(index);
                } else {
                  selectedIndexes.add(index);
                }
              });
            }
          : null,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 편지 내용 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dear. ${draft['nickname']}",
                    style:
                        FontStyles.L1_reg_20.copyWith(color: AppColors.Black),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    draft['preview'] ?? '',
                    style: FontStyles.S3_reg_10.copyWith(color: AppColors.G_06),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "마지막 저장 : ${draft['date']}",
                    style: FontStyles.S3_reg_10.copyWith(color: AppColors.G_06),
                  ),
                ],
              ),
            ),
            // 체크박스 영역 (삭제 모드일 때만 표시)
            if (isSelectMode)
              Padding(
                padding: EdgeInsets.only(left: 12.w, top: 2.h),
                child: _buildCircleCheck(isSelected),
              ),
          ],
        ),
      ),
    );
  }

  // MARK: - 원형 체크박스

  /// 체크 여부에 따라 원형 체크박스를 표시합니다.
  Widget _buildCircleCheck(bool checked) {
    return Container(
      width: 24.w,
      height: 24.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.mainRed, // 항상 빨간색 테두리
          width: 1,
        ),
      ),
      child: checked
          ? Center(
              child: Container(
                width: 16.w,
                height: 16.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.mainRed,
                ),
              ),
            )
          : null,
    );
  }
}
