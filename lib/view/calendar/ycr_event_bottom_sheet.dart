import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dear_deer_demo/controller/calender/ycr_calender_controller.dart';

class YcrEventBottomSheet extends StatelessWidget {
  YcrEventBottomSheet({super.key});

  // 선택된 날짜나 이벤트 추가 기능을 쓰기 위해 필요
  // 사용자가 텍스트 필드에 입력한 일정 내용을 저장하고 추적함
  final controller = Get.find<YcrCalenderController>();
  final TextEditingController eventController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // 선택된 날짜를 가져오고, 바텀 시트를 드래그하여 크기를 조절할 수 있도록 구현
    final selectedDate = controller.selectedDate.value;
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _eventName(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: _date(selectedDate),
              ),
              _button(),
            ],
          ),
        );
      },
    );
  }

  // MARK: 일정 정보를 나타내는 텍스트 필드
  Widget _buildBox(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: eventController,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // MARK: 이벤트 이름 입력 필드
  Widget _eventName() => _buildBox("이벤트 이름을 입력하세요.");

  // MARK: 선택된 날짜를 노출
  Widget _date(DateTime date) {
    final formatted = "${date.year}년 ${date.month}월 ${date.day}일";
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        enabled: false,
        controller: TextEditingController(text: formatted),
        decoration: InputDecoration(
          labelText: "선택한 날짜",
          labelStyle: const TextStyle(color: Colors.black),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  // MARK: 추가 버튼
  Widget _button() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            // 입력한 텍스트가 비어있는지 확인 후에 비어있지 않으면 컨트롤러에 일정을 추가한 뒤, 바텀 시트 닫음
            final eventText = eventController.text;
            if (eventText.isNotEmpty) {
              controller.addEvent(controller.selectedDate.value, eventText);
              Get.back();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Text(
            "추가",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
