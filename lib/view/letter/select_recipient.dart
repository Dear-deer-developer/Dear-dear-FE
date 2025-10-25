import 'package:dear_deer_demo/controller/post/select_recipient_controller.dart';
import 'package:dear_deer_demo/data/app_color.dart';
import 'package:dear_deer_demo/data/font_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class SelectRecipient extends StatefulWidget {
  const SelectRecipient({super.key});

  @override
  State<SelectRecipient> createState() => _SelectRecipientState();
}

class _SelectRecipientState extends State<SelectRecipient> {
  // MARK: - 컨트롤러
  final controller = Get.put(SelectRecipientController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // MARK: - AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              final friend = controller.getSelectedFriend();
              if (friend != null) {
                Get.back(result: friend); // 👈 선택된 친구 전체 Map 전달
              } else {
                Get.back(); // 선택 없으면 그냥 닫기
              }
            },
            child: Text(
              '확인',
              style: FontStyles.S1_reg_13.copyWith(color: Colors.black),
            ),
          ),
        ],
      ),
      // MARK: - Body
      body: Column(
        children: [
          _topTabs(), // 상단 탭
          _searchBar(), // 검색 바
          Expanded(child: _content()),
        ],
      ),
    );
  }

  Widget _topTabs() {
    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 8),
      child: Obx(() => Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _tabItem('사서함 번호', 0),
                  const SizedBox(width: 16),
                  _tabItem('링크로 보내기', 1),
                ],
              ),
              const SizedBox(height: 8),
              const Divider(
                color: AppColors.G_01,
                thickness: 1,
              ),
            ],
          )),
    );
  }

  // MARK: - 탭 아이템
  Widget _tabItem(String title, int index) {
    final isSelected = controller.selectedTabIdx.value == index;

    return GestureDetector(
      onTap: () => controller.selectedTabIdx.value = index, // 탭 선택 시 상태 변경
      child: Padding(
        padding: const EdgeInsets.only(right: 24.0),
        child: Column(
          children: [
            Text(
              title,
              style: FontStyles.H3_bold_16.copyWith(
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                height: 4,
                width: 100,
                color: Colors.black,
              ),
          ],
        ),
      ),
    );
  }

  // MARK: - 검색 바
  Widget _searchBar() {
    return Obx(() {
      final tabIndex = controller.selectedTabIdx.value;

      // 링크로 보내기 탭이면 검색 바 숨김
      if (tabIndex == 1) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: Colors.white, // 배경 흰색
            border: Border.all(color: AppColors.G_02), // 테두리 색
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Icon(Icons.search, color: Colors.grey),
              ),
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    controller.searchQuery.value = value; // 검색어 상태 갱신
                  },
                  decoration: const InputDecoration(
                    hintText: '사서함 번호 검색',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // MARK: - 컨텐츠 영역 (친구 목록 / 링크 안내)
  Widget _content() {
    return Obx(() {
      final tabIndex = controller.selectedTabIdx.value;

      // 링크로 보내기 탭
      if (tabIndex == 1) {
        return _link();
      }

      final friendsList = controller.filteredFriends;

      // 검색어가 비어 있을 경우 안내 메시지
      if (controller.searchQuery.value.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 16,
                ),
                Text(
                  '검색 결과',
                  style: FontStyles.B4_bold_14.copyWith(color: Colors.black),
                ),
                const SizedBox(height: 30),
                Text(
                  "사서함 번호를 입력해 보세요!",
                  style: FontStyles.B3_reg_15.copyWith(color: AppColors.G_06),
                ),
              ],
            ),
          ),
        );
      }

      // 검색 결과 없음
      if (friendsList.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 16,
                ),
                Text(
                  '검색 결과',
                  style: FontStyles.B4_bold_14.copyWith(color: Colors.black),
                ),
                const SizedBox(height: 30),
                Text(
                  "앗, 해당 사서함 번호를 가진 사용자가 없네요. \n다시 확인해 주세요!",
                  style: FontStyles.B3_reg_15.copyWith(color: AppColors.G_06),
                ),
              ],
            ),
          ),
        );
      }

      // ✅ 여기가 핵심 수정 (UI 동일, 토글만 정상 반응)
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: friendsList.length,
        itemBuilder: (context, index) {
          final friend = friendsList[index];
          final selected = controller.selectedIdx.value;
          final isSelected = selected != null && selected == index;

          return Card(
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide.none,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  // 좌측: 프로필 사진
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFFE0E0E0),
                    child: Icon(Icons.person, color: Colors.white, size: 32),
                  ),

                  const SizedBox(width: 12),
                  // 중간: 이름 / 사서함 번호 / 닉네임
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(friend['name'] ?? '',
                            style: FontStyles.B4_bold_14),
                        Text('사서함 번호 : ${friend['number']}',
                            style: FontStyles.S2_reg_12),
                      ],
                    ),
                  ),
                  // 우측: 선택 토글
                  Radio<int>(
                    value: index,
                    groupValue: controller.selectedIdx.value,
                    activeColor: Colors.red,
                    onChanged: (int? value) {
                      if (controller.selectedIdx.value == value) {
                        controller.selectFriend(null); // 선택 해제
                      } else {
                        controller.selectFriend(value); // 선택
                      }
                      print('현재 선택 인덱스: ${controller.selectedIdx.value}');
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  // MARK: - 링크 안내 UI
  Widget _link() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 300.w,
            decoration: BoxDecoration(
              color: AppColors.G_01,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 12, bottom: 12, left: 14, right: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "수신 정보가 없는 친구에게 보내고 싶을 경우",
                    style: FontStyles.B4_reg_14.copyWith(color: AppColors.G_06),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "1. 링크로 보내기를 선택 후",
                    style: FontStyles.B4_reg_14.copyWith(color: AppColors.G_06),
                  ),
                  Text(
                    "2. 편지 작성하고",
                    style: FontStyles.B4_reg_14.copyWith(color: AppColors.G_06),
                  ),
                  Text(
                    "3. 직접 링크를 전달해주세요~!",
                    style: FontStyles.B4_reg_14.copyWith(color: AppColors.G_06),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            "내용을 모두 확인하신 후,\n우측 상단의 확인을 눌러 주세요!",
            style: FontStyles.B4_reg_14.copyWith(color: AppColors.G_06),
            textAlign: TextAlign.left,
          ),
        ],
      );
}
