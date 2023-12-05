import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prefoods/providers/payer_provider.dart';
import 'package:prefoods/styles/text.dart';

class PayerInfo extends ConsumerStatefulWidget {
  const PayerInfo({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _PayerInfoState();
  }
}

class _PayerInfoState extends ConsumerState<PayerInfo> {
  final _payerController = TextEditingController();

  void _onSetPayerInfo() {
    ref.read(payerProvider.notifier).setPayer(_payerController.text);
  }

  @override
  void dispose() {
    _payerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Payer Name',
          style: titleStyle,
        ),
        TextField(
          controller: _payerController,
        ),
        ElevatedButton(
          onPressed: () {
            _onSetPayerInfo();
          },
          child: const Text('Set'),
        ),
      ],
    );
  }
}
