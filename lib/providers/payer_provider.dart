import 'package:flutter_riverpod/flutter_riverpod.dart';

class PayerNotifier extends StateNotifier<String> {
  PayerNotifier() : super('');

  void setPayer(String name) {
    state = name;
  }
}

final payerProvider = StateNotifierProvider<PayerNotifier, String>((ref) {
  return PayerNotifier();
});
