import 'package:intl/intl.dart';

/// 11/01 ~ 12/25 날짜별 지급 테이블
final List<String> _novRewards = [
  'ball_1',
  'icecream',
  'heart',
  'latte',
  'carpet_1',
  'snowman',
  'garland_1',
  'candlelight',
  'wallpaper_1',
  'candy',
  'electric_bulb_1',
  'train',
  'smile_star',
  'bread',
  'santa',
  'snowflake',
  'cake',
  'carousel',
  'cat',
  'bell',
  'macaroon',
  'wallpaper_2',
  'gift_package',
  'pink_star',
  'carpet_2',
  'ball_2',
  'mistletoe',
  'electric_bulb_2',
  'angel',
];

final List<String> _decRewards = [
  'ball_3',
  'cookie',
  'wallpaper_3',
  'socks',
  'candy_gift',
  'snowball',
  'ribbon',
  'garland_2',
  'pine_cone',
  'gloves',
  'dog',
  'two_bells',
  'blue_star',
  'electric_bulb_3',
  'wallpaper_4',
  'sugar_loaf',
  'deer',
  'santa_train',
  'fairy_hat',
  'cupcake',
  'donuts',
  'carpet_3',
  'ball_4',
  'penguin',
  'ginger_cookie',
  'santa_letter',
];

/// 오늘 날짜 기준 선물명 반환 (11/01~12/25 외에는 null)
String? getRewardForToday() => getRewardForDate(DateTime.now());

/// 특정 날짜 기준 선물명
String? getRewardForDate(DateTime date) {
  if (date.month == 11) {
    final idx = date.day - 1; // 1일 → 0
    if (idx >= 0 && idx < _novRewards.length) return _novRewards[idx];
  } else if (date.month == 12) {
    final idx = date.day - 1; // 1일 → 0
    if (idx >= 0 && idx < _decRewards.length) return _decRewards[idx];
  }
  return null;
}
