import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedDayNotifier extends StateNotifier<DateTime> {
  SelectedDayNotifier() : super(DateTime.now());

  void setEventDate(DateTime selectedDay) {
    state = selectedDay;
  }
}

final selectedDayProvider =
    StateNotifierProvider<SelectedDayNotifier, DateTime>((ref) {
  return SelectedDayNotifier();
});
