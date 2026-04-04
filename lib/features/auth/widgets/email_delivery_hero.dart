import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kairo/core/widgets/kairo_email_pill.dart';
import 'package:kairo/core/widgets/kairo_headline.dart';

class EmailDeliveryHero extends StatelessWidget {
  final String email;
  final String headline;
  final String illustrationAsset;
  final String subHeadline;

  const EmailDeliveryHero({
    required this.email,
    required this.headline,
    required this.subHeadline,
    super.key,
    this.illustrationAsset = 'assets/illustrations/mail_check.svg',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 32,
      children: [
        SvgPicture.asset(illustrationAsset, height: 240),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            KairoHeadline(headline: headline, subHeadline: subHeadline),
            KairoEmailPill(email: email),
          ],
        ),
      ],
    );
  }
}
