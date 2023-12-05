import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prefoods/providers/current_group_id_provider.dart';
import 'package:prefoods/providers/delivery_address_provider.dart';
import 'package:prefoods/providers/selected_event_day.dart';
import 'package:prefoods/styles/text.dart';

class DeliveryAddress extends ConsumerStatefulWidget {
  const DeliveryAddress({super.key});

  @override
  ConsumerState<DeliveryAddress> createState() {
    return _DeliveryAddressState();
  }
}

class _DeliveryAddressState extends ConsumerState<DeliveryAddress> {
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _onSetAddress() async {
    ref.read(addressProvider.notifier).setAddress(_addressController.text);
    final String groupID = ref.watch(groupIDProvider);
    final DateTime selectedDay = ref.watch(selectedDayProvider);

    final groupDoc = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupID)
        .get();
    List groupEvents = groupDoc.data()!['events'];
    groupEvents.add({
      "selectedMonth": selectedDay.month,
      "selectedDay": selectedDay.day,
      "selectedYear": selectedDay.year,
      "deliveryAddress": _addressController.text,
      "restaurantVotes": {},
    });

    await FirebaseFirestore.instance.collection('groups').doc(groupID).set(
      {'events': groupEvents},
      SetOptions(merge: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Delivery Address',
          style: titleStyle,
        ),
        TextField(
          controller: _addressController,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: ref.watch(addressProvider),
            alignLabelWithHint: true,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _onSetAddress();
          },
          child: const Text('Set'),
        ),
      ],
    );
  }
}
