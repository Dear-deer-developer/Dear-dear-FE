class MusicTrack {
  final String title;
  final String artist;
  final String coverAssetPath;
  final String audio; // mp3 경로

  const MusicTrack({
    required this.title,
    required this.artist,
    required this.coverAssetPath,
    required this.audio,
  });
}
