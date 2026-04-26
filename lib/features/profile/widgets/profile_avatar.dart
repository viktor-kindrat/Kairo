import 'package:flutter/material.dart';
import 'package:kairo/core/models/local_user.dart';
import 'package:kairo/core/theme/app_colors.dart';
import 'package:kairo/core/utils/responsive_utils.dart';

class ProfileAvatar extends StatelessWidget {
  final VoidCallback onTap;
  final LocalUser user;

  const ProfileAvatar({required this.onTap, required this.user, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
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
              colors: [AppColors.proGradientEnd, AppColors.proGradientStart],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: CircleAvatar(
            radius: context.sp(62),
            backgroundColor: const Color(0xFF6E22D6),
            child: ClipOval(child: SizedBox.expand(child: _avatarContent())),
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
              onTap: onTap,
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
    );
  }

  Widget _avatarContent() {
    final avatarUrl = user.avatarUrl;

    if (_isNetworkUrl(avatarUrl)) {
      return Image.network(
        avatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _AvatarInitials(initials: _buildInitials());
        },
      );
    }

    return _AvatarInitials(initials: _buildInitials());
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

  bool _isNetworkUrl(String? avatarUrl) {
    final uri = Uri.tryParse(avatarUrl ?? '');
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }
}

class _AvatarInitials extends StatelessWidget {
  final String initials;

  const _AvatarInitials({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: context.sp(36),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
