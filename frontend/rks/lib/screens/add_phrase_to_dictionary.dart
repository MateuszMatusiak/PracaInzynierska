import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rks/model/user_details.dart';

import '../globals.dart';
import '../model/dictionary_entries.dart';
import 'dictionary.dart';

class AddToDictionaryScreen extends StatefulWidget {
  DictionaryState dictionaryState;
  int id = -1;
  String title = "";
  String description = "";

  AddToDictionaryScreen.edit(
      this.dictionaryState, this.id, this.title, this.description,
      {super.key});

  AddToDictionaryScreen(this.dictionaryState, {super.key});

  @override
  AddToDictionaryState createState() =>
      AddToDictionaryState(title, description);
}

class AddToDictionaryState extends State<AddToDictionaryScreen> {
  final String url = "${apiUrl}/dictionary";
  UserDetails user = UserDetails.getInstance();

  String title = "";
  String description = "";

  AddToDictionaryState(this.title, this.description);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: const Text('Nowy wpis w słowniku')),
      body: Container(
          alignment: Alignment.topCenter,
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.all(15),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                    child: TextFormField(
                        initialValue: title,
                        onChanged: (v) => {
                              title = v,
                            },
                        style: TextStyle(color: primaryTextColor),
                        decoration: InputDecoration(
                          labelText: 'Wpis',
                          labelStyle: TextStyle(color: primaryTextColor),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryTextColor),
                          ),
                        ))),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
                    child: TextFormField(
                        maxLines: 8,
                        initialValue: description,
                        onChanged: (v) => {
                              description = v,
                            },
                        style: TextStyle(color: primaryTextColor),
                        decoration: InputDecoration(
                          labelText: 'Opis',
                          labelStyle: TextStyle(color: primaryTextColor),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primaryTextColor),
                          ),
                        ))),
                MaterialButton(
                  height: 40,
                  minWidth: double.infinity,
                  onPressed: () async {
                    bool v;
                    if (widget.id == -1) {
                      v = await onAddEntry();
                    } else {
                      v = await onEditEntry();
                    }
                    if (v) {
                      Navigator.of(context).pop(true);
                      widget.dictionaryState.refresh();
                    } else {
                      await onErrorAlert(
                          context, 'Słownik', 'Dodawanie nie powiodło się');
                    }
                  },
                  color: primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                  child: Text('DODAJ DO SŁOWNIKA',
                      style: TextStyle(color: primaryTextColor)),
                ),
              ])),
    );
  }

  Future<bool> onAddEntry() async {
    if (title.isNotEmpty && description.isNotEmpty) {
      Map<String, String> jsonData = {
        "entry": title,
        "description": description
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
        if (response.statusCode == 200) {
          return true;
        }
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  Future<bool> onEditEntry() async {
    if (title.isNotEmpty && description.isNotEmpty) {
      Map<String, String> jsonData = {
        "entry": title,
        "description": description
      };
      try {
        var response = await dio.put('$url/${widget.id}',
            data: jsonData,
            options: Options(
                contentType: "application/json",
                responseType: ResponseType.json,
                headers: {
                  'Authorization': user.token,
                  'App-Version': appVersion
                }));
        if (response.statusCode == 200) {
          return true;
        }
      } catch (e) {
        return false;
      }
    }
    return false;
  }
}
