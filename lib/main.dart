import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lottie/lottie.dart';
import 'package:pinned/screens/home_screen.dart';
import 'package:pinned/utils/db.dart';
import 'package:pinned/utils/theme_builder.dart';

void main() async {
  applyConfig();
  runApp(const MyApp());
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
      home: const MainScreen(),
      builder: EasyLoading.init(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
            future: DB.dbRead(),
            builder: (context, snapshot) {
              if (snapshot.data is bool && snapshot.data as bool == true) {
                return const HomeScreen();
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset('assets/anims/loader.json'),
                  TextButton(
                    child: Text('Loading...'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                  ),
                ],
              );
            }),
      ),
    );
  }
}
