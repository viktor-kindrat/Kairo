import 'package:flutter/material.dart';
import 'package:kairo/features/home/controllers/status_controller.dart';

class StatusContext extends InheritedNotifier<StatusController> {
  const StatusContext({
    required StatusController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static StatusController of(BuildContext context) {
    final statusContext = context
        .dependOnInheritedWidgetOfExactType<StatusContext>();

    assert(statusContext != null, 'StatusContext is missing in widget tree.');

    return statusContext!.notifier!;
  }
}

extension StatusContextExtension on BuildContext {
  StatusController get statuses => StatusContext.of(this);
}
