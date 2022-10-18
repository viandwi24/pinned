import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pinned/screens/home/home-screen.dart';
import 'package:pinned/utils/theme_builder.dart';

void main() {
  runApp(const MyApp());
  applyConfig();
}

void applyConfig() {
  EasyLoading.instance.animationStyle = EasyLoadingAnimationStyle.scale;
  EasyLoading.instance.indicatorType = EasyLoadingIndicatorType.ring;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ThemeData themeData = themeDataBuilder(context, null);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pinned',
      theme: themeData,
      // home: const HomeScreen(),
      home: const TestScreen(),
      builder: EasyLoading.init(),
    );
  }
}

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Center(
            child: TextButton(
              child: Text('test'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
