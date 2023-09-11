// ignore_for_file: use_build_context_synchronously

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:manage_calendar_events/manage_calendar_events.dart';

class CalenderEventHelper {
  static final CalendarPlugin calender = CalendarPlugin();

  // Future<List<CalendarEvent>?> _fetchEvents(String calenderId) async {
  //   return myPlugin.getEvents(calendarId: calenderId);
  // return _fetchEventsByDateRange();
  // return _myPlugin.getEventsByMonth(
  //     calendarId: this.widget.calendarId,
  //     findDate: DateTime(2020, DateTime.december, 15));
  // return _myPlugin.getEventsByWeek(
  //     calendarId: this.widget.calendarId,
  //     findDate: DateTime(2021, DateTime.june, 1));
  // }

  // ignore: unused_element
  // Future<List<CalendarEvent>?> _fetchEventsByDateRange() async {
  //   DateTime endDate =
  //   DateTime.now().toUtc().add(Duration(hours: 23, minutes: 59));
  //   DateTime startDate = endDate.subtract(Duration(days: 3));
  //   return _myPlugin.getEventsByDateRange(
  //     calendarId: this.widget.calendarId,
  //     startDate: startDate,
  //     endDate: endDate,
  //   );
  // }

  // void _updateEvent(CalendarEvent event) async {
  //   event.title = 'Updated from Event';
  //   event.description = 'Test description is updated now';
  //   event.attendees = Attendees(
  //     attendees: [
  //       Attendee(emailAddress: 'updatetest@gmail.com', name: 'Update Test'),
  //     ],
  //   );
  //   _myPlugin
  //       .updateEvent(calendarId: widget.calendarId, event: event)
  //       .then((eventId) {
  //     debugPrint('${event.eventId} is updated to $eventId');
  //   });
  //
  //   if (event.hasAlarm!) {
  //     _updateReminder(event.eventId!, 65);
  //   } else {
  //     _addReminder(event.eventId!, -30);
  //   }
  // }
  //
  // void _addReminder(String eventId, int minutes) async {
  //   _myPlugin.addReminder(
  //       calendarId: widget.calendarId, eventId: eventId, minutes: minutes);
  // }
  //
  // void _updateReminder(String eventId, int minutes) async {
  //   _myPlugin.updateReminder(
  //       calendarId: widget.calendarId, eventId: eventId, minutes: minutes);
  // }

  // void _deleteReminder(String eventId) async {
  //   myPlugin.deleteReminder(eventId: eventId);
  // }

  static Future<dynamic> manageEvent(
      Map<String, dynamic> argData, BuildContext context, String? eventId) async {
    List<Calendar>? calenders = await calender.getCalendars();
    DateTime startDate = DateTime.now();
    DateTime endDate = startDate.add(const Duration(hours: 3));
    if (calenders != null && calenders.isNotEmpty) {
      String calenderId = await getMyCalender(calenders, context);
      if (argData['action'] == "addEvent") {
        CalendarEvent newEvent = CalendarEvent(
          title: argData['title'],
          description: 'test description',
          startDate: startDate,
          endDate: endDate,
          location: 'At my House',
          url: 'https://www.google.com',
          attendees: Attendees(
            attendees: [
              Attendee(emailAddress: 'test1@gmail.com', name: 'Test1'),
              Attendee(emailAddress: 'test2@gmail.com', name: 'Test2'),
            ],
          ),
        );
        String? event =
            await calender.createEvent(calendarId: calenderId, event: newEvent);
        return event;
      } else {
        bool? isDelete = await calender.deleteEvent(
            calendarId: calenderId, eventId: eventId ?? "1");
        return isDelete;
      }
    }
  }

  static Future<String> getMyCalender(
      List<Calendar> calenders, BuildContext context) async {
    Calendar currentCalender = calenders[0];
    await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Choose Calender",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    itemCount: calenders.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                          onTap: () {
                            currentCalender = calenders[index];
                            context.router.pop();
                          },
                          child: Text(calenders[index].name ?? "Unknown"));
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 10);
                    },
                  ),
                  const SizedBox(
                    height: 14,
                  )
                ],
              ),
            ),
          );
        });
    return currentCalender.id ?? "0";
  }
}
