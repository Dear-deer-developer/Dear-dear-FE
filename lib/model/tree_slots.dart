class TreeSlot {
  /// 슬롯 고유 ID (예: S01 ~ S10)
  final String slotId;

  /// 트리 기준 X 좌표 (0.0 = 왼쪽, 1.0 = 오른쪽)
  final double ax;

  /// 트리 기준 Y 좌표 (0.0 = 위, 1.0 = 아래)
  final double ay;

  /// 렌더링 순서
  /// 값이 클수록 화면 위에 그려진다
  final int zIndex;

  /// 기본 회전 값 (라디안 단위)
  final double defaultRotation;

  const TreeSlot({
    required this.slotId,
    required this.ax,
    required this.ay,
    required this.zIndex,
    this.defaultRotation = 0.0,
  });
}

/// 트리 슬롯 전체 정의 클래스
class TreeSlots {
  // 외부에서 인스턴스 생성 방지
  TreeSlots._();

  /// 전체 슬롯 개수 (항상 10)
  static const int slotCount = 10;

  /// 모든 슬롯 정의 목록
  /// ※ 좌표는 임시값
  static const List<TreeSlot> all = [
    // S01 : 트리 최상단 (TOP 슬롯)
    TreeSlot(slotId: 'S01', ax: 0.50, ay: 0.08, zIndex: 100),

    // 상단 영역
    TreeSlot(slotId: 'S02', ax: 0.38, ay: 0.20, zIndex: 90),
    TreeSlot(slotId: 'S03', ax: 0.62, ay: 0.22, zIndex: 91),

    // 중단 영역
    TreeSlot(slotId: 'S04', ax: 0.30, ay: 0.35, zIndex: 80),
    TreeSlot(slotId: 'S05', ax: 0.50, ay: 0.38, zIndex: 81),
    TreeSlot(slotId: 'S06', ax: 0.70, ay: 0.35, zIndex: 82),

    // 하단 영역
    TreeSlot(slotId: 'S07', ax: 0.35, ay: 0.55, zIndex: 70),
    TreeSlot(slotId: 'S08', ax: 0.60, ay: 0.55, zIndex: 71),

    // 최하단 영역
    TreeSlot(slotId: 'S09', ax: 0.42, ay: 0.72, zIndex: 60),
    TreeSlot(slotId: 'S10', ax: 0.58, ay: 0.74, zIndex: 61),
  ];

  /// slotId로 슬롯 하나를 조회
  /// 잘못된 slotId가 들어오면 에러 발생
  static TreeSlot byId(String slotId) {
    return all.firstWhere((s) => s.slotId == slotId);
  }

  /// slotId 유효성 검사 (S01 ~ S10)
  static bool isValidSlotId(String slotId) {
    return all.any((s) => s.slotId == slotId);
  }
}
