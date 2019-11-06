import 'package:clean_deep_link/constants.dart';
import 'package:clean_deep_link/detail/detail_page.dart';
import 'package:clean_deep_link/home/home_page.dart';
import 'package:flutter/material.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
      switch (settings.name) {
        case homePageRoute:
          return MaterialPageRoute(builder: (_) => MyHomePage(title: 'HomePage',));
        case detailPageRoute:
          var data = settings.arguments as String;
          return MaterialPageRoute(builder: (_) => DetailPage(data));
        default:
          return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
      }
  }
}