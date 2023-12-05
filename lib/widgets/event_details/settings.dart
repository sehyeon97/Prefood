import 'package:flutter/material.dart';
import 'package:prefoods/widgets/event_details/delivery_address.dart';
import 'package:prefoods/widgets/event_details/payer_info.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const Column(
          children: [
            PayerInfo(),
            SizedBox(height: 40),
            DeliveryAddress(),
          ],
        ),
      ),
    );
  }
}
