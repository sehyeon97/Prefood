import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prefoods/models/user_model.dart';

// Currently, instead of ID, user is identified by a non-unique name
// They also need to create groups on app open
// this is because a database isn't utilized
class UserNotifier extends StateNotifier<UserModel> {
  UserNotifier()
      : super(
          const UserModel(name: '', groups: []),
        );

  void setUser(String name) {
    state = UserModel(name: name, groups: []);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserModel>((ref) {
  return UserNotifier();
});
