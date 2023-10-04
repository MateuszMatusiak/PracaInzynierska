import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rks/globals.dart';
import 'package:rks/model/user.dart';
import 'package:rks/model/user_details.dart';

class NewUserToEventScreen extends StatefulWidget {
  int _eventId;
  List<User> _users;

  NewUserToEventScreen(this._eventId, this._users, {super.key});

  @override
  NewUserToEventState createState() => NewUserToEventState(_eventId, _users);
}

class NewUserToEventState extends State<NewUserToEventScreen> {
  final UserDetails _user = UserDetails.getInstance();
  final int _eventId;

  NewUserToEventState(this._eventId, this._users);

  late Future<List<User>> _foundUsers;
  List<User> _users;

  @override
  void initState() {
    super.initState();
    _foundUsers = findUsers(username);
  }

  String username = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            'Lista użytkowników',
            style: TextStyle(color: primaryTextColor),
          ),
        ),
        body: Column(
          children: [
            Container(
              constraints: BoxConstraints(minHeight: 0, maxHeight: 260),
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
              child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    User u = _users[index];
                    return Row(
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                          child: Container(
                            width: 50,
                            height: 50,
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: Image.network(
                              '${userImageUrl}${u.id}',
                              fit: BoxFit.fitWidth,
                            ),
                          ),
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
                                        fontSize: 19, color: primaryTextColor)),
                                subtitle: Text("${u.firstname} ${u.lastname}",
                                    style: TextStyle(
                                        fontSize: 13, color: primaryTextColor)),
                                trailing: InkWell(
                                  child: Icon(
                                    Icons.delete,
                                    color: primaryTextColor,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _users.removeAt(index);
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 10.0,
                    color: primaryTextColor,
                    indent: 10.0,
                    endIndent: 10.0,
                  );
                },),
            ),
            Container(
              constraints: BoxConstraints(minHeight: 0, maxHeight: 120),
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: TextField(
                          onChanged: (v) => {
                                username = v,
                              },
                          style: TextStyle(color: primaryTextColor),
                          decoration: InputDecoration(
                            labelText: 'Wprowadź imię',
                            labelStyle: TextStyle(color: primaryTextColor),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryTextColor),
                            ),
                          ))),
                  MaterialButton(
                    color: primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    minWidth: double.infinity,
                    height: 40,
                    onPressed: () async {
                      setState(() {
                        _foundUsers = findUsers(username);
                      });
                    },
                    child: Text(
                      'Szukaj',
                      style: TextStyle(
                        fontSize: 20,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              // constraints: BoxConstraints(minHeight: 0, maxHeight: 260),
              child: FutureBuilder<List<User>>(
                future: _foundUsers,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.isEmpty) {
                      return Center( child:Text(
                        "Nie znaleziono",
                        style: TextStyle(color: primaryTextColor),
                      ));
                    } else {
                      return ListView.separated(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              "${snapshot.data![index].firstname} ${snapshot.data![index].lastname}",
                              style: TextStyle(color: primaryTextColor),
                            ),
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(
                                  '${userImageUrl}${snapshot.data![index].id}'),
                              radius: 22,
                            ),
                            trailing: InkWell(
                              child: Icon(
                                Icons.add,
                                color: primaryTextColor,
                              ),
                              onTap: () {
                                setState(() {
                                  _users.add(snapshot.data![index]);
                                  snapshot.data!.removeAt(index);
                                });
                              },
                            ),
                            onTap: () {},
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider(
                            height: 20.0,
                            color: primaryTextColor,
                            indent: 10.0,
                            endIndent: 10.0,
                          );
                        },
                      );
                    }
                  } else if (snapshot.hasError) {
                    return Text(
                      "${snapshot.error}",
                      style: TextStyle(color: primaryTextColor),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: MaterialButton(
                color: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                minWidth: double.infinity,
                height: 40,
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text(
                  'Gotowe',
                  style: TextStyle(
                    fontSize: 20,
                    color: primaryTextColor,
                  ),
                ),
              ),
            )
          ],
        ));
  }

  Future<List<User>> findUsers(String username) async {
    String url = '${apiUrl}/user/search';
    if (username.isNotEmpty) {
      url += '?name=$username';
    }
    try {
      var response = await dio.get(url,
          options: Options(
              contentType: "application/json",
              responseType: ResponseType.json,
              headers: {
                'Authorization':  _user.token,
                'App-Version': appVersion
              }));
      List<User> foundUsers = [];
      if (response.statusCode == 200) {
        if (response.data is List) {
          for (var g in response.data) {
            User user = User.fromJson(g);
            if (!_users.contains(user)) {
              foundUsers.add(user);
            }
          }
        }
      }
      return foundUsers;
    } catch (e) {
    }
    return [];
  }
}
