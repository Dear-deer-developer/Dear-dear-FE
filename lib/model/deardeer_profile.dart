class DeardeerProfile {
  final int userId;
  final int imageIdx;

  const DeardeerProfile({
    required this.userId,
    required this.imageIdx,
  });

  factory DeardeerProfile.fromJson(Map<String, dynamic> data) {
    return DeardeerProfile(
      userId: data['userId'] as int,
      imageIdx: data['imageIdx'] as int,
    );
  }
}
