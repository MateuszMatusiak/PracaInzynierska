import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:rks/globals.dart';
import 'package:rxdart/rxdart.dart';

import '../model/user_details.dart';
import 'chat.dart';
import 'new_chat.dart';

class ChatRooms extends StatefulWidget {
  const ChatRooms({Key? key}) : super(key: key);

  @override
  State<ChatRooms> createState() => _ChatRoomsState();
}

class _ChatRoomsState extends State<ChatRooms> {
  final UserDetails _user = UserDetails.getInstance();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => NewChatPage(),
            ),
          );
        },
      ),
      body: StreamBuilder<List<types.Room>>(
        stream: getSortedRooms(),
        initialData: const [],
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(
                bottom: 200,
              ),
              child: Text(
                'No rooms',
                style: TextStyle(color: primaryTextColor),
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final room = snapshot.data![index];
              if (index != 0 &&
                  room.metadata != null &&
                  room.metadata!['groupDatabaseId'] != null &&
                  room.metadata!['groupDatabaseId'] == _user.selectedGroup.id) {
                return Container();
              } else {
                return createChatRoomTile(context, room);
              }
            },
          );
        },
      ),
    );
  }

  GestureDetector createChatRoomTile(BuildContext context, types.Room room) {
    int unseenCount = 0;
    if (room.metadata == null ||
        room.metadata?['seen'] == null ||
        room.metadata?['seen'][_user.firebaseId] == null ||
        room.metadata?['seen'][_user.firebaseId]['unseen'] == null) {
      unseenCount = 0;
    } else {
      unseenCount = room.metadata?['seen'][_user.firebaseId]['unseen'];
    }
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              room: room,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            _buildAvatar(room),
            Text(
              room.name ?? '',
              style: TextStyle(
                color: primaryTextColor,
                fontWeight:
                    unseenCount == 0 ? FontWeight.w400 : FontWeight.w900,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Container(
              child: unseenCount != 0
                  ? Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.red,
                            width: 5.0,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Text(
                          "$unseenCount",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : Center(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(types.Room room) {
    var color = getAvatarColor(room.id);

    if (room.type == types.RoomType.direct) {}

    final hasImage = room.imageUrl != null;
    final name = room.name ?? '';

    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: CircleAvatar(
        backgroundColor: hasImage ? Colors.transparent : color,
        backgroundImage: hasImage ? NetworkImage(room.imageUrl!) : null,
        radius: 24,
        child: !hasImage
            ? Text(
                name.isEmpty ? '' : name[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              )
            : null,
      ),
    );
  }

  Stream<List<types.Room>> getSortedRooms() {
    final fu = FirebaseChatCore.instance.firebaseUser;

    if (fu == null) return const Stream.empty();

    var groupStream = FirebaseChatCore.instance
        .getFirebaseFirestore()
        .collection(FirebaseChatCore.instance.config.roomsCollectionName)
        .where('metadata.groupDatabaseId', isEqualTo: _user.selectedGroup.id);

    var groupRoom = groupStream.snapshots().asyncMap(
          (query) => processRoomsQuery(
            fu,
            FirebaseChatCore.instance.getFirebaseFirestore(),
            query,
            FirebaseChatCore.instance.config.usersCollectionName,
          ),
        );

    var remainingStream = FirebaseChatCore.instance
        .getFirebaseFirestore()
        .collection(FirebaseChatCore.instance.config.roomsCollectionName)
        .where('userIds', arrayContains: fu.uid)
        .orderBy('lastMessageTimestamp', descending: true);

    var remainingRooms = remainingStream.snapshots().asyncMap(
          (query) => processRoomsQuery(
            fu,
            FirebaseChatCore.instance.getFirebaseFirestore(),
            query,
            FirebaseChatCore.instance.config.usersCollectionName,
          ),
        );

    return Rx.combineLatest2(groupRoom, remainingRooms,
        (specificRoom, remainingRooms) {
      if (specificRoom != null && specificRoom.isNotEmpty) {
        return [specificRoom.first, ...remainingRooms];
      } else {
        return remainingRooms;
      }
    });
  }
}
