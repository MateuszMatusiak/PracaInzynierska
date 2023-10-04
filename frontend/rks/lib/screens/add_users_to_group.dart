import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rks/globals.dart';
import 'package:rks/model/user.dart';

import '../model/user_details.dart';
import 'group_panel.dart';

class NewUserToGroupScreen extends StatefulWidget {
  List<User> groupUsers;
  GroupState groupPanel;

  NewUserToGroupScreen(this.groupUsers, this.groupPanel, {super.key});

  @override
  NewUserToGroupState createState() => NewUserToGroupState();
}

class NewUserToGroupState extends State<NewUserToGroupScreen> {
  UserDetails user = UserDetails.getInstance();

  late Future<List<User>> futureUsers;
  late List<User> users;

  @override
  void initState() {
    super.initState();
    futureUsers = findUsers(username);
  }

  String username = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text('Dodaj do grupy'),
          actions: <Widget>[
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed('/updateUserDetails', arguments: [user]);
                    },
                    child: CircleAvatar(
                      backgroundImage:
                          NetworkImage('${userImageUrl}${user.id}'),
                      radius: 26,
                    ))),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: TextField(
                          style: TextStyle(color: primaryTextColor),
                          onChanged: (v) => {
                                username = v,
                              },
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
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    onPressed: () async {
                      futureUsers = findUsers(username);
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
              flex: 4,
              child: FutureBuilder<List<User>>(
                future: futureUsers,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.separated(
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          User u = users[index];
                          return Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    2, 2, 2, 2),
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
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        side:
                                            MaterialStateBorderSide.resolveWith(
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
                                            fontSize: 19,
                                            color: primaryTextColor,
                                          )),
                                      subtitle:
                                          Text("${u.firstname} ${u.lastname}",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: primaryTextColor,
                                              )),
                                      trailing: InkWell(
                                        child: Icon(Icons.add,
                                            color: primaryTextColor),
                                        onTap: () {
                                          addUserToGroup(users[index]);
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
                          return const Divider(height: 5.0);
                        });
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: MaterialButton(
                color: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 39, vertical: 15),
                onPressed: () {
                  setState(() {
                    widget.groupPanel.refreshUsers();
                    Navigator.of(context).pop();
                  });
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
      await EasyLoading.show(
        status: 'Pobieranie listy użytkowników',
        maskType: EasyLoadingMaskType.black,
      );
      var response = await dio.get(url,
          options: Options(
              contentType: "application/json",
              responseType: ResponseType.json,
              headers: {
                'Authorization': user.token,
                'App-Version': appVersion
              }));
      List<User> users = [];
      await EasyLoading.dismiss();
      if (response.statusCode == 200) {
        if (response.data is List) {
          for (var g in response.data) {
            User user = User.fromJson(g);
            if (!widget.groupUsers.contains(user)) {
              users.add(user);
            }
          }
        } else {
          User user = User.fromJson(response.data);
          users.add(user);
        }
        setState(() {
          this.users = users;
        });
      }
      return users;
    } catch (e) {}
    return [];
  }

  Future addUserToGroup(User userToAdd) async {
    String url =
        '${apiUrl}/group/${user.selectedGroup.id}/user/${userToAdd.id}';
    try {
      await EasyLoading.show(
        status: 'Dodawanie użytkownika do grupy',
        maskType: EasyLoadingMaskType.black,
      );
      var response = await dio.post(url,
          data: {'role': User.encodeRole(UserRole.user)},
          options: Options(
              contentType: "application/json",
              responseType: ResponseType.json,
              headers: {
                'Authorization': user.token,
                'App-Version': appVersion
              }));
      widget.groupUsers.add(userToAdd);
      users.remove(userToAdd);

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('rooms')
          .where('metadata.groupDatabaseId', isEqualTo: user.selectedGroup.id)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return;
      }
      String roomId = querySnapshot.docs.first.id;

      DocumentReference roomRef =
          FirebaseFirestore.instance.collection('rooms').doc(roomId);

      try {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot roomSnapshot = await transaction.get(roomRef);

          if (!roomSnapshot.exists) {
            return;
          }
          var data = roomSnapshot.data() as Map<String, dynamic>;
          List<String> userIds = List<String>.from(data['userIds']);
          userIds.add(userToAdd.firebaseId);

          Map<String, dynamic> seen = data['metadata']['seen'];
          seen.putIfAbsent(
              userToAdd.firebaseId, () => {'lastSeen': '', 'unseen': 0});

          transaction.update(roomRef, {
            'userIds': userIds,
            'metadata.seen': seen,
          });
        });
      } catch (e) {}

      await Dio().post('${apiUrl}/chat/${roomId}/addUser/${userToAdd.id}',
          options: Options(
              contentType: "application/json",
              responseType: ResponseType.json,
              headers: {
                'Authorization': user.token,
              }));
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return Theme(
            data: Theme.of(context)
                .copyWith(dialogBackgroundColor: primaryBackgroundColor),
            child: AlertDialog(
              title: Text("${userToAdd.firstname} ${userToAdd.lastname}",
                  style: TextStyle(color: userToAdd.getColor())),
              content: Container(
                height: 150.0,
                width: 100.0,
                child: Column(
                  children: [
                    Divider(
                      thickness: 1.5,
                      color: primaryTextColor,
                    ),
                    createRolesList(userToAdd),
                  ],
                ),
              ),
            ),
          );
        },
      );
      await EasyLoading.dismiss();
    } catch (e) {
      setState(() {
        widget.groupPanel.refreshUsers();
        Navigator.of(context).pop();
      });
    }
  }

  ListView createRolesList(User editedUser) {
    List<ListTile> entries = [];
    if (user.isOwner() && editedUser.role != UserRole.admin) {
      entries.add(ListTile(
        title: Text("Admin", style: TextStyle(color: primaryTextColor)),
        onTap: () {
          updateUserRole(editedUser.id, UserRole.admin);
        },
      ));
    }
    if (user.isAdmin() && editedUser.role != UserRole.moderator) {
      entries.add(ListTile(
        title: Text("Moderator", style: TextStyle(color: primaryTextColor)),
        onTap: () {
          updateUserRole(editedUser.id, UserRole.moderator);
        },
      ));
    }
    if (user.isModerator() && editedUser.role != UserRole.user) {
      entries.add(ListTile(
        title: Text("Użytkownik", style: TextStyle(color: primaryTextColor)),
        onTap: () {
          updateUserRole(editedUser.id, UserRole.user);
        },
      ));
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: entries.length,
      itemBuilder: (BuildContext context, int index) {
        return entries[index];
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          height: 1.0,
          color: primaryTextColor,
        );
      },
    );
  }

  void updateUserRole(int userId, UserRole role) async {
    String url = '${apiUrl}/group/${user.selectedGroup.id}/user/$userId';
    var json = {
      "role": User.encodeRole(role),
    };
    try {
      await EasyLoading.show();
      var response = await dio.put(url,
          data: json,
          options: Options(
              contentType: "application/json",
              responseType: ResponseType.json,
              headers: {
                'Authorization': user.token,
                'App-Version': appVersion
              }));
      setState(() {
        findUsers("");
        widget.groupPanel.refreshUsers();
        Navigator.of(context).pop();
      });
      await EasyLoading.dismiss();
    } catch (e) {}
  }
}
