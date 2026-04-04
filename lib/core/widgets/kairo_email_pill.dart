import 'package:flutter/material.dart';
import 'package:kairo/core/widgets/kairo_pill.dart';

class KairoEmailPill extends StatelessWidget {
  final String email;

  const KairoEmailPill({required this.email, super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: KairoPill(icon: Icons.email_outlined, text: email),
    );
  }
}
