import 'dart:async';

import 'package:flutter/foundation.dart';

class ResendCountdownController extends ValueNotifier<int> {
  final int initialSeconds;
  Timer? _timer;

  ResendCountdownController({required this.initialSeconds})
    : super(initialSeconds);

  bool get isActive => value > 0;

  void start() {
    value = initialSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (value > 0) {
        value -= 1;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
