import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rks/globals.dart';
import 'package:rks/model/user_details.dart';

import '../model/group.dart';

class SwitchGroup extends StatefulWidget {
  const SwitchGroup({super.key});

  @override
  SwitchGroupState createState() => SwitchGroupState();
}

class SwitchGroupState extends State<SwitchGroup> {
  UserDetails user = UserDetails.getInstance();

  late Future<List<Group>> groups;

  @override
  void initState() {
    super.initState();
    groups = getGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Zmiana grupy')),
      body: Center(
        child: FutureBuilder<List<Group>>(
          future: groups,
          builder: (context, data) {
            if (data.hasData) {
              return ListView.separated(
                itemCount: data.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      data.data![index].name,
                      style: TextStyle(color: primaryTextColor),
                    ),
                    leading: Icon(
                      Icons.group,
                      color: primaryTextColor,
                    ),
                    onTap: () {
                      user
                          .setSelectedGroup(data.data![index].id)
                          .then((value) => {
                                Navigator.popUntil(
                                    context, ModalRoute.withName('/')),
                                Navigator.of(context).pushNamed('/menu')
                              });
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(height: 20.0);
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.of(context).pushNamed('/addGroup');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<List<Group>> getGroups() async {
    String url = '${apiUrl}/user/groups';
    try {
      await EasyLoading.show(
        status: 'Pobieranie listy grup',
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
      List<Group> groups = [];
      await EasyLoading.dismiss();
      if (response.statusCode == 200) {
        for (var g in response.data) {
          Group group = Group(g['id'], g['name']);
          groups.add(group);
        }
      }
      return groups;
    } catch (e) {
      Navigator.popUntil(context, ModalRoute.withName('/'));
      Navigator.of(context).pushNamed('/menu');
    }
    return [];
  }
}
