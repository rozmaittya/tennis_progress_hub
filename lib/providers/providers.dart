import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/screen_data.dart';


final currentScreenProvider = StateProvider<ScreenData>((ref) {
  return ScreenData(
    title: 'Let\'s progress!',
    screen: const Center(child: Text('Add new skills\nor choose 1-3 goals\nfor game or training', style:
        TextStyle(
          fontFamily: 'Roboto',
          fontSize: 18,
        ),))
  );
});