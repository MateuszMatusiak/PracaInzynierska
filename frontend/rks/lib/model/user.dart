import 'package:flutter/material.dart';
import 'package:rks/globals.dart';

enum UserRole { owner, admin, moderator, user }

class User {
  final String _email;
  int id = 0;
  String _firstname = "";
  String _lastname = "";
  String phone = "";
  String nick = "";
  String birthdate = "2000-01-01";
  UserRole _role = UserRole.user;
  String firebaseId = "";

  String get email => _email;

  User.createNewUser(firstname, lastname, this.id, this._email) {
    this.firstname = firstname;
    this.lastname = lastname;
  }

  User._internal(this._email, this.id, this._firstname, this._lastname,
      this.phone, this.nick, this.birthdate, this._role, this.firebaseId);

  factory User.fromJson(dynamic json) {
    if (json == null) return User.empty();
    int id = json['id'];
    String email = json['email'];
    String firstname = json['firstName'] ?? "";
    String lastname = json['lastName'] ?? "";
    String birthdate = json['birthdate'] ?? "";
    String phone = json['phoneNumber'] ?? "";
    String nick = json['nickname'] ?? "";
    String firebaseId = json['firebaseId']??"";
    UserRole role = decodeRole(json['role']);
    return User._internal(
        email, id, firstname, lastname, phone, nick, birthdate, role,firebaseId);
  }

  User.empty() : this._email = '';

  UserRole get role => _role;

  Color getColor() {
    switch (_role) {
      case UserRole.owner:
        {
          return Colors.red;
        }
      case UserRole.admin:
        {
          return Colors.orange;
        }
      case UserRole.moderator:
        {
          return Colors.yellow;
        }
      default:
        {
          return primaryTextColor;
        }
    }
  }

  static UserRole decodeRole(String value) {
    switch (value) {
      case "ROLE_OWNER":
        {
          return UserRole.owner;
        }
      case "ROLE_ADMIN":
        {
          return UserRole.admin;
        }
      case "ROLE_MODERATOR":
        {
          return UserRole.moderator;
        }
      default:
        {
          return UserRole.user;
        }
    }
  }

  static String encodeRole(UserRole value) {
    switch (value) {
      case UserRole.owner:
        {
          return "ROLE_OWNER";
        }
      case UserRole.admin:
        {
          return "ROLE_ADMIN";
        }
      case UserRole.moderator:
        {
          return "ROLE_MODERATOR";
        }
      default:
        {
          return "ROLE_USER";
        }
    }
  }

  String get lastname => _lastname.toCapitalized();

  set lastname(String value) {
    _lastname = value;
  }

  String get firstname => _firstname.toCapitalized();

  set firstname(String value) {
    _firstname = value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is User && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
