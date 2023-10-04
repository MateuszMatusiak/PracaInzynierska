import 'package:rks/model/map_entry.dart';
import 'package:rks/model/user.dart';

class Event {
  final int id;
  final String name;
  final String description;
  final String startDate;
  final String endDate;
  final MapPoint localization;
  List<User> users;
  final User creator;

  Event(this.id, this.name, this.description, this.startDate, this.endDate,
      this.localization, this.users, this.creator);

  factory Event.fromJson(dynamic json) {
    if (json == null) return Event.empty();
    Event res = Event._json(json);
    List<User> users = [];
    if (json['users'] != null) {
      users =
          List<User>.from(json['users'].map((model) => User.fromJson(model)));
    }
    res.users = users;
    return res;
  }

  Event._json(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'].trim() ?? "",
        description = json['description'].trim() ?? "",
        startDate = json['startDate'].trim(),
        endDate = json['endDate'].trim() ?? "",
        localization = MapPoint.fromJsonBasic(json['localization']),
        users = [],
        creator = User.fromJson(json['creator']);

  Event.basic(Map<String, dynamic> json, MapPoint? localization)
      : id = json['id'],
        name = json['name'] ?? "",
        description = json['description'] ?? "",
        startDate = json['startDate'],
        endDate = json['endDate'] ?? "",
        users = [],
        localization = localization ?? MapPoint.empty(),
        creator = User.fromJson(json['creator']);

  Event.empty()
      : id = 0,
        name = "",
        description = "",
        startDate = "",
        endDate = "",
        localization = MapPoint.empty(),
        users = [],
        creator = User.empty();

  bool isAfter() {
    if (endDate.isNotEmpty) {
      DateTime e = DateTime(
          int.parse(endDate.substring(0, 4)),
          int.parse(endDate.substring(5, 7)),
          int.parse(endDate.substring(8, 10)));
      return e.isBefore(DateTime.now());
    }
    DateTime s = DateTime(
        int.parse(startDate.substring(0, 4)),
        int.parse(startDate.substring(5, 7)),
        int.parse(startDate.substring(8, 10)));
    return s.isBefore(DateTime.now());
  }

  @override
  String toString() {
    return 'Event{id: $id, name: $name, startDate: $startDate, endDate: $endDate, localization: $localization, users: $users}';
  }
}
