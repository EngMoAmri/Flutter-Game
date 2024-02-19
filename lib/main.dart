// import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'pages/home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO move this to the aim game
  // Flame.device.fullScreen();
  // Flame.device.setLandscape();
  runApp(
      // const AimShootGamePage());
      const GetMaterialApp(
          debugShowCheckedModeBanner: false, home: HomePage()));
}

/// TODO list
/// Game 1
/// - win layout
/// - loss layout
/// - pause layout
/// - helps items
/// - main page
/// - levels
/// - set moves text font size on large width