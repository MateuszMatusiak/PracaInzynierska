import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rks/screens/route_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'globals.dart';
import 'model/user_details.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'notification_channel_id', 'channel_name',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true);

bool _loggedIn = false;
String email = "";
String password = "";

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
////////
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const initializationSettingsIOS = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
    // onDidReceiveLocalNotification: onDidReceiveLocalNotification
  );

  const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: DarwinInitializationSettings());

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  ////////

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (error, handler) async {
        await EasyLoading.dismiss();
        if (error.response?.statusCode == 426) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (navigatorKey.currentState != null) {
              navigatorKey.currentState?.popUntil(ModalRoute.withName('/'));
              navigatorKey.currentState?.pushNamed('/wrongVersion');
            }
          });
        } else {
          print(error);
        }
        return handler.next(error);
      },
    ),
  );

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  await initializeDateFormatting();
  await checkSavedCredentials().then((value) async => {
        if (value)
          {
            _loggedIn = await onLogin(email, password),
          }
      });
  String route = _loggedIn ? '/menu' : '/';
  runApp(RKS(route));
}

Future<bool> checkSavedCredentials() async {
  final prefs = await SharedPreferences.getInstance();
  final String? tempLogin = prefs.getString('login');
  final String? tempPassword = prefs.getString('password');
  if (tempLogin != null && tempPassword != null) {
    email = tempLogin;
    password = tempPassword;
    return true;
  }
  return false;
}

Future<bool> onLogin(String email, String password) async {
  String url = apiUrl;
  if (email.isNotEmpty && password.isNotEmpty) {
    String deviceToken = await FirebaseMessaging.instance.getToken() ?? '';
    var jsonData = {
      'email': email.trim(),
      'password': password.trim(),
      'deviceToken': deviceToken.trim(),
    };

    try {
      var response = await Dio().post("$url/login",
          data: jsonData,
          options: Options(
              contentType: "application/json",
              responseType: ResponseType.json,
              headers: {'App-Version': appVersion}));
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      String token = response.headers.value("authorization")!;
      UserDetails user = UserDetails.fromJson(response.data);
      user.token = token;
      return true;
    } catch (e) {
      return false;
    }
  }
  return false;
}

class RKS extends StatefulWidget {
  String route;

  RKS(this.route, {super.key});

  @override
  State<RKS> createState() => RKSState();
}

class RKSState extends State<RKS> {
  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RKS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: primaryColor,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: primaryVariantBackgroundColor,
            unselectedItemColor: primaryTextColor),
        backgroundColor: primaryBackgroundColor,
        scaffoldBackgroundColor: primaryBackgroundColor,
      ),
      initialRoute: widget.route,
      onGenerateRoute: RouteGenerator.generateRoute,
      navigatorKey: navigatorKey,
      builder: EasyLoading.init(),
    );
  }
}
