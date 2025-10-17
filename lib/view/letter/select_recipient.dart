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
  final controller =
      Get.put(SelectRecipientController()); // GetX Controller 인스턴스 생성

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          // 상단 확인 버튼.
          TextButton(
            onPressed: () {
              final selectedIdx = controller.selectedIdx.value;
              if (selectedIdx != null) {
                final friend = controller.filteredFriends[selectedIdx];
                final name = friend['name'] ?? '';
                Get.back(result: name);
              } else {
                Get.back();
              }
            },
            child: Text(
              '확인',
              style: FontStyles.S1_reg_13.copyWith(color: Colors.black),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _topTabs(), // 카카오 친구, 사서함 번호, 미가입자 탭.
          _searchBar(), // 검색창.
          _Label(), // 친구 목록 라벨과 검색 기능을 사용할 때는 검색 결과 라벨.
          Expanded(child: _friendList()), // 친구 목록.
        ],
      ),
    );
  }

  // MARK: - 탭 UI 카카오 친구, 사서함 번호, 미가입자들을 확인할 수 있는 탭.
  /// 상단에 선택된 탭에 따라 내용을 필터링하기 위해 각각 번호를 지정하였습니다.
  /// 카카오 친구 : 0, 사서함 번호 : 1, 미가입자 : 2
  Widget _topTabs() {
    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 45, right: 16, bottom: 8),
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _tabItem('카카오 친구', 0),
              _tabItem('사서함 번호', 1),
              _tabItem('미가입자', 2),
              const Spacer(),
            ],
          )),
    );
  }

  //MARK: - 탭 아이템
  /// 탭 아이템을 클릭하면 해당 탭의 인덱스가 controller.selectedTabIdx에 저장됩니다.
  /// 탭 아이템의 텍스트 색상은 선택된 탭은 검정색, 선택되지 않은 탭은 회색으로 구분하였습니다.
  /// 선택된 탭은 아래에 검은색 디바이더로 표시됩니다.

  Widget _tabItem(String title, int index) {
    final isSelected = controller.selectedTabIdx.value == index;

    return GestureDetector(
      onTap: () => controller.selectedTabIdx.value = index,
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

  //MARK: - 목록 라벨
  /// 친구 목록을 표시할 때는 친구 라벨을 보이고, 검색 결과를 표시할 때는 검색 결과 라벨을 보여 줍니다.
  /// 미가입자 탭일 경우에는 라벨을 숨김 처리합니다.
  Widget _Label() {
    return Obx(() {
      final isSearching = controller.searchQuery.value.isNotEmpty;
      final tabIndex = controller.selectedTabIdx.value;

      if (tabIndex == 2) return const SizedBox.shrink();

      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 30, top: 16, bottom: 16),
          child: Text(
            isSearching ? '검색 결과' : '친구',
            style: FontStyles.B4_bold_14,
          ),
        ),
      );
    });
  }

  //MARK: - 검색창
  /// 검색창은 친구 목록을 필터링하기 위해 사용됩니다.
  /// 검색어가 입력되면 controller.searchQuery에 저장되고, 친구 목록이 필터링됩니다.
  /// 미가입자 탭일 경우에는 검색창을 숨김 처리합니다.
  Widget _searchBar() {
    return Obx(() {
      final tabIndex = controller.selectedTabIdx.value;

      if (tabIndex == 2) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F2F2),
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
                    controller.searchQuery.value = value;
                  },
                  decoration: const InputDecoration(
                    hintText: '친구 이름 검색',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  //MARK: - 친구 목록
  /// 친구 목록은 ListView로 구현되어 있으며, 각 친구는 ListTile로 표시됩니다.
  /// 친구를 선택하면 Radio 버튼이 활성화되고, 선택된 친구는 controller.selectedIdx에 저장됩니다.
  /// 친구 목록이 비어있을 경우에는 검색 결과가 없다는 메시지를 표시합니다.
  /// 미가입자 탭일 경우에는 친구 목록이 비워지도록 처리하였습니다.
  Widget _friendList() {
    return Obx(() {
      final selected = controller.selectedIdx.value;
      final tabIndex = controller.selectedTabIdx.value;
      final friendsList = controller.filteredFriends;

      if (tabIndex == 2) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: _notice(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                "내용을 모두 확인하신 후, \n우측 상단의 확인을 눌러 주세요!",
                style: FontStyles.B3_reg_15.copyWith(color: AppColors.G_06),
              ),
            )
          ],
        );
      }

      if (friendsList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('검색 결과가 없어요!',
                  style: FontStyles.B3_reg_15.copyWith(color: AppColors.G_06)),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: _notice(),
              ),
            ],
          ),
        );
      }

      /// 친구 목록이 비어있지 않을 경우 ListView로 친구 목록을 표시합니다.
      return ListView.separated(
        itemCount: friendsList.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: Color(0xFFF2F2F2)),
        itemBuilder: (context, idx) {
          final friend = friendsList[idx];
          final isSelected = selected == idx;

          return ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE0E0E0),
              radius: 24,
              child: Icon(Icons.person, color: Colors.white, size: 32),
            ),
            title: Text(friend['name'] ?? '', style: FontStyles.B4_bold_14),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('사서함 번호 : ${friend['number']}',
                    style: FontStyles.S3_reg_10),
                Text('사용자 닉네임 : ${friend['nickname']}',
                    style: FontStyles.S3_reg_10),
              ],
            ),
            trailing: Radio<int>(
              value: idx,
              groupValue: selected,
              activeColor: Colors.red,
              onChanged: (int? value) {
                if (isSelected) {
                  controller.selectFriend(null); // 선택 해제
                } else {
                  controller.selectFriend(value);
                }
              },
            ),
          );
        },
      );
    });
  }

  //MARK: - 미가입자 안내 메시지
  /// 미가입자 탭과 검색 결과가 없을 때, 보여지는 안내 메세지입니다.
  Widget _notice() => Container(
        width: 300.w,
        height: 120.h,
        decoration: BoxDecoration(
          color: AppColors.G_01,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8, left: 14),
              child: Text("아직 디어 디어에 가입하지 않은 친구는",
                  style: FontStyles.B4_reg_14.copyWith(color: AppColors.G_06)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text("1. 미가입자를 선택 후",
                  style: FontStyles.B4_reg_14.copyWith(color: AppColors.G_06)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text("2. 편지 작성하고",
                  style: FontStyles.B4_reg_14.copyWith(color: AppColors.G_06)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text("3. 직접 링크를 전달해 주세요~!",
                  style: FontStyles.B4_reg_14.copyWith(color: AppColors.G_06)),
            ),
          ],
        ),
      );
}
