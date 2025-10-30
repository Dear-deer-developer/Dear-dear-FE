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
  final controller = Get.put(SelectRecipientController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: Column(
        children: [
          _topTabs(),
          _searchBar(),
          Expanded(child: _content()),
        ],
      ),
    );
  }

  // MARK: - AppBar
  AppBar _appBar() => AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              final selectedIdx = controller.selectedIdx.value;
              if (selectedIdx != null &&
                  selectedIdx >= 0 &&
                  selectedIdx < controller.filteredFriends.length) {
                final friend = controller.filteredFriends[selectedIdx];

                final selectedFriend = {
                  'id': friend['id'],
                  'name': friend['nickname'] ?? friend['name'] ?? '이름 없음',
                  'number': friend['boxNumber']?.toString() ?? '-',
                };

                print('선택된 친구 반환: $selectedFriend');
                Get.back(result: selectedFriend);
              } else {
                Get.snackbar('알림', '받는 사람을 선택해주세요.');
              }
            },
            child: Text(
              '확인',
              style: FontStyles.S1_reg_13.copyWith(color: Colors.black),
            ),
          ),
        ],
      );

  // MARK: - 상단 탭
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
              const Divider(color: AppColors.G_01, thickness: 1),
            ],
          )),
    );
  }

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

  // MARK: - 검색 바
  Widget _searchBar() {
    return Obx(() {
      final tabIndex = controller.selectedTabIdx.value;
      if (tabIndex == 1) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.G_02),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.search, color: Colors.grey),
              ),
              Expanded(
                child: TextField(
                  onChanged: (value) {
                    controller.searchQuery.value = value;
                    controller.searchUserByZipCode(value);
                  },
                  decoration: const InputDecoration(
                    hintText: '사서함 번호 입력',
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

  // MARK: - 친구 목록
  Widget _content() {
    return Obx(() {
      final tabIndex = controller.selectedTabIdx.value;

      if (tabIndex == 1) return _link();
      if (controller.searchQuery.value.isEmpty) {
        return _message("사서함 번호를 입력해 보세요!");
      }

      final friendsList = controller.filteredFriends;

      if (friendsList.isEmpty) {
        return _message("앗, 해당 사서함 번호를 가진 사용자가 없네요.\n다시 확인해 주세요!");
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: friendsList.length,
        itemBuilder: (context, index) {
          final friend = friendsList[index];
          final isSelected = controller.selectedIdx.value == index;

          return GestureDetector(
            onTap: () => controller.selectFriend(index),
            child: Card(
              color: isSelected
                  ? AppColors.mainRed.withOpacity(0.1)
                  : Colors.white,
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? AppColors.mainRed : AppColors.G_02,
                  width: 1,
                ),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFFE0E0E0),
                  child: Icon(Icons.person, color: Colors.white, size: 32),
                ),
                title: Text(
                  friend['nickname'] ?? friend['name'] ?? '',
                  style: FontStyles.B4_bold_14,
                ),
                subtitle: Text(
                  '사서함번호 : ${friend['zipCode'] ?? friend['zipcode'] ?? '-'}',
                  style: FontStyles.S2_reg_12,
                ),
                trailing: Radio<int>(
                  value: index,
                  groupValue: controller.selectedIdx.value,
                  activeColor: AppColors.mainRed,
                  onChanged: (_) => controller.selectFriend(index),
                ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _message(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('검색 결과',
                  style: FontStyles.B4_bold_14.copyWith(color: Colors.black)),
              const SizedBox(height: 30),
              Text(text,
                  style: FontStyles.B3_reg_15.copyWith(color: AppColors.G_06)),
            ],
          ),
        ),
      );

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
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("수신 정보가 없는 친구에게 보내고 싶을 경우",
                      style:
                          FontStyles.B4_reg_14.copyWith(color: AppColors.G_06)),
                  const SizedBox(height: 6),
                  Text("1. 링크로 보내기를 선택 후",
                      style:
                          FontStyles.B4_reg_14.copyWith(color: AppColors.G_06)),
                  Text("2. 편지 작성하고",
                      style:
                          FontStyles.B4_reg_14.copyWith(color: AppColors.G_06)),
                  Text("3. 직접 링크를 전달해 주세요~!",
                      style:
                          FontStyles.B4_reg_14.copyWith(color: AppColors.G_06)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text("내용을 모두 확인하신 후,\n우측 상단의 확인을 눌러 주세요!",
              style: FontStyles.B4_reg_14.copyWith(color: AppColors.G_06)),
        ],
      );
}
