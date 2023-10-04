import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:rks/model/user_details.dart';

import '../globals.dart';
import '../model/user.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({super.key});

  @override
  GroupState createState() => GroupState();
}

//todo będzie tak że pasek będzie podzielony, na górze scroll z listą ludzi w grupie, potem zębatka ustawienia grupy, potem lista dostępnych grup
//to jest pobranie listy ludzi do prawego wysuwanego paska
class GroupState extends State<GroupScreen> {
  UserDetails user = UserDetails.getInstance();
  late List<User> users;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/addUserToGroup',
              arguments: [users, this]);
        },
      ),
      body: FutureBuilder<List<User>>(
        future: getUsersForGroup(),
        builder: (context, data) {
          if (data.hasData) {
            return Column(
              children: [
                Expanded(
                  flex: 3,
                  child: ListView.separated(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                            "${users[index].firstname} ${users[index].lastname}",
                            style: TextStyle(color: users[index].getColor())),
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage('${userImageUrl}${users[index].id}'),
                          radius: 22,
                        ),
                        trailing: Visibility(
                          visible: user.isAdmin(),
                          child: InkWell(
                            child: Icon(
                              Icons.delete,
                              color: primaryTextColor,
                            ),
                            onTap: () {
                              deleteUserFromGroup(users[index]);
                            },
                          ),
                        ),
                        onTap: () {
                          user.role.index < users[index].role.index
                              ? showDialog(
                                  context: context,
                                  builder: (BuildContext dialogContext) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                          dialogBackgroundColor:
                                              primaryBackgroundColor),
                                      child: AlertDialog(
                                        title: Text(
                                            "${users[index].firstname} ${users[index].lastname}",
                                            style: TextStyle(
                                                color:
                                                    users[index].getColor())),
                                        content: Container(
                                          height: 150.0,
                                          width: 100.0,
                                          child: Column(
                                            children: [
                                              Divider(
                                                thickness: 1.5,
                                                color: primaryTextColor,
                                              ),
                                              createRolesList(users[index]),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : null;
                        },
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const Divider(
                        height: 20.0,
                        color: Color(0xE3FFFFFF),
                        thickness: 0.1,
                        indent: 15,
                        endIndent: 15,
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (data.hasError) {
            return Text(data.error.toString());
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<List<User>> getUsersForGroup() async {
    String url = '${apiUrl}/group/${user.selectedGroup.id}/users';
    try {
      await EasyLoading.show(
        status: 'Pobieranie listy członków',
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
        for (var g in response.data) {
          User user = User.fromJson(g);
          users.add(user);
        }
      }
      this.users = users;
      return users;
    } catch (e) {}
    return [];
  }

  void deleteUserFromGroup(User userToDelete) async {
    String url =
        '${apiUrl}/group/${user.selectedGroup.id}/user/${userToDelete.id}';
    try {
      var response = await dio.delete(url,
          options: Options(
              contentType: "application/json",
              responseType: ResponseType.json,
              headers: {
                'Authorization': user.token,
                'App-Version': appVersion
              }));

      var chatRoom = await getChatRoom();
      if (chatRoom != null) {
        chatRoom.users
            .removeWhere((user) => user.id == userToDelete.firebaseId);

        Map<String, dynamic> seen = chatRoom.metadata!['seen'];
        seen.removeWhere((k, v) => k == userToDelete.firebaseId);

        FirebaseChatCore.instance.updateRoom(chatRoom);
        await Dio().delete(
            '${apiUrl}/chat/${chatRoom.id}/removeUser/${userToDelete.id}',
            options: Options(
                contentType: "application/json",
                responseType: ResponseType.json,
                headers: {
                  'Authorization': user.token,
                }));
      }

      if (response.statusCode == 200) {
        setState(() {
          users.remove(userToDelete);
        });
      }
    } catch (e) {
      EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nie możesz tego zrobić')));
    }
  }

  void refreshUsers() {
    setState(() {});
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
      if (response.statusCode == 200) {
        users.clear();
        for (var g in response.data) {
          User user = User.fromJson(g);
          users.add(user);
        }
      }
      setState(() {
        Navigator.of(context).pop();
      });
      await EasyLoading.dismiss();
    } catch (e) {}
  }

  Future<types.Room?> getChatRoom() async {
    final fu = FirebaseChatCore.instance.firebaseUser;

    if (fu == null) return null;

    var groupStream = FirebaseChatCore.instance
        .getFirebaseFirestore()
        .collection(FirebaseChatCore.instance.config.roomsCollectionName)
        .where('metadata.groupDatabaseId', isEqualTo: user.selectedGroup.id);

    var groupList = await groupStream
        .snapshots()
        .asyncMap(
          (query) => processRoomsQuery(
            fu,
            FirebaseChatCore.instance.getFirebaseFirestore(),
            query,
            FirebaseChatCore.instance.config.usersCollectionName,
          ),
        )
        .first;
    if (groupList.isEmpty) return null;
    return groupList.first;
  }
}
