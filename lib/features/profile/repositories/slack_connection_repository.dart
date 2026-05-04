import 'package:cloud_functions/cloud_functions.dart';
import 'package:kairo/features/profile/models/slack_connection_status.dart';
import 'package:url_launcher/url_launcher.dart';

class SlackConnectionException implements Exception {
  final String message;

  const SlackConnectionException(this.message);

  @override
  String toString() => message;
}

class SlackConnectionRepository {
  final FirebaseFunctions _functions;

  SlackConnectionRepository({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  Future<void> connect() async {
    final data = await _callMap('createSlackOAuthUrl');
    final urlValue = data['url'] as String?;
    final url = Uri.tryParse(urlValue ?? '');

    if (url == null) {
      throw const SlackConnectionException(
        'We could not create a Slack connection link.',
      );
    }

    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);

    if (!launched) {
      throw const SlackConnectionException(
        'We could not open Slack authorization.',
      );
    }
  }

  Future<void> disconnect() async {
    await _functions.httpsCallable('disconnectSlack').call<void>();
  }

  Future<SlackConnectionStatus> getStatus() async {
    final data = await _callMap('getSlackConnectionStatus');
    return SlackConnectionStatus.fromMap(data);
  }

  Future<Map<String, Object?>> _callMap(String name) async {
    try {
      final result = await _functions.httpsCallable(name).call<Object?>();
      final data = result.data;

      if (data is! Map) {
        throw const SlackConnectionException(
          'Slack integration returned an invalid response.',
        );
      }

      return data.map((key, value) => MapEntry(key.toString(), value));
    } on FirebaseFunctionsException catch (error) {
      throw SlackConnectionException(
        error.message ?? 'Slack integration failed. Please try again.',
      );
    }
  }
}
