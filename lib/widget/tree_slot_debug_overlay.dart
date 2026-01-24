import 'package:flutter/material.dart';
import 'package:dear_deer_demo/model/tree_slots.dart';

class TreeSlotDebugOverlay extends StatelessWidget {
  final double width;
  final double height;
  final double markerSize;
  final String? selectedSlotId;

  const TreeSlotDebugOverlay({
    super.key,
    required this.width,
    required this.height,
    this.markerSize = 26,
    this.selectedSlotId,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: TreeSlots.all.map((slot) {
        final left = width * slot.ax - markerSize / 2;
        final top = height * slot.ay - markerSize / 2;
        final isSelected = selectedSlotId == slot.slotId;

        return Positioned(
          left: left,
          top: top,
          child: IgnorePointer(
            ignoring: true,
            child: Container(
              width: markerSize,
              height: markerSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? Colors.orange.withOpacity(0.85)
                    : Colors.black.withOpacity(0.45),
                border: Border.all(
                    color: Colors.white, width: isSelected ? 2 : 1.2),
              ),
              child: Text(
                slot.slotId.replaceFirst('S', ''), // 01~10
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
