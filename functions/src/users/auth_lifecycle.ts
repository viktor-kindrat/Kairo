import * as functions from "firebase-functions/v1";
import {
  deleteUserData,
  logUserDataCleanupError,
  seedDefaultStatuses,
} from "./user_data";

export const seedUserDefaultsOnCreate = functions.auth.user().onCreate(
  async (user) => {
    await seedDefaultStatuses(user.uid);
  },
);

export const cleanupUserDataOnDelete = functions.auth.user().onDelete(
  async (user) => {
    try {
      await deleteUserData(user.uid);
    } catch (error) {
      logUserDataCleanupError(user.uid, error);
      throw error;
    }
  },
);
