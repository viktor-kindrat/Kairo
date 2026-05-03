import 'package:kairo/core/models/status_preset.dart';

class CubeStatusDefinition {
  final String cubeFace;
  final String label;
  final String slackEmojiCode;
  final int sortOrder;

  const CubeStatusDefinition({
    required this.cubeFace,
    required this.label,
    required this.slackEmojiCode,
    required this.sortOrder,
  });

  StatusPreset toPreset({required String id, required bool isActive}) {
    return StatusPreset(
      cubeFace: cubeFace,
      id: id,
      isActive: isActive,
      label: label,
      slackEmojiCode: slackEmojiCode,
      sortOrder: sortOrder,
    );
  }
}

const List<CubeStatusDefinition> defaultCubeStatusDefinitions = [
  CubeStatusDefinition(
    cubeFace: 'faceUp',
    label: 'Deep Work',
    slackEmojiCode: ':zap:',
    sortOrder: 0,
  ),
  CubeStatusDefinition(
    cubeFace: 'faceDown',
    label: 'Break',
    slackEmojiCode: ':coffee:',
    sortOrder: 1,
  ),
  CubeStatusDefinition(
    cubeFace: 'left',
    label: 'Meeting',
    slackEmojiCode: ':busts_in_silhouette:',
    sortOrder: 2,
  ),
  CubeStatusDefinition(
    cubeFace: 'right',
    label: 'Lunch',
    slackEmojiCode: ':fork_and_knife:',
    sortOrder: 3,
  ),
  CubeStatusDefinition(
    cubeFace: 'forward',
    label: 'Ideation',
    slackEmojiCode: ':bulb:',
    sortOrder: 4,
  ),
  CubeStatusDefinition(
    cubeFace: 'backward',
    label: 'Urgent',
    slackEmojiCode: ':fire:',
    sortOrder: 5,
  ),
];
