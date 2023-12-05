import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupIDNotifier extends StateNotifier<String> {
  GroupIDNotifier() : super('');

  void setGroupID(String groupID) {
    state = groupID;
  }
}

final groupIDProvider = StateNotifierProvider<GroupIDNotifier, String>((ref) {
  return GroupIDNotifier();
});
