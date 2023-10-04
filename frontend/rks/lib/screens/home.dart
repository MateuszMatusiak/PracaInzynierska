import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rks/globals.dart';
import 'package:rks/model/user.dart';
import 'package:rks/model/user_details.dart';
import 'package:rks/screens/board.dart';
import 'package:rks/screens/calendar.dart';
import 'package:rks/screens/chat_rooms.dart';
import 'package:rks/screens/dictionary.dart';
import 'package:rks/screens/gallery.dart';
import 'package:rks/screens/map.dart';

import '../main.dart';
import 'group_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<HomeScreen> {
  UserDetails user = UserDetails.getInstance();
  int _currentId = 0;
  late PageController _pageController;

  late List<User> users;
  IconData extraIcon = Icons.group;
  String extraName = 'Grupa';

  @override
  void initState() {
    super.initState();
    fcm();
    _pageController = PageController(initialPage: _currentId);
  }

  void fcm() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                color: Colors.blue,
                playSound: true,
              ),
            ));
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text("${notification.title}"),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text("${notification.body}")],
                  ),
                ),
              );
            });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String groupName = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBackgroundColor,
        title: InkWell(
          child: Text(user.selectedGroup.name),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Zmień nazwę grupy'),
                  content: TextFormField(
                    onChanged: (v) => {
                      groupName = v,
                    },
                    decoration: const InputDecoration(
                      labelText: 'Nowa nazwa',
                    ),
                  ),
                  actions: <Widget>[
                    MaterialButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Anuluj'),
                    ),
                    MaterialButton(
                      onPressed: () {
                        changeGroupName(groupName);
                      },
                      child: const Text('Zmień nazwę'),
                    ),
                  ],
                );
              },
            );
          }, //ewentualna zmiana nazwy grupy
        ),
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed('/updateUserDetails', arguments: [user]);
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage('${userImageUrl}${user.id}'),
                    radius: 26,
                  ))),
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: user.selectedGroup.exists()
            ? [
                ChatRooms(),
                CalendarScreen(),
                BoardScreen(),
                GroupScreen(),
                GalleryPanel(null),
                DictionaryScreen(),
                MapScreen(),
              ]
            : [
                ChatRooms(),
                CalendarScreen(),
              ],
        onPageChanged: _onPageChanged,
      ),
      drawer: user.selectedGroup.exists()
          ? Drawer(
              backgroundColor: primaryVariantBackgroundColor,
              child: Column(children: <Widget>[
                Expanded(
                  child: ListView(padding: EdgeInsets.zero, children: [
                    DrawerHeader(
                      decoration: BoxDecoration(
                        color: primaryColor,
                      ),
                      child: Text('version: ' + appVersion,
                          style: TextStyle(color: primaryTextColor)),
                    ),
                    // ListTile(
                    //   title: Text('Playlista',
                    //       style: TextStyle(color: primaryTextColor)),
                    //   leading: Icon(
                    //     Icons.music_note_sharp,
                    //     color: primaryTextColor,
                    //   ),
                    //   onTap: () {},
                    // ),
                    ListTile(
                      title: Text('Galeria',
                          style: TextStyle(color: primaryTextColor)),
                      leading: Icon(
                        Icons.browse_gallery,
                        color: primaryTextColor,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _pageController.jumpToPage(4);
                      },
                    ),
                    ListTile(
                      title: Text('Słownik',
                          style: TextStyle(color: primaryTextColor)),
                      leading: Icon(
                        Icons.book,
                        color: primaryTextColor,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _pageController.jumpToPage(5);
                      },
                    ),
                    ListTile(
                      title: Text('Mapy',
                          style: TextStyle(color: primaryTextColor)),
                      leading: Icon(
                        Icons.map,
                        color: primaryTextColor,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _pageController.jumpToPage(6);
                      },
                    ),
                    // ListTile(
                    //   title: const Text('Lista zakupów'),
                    //   leading: Icon(Icons.shopping_bag),
                    //   onTap: () {
                    //   },
                    // ),
                  ]),
                ),
                Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: ListTile(
                    hoverColor: primaryColor,
                    dense: true,
                    visualDensity: const VisualDensity(vertical: -4),
                    leading: Icon(
                      Icons.groups,
                      color: primaryTextColor,
                    ),
                    title: Text('Wybór grupy',
                        style: TextStyle(color: primaryTextColor)),
                    onTap: () {
                      Navigator.of(context).pushNamed('/switchGroup');
                    },
                  ),
                )
              ]))
          : Drawer(
              backgroundColor: primaryVariantBackgroundColor,
              child: Column(children: <Widget>[
                Spacer(),
                  ListTile(
                    hoverColor: primaryColor,
                    dense: true,
                    visualDensity: const VisualDensity(vertical: -4),
                    leading: Icon(
                      Icons.groups,
                      color: primaryTextColor,
                    ),
                    title: Text('Wybór grupy',
                        style: TextStyle(color: primaryTextColor)),
                    onTap: () {
                      Navigator.of(context).pushNamed('/switchGroup');
                    },
                  ),
              ])),
      bottomNavigationBar: BottomNavyBar(
        selectedIndex: _currentId,
        backgroundColor: primaryVariantBackgroundColor,
        showElevation: true,
        onItemSelected: (index) => setState(() {
          _currentId = index;
          _pageController.animateToPage(index,
              duration: const Duration(milliseconds: 300), curve: Curves.ease);
        }),
        items: user.selectedGroup.exists()
            ? [
                BottomNavyBarItem(
                  icon: Icon(Icons.chat),
                  title: Text('Czaty'),
                  activeColor: Colors.grey,
                ),
                BottomNavyBarItem(
                  icon: Icon(Icons.calendar_month),
                  title: Text('Kalendarz'),
                  activeColor: Colors.grey,
                ),
                BottomNavyBarItem(
                  icon: Icon(Icons.post_add),
                  title: Text('Tablica'),
                  activeColor: Colors.grey,
                ),
                BottomNavyBarItem(
                  icon: Icon(extraIcon),
                  title: Text(extraName),
                  activeColor: Colors.grey,
                ),
              ]
            : [
                BottomNavyBarItem(
                  icon: Icon(Icons.chat),
                  title: Text('Czaty'),
                  activeColor: Colors.grey,
                ),
                BottomNavyBarItem(
                  icon: Icon(Icons.calendar_month),
                  title: Text('Kalendarz'),
                  activeColor: Colors.grey,
                )
              ],
      ),
    );
  }

  void changeGroupName(String groupName) async {
    String url = '${apiUrl}/group/${user.selectedGroup.id}/${groupName}';
    try {
      await EasyLoading.show(
        status: 'Zmienianie nazwy grupy',
        maskType: EasyLoadingMaskType.black,
      );
      var response = await dio.put(url,
          options: Options(
              contentType: "application/json",
              responseType: ResponseType.json,
              headers: {
                'Authorization': user.token,
                'App-Version': appVersion
              }));
      await EasyLoading.dismiss();
      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Zmieniono nazwę grupy')));
        setState(() {
          user.selectedGroup.name = groupName;
        });
        Navigator.of(context).pushNamed('/menu');
      }
    } catch (e) {
      Navigator.of(context).pushNamed('/menu');
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      switch (page) {
        case 4:
          extraName = 'Galeria';
          extraIcon = Icons.browse_gallery;
          _currentId = 3;
          break;
        case 5:
          extraName = 'Słownik';
          extraIcon = Icons.book;
          _currentId = 3;
          break;
        case 6:
          extraName = 'Mapy';
          extraIcon = Icons.map;
          _currentId = 3;
          break;
        default:
          extraName = 'Grupa';
          extraIcon = Icons.group;
          _currentId = page;
          break;
      }
    });
  }
}
