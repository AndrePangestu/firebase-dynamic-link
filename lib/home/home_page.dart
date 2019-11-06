import 'dart:io';

import 'package:clean_deep_link/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int _counter = 0;

  FirebaseMessaging _firebaseMessaging;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    this.initDynamicLinks();

    setUpFirebase();

    var android = new AndroidInitializationSettings('mipmap/ic_launcher');
    var ios = new IOSInitializationSettings();
    var platform = new InitializationSettings(android, ios);

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.initialize(platform);

  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void initDynamicLinks() async {

//    final DynamicLinkParameters parameters = DynamicLinkParameters(
//      uriPrefix: 'https://canfazzfreelancer.page.link',
//      link: Uri.parse('https://canfazzfreelancer.com/'),
//      androidParameters: AndroidParameters(
//        packageName: 'com.canfazz.freelancer_app',
//        minimumVersion: 125,
//      ),
//      iosParameters: IosParameters(
//        bundleId: 'com.canfazz.freelancer_app',
//        minimumVersion: '1.0.1',
//        appStoreId: '123456789',
//      ),
//    );
//
//    final Uri dynamicUrl = await parameters.buildUrl();
//
//    final ShortDynamicLink shortDynamicLink = await parameters.buildShortLink();
//    final Uri shortUrl = shortDynamicLink.shortUrl;
//    print('dynamicUrl ${dynamicUrl}');
//    print('shortUrl ${shortUrl}');

    final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();

    final Uri deepLink = data?.link;

    if (deepLink != null) {
      Navigator.pushNamed(context, deepLink.path);
      print('DOSSSSSS');
    }

    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData dynamicLink) async {
          print('dynamicLink_uri ${dynamicLink}');
          final Uri deepLink = dynamicLink?.link;

          if (deepLink != null) {
            print('deeplinknya : $deepLink');
            print('path : ${deepLink.path}');
            print('query param : ${deepLink.queryParameters}');
            Navigator.pushNamed(context, deepLink.path, arguments: deepLink.queryParameters['id']);
          }
        },
        onError: (OnLinkErrorException e) async {
          print('onLinkError');
          print(e.message);
        }
    );
  }

  void handleDeepLink(Map<String, dynamic> message) async {

    if (message != null) {
      String link = message['data']['dynamic_link'];
      print('link ${link}');
      final Uri deepLink = Uri.parse(link);
      if (deepLink != null) {
        print('deeplinknya : $deepLink');
        Navigator.pushNamed(context, deepLink.path, arguments: message['data']['id']);
//        Navigator.of(context).pushNamed(res, arguments: message['data']['reference']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.display1,
            ),
            RaisedButton(onPressed: (){
              Navigator.pushNamed(context, detailPageRoute, arguments: 'Data from home');
            },),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  /// hadler
  navigateFromNotif(Map<String, dynamic> message) {
    var res = message['data']['route'];
    if (res != null) {
      print("DATA RES $res");
      Navigator.of(context).pushNamed(res, arguments: message['data']['reference']);
    }
  }
  void setUpFirebase() {
    _firebaseMessaging = FirebaseMessaging();
    firebaseCloudMessagingListeners();
  }

  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iOSPermission();

    _firebaseMessaging.getToken().then((token) {
      print('this token fcm $token');
    });

    Stream<String> fcmStream = _firebaseMessaging.onTokenRefresh;
    fcmStream.listen((token) {
      print('this token new fcm $token');
    });

    _firebaseMessaging.configure(

      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
        showNotification(message);
//        handleDeepLink(message);
      },
//      onBackgroundMessage: myBackgroundMessageHandler,
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
        handleDeepLink(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        handleDeepLink(message);
      },
    );
  }

  Future onSelectNotification(String data){
    showDialog(context: context, builder: (_)=> AlertDialog(
      title: Text(data),
      content: Text(data),
    ));
  }

  void showNotification(Map<String, dynamic> message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.Max, ticker: 'ticker'
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, message['notification']['title'], message['notification']['body'], platformChannelSpecifics, payload: 'item x');
  }

  void iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }
}