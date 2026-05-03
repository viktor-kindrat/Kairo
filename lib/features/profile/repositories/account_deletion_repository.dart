import 'package:cloud_functions/cloud_functions.dart';

class AccountDeletionRepository {
  final FirebaseFunctions _functions;

  AccountDeletionRepository({FirebaseFunctions? functions})
    : _functions = functions ?? FirebaseFunctions.instance;

  Future<void> deleteCurrentUserAccount() async {
    await _functions.httpsCallable('deleteCurrentUserAccount').call<void>();
  }
}
