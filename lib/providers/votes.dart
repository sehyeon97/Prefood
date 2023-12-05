import 'package:flutter_riverpod/flutter_riverpod.dart';

// String : name of place + int : vote count
class VotesNotifier extends StateNotifier<Map<String, int>> {
  VotesNotifier() : super({});

  // adding
  void updateData(String name) {
    if (state.containsKey(name)) {
      int votes = state['name']! + 1;
      state = {...state, name: votes};
    } else {
      state = {...state, name: 1};
    }
  }

  void removeData(String name) {
    Map<String, int> temp = Map.of(state);
    temp.remove(name);
    state = temp;
  }

  // used for setting the y axis for the chart
  int getTotalVotes() {
    int votes = 0;

    for (String key in state.keys) {
      votes += state[key]!;
    }

    return votes;
  }
}

final votesProviders =
    StateNotifierProvider<VotesNotifier, Map<String, int>>((ref) {
  return VotesNotifier();
});

// stores all places that have been voted
// use this to determine whether to make changes to bar data in chart.dart
class BarDataNotifier extends StateNotifier<Set<String>> {
  BarDataNotifier() : super({});

  void add(String place) {
    state = {...state, place};
  }

  void remove(String place) {
    Set<String> temp = Set.of(state);
    temp.remove(place);
    state = temp;
  }

  bool contains(String place) {
    return state.contains(place);
  }
}

final barDataProvider =
    StateNotifierProvider<BarDataNotifier, Set<String>>((ref) {
  return BarDataNotifier();
});
