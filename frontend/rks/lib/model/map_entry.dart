import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rks/model/event.dart';
import 'package:rks/model/point_type.dart';

class MapPoint {
  final PointType type;
  late final int id;
  final double latitude;
  final double longitude;
  final String name;
  late List<Event> events;

  MapPoint(this.name, this.latitude, this.longitude, this.type) {
    events = [];
    id = -1;
  }

  MapPoint.empty()
      : type = PointType.EXTRA,
        id = 0,
        latitude = 0,
        longitude = 0,
        name = "",
        events = [];

  MapPoint._internal(this.type, this.id, this.latitude, this.longitude,
      this.name, this.events);

  factory MapPoint.fromJson(Map<String, dynamic> json) {
    if (json == null) return MapPoint.empty();
    PointType type = decodeType(json['type']);
    int id = json['id'];
    double latitude = json['latitude'];
    double longitude = json['longitude'];
    String name = json['name'];
    MapPoint res = MapPoint._internal(type, id, latitude, longitude, name, []);
    List<Event> e = List<Event>.from(
        json['events'].map((model) => Event.basic(model, res)));
    res.events = e;
    return res;
  }

  factory MapPoint.fromJsonBasic(dynamic json) {
    if (json == null) return MapPoint.empty();
    PointType type = decodeType(json['type']);
    int id = json['id'];
    double latitude = json['latitude'];
    double longitude = json['longitude'];
    String name = json['name'];
    MapPoint res = MapPoint._internal(type, id, latitude, longitude, name, []);
    return res;
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.encodeType(),
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
    };
  }

  Icon getIcon(double size) {
    return type.decodeIcon(size);
  }

  static PointType decodeType(String typeString) {
    switch (typeString) {
      case 'FLAT':
        return PointType.FLAT;
      case 'WILD':
        return PointType.WILD;
      case 'MOUNTAIN':
        return PointType.MOUNTAIN;
      case 'FORTUNE':
        return PointType.FORTUNE;
      case 'TROPIC':
        return PointType.TROPIC;
      case 'PARTY':
        return PointType.PARTY;
      case 'EDUCATION':
        return PointType.EDUCATION;
      case 'BURGER':
        return PointType.BURGER;
      case 'FOREST':
        return PointType.FOREST;
      case 'CIGARETTE':
        return PointType.CIGARETTE;
      case 'PAINTBALL':
        return PointType.PAINTBALL;
      case 'GRAVE':
        return PointType.GRAVE;
      case 'SHIP':
        return PointType.SHIP;
      case 'BOXER':
        return PointType.BOXER;
      case 'BOAT':
        return PointType.BOAT;
      case 'XXX':
        return PointType.XXX;
      case 'SPOT':
        return PointType.SPOT;
      case 'PIZZERIA':
        return PointType.PIZZERIA;
      case 'SIGHTSEEING':
        return PointType.SIGHTSEEING;
      case 'SUMMER_HOUSE':
        return PointType.HEART;
      case 'SHOP':
        return PointType.SHOP;
      case 'PAW':
        return PointType.PAW;
      case 'CAMPFIRE':
        return PointType.CAMPFIRE;
      case 'BEACH':
        return PointType.BEACH;
      case 'BATTLE':
        return PointType.BATTLE;
      case 'TRUCK':
        return PointType.TRUCK;
      case 'BEER':
        return PointType.BEER;
      case 'PETROL':
        return PointType.PETROL;
      case 'TRACTOR':
        return PointType.TRACTOR;
      case 'BISTRO':
        return PointType.BISTRO;
      case 'FISH':
        return PointType.FISH;
      case 'SKATES':
        return PointType.SKATES;
      case 'ACCIDENT':
        return PointType.ACCIDENT;
      case 'RESTAURANT':
        return PointType.RESTAURANT;
      case 'HOUSE':
        return PointType.HOUSE;
      case 'TRIP':
        return PointType.TRIP;
      case 'VOLLEYBALL':
        return PointType.VOLLEYBALL;
      case 'ICE_CREAM':
        return PointType.ICE_CREAM;
      case 'BIRTHDAY':
        return PointType.BIRTHDAY;
      case 'CAR':
        return PointType.CAR;
      case 'UFO':
        return PointType.UFO;
      case 'HEART':
        return PointType.HEART;
      default:
        return PointType.EXTRA;
    }
  }

  @override
  String toString() {
    return 'MapPoint{id: $id, latitude: $latitude, longitude: $longitude, name: $name}';
  }

  bool isEmpty() {
    return id == 0;
  }
}
