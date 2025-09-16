import 'package:dear_deer_demo/data/image_data.dart';
import 'package:dear_deer_demo/model/music.dart';
import 'package:get/get.dart';
import 'package:dear_deer_demo/main.dart';

class BgMusicController extends GetxController {
  // 기본 인덱스 값 -> 0
  final RxInt selectedIndex = 0.obs;
  // 현재 재생 여부
  final RxBool isPlaying = false.obs;

  bool isSelected(int index) => selectedIndex.value == index;

  void select(int index) {
    selectedIndex.value = index;
    sharedPreferences.setInt(SharedPreferencesKeys.bgMusicSelectedIndex, index);
  }

  void togglePlay(int index) {
    if (selectedIndex.value == index) {
      // 이미 선택된 곡이면 -> 재생/정지
      isPlaying.toggle();
    } else {
      // 다른 곡을 누르면 -> 선택 곡 변경 & 무조건 재생 시작
      selectedIndex.value = index;
      isPlaying.value = true;
    }
  }

  @override
  void onInit() {
    super.onInit();
    // 저장값 복원 (없으면 0 유지)
    final saved =
        sharedPreferences.getInt(SharedPreferencesKeys.bgMusicSelectedIndex);
    if (saved != null) {
      selectedIndex.value = saved;
    } else {
      selectedIndex.value = 0;
    }
  }

  // MARK: - Track List // 백엔드 연동 시 여기만 변경
  final RxList<MusicTrack> tracks = <MusicTrack>[
    MusicTrack(
      title: 'O Christmas Tree (Instrumental)',
      artist: 'Jingle Punks',
      coverAssetPath: ImagePath.cover_image_1,
    ),
    MusicTrack(
      title: 'Jingle Bells (Instrumental)',
      artist: 'Jingle Punks',
      coverAssetPath: ImagePath.cover_image_2,
    ),
    MusicTrack(
      title: 'Deck the Halls (Instrumental)',
      artist: 'Jingle Punks',
      coverAssetPath: ImagePath.cover_image_3,
    ),
    MusicTrack(
      title: 'Silent Night  (Instrumental Jazz)',
      artist: 'E\'s Jammy Jams',
      coverAssetPath: ImagePath.cover_image_4,
    ),
    MusicTrack(
      title: 'We Wish You a Merry Christmas (Instrumental Jazz)',
      artist: 'E\'s Jammy Jams',
      coverAssetPath: ImagePath.cover_image_5,
    ),
    MusicTrack(
      title: 'Christmas Village',
      artist: 'Aaron Kenny',
      coverAssetPath: ImagePath.cover_image_6,
    ),
  ].obs;
}
