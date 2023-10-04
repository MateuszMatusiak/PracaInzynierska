import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rks/model/user_details.dart';

import '../globals.dart';
import '../model/board_post.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  BoardState createState() => BoardState();
}

class BoardState extends State<BoardScreen> {
  UserDetails user = UserDetails.getInstance();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<List<PostEntry>>(
          future: getBoardPosts(),
          builder: (context, data) {
            if (data.hasData) {
              return Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: ListView.separated(
                  itemCount: data.data!.length,
                  itemBuilder: (context, index) {
                    PostEntry entry = data.data![index];
                    return Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                  '${userImageUrl}${entry.user.id}'),
                              radius: 18,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(7, 0, 10, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.event == null
                                        ? '${entry.user.firstname} ${entry.user.lastname}'
                                        : '${data.data![index].event!.name}',
                                    style: TextStyle(
                                        color: primaryTextColor, fontSize: 16),
                                  ),
                                  Text(
                                    entry.event == null
                                        ? '${entry.date.substring(0, 16)}'
                                        : '${entry.user.firstname} ${entry.user.lastname} ${entry.date.substring(0, 16)}',
                                    style: TextStyle(
                                        color: primaryTextColor, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(5, 10, 10, 0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              entry.content,
                              style: TextStyle(
                                color: primaryTextColor,
                              ),
                            ),
                          ),
                        )
                      ],
                    );

                    // return Text.rich(
                    //   TextSpan(
                    //     children: <TextSpan>[
                    //       TextSpan(
                    //           text: "${data.data![index].date.split(".")[0]} ",
                    //           style: const TextStyle(
                    //               fontWeight: FontWeight.normal, fontSize: 18)),
                    //       TextSpan(
                    //           text:
                    //               "Wydarzenie: ${data.data![index].eventName}",
                    //           style: const TextStyle(
                    //               fontWeight: FontWeight.normal, fontSize: 18)),
                    //       TextSpan(
                    //           text:
                    //               "\n${data.data![index].userFirstname} ${data.data![index].userLastname} pisze:",
                    //           style: const TextStyle(
                    //               fontWeight: FontWeight.bold, fontSize: 20)),
                    //       TextSpan(
                    //           text: '\n${data.data![index].content}',
                    //           style: const TextStyle(
                    //               fontWeight: FontWeight.normal, fontSize: 18)),
                    //     ],
                    //   ),
                    // );
                  },
                  separatorBuilder: (context, index) {
                    return Divider(
                      height: 10.0,
                      color: primaryTextColor,
                    );
                  },
                ),
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
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.pushNamed(context, '/addNewPost');
        },
      ),
    );
  }

  Future<List<PostEntry>> getBoardPosts() async {
    String url = '${apiUrl}/post';
    try {
      var response = await dio.get(url,
          options: Options(
              contentType: "application/json",
              responseType: ResponseType.json,
              headers: {
                'Authorization': user.token,
                'App-Version': appVersion
              }));
      List<PostEntry> entries = [];
      if (response.statusCode == 200) {
        for (var g in response.data) {
          PostEntry entry = PostEntry.fromJson(g);
          entries.add(entry);
        }
      }
      return entries;
    } catch (e) {
    }
    return [];
  }
}
