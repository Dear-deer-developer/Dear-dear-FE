// import 'package:dear_deer_demo/controller/bottom_nav_controller.dart';
// import 'package:dear_deer_demo/view/calendar.dart';
// import 'package:dear_deer_demo/view/contents.dart';
// import 'package:dear_deer_demo/view/home.dart';
// import 'package:dear_deer_demo/view/post.dart';
// import 'package:dear_deer_demo/widget/bottom_nav.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class MainView extends GetView<BottomNavController> {
//   const MainView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Obx(
//       () => PopScope(
//         // 뒤로가기
//         canPop: true,
//         onPopInvoked: (didPop) {
//           controller.popAction();
//         },
//         child: Scaffold(
//           resizeToAvoidBottomInset: false, // 키보드 픽셀 over 방지
//           body: SafeArea(child: _body()),
//           bottomNavigationBar: const BottomNav(),
//         ),
//       ),
//     );
//   }

//   Widget _body() {
//     return IndexedStack(
//       index: controller.index,
//       children: [
//         const Home(), // 0
//         PostMain(), // 1
//         const CalendarMain(), // 2
//         const ContentsMain(), // 3
//       ],
//     );
//   }
// }
