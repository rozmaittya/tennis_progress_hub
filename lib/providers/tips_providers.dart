import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/random_tennis_tips.dart';
import 'dart:math';

typedef Tip = ({String areaKey, String text});

final tipProvider = NotifierProvider<TipNotifier, Tip>(TipNotifier.new);

class TipNotifier extends Notifier<Tip> {
  final _rnd = Random();

  @override
  Tip build() {
    return _tipOfTheDay();
  }

  Tip _tipOfTheDay() {
    final now = DateTime.now();

    final dayOfYear = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(now.year, 1, 1)).inDays;

    final categories = tennisTipsByCategory.keys.toList();
    final areaKey = categories[dayOfYear % categories.length];

    final tips = tennisTipsByCategory[areaKey] ?? const <String>[];
    if (tips.isEmpty) return (areaKey: areaKey, text: '');

    final text = tips[dayOfYear % tips.length];
    return (areaKey: areaKey, text: text);
  }

  Tip _randomTip() {
    final keys = tennisTipsByCategory.keys.toList();
    final areaKey = keys[_rnd.nextInt(keys.length)];

    final tips = tennisTipsByCategory[areaKey] ?? <String>[];
    if (tips.isEmpty) return (areaKey: areaKey, text: '');

    final text = tips[_rnd.nextInt(tips.length)];
    return (areaKey: areaKey, text: text);
  }

  void nextTip() => state = _randomTip();
}
