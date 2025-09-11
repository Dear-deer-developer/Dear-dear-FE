// enum
enum GiftCategory {
  ornament,
  star,
  electric,
  bulb,
  interior,
  animal,
}

// server
GiftCategory giftCategoryFromServer(String value) {
  switch (value.toUpperCase()) {
    case 'ORNAMENT':
      return GiftCategory.ornament;
    case 'STAR':
      return GiftCategory.star;
    case 'ELECTRIC':
      return GiftCategory.electric;
    case 'BULB':
      return GiftCategory.bulb;
    case 'INTERIOR':
      return GiftCategory.interior;
    case 'ANIMAL':
      return GiftCategory.animal;
    default:
      throw ArgumentError('Unknown GiftCategory: $value');
  }
}

// enum → 서버 문자열 변환
String giftCategoryToServer(GiftCategory category) {
  return category.name.toUpperCase();
}

class DeardeerGift {
  int id;
  String name;
  String imageUrl;
  GiftCategory category;
  bool isNew;

  DeardeerGift({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.category,
    this.isNew = false,
  });

  /// JSON → 모델
  factory DeardeerGift.fromJson(Map<String, dynamic> json) {
    return DeardeerGift(
      id: json['id'] as int,
      name: (json['name'] ?? '') as String,
      imageUrl: (json['imageUrl'] ?? '') as String,
      category: giftCategoryFromServer(json['category'] as String),
      isNew: (json['isNew'] ?? false) as bool,
    );
  }

  /// 모델 → JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'category': giftCategoryToServer(category),
        'isNew': isNew,
      };
}
