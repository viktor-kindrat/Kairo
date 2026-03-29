import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

class ProfileHero extends StatelessWidget {
  final VoidCallback onAvatarTap;
  final LocalUser user;

  const ProfileHero({required this.onAvatarTap, required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 22,
                      spreadRadius: 4,
                    ),
                  ],
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.proGradientEnd,
                      AppColors.proGradientStart,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: CircleAvatar(
                  radius: context.sp(62),
                  backgroundColor: const Color(0xFF6E22D6),
                  child: ClipOval(
                    child: SizedBox.expand(child: _buildAvatarContent(context)),
                  ),
                ),
              ),
              Positioned(
                right: -2,
                bottom: 2,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onAvatarTap,
                    child: Padding(
                      padding: EdgeInsets.all(context.sp(12)),
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: const Color(0xFF7B7B86),
                        size: context.sp(20),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.sp(24)),
          Text(
            user.fullName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.sp(26),
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: context.sp(14)),
          DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.proGradientEnd, AppColors.proGradientStart],
              ),
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.sp(18),
                vertical: context.sp(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.workspace_premium_rounded,
                    color: Color(0xFFFFE66E),
                    size: 18,
                  ),
                  SizedBox(width: context.sp(8)),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: context.sp(180)),
                    child: Text(
                      user.roleTitle.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.sp(14),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarContent(BuildContext context) {
    final avatarPath = user.avatarPath;
    final avatarFile = avatarPath == null ? null : File(avatarPath);

    if (avatarFile != null && avatarFile.existsSync()) {
      return Image.file(avatarFile, fit: BoxFit.cover);
    }

    return Center(
      child: Text(
        _buildInitials(),
        style: TextStyle(
          color: Colors.white,
          fontSize: context.sp(36),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  String _buildInitials() {
    final parts = user.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'KA';
    }

    final firstInitial = parts.first.characters.first.toUpperCase();
    final secondInitial = parts.length > 1
        ? parts[1].characters.first.toUpperCase()
        : parts.first.characters.skip(1).firstOrNull?.toUpperCase() ?? 'A';

    return '$firstInitial$secondInitial';
  }
}
