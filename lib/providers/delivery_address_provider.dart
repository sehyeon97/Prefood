import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prefoods/providers/current_group_id_provider.dart';

class AddressNotifier extends StateNotifier<String> {
  AddressNotifier() : super('');

  void checkFirestoreModifyAddress(WidgetRef ref, DateTime selectedDay) async {
    String groupID = ref.watch(groupIDProvider);

    final groupsDocument = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupID)
        .get();
    final groupsData = groupsDocument.data()!;
    List events = groupsData['events'];

    String? deliveryAddress;
    for (final event in events) {
      if (event['selectedDay'] == selectedDay.day &&
          event['selectedMonth'] == selectedDay.month &&
          event['selectedYear'] == selectedDay.year) {
        deliveryAddress = event['deliveryAddress'];
        break;
      }
    }

    state = deliveryAddress ?? '';
  }

  void setAddress(String address) {
    state = address;
  }
}

final addressProvider = StateNotifierProvider<AddressNotifier, String>((ref) {
  return AddressNotifier();
});
