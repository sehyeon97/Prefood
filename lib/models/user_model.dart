import 'package:prefoods/models/group.dart';

class UserModel {
  const UserModel({
    required this.name,
    required this.groups,
  });

  final String name;
  final List<Group> groups;
}
