import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../globals.dart';
import '../model/user_details.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.room,
  });

  final types.Room room;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isAttachmentUploading = false;
  UserDetails user = UserDetails.getInstance();
  List<Color> colors = [
    Color(0xffff6767),
    Color(0xff67ff90),
    Color(0xff5f27cd),
    Color(0xff2ed573),
    Color(0xff00cec9),
    Color(0xfffdcb6e),
    Color(0xffe17055),
    Color(0xff6c5ce7),
    Color(0xffffeaa7),
    Color(0xff74b9ff),
    Color(0xffa29bfe),
    Color(0xff55efc4),
    Color(0xfff368e0),
    Color(0xffbadc58),
    Color(0xffe84393),
    Color(0xff81ecec),
    Color(0xfff19066),
    Color(0xffdfe6e9),
    Color(0xff1dd1a1),
    Color(0xff273c75),
    Color(0xff9b59b6),
    Color(0xffff9ff3),
    Color(0xffe74c3c),
    Color(0xff00b894),
    Color(0xffe67e22),
    Color(0xff487eb0),
    Color(0xfff368e0),
    Color(0xfff5cd79),
    Color(0xff55efc4),
    Color(0xffffeaa7),
    Color(0xff7bed9f),
    Color(0xffff6b6b),
    Color(0xff48dbfb),
    Color(0xff6ab04c),
    Color(0xff95afc0),
    Color(0xffd63031),
    Color(0xfffc427b),
    Color(0xff009432),
    Color(0xffe58e26),
    Color(0xff8c7ae6),
    Color(0xff006266),
    Color(0xffffbe76),
    Color(0xff1e90ff),
    Color(0xfffd79a8),
    Color(0xffb2bec3),
    Color(0xffe55039),
    Color(0xff3742fa),
    Color(0xff0652dd),
    Color(0xffc44569),
    Color(0xff44bd32),
    Color(0xff9980fa),
  ];

  @override
  void initState() {
    super.initState();
    widget.room.metadata?['seen'][user.firebaseId]['unseen'] = 0;
    FirebaseChatCore.instance.updateRoom(widget.room);
  }

  @override
  void dispose() {
    widget.room.metadata?['seen'][user.firebaseId]['unseen'] = 0;
    FirebaseChatCore.instance.updateRoom(widget.room);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            backgroundColor: primaryBackgroundColor,
            title: Text(widget.room.name ?? '')),
        body: StreamBuilder<types.Room>(
          initialData: widget.room,
          stream: FirebaseChatCore.instance.room(widget.room.id),
          builder: (context, snapshot) => StreamBuilder<List<types.Message>>(
              initialData: const [],
              stream: FirebaseChatCore.instance.messages(snapshot.data!),
              builder: (context, snapshot) {
                return Chat(
                  theme: _getTheme(),
                  showUserNames: true,
                  isAttachmentUploading: _isAttachmentUploading,
                  messages: snapshot.data ?? [],
                  onAttachmentPressed: _handleAttachmentPressed,
                  onMessageTap: _handleMessageTap,
                  onPreviewDataFetched: _handlePreviewDataFetched,
                  onSendPressed: _handleSendPressed,
                  scrollToUnreadOptions: ScrollToUnreadOptions(),
                  user: types.User(
                    id: FirebaseChatCore.instance.firebaseUser?.uid ?? '',
                  ),
                );
              }),
        ),
      );

  ChatTheme _getTheme() {
    return DefaultChatTheme(
        backgroundColor: Colors.black,
        primaryColor: _getColor(),
        secondaryColor: Colors.white24,
        inputTextColor: primaryTextColor,
        userAvatarNameColors: colors,
        userAvatarTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        userNameTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        receivedMessageBodyTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        receivedMessageLinkTitleTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        receivedMessageLinkDescriptionTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        dateDividerTextStyle: TextStyle(
          color: primaryTextColor,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ));
  }

  void _handleAttachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => SafeArea(
        child: SizedBox(
          height: 144,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleImageSelection();
                },
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Photo'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleFileSelection();
                },
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('File'),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      _setAttachmentUploading(true);
      final name = result.files.single.name;
      final filePath = result.files.single.path!;
      final file = File(filePath);

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialFile(
          mimeType: lookupMimeType(filePath),
          name: name,
          size: result.files.single.size,
          uri: uri,
        );

        FirebaseChatCore.instance.sendMessage(message, widget.room.id);
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      _setAttachmentUploading(true);
      final file = File(result.path);
      final size = file.lengthSync();
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final name = '${result.name}_${DateTime.now().millisecondsSinceEpoch}';

      try {
        final reference = FirebaseStorage.instance.ref(name);

        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialImage(
          height: image.height.toDouble(),
          name: name,
          size: size,
          uri: uri,
          width: image.width.toDouble(),
        );

        FirebaseChatCore.instance.sendMessage(
          message,
          widget.room.id,
        );
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleMessageTap(BuildContext _, types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        try {
          final updatedMessage = message.copyWith(isLoading: true);
          FirebaseChatCore.instance.updateMessage(
            updatedMessage,
            widget.room.id,
          );

          final client = http.Client();
          final request = await client.get(Uri.parse(message.uri));
          final bytes = request.bodyBytes;
          final documentsDir = (await getApplicationDocumentsDirectory()).path;
          localPath = '$documentsDir/${message.name}';

          if (!File(localPath).existsSync()) {
            final file = File(localPath);
            await file.writeAsBytes(bytes);
          }
        } finally {
          final updatedMessage = message.copyWith(isLoading: false);
          FirebaseChatCore.instance.updateMessage(
            updatedMessage,
            widget.room.id,
          );
        }
      }

      await OpenFilex.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final updatedMessage = message.copyWith(previewData: previewData);

    FirebaseChatCore.instance.updateMessage(updatedMessage, widget.room.id);
  }

  void _handleSendPressed(types.PartialText message) {
    sendToFirebase(
      message,
      widget.room.id,
    );
    dio.post("${apiUrl}/chat",
        data: {
          "message": message.text,
          "roomId": widget.room.id,
        },
        options: Options(
            contentType: "application/json",
            responseType: ResponseType.json,
            headers: {'Authorization': user.token, 'App-Version': appVersion}));
    if (widget.room.metadata?['seen'] != null) {
      var seenMap = widget.room.metadata?['seen'] as Map<dynamic, dynamic>;
      seenMap.forEach((key, value) {
        if (key != user.firebaseId) {
          value['unseen']++;
        }
      });
      FirebaseChatCore.instance.updateRoom(widget.room);
    }
  }

  Future<void> sendToFirebase(dynamic partialMessage, String roomId) async {
    var firebaseUser = FirebaseChatCore.instance.firebaseUser;
    if (firebaseUser == null) return;

    types.Message? message;

    if (partialMessage is types.PartialCustom) {
      message = types.CustomMessage.fromPartial(
        author: types.User(id: firebaseUser.uid),
        id: '',
        partialCustom: partialMessage,
      );
    } else if (partialMessage is types.PartialFile) {
      message = types.FileMessage.fromPartial(
        author: types.User(id: firebaseUser.uid),
        id: '',
        partialFile: partialMessage,
      );
    } else if (partialMessage is types.PartialImage) {
      message = types.ImageMessage.fromPartial(
        author: types.User(id: firebaseUser.uid),
        id: '',
        partialImage: partialMessage,
      );
    } else if (partialMessage is types.PartialText) {
      message = types.TextMessage.fromPartial(
        author: types.User(id: firebaseUser.uid),
        id: '',
        partialText: partialMessage,
      );
    }

    if (message != null) {
      final messageMap = message.toJson();
      messageMap.removeWhere((key, value) => key == 'author' || key == 'id');
      messageMap['authorId'] = firebaseUser!.uid;
      messageMap['createdAt'] = FieldValue.serverTimestamp();
      messageMap['updatedAt'] = FieldValue.serverTimestamp();

      await FirebaseChatCore.instance
          .getFirebaseFirestore()
          .collection(
              '${FirebaseChatCore.instance.config.roomsCollectionName}/$roomId/messages')
          .add(messageMap);

      await FirebaseChatCore.instance
          .getFirebaseFirestore()
          .collection(FirebaseChatCore.instance.config.roomsCollectionName)
          .doc(roomId)
          .update({
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  void _setAttachmentUploading(bool uploading) {
    setState(() {
      _isAttachmentUploading = uploading;
    });
  }

  Color _getColor() {
    String digitsOnly = widget.room.id.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length > 10) digitsOnly = digitsOnly.substring(0, 10);
    Random random = Random(int.parse(digitsOnly));
    int colorId = random.nextInt(colors.length);
    return colors[colorId];
  }
}
