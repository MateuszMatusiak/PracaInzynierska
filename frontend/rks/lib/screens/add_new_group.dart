import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';

import '../globals.dart';
import '../model/user_details.dart';

class AddNewGroupScreen extends StatefulWidget {
  const AddNewGroupScreen({super.key});

  @override
  AddNewGroupState createState() => AddNewGroupState();
}

class AddNewGroupState extends State<AddNewGroupScreen> {
  final String url = "${apiUrl}/group";
  UserDetails user = UserDetails.getInstance();

  String groupName = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          alignment: Alignment.topCenter,
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.all(15),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                    child: TextField(
                        onChanged: (v) => {groupName = v},
                        style: TextStyle(color: primaryTextColor),
                        decoration: InputDecoration(
                          labelText: 'Nazwa grupy',
                          labelStyle: TextStyle(color: primaryTextColor),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryTextColor),
                          ),
                        ))),
                MaterialButton(
                  height: 40,
                  minWidth: double.infinity,
                  onPressed: () {
                    onAddGroup().then((v) async => {
                          if (v > 0)
                            {
                              await user.setSelectedGroup(v),
                              navigatorKey.currentState
                                  ?.popUntil(ModalRoute.withName('/')),
                              Navigator.pushNamed(context, "/menu"),
                            }
                          else
                            {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Dodawanie nie powiodło się')))
                            }
                        });
                  },
                  color: primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  child: Text('Utwórz grupę',
                      style: TextStyle(color: primaryTextColor)),
                ),
              ])),
    );
  }

  Future<int> onAddGroup() async {
    if (groupName.isNotEmpty) {
      var jsonData = {'name': groupName};
      try {
        await EasyLoading.show(
          status: 'Dodawanie grupy',
          maskType: EasyLoadingMaskType.black,
        );
        var response = await dio.post("$url",
            data: jsonData,
            options: Options(
                contentType: "application/json",
                responseType: ResponseType.json,
                headers: {
                  'Authorization': user.token,
                  'App-Version': appVersion
                }));
        await EasyLoading.dismiss();
        int groupId = response.data['id'];

        var seenMap = {};
        seenMap.putIfAbsent(
            user.firebaseId, () => {'lastSeen': '', 'unseen': 0});
       var room= await FirebaseChatCore.instance.createGroupRoom(
            name: groupName,
            users: [],
            metadata: {'groupDatabaseId': groupId, 'seen': seenMap});
        await createChatRoomInDb(groupName, room.id, []);

        return groupId;
      } catch (e) {
        return -2;
      }
    }
    return -1;
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
