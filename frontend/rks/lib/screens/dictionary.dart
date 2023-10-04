import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rks/model/dictionary_entries.dart';
import 'package:rks/model/user.dart';
import 'package:rks/model/user_details.dart';
import 'package:rks/screens/message.dart';

import '../globals.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  DictionaryState createState() => DictionaryState();
}

class DictionaryState extends State<DictionaryScreen> {
  UserDetails user = UserDetails.getInstance();

  late Future<List<DictionaryEntry>> entries;

  @override
  void initState() {
    super.initState();
    entries = getDictionaryEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: user.isModerator()
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed('/AddToDictionary', arguments: [this]);
              },
            )
          : const Scaffold(),
      body: Center(
        child: FutureBuilder<List<DictionaryEntry>>(
          future: entries,
          builder: (context, data) {
            if (data.hasData) {
              return ListView.separated(
                itemCount: data.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    textColor: primaryTextColor,
                    title: Text(data.data![index].entry),
                    trailing: Visibility(
                      visible: user.isModerator(),
                      child: InkWell(
                        child: Icon(
                          Icons.settings,
                          color: primaryTextColor,
                        ),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed('/editDictionary', arguments: [
                            this,
                            data.data![index].id,
                            data.data![index].entry,
                            data.data![index].description
                          ]);
                        },
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                                dialogBackgroundColor: primaryBackgroundColor),
                            child: AlertDialog(
                              title: Text(data.data![index].entry,
                                  style: TextStyle(color: primaryTextColor)),
                              content: Text(data.data![index].description,
                                  style: TextStyle(color: primaryTextColor)),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 20.0,
                    color: primaryColor,
                  );
                },
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
      ),
    );
  }

  void refresh() {
    setState(() {
      entries = getDictionaryEntries();
    });
  }

  Future<List<DictionaryEntry>> getDictionaryEntries() async {
    String url = '${apiUrl}/dictionary';
    try {
      var response = await dio.get(url,
          options: Options(
              contentType: "application/json",
              responseType: ResponseType.json,
              headers: {
                'Authorization': user.token,
                'App-Version': appVersion
              }));
      List<DictionaryEntry> entries = [];
      if (response.statusCode == 200) {
        for (var g in response.data) {
          DictionaryEntry entry = DictionaryEntry(
              g['id'], g['entry'], g['description'], g['creationTime']);
          entries.add(entry);
        }
      }
      return entries;
    } catch (e) {}
    return [];
  }
}
