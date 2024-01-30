import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'pages/aim_shoot_game_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Flame.device.fullScreen();
  Flame.device.setLandscape();
  runApp(const AimShootGamePage());
  // const GetMaterialApp(
  //     debugShowCheckedModeBanner: false, home: HomePage()));
}

/// TODO list
/// Game 1
/// - helps items
/// - main page
/// - levels
/// - set moves text font size on large width