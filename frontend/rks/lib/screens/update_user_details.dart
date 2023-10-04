import 'package:date_time_picker/date_time_picker.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rks/model/user_details.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:shared_preferences/shared_preferences.dart';

import '../globals.dart';

class UpdateUserDetailsScreen extends StatefulWidget {
  final UserDetails _user;

  const UpdateUserDetailsScreen(this._user, {super.key});

  @override
  UpdateUserDetailsState createState() => UpdateUserDetailsState(_user);
}

class UpdateUserDetailsState extends State<UpdateUserDetailsScreen> {
  final UserDetails _user;
  final ImagePicker _imagePicker = ImagePicker();
  String imageUrl = '${userImageUrl}0';
  late NetworkImage avatar;

  UpdateUserDetailsState(this._user);

  final String url = "${apiUrl}/user";

  String _firstname = "";
  String _lastname = "";
  String _phone = "";
  String? _nick;
  String _birthdate = "";

  @override
  void initState() {
    super.initState();
    imageUrl = '${userImageUrl}${_user.id}';
    avatar = NetworkImage(imageUrl);
    _birthdate = _user.birthdate;
    _firstname = _user.firstname;
    _lastname = _user.lastname;
    _nick = _user.nick;
    _phone = _user.phone;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
          child: Container(
              alignment: Alignment.topCenter,
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(15),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                        child: TextFormField(
                            initialValue: _firstname,
                            onChanged: (v) => {
                                  _firstname = v,
                                },
                            style: TextStyle(color: primaryTextColor),
                            decoration: InputDecoration(
                              labelText: 'Imię*',
                              labelStyle: TextStyle(color: primaryTextColor),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primaryTextColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primaryTextColor),
                              ),
                            ))),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                        child: TextFormField(
                            initialValue: _lastname,
                            onChanged: (v) => {
                                  _lastname = v,
                                },
                            style: TextStyle(color: primaryTextColor),
                            decoration: InputDecoration(
                              labelText: 'Nazwisko*',
                              labelStyle: TextStyle(color: primaryTextColor),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primaryTextColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primaryTextColor),
                              ),
                            ))),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                        child: TextFormField(
                            initialValue: _phone,
                            onChanged: (v) => {
                                  _phone = v,
                                },
                            style: TextStyle(color: primaryTextColor),
                            decoration: InputDecoration(
                              labelText: 'nr telefonu*',
                              labelStyle: TextStyle(color: primaryTextColor),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primaryTextColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primaryTextColor),
                              ),
                            ))),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                        child: TextFormField(
                            initialValue: _nick,
                            onChanged: (v) => {
                                  _nick = v,
                                },
                            style: TextStyle(color: primaryTextColor),
                            decoration: InputDecoration(
                              labelText: 'nickname',
                              labelStyle: TextStyle(color: primaryTextColor),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primaryTextColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primaryTextColor),
                              ),
                            ))),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                        child: DateTimePicker(
                            dateMask: 'yyyy-MM-dd',
                            firstDate: DateTime(1950),
                            lastDate: DateTime.now(),
                            initialValue: _birthdate,
                            dateLabelText: 'Date',
                            onChanged: (v) => {
                                  _birthdate = v,
                                },
                            style: TextStyle(color: primaryTextColor),
                            decoration: InputDecoration(
                              labelText: 'Data urodzenia*',
                              labelStyle: TextStyle(color: primaryTextColor),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primaryTextColor),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: primaryTextColor),
                              ),
                            ))),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: MaterialButton(
                            onPressed: () async {
                              pickImageFromGallery();
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(360)),
                            child: CircleAvatar(
                              backgroundImage: avatar,
                              radius: 75,
                            ))),
                    MaterialButton(
                      height: 39,
                      minWidth: double.infinity,
                      onPressed: () {
                        if (_birthdate.isNotEmpty &&
                            _firstname.isNotEmpty &&
                            _lastname.isNotEmpty &&
                            _phone.isNotEmpty) {
                          onConfirmData().then((v) async => {
                                await EasyLoading.dismiss(),
                                if (v == 200)
                                  {
                                    Navigator.popUntil(
                                        context, ModalRoute.withName('/')),
                                    Navigator.of(context).pushNamed('/menu'),
                                  }
                                else
                                  {
                                    await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                        content: Text(
                                          'Aktualizacja nie powiodła się',
                                        ),
                                        title: const Text(
                                            'Aktualizacja danych użytkownika'),
                                      ),
                                    ),
                                  }
                              });
                        } else {}
                      },
                      color: primaryColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      child: Text('Zapisz dane',
                          style: TextStyle(color: primaryTextColor)),
                    ),
                    MaterialButton(
                      height: 39,
                      minWidth: double.infinity,
                      onPressed: () {
                        onLogout().then((value) => {
                              Navigator.popUntil(
                                  context, ModalRoute.withName('/')),
                              Navigator.of(context).pushNamed('/'),
                            });
                      },
                      color: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      child: Text('Wyloguj się',
                          style: TextStyle(color: primaryTextColor)),
                    ),
                  ]))),
    );
  }

  Future<int> onConfirmData() async {
    Map<String, String> jsonData = {
      "birthdate": _birthdate,
      "firstName": _firstname,
      "lastName": _lastname,
      "nickname": _nick ?? "",
      "phoneNumber": _phone,
      "firebaseId": _user.firebaseId.trim(),
    };

    _user.birthdate = _birthdate;
    _user.firstname = _firstname;
    _user.lastname = _lastname;
    _user.nick = _nick ?? "";
    _user.phone = _phone;

    try {
      await EasyLoading.show(
        status: 'Aktualizacja danych użytkownika',
        maskType: EasyLoadingMaskType.black,
      );

      var response = await dio.put(url,
          data: jsonData,
          options: Options(
              contentType: "application/json",
              responseType: ResponseType.json,
              headers: {
                'Authorization': _user.token,
                'App-Version': appVersion
              }));
      await FirebaseChatCore.instance.createUserInFirestore(
        types.User(
          firstName: _firstname.trim(),
          id: _user.firebaseId.trim(),
          imageUrl: '${userImageUrl}${_user.id}',
          lastName: _lastname.trim(),
          metadata: {'databaseId': _user.id},
        ),
      );
      return 200;
    } catch (e) {
      return -2;
    }
    return -1;
  }

  void pickImageFromGallery() async {
    var selectedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (selectedImage != null) uploadImages(selectedImage.path);
  }

  void uploadImages(String filePath) async {
    String url = '${apiUrl}/image/profile';
    var formData = FormData();
    formData.files
        .add(MapEntry("image", await MultipartFile.fromFile(filePath)));

    try {
      await EasyLoading.show();
      var response = await dio.post(url,
          data: formData,
          options: Options(contentType: "multipart/form-data", headers: {
            'Authorization': _user.token,
            'App-Version': appVersion
          }));
      await EasyLoading.dismiss();
      if (response.statusCode == 200) {
        setState(() {
          avatar.evict();
        });
      }
    } catch (e) {}
  }

  Future onLogout() async {
    _user.clean();
    FirebaseAuth.instance.signOut();
    var prefs = await SharedPreferences.getInstance();
    await prefs.remove('login');
    await prefs.remove('password');
  }
}
