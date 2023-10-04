import 'package:flutter/material.dart';
import 'package:rks/screens/add_new_post.dart';
import 'package:rks/screens/board.dart';
import 'package:rks/screens/chat_rooms.dart';
import 'package:rks/screens/dictionary.dart';
import 'package:rks/screens/edit_event.dart';
import 'package:rks/screens/event_panel.dart';
import 'package:rks/screens/home.dart';
import 'package:rks/screens/register_panel.dart';
import 'package:rks/screens/switch_group.dart';
import 'package:rks/screens/update_user_details.dart';

import 'add_new_group.dart';
import 'add_phrase_to_dictionary.dart';
import 'add_point_to_map.dart';
import 'add_users_to_event.dart';
import 'add_users_to_group.dart';
import 'calendar.dart';
import 'error_panel.dart';
import 'gallery.dart';
import 'login.dart';
import 'map.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case '/register':
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case '/menu':
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case '/map':
        return MaterialPageRoute(builder: (_) => const MapScreen());
      case '/chat':
        return MaterialPageRoute(builder: (_) => const ChatRooms());
      case '/calendar':
        return MaterialPageRoute(builder: (_) => const CalendarScreen());
      case '/board':
        return MaterialPageRoute(builder: (_) => const BoardScreen());
      case '/addNewPost':
        return MaterialPageRoute(builder: (_) => const AddNewPost());
      case '/switchGroup':
        return MaterialPageRoute(builder: (_) => const SwitchGroup());
      case '/dictionary':
        return MaterialPageRoute(builder: (_) => const DictionaryScreen());
      case '/AddToDictionary':
        List<dynamic> a = settings.arguments as List;
        return MaterialPageRoute(builder: (_) => AddToDictionaryScreen(a[0]));
      case '/editDictionary':
        List<dynamic> a = settings.arguments as List;
        return MaterialPageRoute(builder: (_) => AddToDictionaryScreen.edit(a[0], a[1], a[2], a[3]));
      case '/updateUserDetails':
        List<dynamic> a = settings.arguments as List;
        return MaterialPageRoute(builder: (_) => UpdateUserDetailsScreen(a[0]));
      case '/addEvent':
        List<dynamic> a = settings.arguments as List;
        if (a.length == 1) {
          return MaterialPageRoute(
              builder: (_) => EditEventScreen.add(a[0], null));
        } else {
          return MaterialPageRoute(
              builder: (_) => EditEventScreen.add(a[0], a[1]));
        }
      case '/editEvent':
        List<dynamic> a = settings.arguments as List;
        return MaterialPageRoute(builder: (_) => EditEventScreen(a[0]));
      case '/addGroup':
        return MaterialPageRoute(builder: (_) => const AddNewGroupScreen());
      case '/event':
        List<dynamic> a = settings.arguments as List;
        return MaterialPageRoute(builder: (_) => EventPanel(a[0]));
      case '/addUserToEvent':
        List<dynamic> a = settings.arguments as List;
        return MaterialPageRoute(
            builder: (_) => NewUserToEventScreen(a[0], a[1]));
      case '/addUserToGroup':
        List<dynamic> a = settings.arguments as List;
        return MaterialPageRoute(
            builder: (_) => NewUserToGroupScreen(a[0], a[1]));
      case '/gallery':
        return MaterialPageRoute(builder: (_) => GalleryPanel(null));
      case '/addMapPoint':
        List<dynamic> a = settings.arguments as List;
        return MaterialPageRoute(builder: (_) => AddMapPoint(a[0], a[1]));
      case '/wrongVersion':
        return MaterialPageRoute(builder: (_) => const WrongVersionPanel());
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) => const LoginPage());
  }
}
