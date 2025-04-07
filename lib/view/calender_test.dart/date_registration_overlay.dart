import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DateRegistrationOverlay extends StatelessWidget {
  final DateTime date;

  const DateRegistrationOverlay({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20.w, horizontal: 30.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Display the selected date
            Text(
              'Register on ${date.toLocal().toString().split(' ')[0]}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            // 공백
            SizedBox(height: 20.h),
            // Example input fields for registration
            const TextField(
              decoration: InputDecoration(
                labelText: '일정',
              ),
            ),
            // 공백
            SizedBox(height: 10.h),
            const TextField(
              decoration: InputDecoration(
                labelText: '내용',
              ),
            ),
            // 공백
            SizedBox(height: 20.h),
            // 등록 버튼
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('일정 등록'),
            ),
          ],
        ),
      ),
    );
  }
}
