String slackEmojiGlyph(String? emojiCode) {
  final normalizedCode = emojiCode?.trim();

  if (normalizedCode == null || normalizedCode.isEmpty) {
    return '💬';
  }

  return _knownSlackEmojiGlyphs[normalizedCode] ?? '💬';
}

const Map<String, String> _knownSlackEmojiGlyphs = {
  ':zap:': '⚡',
  ':coffee:': '☕',
  ':busts_in_silhouette:': '👥',
  ':fork_and_knife:': '🍴',
  ':bulb:': '💡',
  ':fire:': '🔥',
};
