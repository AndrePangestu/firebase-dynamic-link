import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'home/home_page.dart';
import 'router.dart';
import 'constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(debugLabel:"navigator");

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Deeplink',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: Router.generateRoute,
      initialRoute: homePageRoute,
      navigatorKey: navigatorKey,
    );
  }
}

