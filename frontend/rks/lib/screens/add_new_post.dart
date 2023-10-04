import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rks/globals.dart';
import 'package:rks/model/event.dart';
import 'package:rks/model/user_details.dart';

import 'message.dart';

class AddNewPost extends StatefulWidget {
  const AddNewPost({super.key});

  @override
  AddNewPostState createState() => AddNewPostState();
}

class AddNewPostState extends State<AddNewPost> {
  final String url = "${apiUrl}/post";
  UserDetails user = UserDetails.getInstance();

  String postData = "";
  var selectedEvent = 'Brak';
  var eventList = [];
  var eventName = ['Brak'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Nowy post')),
      body: Container(
          alignment: Alignment.topCenter,
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.all(15),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: TextField(
                        style: TextStyle(fontSize: 22, color: primaryTextColor),
                        maxLines: 20,
                        minLines: 10,
                        onChanged: (v) => {
                              postData = v,
                            },
                        decoration: InputDecoration(
                          labelText: 'Treść posta',
                          labelStyle: TextStyle(color: primaryTextColor),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryTextColor),
                          ),
                        ))),
                Text("Wybierz połączone wydarzenie:",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: DropdownButton(
                    isExpanded: true,
                    dropdownColor: primaryBackgroundColor,
                    value: selectedEvent,
                    icon: Icon(Icons.keyboard_arrow_down,
                        color: primaryTextColor),
                    items: eventName.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text(
                          items,
                          style: TextStyle(color: primaryTextColor),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      onChangedEvent(newValue);
                    },
                  ),
                ),
                MaterialButton(
                  height: 40,
                  minWidth: double.infinity,
                  onPressed: () {
                    onAddPost().then((v) => {
                          if (v == 200)
                            {
                              Navigator.of(context).pop(true),
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
                  child: Text('DODAJ NOWY POST',
                      style: TextStyle(color: primaryTextColor)),
                ),
              ])),
    );
  }

  @override
  void initState() {
    super.initState();
    getEvents();
  }

  getEvents() async {
    String url = '${apiUrl}/events';
    try {
      var response = await dio.get(url,
          options: Options(
              contentType: "application/json",
              responseType: ResponseType.json,
              headers: {
                'Authorization': user.token,
                'App-Version': appVersion
              }));
      List<Event> entries = [];
      if (response.statusCode == 200) {
        for (var g in response.data) {
          Event entry = Event.fromJson(g);
          entries.add(entry);
          eventName.insert(0, entry.name);
          eventList.insert(0, entry);
        }
      }
      onChangedEvent("Brak");
    } catch (e) {
    }
  }

  Future<int> onAddPost() async {
    if (postData.isNotEmpty) {
      var selectedEventId = -1;
      for (Event event in eventList) {
        if (event.name == selectedEvent) {
          selectedEventId = event.id;
        }
      }
      Map<String, String> jsonData = {
        "content": postData,
        "eventId": selectedEventId.toString()
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
        if (response.statusCode == 200 || response.statusCode == 201) {
          return 200;
        }
      } catch (e) {
        return -2;
      }
    }
    return -1;
  }

  void onChangedEvent(String? newValue) {
    setState(() {
      selectedEvent = newValue!;
    });
  }
}
