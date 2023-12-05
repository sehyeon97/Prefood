import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prefoods/models/group.dart';
import 'package:prefoods/providers/delivery_address_provider.dart';
import 'package:prefoods/providers/selected_event_day.dart';
import 'package:prefoods/screens/group/event_details.dart';

import 'package:table_calendar/table_calendar.dart';

class Calendar extends ConsumerStatefulWidget {
  const Calendar({
    super.key,
    required this.group,
  });

  final Group group;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _CalendarState();
  }
}

class _CalendarState extends ConsumerState<Calendar> {
  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();

    return TableCalendar(
      focusedDay: today,
      firstDay: DateTime(
        today.year,
        today.month,
        today.day,
      ),
      lastDay: DateTime(
        today.year,
        today.month,
        today.day + 14,
      ),
      calendarFormat: CalendarFormat.twoWeeks,
      onDaySelected: (selectedDay, focusedDay) {
        ref.read(selectedDayProvider.notifier).setEventDate(selectedDay);
        ref
            .read(addressProvider.notifier)
            .checkFirestoreModifyAddress(ref, selectedDay);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (contxt) => EventDetailsScreen(
              selectedDay: selectedDay,
              group: widget.group,
            ),
          ),
        );
      },
    );
  }
}
