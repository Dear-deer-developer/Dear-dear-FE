import 'package:flutter/material.dart';
import 'package:dear_deer_demo/model/tree_slots.dart';

class TreeSlotHitLayer extends StatelessWidget {
  final double width;
  final double height;
  final double hitSize;
  final void Function(String slotId) onTapSlot;

  const TreeSlotHitLayer({
    super.key,
    required this.width,
    required this.height,
    required this.onTapSlot,
    this.hitSize = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: TreeSlots.all.map((slot) {
        final left = width * slot.ax - hitSize / 2;
        final top = height * slot.ay - hitSize / 2;

        return Positioned(
          left: left,
          top: top,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onTapSlot(slot.slotId),
            child: SizedBox(width: hitSize, height: hitSize),
          ),
        );
      }).toList(),
    );
  }
}
