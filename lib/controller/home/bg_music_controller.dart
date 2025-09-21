import 'package:audio_session/audio_session.dart';
import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/model/music.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:dear_deer_demo/main.dart';
import 'package:just_audio/just_audio.dart';

class BgMusicController extends GetxController with WidgetsBindingObserver {
  // 기본 인덱스 값 -> 0
  final RxInt selectedIndex = 0.obs;
  // 현재 재생 여부
  final RxBool isPlaying = false.obs;
  // Audio Player
  final AudioPlayer player = AudioPlayer();

  bool isSelected(int index) => selectedIndex.value == index;

  bool _wasPlayingBeforePause = false; // 백그라운드로 갈 때 재생 중이었는지 기억

  // -------------------- 내부 유틸 --------------------
  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  Future<void> _loadAndPlay(int index) async {
    if (index < 0 || index >= tracks.length) return;
    final t = tracks[index];

    final src = AudioSource.asset(t.audio);

    await player.setAudioSource(src, preload: true);
    await player.setLoopMode(LoopMode.one); // 한 곡만 반복
    await player.play();
    isPlaying.value = true;
  }

  // -------------------- 외부에서 쓰는 액션 --------------------
  /// 단순 선택(재생 없이)만 필요할 때
  void select(int index) {
    selectedIndex.value = index;
    sharedPreferences.setInt(SharedPreferencesKeys.bgMusicSelectedIndex, index);
  }

  /// 탭 동작: 같은 곡이면 토글, 다른 곡이면 전환+재생
  Future<void> togglePlay(int index) async {
    if (selectedIndex.value == index) {
      // 같은 곡 → 토글
      if (isPlaying.value) {
        await player.pause();
        isPlaying.value = false;
      } else {
        await player.play();
        isPlaying.value = true;
      }
    } else {
      // 다른 곡 → 선택 저장 + 로드&재생
      selectedIndex.value = index;
      sharedPreferences.setInt(
          SharedPreferencesKeys.bgMusicSelectedIndex, index);
      await _loadAndPlay(index);
    }
  }

  Future<void> playNext() async {
    if (tracks.isEmpty) return;

    final nextIndex = (selectedIndex.value + 1) % tracks.length;
    selectedIndex.value = nextIndex;

    // 선택값 저장
    sharedPreferences.setInt(
      SharedPreferencesKeys.bgMusicSelectedIndex,
      nextIndex,
    );

    // 로드 & 재생
    await _loadAndPlay(nextIndex);
  }

  // MARK: onInit
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _configureAudioSession();

    // 저장값 복원 (없으면 0 유지)
    final saved =
        sharedPreferences.getInt(SharedPreferencesKeys.bgMusicSelectedIndex);
    selectedIndex.value = saved ?? 0;

    // 현재 선택된 곡 정보
    final currentTrack = tracks[selectedIndex.value];
    logger.d("🎵 BgMusic : index=${selectedIndex.value}, "
        "title=${currentTrack.title}, artist=${currentTrack.artist}");

    // 재생 상태 변경 로그
    player.playingStream.listen((playing) {
      isPlaying.value = playing;
      logger.d(playing
          ? "▶️ 재생 시작: ${tracks[selectedIndex.value].title}"
          : "⏸️ 일시정지: ${tracks[selectedIndex.value].title}");
    });
  }

  @override
  void onReady() async {
    super.onReady();
    // 앱 시작 시 이전 곡 자동 재생
    await _autoplayLastSelected();
  }

  Future<void> _autoplayLastSelected() async {
    try {
      await _loadAndPlay(selectedIndex.value);
      logger.d("🚀 자동 재생 완료: ${tracks[selectedIndex.value].title}");
    } catch (e) {
      logger.e("자동 재생 실패: $e");
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this); // <- 해제
    player.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_wasPlayingBeforePause) {
        player.play(); // 복귀 시 이어재생
      }
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _wasPlayingBeforePause = isPlaying.value;
      player.pause(); // 앱 배경/전환 시 일시정지
    }
  }

  // MARK: - Track List // 백엔드 연동 시 여기만 변경
  final RxList<MusicTrack> tracks = <MusicTrack>[
    MusicTrack(
        title: 'O Christmas Tree (Instrumental)',
        artist: 'Jingle Punks',
        coverAssetPath: ImagePath.cover_image_1,
        audio:
            'assets/audio/O Christmas Tree (Instrumental) - Jingle Punks.mp3'),
    MusicTrack(
        title: 'Jingle Bells (Instrumental)',
        artist: 'Jingle Punks',
        coverAssetPath: ImagePath.cover_image_2,
        audio: 'assets/audio/Jingle Bells (Instrumental) - Jingle Punks.mp3'),
    MusicTrack(
        title: 'Deck the Halls (Instrumental)',
        artist: 'Jingle Punks',
        coverAssetPath: ImagePath.cover_image_3,
        audio: 'assets/audio/Deck the Halls (Instrumental) - Jingle Punks.mp3'),
    MusicTrack(
        title: 'Silent Night  (Instrumental Jazz)',
        artist: 'E\'s Jammy Jams',
        coverAssetPath: ImagePath.cover_image_4,
        audio:
            'assets/audio/Silent Night  (Instrumental Jazz) - E\'s Jammy Jams.mp3'),
    MusicTrack(
        title: 'We Wish You a Merry Christmas (Instrumental Jazz)',
        artist: 'E\'s Jammy Jams',
        coverAssetPath: ImagePath.cover_image_5,
        audio:
            'assets/audio/We Wish You a Merry Christmas (Instrumental Jazz) - E\'s Jammy Jams.mp3'),
    MusicTrack(
        title: 'Christmas Village',
        artist: 'Aaron Kenny',
        coverAssetPath: ImagePath.cover_image_6,
        audio: 'assets/audio/Christmas Village - Aaron Kenny.mp3'),
  ].obs;
}
