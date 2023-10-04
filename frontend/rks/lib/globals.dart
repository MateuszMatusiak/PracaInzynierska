import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

const String appVersion = "0.0.7";

//global
const String apiUrl = "http://130.162.237.148:4567";
//local
// const String apiUrl = "http://192.168.1.113:4567";

const String userImageUrl = '$apiUrl/image/profile/';
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final dio = Dio();

const int _xPrimaryValue = 0xEE434343;
const int _textPrimaryValue = 0xE3FFFFFF;

MaterialColor x = createMaterialColor(Color(_xPrimaryValue));

MaterialColor primaryColor = x;
Color primaryVariantColor = x.shade50;
Color primaryBackgroundColor = x.shade900;
Color primaryVariantBackgroundColor = x.shade800;
Color primaryTextColor = Color(_textPrimaryValue);

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = {};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

const colors = [
  Color(0xffff6767),
  Color(0xff66e0da),
  Color(0xfff5a2d9),
  Color(0xfff0c722),
  Color(0xff6a85e5),
  Color(0xfffd9a6f),
  Color(0xff92db6e),
  Color(0xff73b8e5),
  Color(0xfffd7590),
  Color(0xffc78ae5),
];

Color getAvatarColor(String id) {
  final index = id.hashCode % colors.length;
  return colors[index];
}

String getUserName(types.User user) =>
    '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();

extension StringCasingExtension on String {
  String toCapitalized() =>
      length > 0 ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';

  String toTitleCase() => replaceAll(RegExp(' +'), ' ')
      .split(' ')
      .map((str) => str.toCapitalized())
      .join(' ');
}

Future<void> onErrorAlert(
    BuildContext context, String title, String decription) async {
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
      content: Text(
        decription,
      ),
      title: Text(title),
    ),
  );
}
