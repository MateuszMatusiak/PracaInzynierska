import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:latlong2/latlong.dart';
import 'package:rks/model/map_entry.dart';
import 'package:rks/model/point_type.dart';
import 'package:rks/model/user_details.dart';

import '../globals.dart';
import 'map.dart';

class AddMapPoint extends StatefulWidget {
  final LatLng cords;
  final MapScreenState mapScreen;

  const AddMapPoint(this.cords, this.mapScreen, {super.key});

  @override
  State<AddMapPoint> createState() => _AddMapPointState();
}

class _AddMapPointState extends State<AddMapPoint> {
  final UserDetails _user = UserDetails.getInstance();
  late MapPoint newPoint;
  Map<String, String> types = {
    'FLAT': 'Mieszkanie',
    'WILD': 'Łoś',
    'MOUNTAIN': 'Góry',
    'FORTUNE': 'Majątek',
    'TROPIC': 'Wakacje',
    'PARTY': 'Impreza',
    'EDUCATION': 'Liceum',
    'BURGER': 'Burger',
    'FOREST': 'Las',
    'CIGARETTE': 'Papieros',
    'PAINTBALL': 'Paintball',
    'GRAVE': 'Grób',
    'SHIP': 'Statek',
    'BOXER': 'Bokser',
    'BOAT': 'Łódź',
    'XXX': 'XXX',
    'SPOT': 'Miejscówa',
    'PIZZERIA': 'Pizzeria',
    'SIGHTSEEING': 'Wycieczka',
    'HEART': 'Serce',
    'SHOP': 'Sklep',
    'PAW': 'Łapa',
    'CAMPFIRE': 'Ognisko',
    'BEACH': 'Plaża',
    'BATTLE': 'Bitwa',
    'TRUCK': 'Ciężarówka',
    'BEER': 'Piwo',
    'EXTRA': 'Extra',
    'PETROL': 'CPN',
    'TRACTOR': 'Traktor',
    'BISTRO': 'Fastfood',
    'FISH': 'Ryba',
    'SKATES': 'Łyżwy',
    'ACCIDENT': 'Wypadek',
    'RESTAURANT': 'Restauracja',
    'HOUSE': 'Dom',
    'TRIP': 'Wyjazd',
    'VOLLEYBALL': 'Siatkówka',
    'ICE_CREAM': 'Lody',
    'BIRTHDAY': 'Urodziny',
    'CAR': 'Samochód',
    'UFO': 'UFO'
  };

  List<DropdownMenuItem<String>> typesList = [];

  String selectedType = 'EXTRA';
  String _name = '';

  @override
  void initState() {
    types.forEach((key, value) {
      typesList.add(DropdownMenuItem<String>(
          value: key,
          child: Text(
            value,
            style: TextStyle(color: primaryTextColor),
          )));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Dodawanie punktu')),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(50, 130, 50, 0),
          child: Column(
            children: [
              TextFormField(
                  initialValue: "",
                  onChanged: (v) => {
                        _name = v,
                      },
                  style: TextStyle(color: primaryTextColor),
                  decoration: InputDecoration(
                    labelText: 'nazwa',
                    labelStyle: TextStyle(color: primaryTextColor),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: primaryTextColor),
                    ),
                  )),
              const SizedBox(
                height: 50,
              ),
              Row(children: [
                Text("Typ punktu: ",
                    style: TextStyle(
                      fontSize: 20,
                      color: primaryTextColor,
                    )),
                const SizedBox(
                  width: 25,
                ),
                DropdownButton(
                  items: typesList,
                  value: selectedType,
                  dropdownColor: primaryBackgroundColor,
                  style: TextStyle(color: primaryTextColor),
                  onChanged: (value) => setState(() {
                    selectedType = value ?? 'EXTRA';
                  }),
                ),
              ]),
              Container(
                  width: 180.0,
                  height: 180.0,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(180),
                    color: MapPoint.decodeType(selectedType).getColor(),
                  ),
                  child: Center(
                    child: MapPoint.decodeType(selectedType).decodeIcon(150.0),
                  )),
              const SizedBox(
                height: 50,
              ),
              MaterialButton(
                height: 40,
                minWidth: double.infinity,
                onPressed: () {
                  onAddPoint().then((v) => {
                        if (v == 200)
                          {
                            Navigator.of(context).pop(true),
                            widget.mapScreen.refresh(),
                          }
                        else
                          {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Dodawanie nie powiodło się')))
                          }
                      });
                },
                color: primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
                child: Text('Dodaj punkt',
                    style: TextStyle(color: primaryTextColor)),
              )
            ],
          )),
    );
  }

  Future<int> onAddPoint() async {
    if (_name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nazwa nie może być pusta')));
      return -1;
    }
    Map<String, dynamic> jsonData = {
      'name': _name,
      'latitude': widget.cords.latitude,
      'longitude': widget.cords.longitude,
      'type': selectedType,
    };

    String url = "${apiUrl}/map/point";
    try {
      await EasyLoading.show();
      var response = await dio.post(url,
          data: jsonData,
          options: Options(
              contentType: "application/json",
              responseType: ResponseType.json,
              headers: {
                'Authorization':  _user.token,
                'App-Version': appVersion
              }));
      if (response.statusCode == 200) {
        await EasyLoading.dismiss();
        return 200;
      }
    } catch (e) {
      await EasyLoading.dismiss();
      return -2;
    }
    return -1;
  }
}
