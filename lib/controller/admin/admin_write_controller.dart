import 'package:get/get.dart';
import 'package:flutter/material.dart';

class WriteController extends GetxController {
  /// 여러 개를 선택할 수 있도록 선택된 편지지의 인덱스를 저장하는 리스트입니다.
  RxList<int> selectedIndices = <int>[].obs;

  // MARK: 편지지 목록
  /// 임의로 편지지를 받기 전까지 색상 데이터를 넣어두었습니다.
  final List<Color> letterPapers = [
    Colors.grey,
    Colors.pink,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.yellow,
    Colors.purple,
    Colors.brown,
    Colors.teal,
    Colors.indigo,
    Colors.cyan,
    Colors.lime,
    Colors.redAccent,
    Colors.lightBlue,
    Colors.deepPurple,
    Colors.amber,
    Colors.blueGrey,
    Colors.deepOrange,
  ];

  // MARK: 편지지 선택 토글
  /// 선택된 편지지 인덱스 리스트에 있으면 제거, 없으면 추가하여 선택 및 해제를 표시합니다.
  void toggleSelection(int index) {
    if (selectedIndices.contains(index)) {
      selectedIndices.remove(index); // 선택 해제
    } else {
      selectedIndices.add(index); // 새로 선택
    }
  }
}
