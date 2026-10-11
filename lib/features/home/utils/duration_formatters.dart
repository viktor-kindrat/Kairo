String formatCompactDuration(Duration duration) {
  final safeDuration = duration.isNegative ? Duration.zero : duration;
  final hours = safeDuration.inHours;
  final minutes = safeDuration.inMinutes.remainder(60);

  if (hours > 0 && minutes > 0) {
    return '${hours}h ${minutes}m';
  }

  if (hours > 0) {
    return '${hours}h';
  }

  return '${minutes}m';
}

String formatTimerDuration(Duration duration) {
  final safeDuration = duration.isNegative ? Duration.zero : duration;
  final hours = safeDuration.inHours.toString().padLeft(2, '0');
  final minutes = safeDuration.inMinutes
      .remainder(60)
      .toString()
      .padLeft(2, '0');
  final seconds = safeDuration.inSeconds
      .remainder(60)
      .toString()
      .padLeft(2, '0');

  return '$hours:$minutes:$seconds';
}
