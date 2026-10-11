export interface CubeStatusDefinition {
  cubeFace: string;
  label: string;
  slackEmojiCode: string;
  sortOrder: number;
}

export const defaultCubeStatusDefinitions: CubeStatusDefinition[] = [
  {
    cubeFace: "faceUp",
    label: "Deep Work",
    slackEmojiCode: ":zap:",
    sortOrder: 0,
  },
  {
    cubeFace: "faceDown",
    label: "Break",
    slackEmojiCode: ":coffee:",
    sortOrder: 1,
  },
  {
    cubeFace: "left",
    label: "Meeting",
    slackEmojiCode: ":busts_in_silhouette:",
    sortOrder: 2,
  },
  {
    cubeFace: "right",
    label: "Lunch",
    slackEmojiCode: ":fork_and_knife:",
    sortOrder: 3,
  },
  {
    cubeFace: "forward",
    label: "Ideation",
    slackEmojiCode: ":bulb:",
    sortOrder: 4,
  },
  {
    cubeFace: "backward",
    label: "Urgent",
    slackEmojiCode: ":fire:",
    sortOrder: 5,
  },
];
