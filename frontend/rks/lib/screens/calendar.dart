import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../globals.dart';
import '../model/event.dart';
import '../model/user_details.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<StatefulWidget> createState() => _CalendarScreen();
}

class _CalendarScreen extends State<CalendarScreen> {
  final UserDetails _user = UserDetails.getInstance();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late LinkedHashMap<DateTime, List<Event>> _userEvents;
  late ValueNotifier<List<Event>> _selectedEvents;

  @override
  void initState() {
    super.initState();
  }

  void refresh() {
    setState(() {});
  }

  @override
  void dispose() {
    try {
      _selectedEvents.dispose();
    } catch (e) {
      //ignore
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add), onPressed: () => _onAddEvent()),
      body: FutureBuilder(
        future: _getEventsForUser(),
        builder: (context, value) {
          if (value.hasData) {
            _userEvents = value.data!;
            _selectedDay = _focusedDay;
            _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
            return Column(
              children: [
                TableCalendar<Event>(
                  locale: 'pl_PL',
                  focusedDay: _focusedDay,
                  firstDay: DateTime.parse("2015-01-01"),
                  lastDay: DateTime.parse("2050-12-31"),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  rangeStartDay: _rangeStart,
                  rangeEndDay: _rangeEnd,
                  rangeSelectionMode: _rangeSelectionMode,
                  eventLoader: _getEventsForDay,
                  headerStyle: HeaderStyle(
                    titleTextStyle:
                        TextStyle(fontSize: 17.0, color: primaryTextColor),
                    formatButtonTextStyle:
                        TextStyle(fontSize: 14.0, color: primaryTextColor),
                    formatButtonDecoration: BoxDecoration(
                        border: const Border.fromBorderSide(BorderSide()),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12.0)),
                        color: primaryColor),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: primaryVariantColor),
                    weekendStyle: TextStyle(color: primaryVariantColor),
                  ),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: BoxDecoration(
                      color: primaryVariantColor,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: TextStyle(color: primaryVariantColor),
                    defaultTextStyle: TextStyle(color: primaryTextColor),
                    markerDecoration: BoxDecoration(
                      color: primaryVariantColor,
                      shape: BoxShape.circle,
                    ),
                    rangeStartDecoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    rangeEndDecoration: BoxDecoration(
                      color: primaryVariantColor,
                      shape: BoxShape.circle,
                    ),
                    rangeHighlightColor: Colors.grey.shade400,
                  ),
                  onDaySelected: _onDaySelected,
                  onRangeSelected: _onRangeSelected,
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: ValueListenableBuilder<List<Event>>(
                    valueListenable: _selectedEvents,
                    builder: (context, value, _) {
                      return ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              onTap: () => {
                                Navigator.of(context).pushNamed('/event',
                                    arguments: [
                                      value[index].id
                                    ]).then((value) => refresh()),
                              },
                              title: Text(
                                  '${value[index].name.toTitleCase()}\nStart: ${value[index].startDate.substring(11)}'),
                              textColor: primaryTextColor,
                              tileColor: primaryVariantBackgroundColor,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _userEvents[day] ?? [];
  }

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  Future<LinkedHashMap<DateTime, List<Event>>> _getEventsForUser() async {
    String url = '${apiUrl}/events';
    LinkedHashMap<DateTime, List<Event>> result =
        LinkedHashMap<DateTime, List<Event>>(
      equals: isSameDay,
      hashCode: getHashCode,
    );

    try {
      var response = await dio.get(url,
          options: Options(
              contentType: "application/json",
              responseType: ResponseType.json,
              headers: {
                'Authorization': _user.token,
                'App-Version': appVersion
              }));
      for (var i in response.data) {
        Event e = Event.basic(i, null);
        DateTime date = DateTime.parse(e.startDate.substring(0, 10));
        result[date] ??= [];
        result[date]?.add(e);
      }
    } catch (e) {}
    return result;
  }

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  List<DateTime> daysInRange(DateTime first, DateTime last) {
    final dayCount = last.difference(first).inDays + 1;
    return List.generate(
      dayCount,
      (index) => DateTime.utc(first.year, first.month, first.day + index),
    );
  }

  _onAddEvent() {
    if (_rangeEnd != null) {
      Navigator.of(context)
          .pushNamed('/addEvent', arguments: [_rangeStart, _rangeEnd]).then((value) => refresh());
    } else {
      Navigator.of(context)
          .pushNamed('/addEvent', arguments: [_focusedDay]).then((value) => refresh());
    }
  }
}
