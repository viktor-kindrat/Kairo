import 'package:flutter/material.dart';
import 'package:kairo/core/utils/snackbar_extensions.dart';
import 'package:kairo/features/profile/models/slack_connection_status.dart';
import 'package:kairo/features/profile/repositories/slack_connection_repository.dart';
import 'package:kairo/features/profile/widgets/profile_account_row.dart';
import 'package:kairo/features/profile/widgets/slack_connection_action_button.dart';

class SlackConnectionTile extends StatefulWidget {
  const SlackConnectionTile({super.key});

  @override
  State<SlackConnectionTile> createState() => _SlackConnectionTileState();
}

class _SlackConnectionTileState extends State<SlackConnectionTile>
    with WidgetsBindingObserver {
  final SlackConnectionRepository _repository = SlackConnectionRepository();

  SlackConnectionStatus _status = const SlackConnectionStatus(connected: false);
  bool _isBusy = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfileAccountRow(
      backgroundTint: const Color(0xFFF5EEFF),
      borderTint: const Color(0xFFE0CCFF),
      iconColor: const Color(0xFF6B4EFF),
      icon: Icons.link_rounded,
      title: _status.connected ? 'Slack connected' : 'Connect Slack',
      subtitle: _isLoading ? 'Checking Slack connection...' : _status.subtitle,
      trailing: SlackConnectionActionButton(
        connected: _status.connected,
        isBusy: _isBusy || _isLoading,
        onPressed: _handleAction,
      ),
    );
  }

  Future<void> _handleAction() async {
    if (_status.connected) {
      await _disconnect();
      return;
    }

    await _connect();
  }

  Future<void> _connect() async {
    await _runBusyAction(() async {
      await _repository.connect();

      if (!mounted) {
        return;
      }

      context.showSuccessSnackBar('Finish Slack authorization in browser.');
    });
  }

  Future<void> _disconnect() async {
    await _runBusyAction(() async {
      await _repository.disconnect();
      await _loadStatus();

      if (mounted) {
        context.showSuccessSnackBar('Slack disconnected.');
      }
    });
  }

  Future<void> _loadStatus() async {
    try {
      final status = await _repository.getStatus();

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _status = status;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _runBusyAction(Future<void> Function() action) async {
    if (_isBusy) {
      return;
    }

    setState(() => _isBusy = true);

    try {
      await action();
    } on SlackConnectionException catch (error) {
      if (mounted) {
        context.showErrorSnackBar(error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }
}
