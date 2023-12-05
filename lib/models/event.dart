// Each event composes of:
// (1) event date
// (2) where the event is taking place
// (3) restaurantVotes:
//      key: Name of Restaurant || value: number of votes for restaurant
class Event {
  const Event({
    required this.dateTime,
    required this.deliveryAddress,
    required this.restaurantVotes,
  });

  final DateTime dateTime;
  final String deliveryAddress;
  final Map<String, int> restaurantVotes;
}
