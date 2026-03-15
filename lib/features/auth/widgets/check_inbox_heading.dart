import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kairo/core/widgets/kairo_email_pill.dart';
import 'package:kairo/core/widgets/kairo_headline.dart';

class CheckInboxHeading extends StatelessWidget {
  final String email;

  const CheckInboxHeading({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 32,
      children: [
        SvgPicture.asset('assets/illustrations/mail_check.svg', height: 240),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            const KairoHeadline(
              headline: 'Check your inbox.',
              subHeadline: 'We\'ve sent a reset link to',
            ),

            KairoEmailPill(email: email),
          ],
        ),
      ],
    );
  }
}
