import 'package:get/get.dart';
import 'package:dear_deer_demo/model/music.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/service/api_service.dart';

enum AlarmDay { eve, xmas }

class AlarmController extends GetxController {
  // ---------------- 상태 ----------------
  final Rxn<AlarmDay> selectedDay = Rxn<AlarmDay>(); // 날짜(12/24, 12/25)
  final RxBool isAm = true.obs; // 오전(true)/오후(false)
  final RxInt hour = 12.obs; // 1~12
  final RxInt minute = 0.obs; // 0~59

  // 사운드(표시/선택)
  final RxList<MusicTrack> tracks = <MusicTrack>[
    MusicTrack(
      title: 'O Christmas Tree (Instrumental)',
      artist: 'Jingle Punks',
      coverAssetPath: ImagePath.cover_image_1,
      audio: 'assets/audio/O Christmas Tree (Instrumental) - Jingle Punks.mp3',
    ),
    MusicTrack(
      title: 'Jingle Bells (Instrumental)',
      artist: 'Jingle Punks',
      coverAssetPath: ImagePath.cover_image_2,
      audio: 'assets/audio/Jingle Bells (Instrumental) - Jingle Punks.mp3',
    ),
    MusicTrack(
      title: 'Deck the Halls (Instrumental)',
      artist: 'Jingle Punks',
      coverAssetPath: ImagePath.cover_image_3,
      audio: 'assets/audio/Deck the Halls (Instrumental) - Jingle Punks.mp3',
    ),
    MusicTrack(
      title: 'Silent Night  (Instrumental Jazz)',
      artist: "E's Jammy Jams",
      coverAssetPath: ImagePath.cover_image_4,
      audio:
          "assets/audio/Silent Night  (Instrumental Jazz) - E's Jammy Jams.mp3",
    ),
    MusicTrack(
      title: 'We Wish You a Merry Christmas (Instrumental Jazz)',
      artist: "E's Jammy Jams",
      coverAssetPath: ImagePath.cover_image_5,
      audio:
          "assets/audio/We Wish You a Merry Christmas (Instrumental Jazz) - E's Jammy Jams.mp3",
    ),
    MusicTrack(
      title: 'Christmas Village',
      artist: 'Aaron Kenny',
      coverAssetPath: ImagePath.cover_image_6,
      audio: 'assets/audio/Christmas Village - Aaron Kenny.mp3',
    ),
  ].obs;

  final Rx<MusicTrack?> selectedTrack = Rx<MusicTrack?>(null);

  // 확인 화면 토글
  final RxBool isConfirmed = false.obs;

  // API
  final ApiService _api = Get.find<ApiService>();

  // 서버에 내가 만든 알람 존재 여부 (POST 성공 시 true, DELETE 시 false)
  bool _hasServerAlarm = false;

  // 서버 상태 확인 중(뷰에서 로딩 보여줄 때 사용)
  final RxBool isChecking = false.obs;

  // ---------------- 매핑: 제목 -> 서버 musicId ----------------
  // 서버 seed와 일치하도록 실제 id로 교체하세요.
  // (혹은 아래 loadMusicIds()로 /musics 조회해서 자동 채움)
  final Map<String, int> _musicIdMap = {
    'O Christmas Tree (Instrumental)': 1,
    'Jingle Bells (Instrumental)': 2,
    'Deck the Halls (Instrumental)': 3,
    'Silent Night  (Instrumental Jazz)': 4,
    'We Wish You a Merry Christmas (Instrumental Jazz)': 5,
    'Christmas Village': 6,
  };

  int? get selectedMusicId => selectedTrack.value == null
      ? null
      : _musicIdMap[selectedTrack.value!.title];

  // 필요시 /musics로 동기화 (제목 매칭)
  Future<void> loadMusicIds() async {
    try {
      final resp = await _api.get('/musics'); // Response<dynamic>
      final body = resp.body; // 실제 JSON
      if (body is List) {
        for (final m in body) {
          if (m is Map) {
            final title = (m['title'] ?? '').toString();
            final id = m['id'] as int?;
            if (title.isNotEmpty && id != null) {
              _musicIdMap[title] = id;
            }
          }
        }
      }
    } catch (_) {/* 네트워크 실패 시 로컬 매핑 사용 */}
  }

  // 탭 진입 시 서버 알람 동기화
  @override
  void onReady() {
    super.onReady();
    _syncFromServer(); // 진입 시 1회 확인
  }

  // 서버의 내 알람을 조회하여 화면 상태를 초기화
  Future<void> _syncFromServer() async {
    isChecking.value = true;
    try {
      await loadMusicIds().catchError((_) {});

      // swagger: GET /alarms/me (있으면 200, 없으면 404)
      final resp = await _api.get('/alarms/me'); // Response<dynamic>
      final body = resp.body; // 실제 JSON

      if (resp.isOk && body is Map && body['scheduledAt'] != null) {
        final scheduled =
            DateTime.parse(body['scheduledAt'] as String).toLocal();

        // 날짜(12/24 or 12/25)
        if (scheduled.month == 12 && scheduled.day == 25) {
          selectedDay.value = AlarmDay.xmas;
        } else {
          selectedDay.value = AlarmDay.eve;
        }

        // 시간(24h → 12h, AM/PM)
        final h24 = scheduled.hour;
        isAm.value = h24 < 12;
        hour.value = (h24 % 12 == 0) ? 12 : (h24 % 12);
        minute.value = scheduled.minute;

        // 음악 선택(서버 musicId → 로컬 트랙)
        final int? musicId = (body['musicId'] is int)
            ? body['musicId'] as int
            : (body['music'] is Map ? (body['music']['id'] as int?) : null);

        if (musicId != null) {
          final title = _titleFromId(musicId);
          final track = _findTrackByTitle(title);
          if (track != null) selectedTrack.value = track;
        }

        _hasServerAlarm = true;
        isConfirmed.value = true; // 요약 화면
      } else {
        // 404 등: 알람 없음
        _hasServerAlarm = false;
        isConfirmed.value = false;
      }
    } catch (e) {
      _hasServerAlarm = false;
      isConfirmed.value = false;
    } finally {
      isChecking.value = false;
    }
  }

  // id → title 변환(로컬 매핑 역방향)
  String? _titleFromId(int id) {
    try {
      return _musicIdMap.entries.firstWhere((e) => e.value == id).key;
    } catch (_) {
      return null;
    }
  }

  // title로 트랙 찾기
  MusicTrack? _findTrackByTitle(String? title) {
    if (title == null) return null;
    for (final t in tracks) {
      if (t.title == title) return t;
    }
    return null;
  }

  // ---------------- 파생 값 ----------------
  String get soundLabel => selectedTrack.value?.title ?? '없음';
  // 버튼 활성: 날짜 + 음악 선택이 모두 있어야 함(스웨거에서 musicId 필수이므로)
  bool get canConfirm => selectedDay.value != null && selectedMusicId != null;

  String get ampmLabel => isAm.value ? '오전' : '오후';
  String get timeLabel =>
      '${hour.value.toString().padLeft(2, '0')}:${minute.value.toString().padLeft(2, '0')}';

  String get dayDesc => switch (selectedDay.value) {
        AlarmDay.eve => '크리스마스 이브',
        AlarmDay.xmas => '크리스마스',
        _ => '',
      };

  String get selectedImage => selectedDay.value == AlarmDay.xmas
      ? ImagePath.alarmXmas
      : ImagePath.alarmEve;

  /// 지금 시각 기준 "가장 가까운" 12/24 또는 12/25의 알람 시각(로컬)
  DateTime? get nextOccurrence {
    final d = selectedDay.value;
    if (d == null) return null;

    final now = DateTime.now();
    final day = (d == AlarmDay.eve) ? 24 : 25;

    // 12 -> 0 보정 후 24시간 변환
    final h12 = hour.value % 12;
    final h24 = isAm.value ? h12 : h12 + 12;

    var dt = DateTime(now.year, 12, day, h24, minute.value);
    if (dt.isBefore(now)) {
      dt = DateTime(now.year + 1, 12, day, h24, minute.value);
    }
    return dt;
  }

  // 요약 라벨(뷰에서 사용)
  String get dayLabel => nextOccurrence == null
      ? ''
      : '${nextOccurrence!.month}월 ${nextOccurrence!.day}일';

  String get weekdayLabel {
    if (nextOccurrence == null) return '';
    const w = ['월', '화', '수', '목', '금', '토', '일'];
    return '${w[nextOccurrence!.weekday - 1]}요일';
  }

  // ---------------- 액션 ----------------
  void selectDay(AlarmDay day) => selectedDay.value = day;
  void setAm(bool am) => isAm.value = am;
  void setHourIndex(int index) => hour.value = (index % 12) + 1; // 0~11 → 1~12
  void setMinuteIndex(int index) => minute.value = index % 60; // 0~59
  void setSound(MusicTrack? track) => selectedTrack.value = track;

  /// 확인하기: 서버에 스케줄 등록 + 요약 화면 전환 (FCM은 서버에서 발송)
  Future<bool> confirmAndSchedule() async {
    final when = nextOccurrence;
    final musicId = selectedMusicId;
    if (when == null || musicId == null) return false;

    // 기존 예약이 있으면 삭제 후 재등록(단순화된 정책)
    if (_hasServerAlarm) {
      await _api.delete('/alarms/me').catchError((_) {});
    }

    // 서버에 보낼 페이로드 (스웨거 규격: scheduledAt, musicId)
    final payload = {
      'scheduledAt': when.toUtc().toIso8601String(), // 서버가 이 시각에 맞춰 FCM 발송
      'musicId': musicId,
    };

    try {
      await _api.post('/alarms', payload);
      _hasServerAlarm = true;
      isConfirmed.value = true; // UI를 요약 화면으로 전환
      return true; // 성공
    } catch (e) {
      // 실패 시 여기서는 false만 반환하고, 뷰(onTap)에서 logger로 표시
      // Get.snackbar('알람 예약 실패', '네트워크 문제로 예약을 저장하지 못했어요.');
      return false;
    }
  }

  /// 수정하기: 다시 편집 화면으로
  void edit() => isConfirmed.value = false;

  /// 삭제(휴지통): 서버 알람 삭제 + 상태 초기화
  Future<void> deleteAlarm() async {
    try {
      await _api.delete('/alarms/me'); // 서버 규격에 맞게 수정
    } finally {
      _hasServerAlarm = false;
      isConfirmed.value = false;
      selectedDay.value = null;
      isAm.value = true;
      hour.value = 12;
      minute.value = 0;
      selectedTrack.value = null;
    }
  }
}
