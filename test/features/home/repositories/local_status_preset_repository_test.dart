import 'package:flutter_test/flutter_test.dart';
import 'package:kairo/core/models/status_preset.dart';
import 'package:kairo/features/home/repositories/local_status_preset_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalStatusPresetRepository', () {
    late SharedPreferences preferences;
    late LocalStatusPresetRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferences = await SharedPreferences.getInstance();
      repository = LocalStatusPresetRepository(preferences);
    });

    test('create, update, setActive and delete preset', () async {
      const firstPreset = StatusPreset(
        id: 'one',
        label: 'Deep Work',
        iconKey: 'bolt',
        isActive: true,
      );
      const secondPreset = StatusPreset(
        id: 'two',
        label: 'Meeting',
        iconKey: 'groups_outlined',
        isActive: false,
      );

      await repository.create(firstPreset);
      await repository.create(secondPreset);
      await repository.update(secondPreset.copyWith(label: 'Client Meeting'));
      await repository.setActive('two');

      final storedPresets = await repository.getAll();

      expect(storedPresets, hasLength(2));
      expect(storedPresets.last.label, 'Client Meeting');
      expect(storedPresets.last.isActive, isTrue);
      expect(storedPresets.first.isActive, isFalse);

      final presetsAfterDelete = await repository.delete('one');

      expect(presetsAfterDelete, hasLength(1));
      expect(presetsAfterDelete.single.id, 'two');
    });
  });
}
