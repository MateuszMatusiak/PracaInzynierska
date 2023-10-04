import 'package:rks/model/event.dart';
import 'package:rks/model/user.dart';

class PostEntry {
  final int id;
  final String content;
  final String date;
  final User user;
  final Event? event;

  PostEntry(this.id, this.content, this.date, this.user, this.event);

  factory PostEntry.fromJson(Map<String, dynamic> json) {
    int id = json['id'];
    String date = json['date'].trim();
    String content = json['content'].trim();
    User user = User.fromJson(json['user']);
    Event? event = json['event'] == null ? null : Event.fromJson(json['event']);
    return PostEntry(id, content, date, user, event);
  }

  Map<String, String> toJson() {
    return {
      'content': content,
      'date': date,
      'id': id.toString(),
    };
  }

  @override
  String toString() {
    return 'PostEntry{id: $id}';
  }
}
