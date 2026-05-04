export interface SlackStatusPayload {
  emoji: string;
  text: string;
}

export function asTrimmedString(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }

  const trimmed = value.trim();
  return trimmed.length === 0 ? null : trimmed;
}

export function orientationFromMqttEvent(value: unknown): string | null {
  if (!isRecord(value)) {
    return null;
  }

  return asTrimmedString(value.orientation);
}

export function truncateStatusText(value: string | null): string | null {
  if (value == null) {
    return null;
  }

  return value.length > 100 ? value.substring(0, 100) : value;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null;
}
