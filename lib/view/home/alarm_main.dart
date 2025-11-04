import 'package:dear_deer_demo/controller/home/alarm_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/main.dart';
import 'package:dear_deer_demo/util/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AlarmMain extends GetView<AlarmController> {
  const AlarmMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _head(),
            // ▼ 선택 화면 ↔ 확인(요약) 화면 토글 (기존 레이아웃을 섹션으로 분리) // ✅
            Expanded(
              child: Obx(() => controller.isConfirmed.value
                  ? _confirmedSection() // 확인 화면(요약)
                  : _selectSection()), // 기존 선택 화면
            ),
          ],
        ),
      ),
    );
  }

  // MARK: -선택 화면
  Widget _selectSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            // left/right 는 가로 기준이므로 .w 사용 (기존 코드의 .h를 .w로 수정) // ✅
            padding: EdgeInsets.only(
                top: 12.h, left: 24.w, right: 24.w, bottom: 12.h),
            child:
                Text('이브와 크리스마스 중, 언제 알람을 드릴까요?', style: FontStyles.B3_bold_15),
          ),
          // MARK: - eve, xmas check (기존 그대로 유지)
          Padding(
            padding: EdgeInsets.only(left: 24.w, right: 24.w),
            child: _dayRow(),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.only(left: 24.w, right: 24.w),
            child: Obx(() => controller.selectedDay.value == null
                ? const SizedBox.shrink()
                : Column(
                    children: [
                      _timePickerCard(),
                      SizedBox(height: 12.h),
                      _soundRow(),
                    ],
                  )),
          ),
          SizedBox(height: 24.h),
          Padding(
            padding: EdgeInsets.only(left: 24.w, right: 24.w),
            child:
                _confirmButton(), // onTap 은 아래에서 confirmAndSchedule 로 변경 // ✅
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  //  MARK: - 확인 화면
  Widget _confirmedSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          SizedBox(height: 12.h),

          // 요약 카드 (Figma 기준)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.G_02),
            ),
            child: Stack(
              children: [
                // 휴지통(삭제)
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: controller.deleteAlarm, // 예약 취소 + 상태 초기화 // ✅
                    child: Container(
                      width: 28.w,
                      height: 28.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 6)
                        ],
                      ),
                      child: Icon(Icons.delete_outline,
                          size: 18.w, color: AppColors.G_05),
                    ),
                  ),
                ),

                // 내용
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 4.h),
                    // 날짜에 맞는 이미지(eve/xmas)
                    Obx(() => Image.asset(controller.selectedImage,
                        width: 96.w, height: 96.w)),
                    SizedBox(height: 8.h),

                    // ex) "12월 24일 오전12:00"
                    Obx(() => Text(
                          '${controller.dayLabel} ${controller.ampmLabel}${controller.timeLabel}',
                          style: FontStyles.B2_reg_16,
                          textAlign: TextAlign.center,
                        )),
                    SizedBox(height: 4.h),

                    // ex) "수요일"
                    Obx(() => Text(
                          controller.weekdayLabel,
                          style: FontStyles.S1_reg_13,
                          textAlign: TextAlign.center,
                        )),
                    SizedBox(height: 8.h),

                    // ex) "크리스마스 이브의 오전 12:00에 알람이 울려요."
                    Obx(() => Text(
                          '${controller.dayDesc}의 ${controller.ampmLabel} ${controller.timeLabel}에 알람이 울려요.',
                          style: FontStyles.S1_reg_13.copyWith(
                              color: AppColors.G_05),
                          textAlign: TextAlign.center,
                        )),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(),

          // 수정하기 버튼
          GestureDetector(
            onTap: controller.edit, // 편집 화면으로 복귀 // ✅
            child: Container(
              width: double.infinity,
              height: 52.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.mainGreen,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text('수정하기',
                  style:
                      FontStyles.Button_bold_17.copyWith(color: Colors.white)),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _head() {
    return Padding(
      padding: EdgeInsets.only(left: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Image.asset(ImagePath.backIcon, width: 48.w, height: 48.h),
          ),
          Expanded(
            child:
                Center(child: Text('크리스마스 알람', style: FontStyles.H2_bold_17)),
          ),
          SizedBox(width: 48.w), // 좌우 밸런스
        ],
      ),
    );
  }

  Widget _dayRow() {
    return Obx(() => Row(
          children: [
            _DayCard(
              selected: controller.selectedDay.value == AlarmDay.eve,
              onTap: () => controller.selectDay(AlarmDay.eve),
              imagePath: ImagePath.alarmEve,
              title: '12월 24일',
              subtitle: '수요일 | 크리스마스 이브',
            ),
            SizedBox(width: 12.w),
            _DayCard(
              selected: controller.selectedDay.value == AlarmDay.xmas,
              onTap: () => controller.selectDay(AlarmDay.xmas),
              imagePath: ImagePath.alarmXmas,
              title: '12월 25일',
              subtitle: '목요일 | 크리스마스',
            ),
          ],
        ));
  }

  Widget _timePickerCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.G_02),
      ),
      child: Obx(() {
        final amIndex = controller.isAm.value ? 0 : 1;
        final hourIndex = (controller.hour.value - 1) % 12; // 1~12 -> 0~11
        final minuteIndex = controller.minute.value; // 0~59

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 오전/오후
            _pickerColumn(
              width: 84.w,
              items: const ['오전', '오후'],
              initialIndex: amIndex,
              textStyle: FontStyles.H1_bold_22,
              onSelected: (i) => controller.isAm.value = (i == 0),
              looping: false,
            ),
            // 시 (01~12)
            _pickerColumn(
              width: 84.w,
              items:
                  List.generate(12, (i) => (i + 1).toString().padLeft(2, '0')),
              initialIndex: hourIndex,
              textStyle: FontStyles.H1_bold_22,
              onSelected: (i) => controller.hour.value = (i % 12) + 1,
            ),
            // 분 (00~59)
            _pickerColumn(
              width: 84.w,
              items: List.generate(60, (i) => i.toString().padLeft(2, '0')),
              initialIndex: minuteIndex,
              textStyle: FontStyles.H1_bold_22,
              onSelected: (i) => controller.minute.value = i % 60,
            ),
          ],
        );
      }),
    );
  }

  // MARK: - 공통 피커 컬럼
  Widget _pickerColumn({
    required List<String> items,
    required int initialIndex,
    required ValueChanged<int> onSelected,
    required TextStyle textStyle,
    double? width,
    bool looping = true,
  }) {
    return SizedBox(
      width: width ?? 84.w,
      height: 136.h, // 피커 높이
      child: CupertinoPicker(
        scrollController:
            FixedExtentScrollController(initialItem: initialIndex),
        itemExtent: 36.h, // 각 행 높이
        useMagnifier: false, // 돋보기 효과 OFF (Figma 느낌)
        magnification: 1.0,
        squeeze: 1.1,
        looping: looping,
        onSelectedItemChanged: onSelected,
        backgroundColor: Colors.white,
        selectionOverlay: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.mainGreen, width: 2),
              bottom: BorderSide(color: AppColors.mainGreen, width: 2),
            ),
          ),
        ),
        // 중앙 텍스트 스타일(주변 항목은 자동으로 흐려보임)
        children:
            items.map((t) => Center(child: Text(t, style: textStyle))).toList(),
      ),
    );
  }

  // MARK: - 사운드박스
  Widget _soundRow() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _openSoundSheet,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.G_02),
        ),
        child: Row(
          children: [
            Text('사운드', style: FontStyles.B3_bold_15),
            const Spacer(),
            Obx(() => Text(controller.soundLabel, style: FontStyles.S1_reg_13)),
            SizedBox(width: 6.w),
            Image.asset(ImagePath.greyArrow, width: 5.w, height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _confirmButton() {
    return Obx(() {
      final enabled = controller.canConfirm;
      return GestureDetector(
        onTap: enabled
            ? () async {
                // 예약 + 요약 화면 전환
                final ok = await controller.confirmAndSchedule();
                if (ok) {
                  final when = controller.nextOccurrence;
                  final label =
                      '${controller.dayDesc} ${controller.ampmLabel} ${controller.timeLabel}';
                  final music =
                      controller.selectedTrack.value?.title ?? '(no music)';
                  logger.i(
                      '[ALARM] 예약 성공 • when=${when?.toIso8601String()} • label=$label • music=$music');
                } else {
                  logger.w('[ALARM] 예약 실패');
                }
              }
            : null,
        child: Container(
          width: double.infinity,
          height: 52.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: enabled ? AppColors.mainGreen : AppColors.G_01,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            '확인하기',
            style: FontStyles.Button_bold_17.copyWith(
              color: enabled ? Colors.white : AppColors.G_02,
            ),
          ),
        ),
      );
    });
  }

  // MARK: - 음악 선택 바텀시트 (Figma 기준, '없음' 항목 제거)
  void _openSoundSheet() {
    final c = controller; // 컨트롤러 단축 참조

    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // 둥근 모서리 살리기
      builder: (context) {
        return SafeArea(
          top: false,
          child: Container(
            height: 0.85.sh, // 바텀시트 높이(화면의 85%)
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Column(
              children: [
                // ---------- 헤더 ----------
                Padding(
                  padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 8.h),
                  child: Row(
                    children: [
                      // 뒤로가기
                      GestureDetector(
                        onTap: Get.back,
                        child: Image.asset(
                          ImagePath.backIcon,
                          width: 48.w,
                          height: 48.h,
                        ),
                      ),
                      // 중앙 타이틀
                      Expanded(
                        child: Center(
                          child: Text('알람 선택', style: FontStyles.H2_bold_17),
                        ),
                      ),
                      // 우측 공간(좌우 밸런스)
                      SizedBox(width: 48.w),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),

                // ---------- 리스트 ----------
                Expanded(
                  child: Obx(() {
                    final list = c.tracks; // AlarmController의 곡 목록 (6개)

                    return ListView.separated(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      itemCount: list.length, // 곡 개수
                      separatorBuilder: (_, __) => SizedBox(height: 8.h),
                      itemBuilder: (context, index) {
                        final track = list[index];
                        final selected =
                            c.selectedTrack.value?.audio == track.audio;

                        // ---------- 단일 아이템(곡 한 줄) ----------
                        return ListTile(
                          // Figma에서 카드 테두리가 거의 안 보이면 shape를 제거해도 됨.
                          // shape를 남겨둬도 되고(선택 시만 강조), 배경색만 표시해도 OK.
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            side: BorderSide(
                              color: selected
                                  ? AppColors.mainGreen
                                  : AppColors.G_02,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 8.h),

                          // 앨범 커버
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6.r),
                            child: Image.asset(
                              track.coverAssetPath,
                              width: 40.w,
                              height: 40.w,
                              fit: BoxFit.cover,
                            ),
                          ),

                          // 제목 / 아티스트
                          title: Text(
                            track.title,
                            style: FontStyles.B4_bold_14,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            track.artist,
                            style: FontStyles.S1_reg_13,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // 선택 표시(체크)
                          trailing: selected
                              ? Icon(Icons.check, color: AppColors.mainGreen)
                              : null,

                          // 탭 → 선택값 반영 후 닫기
                          onTap: () {
                            c.setSound(track);
                            Get.back();
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

//  기존 프라이빗 위젯들 유지

// MARK: - widget
class _DayCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final String imagePath;
  final String title;
  final String subtitle;

  const _DayCard({
    required this.selected,
    required this.onTap,
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 156.h,
          width: 148.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: selected ? AppColors.mainRed : AppColors.G_02,
              width: selected ? 3 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),
              Image.asset(imagePath, width: 80.w, height: 80.h),
              Text(title, style: FontStyles.B4_bold_14),
              SizedBox(height: 2.h),
              Text(subtitle, style: FontStyles.S3_reg_10)
            ],
          ),
        ),
      ),
    );
  }
}

class _AmPmPill extends StatelessWidget {
  final bool isAm;
  final VoidCallback onTap;

  const _AmPmPill({required this.isAm, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: AppColors.G_02),
          color: Colors.white,
        ),
        child: Text(isAm ? '오전' : '오후', style: FontStyles.H1_bold_22),
      ),
    );
  }
}

class _Spinner extends StatelessWidget {
  final String label; // '시' / '분'
  final String valueText;
  final VoidCallback onInc;
  final VoidCallback onDec;

  const _Spinner({
    required this.label,
    required this.valueText,
    required this.onInc,
    required this.onDec,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96.w,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.G_02),
        color: Colors.white,
      ),
      child: Column(
        children: [
          // ▼▼▼ 변경: 이미지 → 기본 아이콘 사용
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_up),
            iconSize: 20.w,
            onPressed: onInc,
            splashRadius: 18.w,
          ),
          Text(valueText, style: FontStyles.L1_reg_20),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down),
            iconSize: 20.w,
            onPressed: onDec,
            splashRadius: 18.w,
          ),
          // ▲▲▲
        ],
      ),
    );
  }
}
