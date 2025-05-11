import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ContentsController extends GetxController {
  final ScrollController scrollController = ScrollController();

  void scrollUp() {
    scrollController.animateTo(0,
        duration: const Duration(milliseconds: 700), curve: Curves.easeIn);
  }
}
