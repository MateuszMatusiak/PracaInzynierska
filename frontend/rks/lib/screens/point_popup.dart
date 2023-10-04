import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:rks/globals.dart';
import 'package:rks/model/event.dart';
import 'package:rks/model/map_entry.dart';

class MapPointPopup extends StatefulWidget {
  final Marker marker;
  final MapPoint entry;

  const MapPointPopup(this.marker, this.entry, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MapPointPopupState();
}

class _MapPointPopupState extends State<MapPointPopup> {
  late final MapPoint entry;

  @override
  void initState() {
    super.initState();
    entry = widget.entry;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !entry.isEmpty()
        ? (entry.events.isNotEmpty
            ? Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                constraints: const BoxConstraints(
                    minWidth: 215,
                    maxWidth: 215,
                    minHeight: 181,
                    maxHeight: 181),
                child: Column(children: [
                  Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Text(
                    entry.name.toTitleCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 17),
                    textAlign: TextAlign.center,
                  )),
                  Expanded(
                      child: ListView.builder(
                    itemCount: entry.events.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          onTap: () => {
                            Navigator.of(context).pushNamed('/event',
                                arguments: [entry.events[index].id]),
                          },
                          title: Text(
                              '${entry.events[index].name.toTitleCase()}\n${entry.events[index].startDate}'),
                        ),
                      );
                    },
                  )),
                ]))
            : Container(
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                constraints: const BoxConstraints(
                    minWidth: 70, maxWidth: 130, minHeight: 25, maxHeight: 100),
                child: Column(children: [
                  Center(
                      child: Text(
                    entry.name.toTitleCase(),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                    textAlign: TextAlign.center,
                  )),
                  const SizedBox(
                    height: 5,
                  ),
                  const Center(child: Text("Brak wydarzeń")),
                ])))
        : Container(
            child: null,
          );
  }
}
