import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:progress_hub_2/screens/home_content_screen.dart';
import '../screens/screen_data.dart';
import '../screens/home_content_screen.dart';


final currentScreenProvider = StateProvider<ScreenData>((ref) {
  return ScreenData(
    title: 'Tennis Hub',
    screen: const HomeContentScreen(),
        );
});