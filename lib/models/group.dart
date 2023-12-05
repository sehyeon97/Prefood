import 'package:prefoods/models/event.dart';

class Group {
  const Group({
    required this.id,
    required this.name,
    required this.inviteLink,
    required this.events,
  });

  final String id;
  final String name;
  final String inviteLink;
  final List<Event> events;
}
