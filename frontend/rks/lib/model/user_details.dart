import 'package:dio/dio.dart';
import 'package:rks/globals.dart';
import 'package:rks/model/user.dart';

import 'group.dart';

class UserDetails {
  static UserDetails? _instance;

  String _email;
  String _password;
  String token = "";

  int id = 0;
  String firstname = "";
  String lastname = "";
  String phone = "";
  String nick = "";
  String birthdate = "2000-01-01";
  UserRole _role = UserRole.user;
  Group _selectedGroup = Group(-1, "");
  String firebaseId = "";

  UserDetails(this._email, this._password);

  UserDetails._internal(
      this._email,
      this.id,
      this.firstname,
      this.lastname,
      this.phone,
      this.nick,
      this.birthdate,
      this._password,
      this._role,
      this.firebaseId);

  void clean() {
    _email = "";
    _password = "";
    token = "";
    id = 0;
    firstname = "";
    lastname = "";
    phone = "";
    nick = "";
    birthdate = "2000-01-01";
    _role = UserRole.user;
    _selectedGroup = Group(-1, "");
    firebaseId = "";
  }

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    int id = json['id'] ?? -1;
    String email = json['email'];
    String firstname = json['firstName'] ?? "";
    String lastname = json['lastName'] ?? "";
    String birthdate = json['birthdate'] ?? "";
    String phone = json['phoneNumber'] ?? "";
    String nick = json['nickname'] ?? "";
    String firebaseId = json['firebaseId'] ?? "";
    UserRole role = User.decodeRole(json['role']);
    UserDetails u = UserDetails._internal(email, id, firstname, lastname, phone,
        nick, birthdate, "", role, firebaseId);
    u._selectedGroup = Group.fromJson(json['selectedGroup']);
    _instance = u;
    return u;
  }

  factory UserDetails.getInstance() {
    return _instance!;
  }

  Future<Group> setSelectedGroup(int id) async {
    String url = '${apiUrl}/user/group/$id';
    try {
      var response = await dio.put(url,
          options: Options(
              contentType: "application/json",
              responseType: ResponseType.json,
              headers: {'Authorization': token, 'App-Version': appVersion}));
      UserDetails user = UserDetails.fromJson(response.data);
      _instance = user;
    } catch (e) {
    }
    return _selectedGroup;
  }

  Group get selectedGroup => _selectedGroup;

  UserRole get role => _role;

  bool isOwner() {
    return _role == UserRole.owner;
  }

  bool isAdmin() {
    return _role == UserRole.owner || _role == UserRole.admin;
  }

  bool isModerator() {
    return _role == UserRole.owner ||
        _role == UserRole.admin ||
        _role == UserRole.moderator;
  }

  @override
  String toString() {
    return 'UserDetails{_email: $_email, token: $token, id: $id, firstname: $firstname, lastname: $lastname, phone: $phone, nick: $nick, birthdate: $birthdate, _role: $_role, _selectedGroup: $_selectedGroup}';
  }
}
