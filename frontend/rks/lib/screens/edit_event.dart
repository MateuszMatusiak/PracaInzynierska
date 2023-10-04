import 'dart:io';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rks/model/map_entry.dart';
import 'package:rks/model/user_details.dart';

import '../globals.dart';
import '../model/event.dart';
import '../model/user.dart';

class EditEventScreen extends StatefulWidget {
  int eventId;
  DateTime? _startDate;
  DateTime? _endDate;

  factory EditEventScreen.add(DateTime startDate, DateTime? endDate) {
    return EditEventScreen._internal(0, startDate, endDate);
  }

  EditEventScreen._internal(this.eventId, this._startDate, this._endDate);

  EditEventScreen(this.eventId, {super.key});

  @override
  EditEventState createState() => EditEventState(eventId, _startDate, _endDate);
}

class EditEventState extends State<EditEventScreen> {
  final UserDetails _user = UserDetails.getInstance();
  late final int _eventId;
  final ImagePicker _imagePicker = ImagePicker();
  String filePath = "";

  DateTime n = DateTime.now();
  String _name = "";
  String _startDateStr = "";
  String _endDateStr = "";
  String _localization = "";
  String _description = "";
  DateTime _start = DateTime.now();
  DateTime _end = DateTime.now();
  bool _addToMap = false;
  late Future<Event> _event;
  late List<User> _users = List.empty();

  late Future<List<MapPoint>> _entries;
  final _descriptionController = TextEditingController();

  EditEventState(int eventId, DateTime? startDate, DateTime? endDate) {
    _eventId = eventId;
    _start = startDate ?? DateTime.now();
    _startDateStr = startDate == null ? "" : startDate.toString();
    _end = endDate ?? DateTime.now();
    _endDateStr = endDate == null ? "" : endDate.toString();
  }

  @override
  void initState() {
    super.initState();
    _event = getEvent();
    _entries = getAvailablePlaces();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Event>(
        future: _event,
        builder: (context, data) {
          if (data.hasData) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                  title: _eventId > 0
                      ? const Text('Edytuj wydarzenie')
                      : const Text('Dodaj wydarzenie')),
              body: Container(
                alignment: Alignment.topCenter,
                margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 5),
                child: Column(children: <Widget>[
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: TextFormField(
                          initialValue: _name,
                          onChanged: (v) => {
                                _name = v,
                              },
                          style: TextStyle(color: primaryTextColor),
                          decoration: InputDecoration(
                            labelText: 'nazwa',
                            labelStyle: TextStyle(color: primaryTextColor),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryTextColor),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryTextColor),
                            ),
                          ))),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 1, 0, 0),
                      child: TextField(
                          maxLines: 3,
                          controller: _descriptionController,
                          onChanged: (v) => {
                                _description = v,
                              },
                          style: TextStyle(color: primaryTextColor),
                          decoration: InputDecoration(
                            labelText: 'opis',
                            labelStyle: TextStyle(color: primaryTextColor),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryTextColor),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryTextColor),
                            ),
                          ))),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                      child: DateTimePicker(
                          dateMask: 'd MM yyyy',
                          type: DateTimePickerType.dateTimeSeparate,
                          firstDate: DateTime(n.year - 10, 1, 1, 0, 0, 0, 0, 0),
                          lastDate: DateTime(n.year + 10, 1, 1, 0, 0, 0, 0, 0),
                          initialValue: _startDateStr,
                          dateLabelText: 'Date',
                          timeLabelText: "Hour",
                          onChanged: (v) => {
                                _startDateStr = v,
                                _start = DateTime.parse(_startDateStr),
                              },
                          style: TextStyle(color: primaryTextColor),
                          decoration: InputDecoration(
                            labelText: 'start wydarzenia',
                            labelStyle: TextStyle(color: primaryTextColor),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryTextColor),
                            ),
                          ))),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                      child: DateTimePicker(
                          dateMask: 'd MM yyyy',
                          type: DateTimePickerType.dateTimeSeparate,
                          firstDate: DateTime(n.year - 10, 1, 1, 0, 0, 0, 0, 0),
                          lastDate:
                              DateTime(_start.year + 10, 1, 1, 0, 0, 0, 0, 0),
                          dateLabelText: 'Date',
                          timeLabelText: "Hour",
                          initialValue: _endDateStr,
                          onChanged: (v) => {
                                _endDateStr = v,
                                _end = DateTime.parse(_endDateStr),
                              },
                          style: TextStyle(color: primaryTextColor),
                          decoration: InputDecoration(
                            labelText: 'koniec wydarzenia',
                            labelStyle: TextStyle(color: primaryTextColor),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: primaryTextColor),
                            ),
                          ))),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Column(
                      children: [
                        filePath.isEmpty
                            ? MaterialButton(
                                height: 40,
                                minWidth: double.infinity,
                                onPressed: () {
                                  pickEventImage();
                                },
                                color: primaryColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                child: Text('Dodaj zdjęcie',
                                    style: TextStyle(color: primaryTextColor)),
                              )
                            : IconButton(
                                iconSize: 200,
                                padding: const EdgeInsets.only(),
                                icon: Image.file(File(filePath),
                                    width: 300.0,
                                    height: 300.0,
                                    fit: BoxFit.fitWidth),
                                onPressed: () => pickEventImage(),
                              ),
                        Visibility(
                          visible: filePath.isNotEmpty,
                          child: MaterialButton(
                            height: 40,
                            minWidth: double.infinity,
                            onPressed: () {
                              setState(() {
                                filePath = "";
                              });
                            },
                            color: primaryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            child: Text('Usuń zdjęcie',
                                style: TextStyle(color: primaryTextColor)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Row(
                        children: [
                          Text(
                            'Dodaj do map',
                            style: TextStyle(color: primaryTextColor),
                          ),
                          Switch(
                            activeColor: primaryTextColor,
                            value: _addToMap,
                            onChanged: (value) {
                              setState(() => _addToMap = value);
                            },
                          ),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(10, 8, 0, 0),
                              child: Visibility(
                                visible: _addToMap,
                                child: FutureBuilder<List<MapPoint>>(
                                  future: _entries,
                                  builder: (context, data) {
                                    if (data.hasData) {
                                      return DropdownButton(
                                        dropdownColor: primaryBackgroundColor,
                                        items: data.data!
                                            .map<DropdownMenuItem<String>>(
                                                (MapPoint value) {
                                          return DropdownMenuItem<String>(
                                            value: value.id.toString(),
                                            child: SizedBox(
                                                width: 170,
                                                child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 0, 0, 7),
                                                    child: Text(
                                                      value.name.toTitleCase(),
                                                      style: TextStyle(
                                                          overflow:
                                                              TextOverflow.fade,
                                                          color:
                                                              primaryTextColor),
                                                    ))),
                                          );
                                        }).toList(),
                                        value: _localization.isNotEmpty &&
                                                _localization != '0'
                                            ? _localization
                                            : null,
                                        onChanged: (value) => setState(() {
                                          _localization = value!;
                                        }),
                                      );
                                    } else {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                  },
                                ),
                              )),
                        ],
                      )),
                  MaterialButton(
                    height: 40,
                    minWidth: double.infinity,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/addUserToEvent',
                          arguments: [_eventId, _users]);
                    },
                    color: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    child: Text('Lista osób',
                        style: TextStyle(color: primaryTextColor)),
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                      child: MaterialButton(
                        height: 40,
                        minWidth: double.infinity,
                        onPressed: () {
                          onConfirm();
                        },
                        color: primaryColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        child: _eventId <= 0
                            ? Text('Dodaj wydarzenie',
                                style: TextStyle(color: primaryTextColor))
                            : Text('Aktualizuj wydarzenie',
                                style: TextStyle(color: primaryTextColor)),
                      )),
                ]),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }

  Future onConfirm() async {
    if (_name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nazwa nie może być pusta')));
      return;
    }
    if (_startDateStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data startu nie może być pusta')));
      return;
    }
    if (_endDateStr.isNotEmpty && _end.isBefore(_start)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Data końcowa nie może przed początkową')));
      return;
    }
    if (!_addToMap) {
      _localization = "0";
    }

    if (_endDateStr.length == 10) {
      _endDateStr += " 00:00";
    }

    List<int> usersIds = List.empty(growable: true);
    for (var element in _users) {
      usersIds.add(element.id);
    }
    _startDateStr = _startDateStr.substring(0, 16);
    String? e = _endDateStr.isNotEmpty ? _endDateStr.substring(0, 16) : null;
    Map<String, dynamic> jsonData = {
      'name': _name,
      'description': _description,
      'startDate': _startDateStr,
      'endDate': e,
      'localizationId': _localization,
      'usersIds': usersIds,
    };
    if (_eventId <= 0) {
      String url = "${apiUrl}/event";
      try {
        var response = await dio.post(url,
            data: jsonData,
            options: Options(
                contentType: "application/json",
                responseType: ResponseType.json,
                headers: {
                  'Authorization': _user.token,
                  'App-Version': appVersion
                }));
        if (response.statusCode == 200) {
          int e = response.data['id'];
          widget.eventId = e;
          uploadImages();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dodawanie nie powiodło się')));
      }
    } else {
      String url = "${apiUrl}/event/$_eventId";
      uploadImages();
      try {
        await dio.put(url,
            data: jsonData,
            options: Options(
                contentType: "application/json",
                responseType: ResponseType.json,
                headers: {
                  'Authorization': _user.token,
                  'App-Version': appVersion
                }));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dodawanie nie powiodło się')));
      }
    }
    Navigator.pop(context);
  }

  Future<List<MapPoint>> getAvailablePlaces() async {
    String url = '${apiUrl}/map';
    try {
      var response = await dio.get(url,
          options: Options(
              contentType: "application/json",
              responseType: ResponseType.json,
              headers: {
                'Authorization': _user.token,
                'App-Version': appVersion
              }));
      List<MapPoint> entries = [];
      if (response.statusCode == 200) {
        for (var g in response.data) {
          MapPoint entry = MapPoint.fromJsonBasic(g);
          entries.add(entry);
        }
      }
      return entries;
    } catch (e) {}
    return [];
  }

  Future<Event> getEvent() async {
    if (_eventId <= 0) {
      await getUsers();
      return Event.empty();
    }
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
        Event e = Event.fromJson(response.data);
        _name = e.name;
        _description = e.description;
        _descriptionController.text = _description;
        _startDateStr = e.startDate;
        _start = DateTime.parse(_startDateStr);
        _endDateStr = e.endDate;
        if (_endDateStr.isNotEmpty) {
          _end = DateTime.parse(_endDateStr);
        }
        _localization = e.localization.id.toString();
        _addToMap = !e.localization.isEmpty();
        _users = e.users;
        return e;
      }
    } catch (e) {}
    await getUsers();
    return Event.empty();
  }

  Future<List<User>> getUsers() async {
    String url = '${apiUrl}/group/${_user.selectedGroup.id}/users';
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
        List<User> res =
            List<User>.from(response.data.map((model) => User.fromJson(model)));
        _users = res;
        return res;
      }
    } catch (e) {}
    return List.empty();
  }

  void pickEventImage() async {
    var selectedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (selectedImage != null) {
        filePath = selectedImage.path;
      }
    });
  }

  void uploadImages() async {
    if (filePath.isEmpty) return;
    if (widget.eventId == null) return;
    String url = '${apiUrl}/image/event/${widget.eventId}';
    var formData = FormData();
    formData.files
        .add(MapEntry("image", await MultipartFile.fromFile(filePath)));
    try {
      await EasyLoading.show();
      await dio.post(url,
          data: formData,
          options: Options(contentType: "multipart/form-data", headers: {
            'Authorization': _user.token,
            'App-Version': appVersion
          }));
      await EasyLoading.dismiss();
    } catch (e) {}
  }
}
