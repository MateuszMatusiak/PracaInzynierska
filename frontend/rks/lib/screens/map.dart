import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:latlong2/latlong.dart';
import 'package:rks/model/map_entry.dart';
import 'package:rks/model/user_details.dart';

import '../globals.dart';
import '../model/point_type.dart';
import 'point_popup.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  UserDetails user = UserDetails.getInstance();
  Map<Key, MapPoint> mapEntries = {};
  final MapController _mapController = MapController();

  List<Marker> markers = [];

  LatLng? newPoint;
  bool isAddNewPoint = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: user.isModerator()
            ? (isAddNewPoint
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Visibility(
                        visible: newPoint != null,
                        child: FloatingActionButton(
                          backgroundColor: Colors.green,
                          onPressed: () {
                            setState(() {
                              Navigator.of(context).pushNamed('/addMapPoint',
                                  arguments: [newPoint, this]);
                              newPoint = null;
                              isAddNewPoint = false;
                            });
                          },
                          child: const Icon(Icons.add),
                        ),
                      ),
                      const SizedBox(height: 15),
                      FloatingActionButton(
                        backgroundColor: Colors.red,
                        onPressed: () {
                          setState(() {
                            if (!(newPoint == null)) {
                              markers.clear();
                            }
                            newPoint = null;
                            isAddNewPoint = false;
                          });
                        },
                        child: const Icon(Icons.clear),
                      ),
                    ],
                  )
                : FloatingActionButton(
                    child: const Icon(Icons.add),
                    onPressed: () {
                      setState(() {
                        isAddNewPoint = true;
                      });
                    },
                  ))
            : Container(),
        body: FutureBuilder(
          future: getMapEntries(),
          builder: (context, value) {
            if (value.hasData) {
              for (int i = 0; i < value.data!.length; ++i) {
                Key k = Key('${value.data![i].id} ${DateTime.now()}');
                Marker m = Marker(
                  key: k,
                  width: 80,
                  height: 80,
                  point:
                      LatLng(value.data![i].latitude, value.data![i].longitude),
                  builder: (ctx) => Container(
                    key: Key(i.toString()),
                    child: Container(
                      alignment: Alignment.center,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(32),
                          color: value.data![i].type.getColor(),
                          // color: Colors.white,
                        ),
                        child: value.data![i].getIcon(20.0),
                      ),
                    ),
                  ),
                );
                markers.add(m);
                mapEntries[k] = value.data![i];
              }
              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  onTap: _handleAddPoint,
                  interactiveFlags:
                      InteractiveFlag.all & ~InteractiveFlag.rotate,
                  center: LatLng(52.70702, 21.08987),
                  zoom: 14.0,
                  minZoom: 4.0,
                  maxZoom: 18.45,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'zam.rks',
                  ),
                  // MarkerLayer(markers: markers),
                  PopupMarkerLayerWidget(
                    options: PopupMarkerLayerOptions(
                      markers: markers,
                      popupBuilder: (BuildContext context, Marker marker) =>
                          MapPointPopup(marker,
                              mapEntries[marker.key] ?? MapPoint.empty()),
                    ),
                  )
                ],
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ));
  }

  void _handleAddPoint(dynamic tapPosition, LatLng latlng) {
    if (isAddNewPoint) {
      if (!(newPoint == null)) {
        setState(() {
          markers.clear();
          newPoint = null;
        });
      }
      setState(() {
        newPoint = latlng;
        Marker m = Marker(
          key: Key('${DateTime.now()}'),
          width: 80,
          height: 80,
          point: latlng,
          builder: (ctx) => const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 35.0,
          ),
        );
        markers.add(m);
      });
    }
  }

  Future<List<MapPoint>> getMapEntries() async {
    String url = '${apiUrl}/map';
    try {
      var response = await dio.get(url,
          options: Options(
              contentType: "application/json",
              responseType: ResponseType.json,
              headers: {
                'Authorization': user.token,
                'App-Version': appVersion
              }));
      List<MapPoint> entries = [];
      if (response.statusCode == 200) {
        for (var g in response.data) {
          MapPoint entry = MapPoint.fromJson(g);
          entries.add(entry);
        }
      }
      return entries;
    } catch (e) {}
    return [];
  }
}
