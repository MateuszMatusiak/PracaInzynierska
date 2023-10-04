import 'package:flutter/material.dart';
import 'package:fluttericon/font_awesome5_icons.dart';
import 'package:fluttericon/fontelico_icons.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';

enum PointType {
  FLAT,
  WILD,
  MOUNTAIN,
  FORTUNE,
  TROPIC,
  PARTY,
  EDUCATION,
  BURGER,
  FOREST,
  CIGARETTE,
  PAINTBALL,
  GRAVE,
  SHIP,
  BOXER,
  BOAT,
  XXX,
  SPOT,
  PIZZERIA,
  SIGHTSEEING,
  HEART,
  SHOP,
  PAW,
  CAMPFIRE,
  BEACH,
  BATTLE,
  TRUCK,
  BEER,
  EXTRA,
  PETROL,
  TRACTOR,
  BISTRO,
  FISH,
  SKATES,
  ACCIDENT,
  RESTAURANT,
  HOUSE,
  TRIP,
  VOLLEYBALL,
  ICE_CREAM,
  BIRTHDAY,
  CAR,
  UFO
}

extension PointTypeExtension on PointType {
  String encodeType() {
    switch (this) {
      case PointType.FLAT:
        return "FLAT";
      case PointType.WILD:
        return "WILD";
      case PointType.MOUNTAIN:
        return "MOUNTAIN";
      case PointType.FORTUNE:
        return "FORTUNE";
      case PointType.TROPIC:
        return "TROPIC";
      case PointType.PARTY:
        return "PARTY";
      case PointType.EDUCATION:
        return "EDUCATION";
      case PointType.BURGER:
        return "BURGER";
      case PointType.FOREST:
        return "FOREST";
      case PointType.CIGARETTE:
        return "CIGARETTE";
      case PointType.PAINTBALL:
        return "PAINTBALL";
      case PointType.GRAVE:
        return "GRAVE";
      case PointType.SHIP:
        return "SHIP";
      case PointType.BOXER:
        return "BOXER";
      case PointType.BOAT:
        return "BOAT";
      case PointType.XXX:
        return "XXX";
      case PointType.SPOT:
        return "SPOT";
      case PointType.PIZZERIA:
        return "PIZZERIA";
      case PointType.SIGHTSEEING:
        return "SIGHTSEEING";
      case PointType.HEART:
        return "HEART";
      case PointType.SHOP:
        return "SHOP";
      case PointType.PAW:
        return "PAW";
      case PointType.CAMPFIRE:
        return "CAMPFIRE";
      case PointType.BEACH:
        return "BEACH";
      case PointType.BATTLE:
        return "BATTLE";
      case PointType.TRUCK:
        return "TRUCK";
      case PointType.BEER:
        return "BEER";
      case PointType.PETROL:
        return "PETROL";
      case PointType.TRACTOR:
        return "TRACTOR";
      case PointType.BISTRO:
        return "BISTRO";
      case PointType.FISH:
        return "FISH";
      case PointType.SKATES:
        return "SKATES";
      case PointType.ACCIDENT:
        return "ACCIDENT";
      case PointType.RESTAURANT:
        return "RESTAURANT";
      case PointType.HOUSE:
        return "HOUSE";
      case PointType.TRIP:
        return "TRIP";
      case PointType.VOLLEYBALL:
        return "VOLLEYBALL";
      case PointType.ICE_CREAM:
        return "ICE_CREAM";
      case PointType.BIRTHDAY:
        return "BIRTHDAY";
      case PointType.CAR:
        return "CAR";
      case PointType.UFO:
        return "UFO";
      default:
        return "EXTRA";
    }
  }

  Icon decodeIcon(double size) {
    return Icon(
      _getIconForType(this),
      // color: typeToColor[this],
      color: Colors.white,
      size: size,
    );
  }

  static IconData _getIconForType(PointType type) {
    switch (type) {
      case PointType.FLAT:
        return Icons.apartment;
      case PointType.WILD:
        return FontAwesome5.democrat;
      case PointType.MOUNTAIN:
        return Icons.terrain;
      case PointType.FORTUNE:
        return Icons.temple_buddhist;
      case PointType.TROPIC:
        return Icons.sunny;
      case PointType.PARTY:
        return Icons.celebration;
      case PointType.EDUCATION:
        return Icons.school;
      case PointType.BURGER:
        return FontAwesome5.hamburger;
      case PointType.FOREST:
        return Icons.forest;
      case PointType.CIGARETTE:
        return Icons.smoking_rooms;
      case PointType.PAINTBALL:
        return Fontelico.emo_shoot;
      case PointType.GRAVE:
        return FontAwesome5.skull_crossbones;
      case PointType.SHIP:
        return Icons.directions_boat;
      case PointType.BOXER:
        return Icons.sports_mma;
      case PointType.BOAT:
        return Icons.directions_boat;
      case PointType.XXX:
        return Icons.close;
      case PointType.PIZZERIA:
        return Icons.local_pizza;
      case PointType.SIGHTSEEING:
        return Icons.camera_alt;
      case PointType.HEART:
        return Icons.favorite;
      case PointType.SHOP:
        return Icons.shopping_basket;
      case PointType.PAW:
        return Icons.pets;
      case PointType.CAMPFIRE:
        return Icons.local_fire_department;
      case PointType.BEACH:
        return Icons.beach_access;
      case PointType.BATTLE:
        return RpgAwesome.crossed_swords;
      case PointType.TRUCK:
        return Icons.local_shipping;
      case PointType.BEER:
        return Icons.sports_bar;
      case PointType.PETROL:
        return Icons.local_gas_station;
      case PointType.TRACTOR:
        return Icons.agriculture;
      case PointType.BISTRO:
        return Icons.fastfood;
      case PointType.FISH:
        return FontAwesome5.fish;
      case PointType.SKATES:
        return Icons.ice_skating;
      case PointType.ACCIDENT:
        return Icons.car_crash;
      case PointType.RESTAURANT:
        return Icons.restaurant;
      case PointType.HOUSE:
        return Icons.home;
      case PointType.TRIP:
        return Icons.hiking;
      case PointType.VOLLEYBALL:
        return Icons.sports_volleyball;
      case PointType.ICE_CREAM:
        return Icons.icecream;
      case PointType.BIRTHDAY:
        return Icons.cake;
      case PointType.CAR:
        return Icons.directions_car;
      case PointType.SPOT:
        return FontAwesome5.campground;
      case PointType.UFO:
        return FontAwesome5.reddit_alien;
      default:
        return Icons.question_mark;
    }
  }

  Color getColor() {
    return typeToColor[this]!;
  }

  static Map<PointType, Color> typeToColor = {
    PointType.FLAT: Colors.deepOrange,
    PointType.WILD: Colors.black,
    PointType.MOUNTAIN: Colors.grey,
    PointType.FORTUNE: Colors.blue.shade900,
    PointType.TROPIC: Colors.orangeAccent,
    PointType.PARTY: Colors.brown,
    PointType.EDUCATION: Colors.lightGreen.shade800,
    PointType.BURGER: Colors.deepPurpleAccent.shade100,
    PointType.FOREST: Colors.green,
    PointType.CIGARETTE: Colors.grey,
    PointType.PAINTBALL: Colors.redAccent,
    PointType.GRAVE: Colors.black,
    PointType.SHIP: Colors.blue,
    PointType.BOXER: Colors.grey.shade700,
    PointType.BOAT: Colors.blue,
    PointType.XXX: Colors.red,
    PointType.SPOT: Colors.green.shade700,
    PointType.PIZZERIA: Colors.purple.shade500,
    PointType.SIGHTSEEING: Colors.brown.shade400,
    PointType.HEART: Colors.red,
    PointType.SHOP: Colors.green,
    PointType.PAW: Colors.brown,
    PointType.CAMPFIRE: Colors.teal,
    PointType.BEACH: Colors.yellow,
    PointType.BATTLE: Colors.black,
    PointType.TRUCK: Colors.orange,
    PointType.BEER: Colors.amber,
    PointType.EXTRA: Colors.pinkAccent,
    PointType.PETROL: Colors.brown,
    PointType.TRACTOR: Colors.brown,
    PointType.BISTRO: Colors.purple,
    PointType.FISH: Colors.blue,
    PointType.SKATES: Colors.greenAccent,
    PointType.ACCIDENT: Colors.black,
    PointType.RESTAURANT: Colors.purple.shade900,
    PointType.HOUSE: Colors.red.shade900,
    PointType.TRIP: Colors.yellow.shade800,
    PointType.VOLLEYBALL: Colors.orange,
    PointType.ICE_CREAM: Colors.pinkAccent,
    PointType.BIRTHDAY: Colors.pink,
    PointType.CAR: Colors.indigo.shade400,
    PointType.UFO: Colors.green,
  };
}
