import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

import '../globals.dart';
import '../model/user_details.dart';
import 'chat.dart';

class NewChatPage extends StatefulWidget {
  const NewChatPage({Key? key}) : super(key: key);

  @override
  State<NewChatPage> createState() => _NewChatPageState();
}

class _NewChatPageState extends State<NewChatPage> {
  Map<types.User, bool> checkedUsers = {};
  UserDetails user = UserDetails.getInstance();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          title: const Text('Users'),
          actions: [
            IconButton(
              onPressed: onAdd,
              icon: Icon(
                Icons.add,
                color: primaryTextColor,
              ),
            )
          ],
        ),
        body: StreamBuilder<List<types.User>>(
          stream: FirebaseChatCore.instance.users(),
          initialData: const [],
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(
                  bottom: 200,
                ),
                child: const Text('No users'),
              );
            }
            for (types.User u in snapshot.data!) {
              checkedUsers.putIfAbsent(u, () => false);
            }
            return ListView.separated(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final user = snapshot.data![index];

                return CheckboxListTile(
                  title: Text(
                    getUserName(user),
                    style: TextStyle(color: primaryTextColor),
                  ),
                  value: checkedUsers[user],
                  onChanged: (bool? value) {
                    setState(() {
                      checkedUsers[user] = value!;
                    });
                  },
                  secondary: _buildAvatar(user),
                  side: MaterialStateBorderSide.resolveWith(
                    (Set<MaterialState> states) {
                      return BorderSide(color: primaryTextColor);
                    },
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  indent: 11.0,
                  endIndent: 11.0,
                  height: 1.0,
                  color: primaryTextColor,
                );
              },
            );
          },
        ),
      );

  Widget _buildAvatar(types.User user) {
    final color = getAvatarColor(user.id);
    final hasImage = user.imageUrl != null;
    final name = getUserName(user);

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: hasImage ? Colors.transparent : color,
        backgroundImage: hasImage ? NetworkImage(user.imageUrl!) : null,
        radius: 20,
        child: !hasImage
            ? Text(
                name.isEmpty ? '' : name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
    );
  }

  List<types.User> getUsersToAdd() {
    List<types.User> res = [];
    checkedUsers.forEach((key, value) {
      if (value == true) {
        res.add(key);
      }
    });
    return res;
  }

  void onAdd() async {
    List<types.User> usersToAdd = getUsersToAdd();
    var seenMap = {};
    for (var userToAdd in usersToAdd) {
      seenMap.putIfAbsent(userToAdd.id, () => {'lastSeen': '', 'unseen': 0});
    }
    seenMap.putIfAbsent(user.firebaseId, () => {'lastSeen': '', 'unseen': 0});

    if (usersToAdd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lista osób nie może być pusta')));
    } else if (usersToAdd.length == 1) {
      final navigator = Navigator.of(context);
      final room = await FirebaseChatCore.instance
          .createRoom(usersToAdd[0], metadata: {'seen': seenMap});
      await createChatRoomInDb(
          "", room.id, [usersToAdd[0].metadata!['databaseId']]);
      navigator.pop();
      await navigator.push(
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            room: room,
          ),
        ),
      );
    } else {
      String name = '';
      List<int> ids = List<int>.empty(growable: true);
      for (var element in usersToAdd) {
        ids.add(usersToAdd[0].metadata!['databaseId']);
        name += element.firstName ?? '';
        name += ', ';
      }

      name = name.substring(0, name.length - 2);
      final navigator = Navigator.of(context);
      final room = await FirebaseChatCore.instance.createGroupRoom(
          users: usersToAdd, name: name, metadata: {'seen': seenMap});
      await createChatRoomInDb(name, room.id, ids);

      navigator.pop();
      await navigator.push(
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            room: room,
          ),
        ),
      );
    }
  }

  Future<void> createChatRoomInDb(
      String name, String firebaseId, List<int> userIds) async {
    String url = '${apiUrl}/chat/createChatRoom';

    var jsonData = {
      'firebaseId': firebaseId.trim(),
      'name': name.trim(),
      'usersIds': userIds,
    };
    try {
      var response = await dio.post(url,
          data: jsonData,
          options: Options(
              contentType: "application/json",
              responseType: ResponseType.json,
              headers: {
                'Authorization': user.token,
                'App-Version': appVersion
              }));
    } catch (e) {}
  }
}
