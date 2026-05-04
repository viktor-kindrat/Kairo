import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kairo/core/cubit/network_cubit.dart';
import 'package:kairo/core/cubit/network_state.dart';
import 'package:kairo/core/utils/snackbar_extensions.dart';

class NetworkWrapper extends StatelessWidget {
  final Widget child;

  const NetworkWrapper({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NetworkCubit, NetworkState>(
      listenWhen: (previous, current) =>
          current.isOffline && !previous.isOffline,
      listener: (context, state) {
        context.showErrorSnackBar(
          'Немає підключення до Інтернету. Додаток працює в офлайн-режимі',
        );
      },
      child: child,
    );
  }
}
