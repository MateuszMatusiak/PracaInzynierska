import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:rks/model/user_details.dart';
import 'package:rks/screens/gallery.dart';

import '../globals.dart';
import '../model/event.dart';
import '../model/user.dart';

class EventPanel extends StatefulWidget {
  final int _eventId;

  const EventPanel(this._eventId, {super.key});

  @override
  State<EventPanel> createState() => _EventPanelState();
}

class _EventPanelState extends State<EventPanel> {
  final UserDetails _user = UserDetails.getInstance();
  late final int _eventId;
  late Future<Event> future;
  late Event event;
  late Future<ImageProvider?> futureEventImage;
  DefaultCacheManager cacheManager = DefaultCacheManager();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _eventId = widget._eventId;
    future = getEvent();
    futureEventImage = getEventImage();
    future.then(
        (value) => {_selectedIndex = value.isAfter() ? 1 : 0, setState(() {})});
  }

  void refresh() {
    setState(() {
      future = getEvent();
      futureEventImage = getEventImage();
      future.then((value) =>
          {_selectedIndex = value.isAfter() ? 1 : 0, setState(() {})});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _selectedIndex == 0
          ? organizationPanel(context)
          : summaryPanel(context),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_filled_sharp),
            label: 'Organizacja',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: 'Podsumowanie',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: primaryColor,
        onTap: (int index) {
          switch (index) {
            case 0:
              break;
            case 1:
              break;
          }
          setState(
            () {
              _selectedIndex = index;
            },
          );
        },
      ),
    );
  }

  FutureBuilder summaryPanel(BuildContext widgetContext) {
    return FutureBuilder<Event>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<Event> data) {
        if (data.hasData) {
          return Scaffold(
              appBar: AppBar(
                title: Text(
                  data.data!.name.toTitleCase(),
                  style: TextStyle(
                    color: primaryTextColor,
                  ),
                ),
              ),
              body: Container(
                alignment: Alignment.topCenter,
                margin: const EdgeInsets.all(5),
                padding: const EdgeInsets.all(15),
                child: Column(children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                      child: Column(children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "${data.data!.startDate.substring(0, 10)}${data.data!.endDate.isNotEmpty ? " - ${data.data!.endDate.substring(0, 10)}" : ""}",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: primaryTextColor,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ])),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Lista osób:',
                      style: TextStyle(color: primaryTextColor),
                    ),
                  ),
                  Divider(
                    height: 10,
                    thickness: 1,
                    color: primaryTextColor,
                  ),
                  Expanded(
                    flex: 1,
                    child: ListView.separated(
                      itemCount: data.data!.users.length,
                      itemBuilder: (context, index) {
                        User u = data.data!.users[index];
                        return Row(
                          children: <Widget>[
                            CircleAvatar(
                              backgroundImage:
                                  NetworkImage('${userImageUrl}${u.id}'),
                              radius: 25,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    2, 0, 0, 0),
                                child: Theme(
                                  data: ThemeData(
                                    checkboxTheme: CheckboxThemeData(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      side: MaterialStateBorderSide.resolveWith(
                                        (Set<MaterialState> states) {
                                          return BorderSide(
                                              color: primaryTextColor);
                                        },
                                      ),
                                    ),
                                    unselectedWidgetColor: Color(0xFF7C8791),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                        u.nick.isEmpty
                                            ? "${u.firstname} ${u.lastname}"
                                            : u.nick,
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: primaryTextColor)),
                                    subtitle: Text(
                                        "${u.firstname} ${u.lastname}",
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: primaryTextColor)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: 0.5,
                          color: primaryTextColor,
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 9, 0, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Zdjęcia:',
                        style: TextStyle(color: primaryTextColor),
                      ),
                    ),
                  ),
                  Divider(
                    height: 10,
                    thickness: 1,
                    color: primaryTextColor,
                  ),
                  Expanded(flex: 2, child: GalleryPanel(data.data!.id)),
                ]),
              ));
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  FutureBuilder organizationPanel(BuildContext widgetContext) {
    return FutureBuilder<Event>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<Event> data) {
        if (data.hasData) {
          return Scaffold(
              appBar: AppBar(
                title: Text(
                  data.data!.name.toTitleCase(),
                  style: TextStyle(color: primaryTextColor),
                ),
                actions: data.data?.creator.id == _user.id
                    ? [
                        PopupMenuButton(onSelected: (option) {
                          switch (option) {
                            case 0:
                              {
                                Navigator.of(context).pushNamed('/editEvent',
                                    arguments: [
                                      data.data!.id
                                    ]).then((value) => refresh());
                                break;
                              }
                          }
                        }, itemBuilder: (context) {
                          return [
                            const PopupMenuItem(
                              value: 0,
                              child: Text("Edytuj"),
                            ),
                          ];
                        }),
                      ]
                    : null,
              ),
              body: Container(
                alignment: Alignment.topCenter,
                margin: const EdgeInsets.fromLTRB(5, 7, 5, 5),
                padding: const EdgeInsets.fromLTRB(15, 7, 15, 15),
                child: Column(children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                      child: Container(
                          constraints:
                              BoxConstraints(minHeight: 0, maxHeight: 150),
                          child: Row(
                            children: [
                              Column(children: <Widget>[
                                const Padding(
                                    padding: EdgeInsets.fromLTRB(0, 0, 0, 6)),
                                Text(data.data!.startDate,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                        fontSize: 20, color: primaryTextColor)),
                                Divider(
                                  height: 20.0,
                                  color: primaryTextColor,
                                ),
                                data.data!.endDate.isNotEmpty
                                    ? Column(children: <Widget>[
                                        Text('Koniec: ',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: primaryTextColor)),
                                        Text(data.data!.endDate,
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: primaryTextColor)),
                                        Divider(
                                          height: 20.0,
                                          color: primaryTextColor,
                                        ),
                                      ])
                                    : Container(),
                              ]),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  child: FutureBuilder(
                                    future: futureEventImage,
                                    builder: (BuildContext context,
                                        AsyncSnapshot<ImageProvider?> data) {
                                      if (data.connectionState ==
                                          ConnectionState.done) {
                                        if (data.hasData) {
                                          return data.data == null
                                              ? Container()
                                              : Image(
                                                  image: data.data!,
                                                  width: 150.0,
                                                  height: 150.0,
                                                  fit: BoxFit.fitWidth);
                                        } else {
                                          return Container();
                                        }
                                      } else if (data.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    },
                                  )),
                            ],
                          ))),
                  Expanded(
                      flex: data.data!.description.length > 350 ? 1 : 0,
                      child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Text(data.data!.description.toCapitalized(),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 20, color: primaryTextColor)))),
                  Divider(
                    height: 20,
                    thickness: 1,
                    color: primaryTextColor,
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: data.data!.users.length,
                      itemBuilder: (context, index) {
                        User u = data.data!.users[index];
                        return Row(
                          children: <Widget>[
                            CircleAvatar(
                              backgroundImage:
                                  NetworkImage('${userImageUrl}${u.id}'),
                              radius: 25,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    2, 0, 0, 0),
                                child: Theme(
                                  data: ThemeData(
                                    checkboxTheme: CheckboxThemeData(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      side: MaterialStateBorderSide.resolveWith(
                                        (Set<MaterialState> states) {
                                          return BorderSide(
                                              color: primaryTextColor);
                                        },
                                      ),
                                    ),
                                    unselectedWidgetColor: Color(0xFF7C8791),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                        u.nick.isEmpty
                                            ? "${u.firstname} ${u.lastname}"
                                            : u.nick,
                                        style: TextStyle(
                                            fontSize: 25,
                                            color: primaryTextColor)),
                                    subtitle: Text(
                                        "${u.firstname} ${u.lastname}",
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: primaryTextColor)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider(
                          height: 20.0,
                          color: primaryTextColor,
                        );
                      },
                    ),
                  ),
                ]),
              ));
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Future<Event> getEvent() async {
    String url = '${apiUrl}/events/$_eventId';
    try {
      var response = await dio.get(url,
          options: Options(
              contentType: "application/json",
              responseType: ResponseType.json,
              headers: {
                'Authorization': _user.token,
                'App-Version': appVersion
              }));
      if (response.statusCode == 200) {
        return Event.fromJson(response.data);
      }
    } catch (e) {}
    return Event.empty();
  }

  Future<ImageProvider?> getEventImage() async {
    String url = '${apiUrl}/image/event/$_eventId';

    var file = await cacheManager.getFileFromCache('event/$_eventId');
    if (file == null) {
      try {
        var response = await dio.get(url,
            options: Options(
                contentType: "application/json",
                responseType: ResponseType.bytes,
                headers: {
                  'Authorization': _user.token,
                  'App-Version': appVersion
                }));
        if (response.statusCode == 200) {
          if (response.data != null) {
            await cacheManager.putFile('event/$_eventId', response.data);
            return Image.memory(
              response.data,
            ).image;
          } else {
            return null;
          }
        }
      } catch (e) {
        return null;
      }
    }
    return Image.file(
      file!.file,
    ).image;
  }
}
