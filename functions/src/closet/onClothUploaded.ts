import * as functions from "firebase-functions/v2";
import { getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { getTextModel } from "../shared/gemini";
import { CLOTH_CLASSIFICATION_PROMPT } from "../shared/prompts";

export const onClothUploaded = functions.storage.onObjectFinalized(
  { region: "asia-northeast3" },
  async (event) => {
    const filePath = event.data.name;
    if (!filePath || !filePath.startsWith("users/")) return;

    // Path: users/{userId}/clothes/{clothId}/original.jpg
    const parts = filePath.split("/");
    if (parts.length < 4 || parts[2] !== "clothes") return;

    const userId = parts[1];
    const clothId = parts[3];

    const db = getFirestore();
    const bucket = getStorage().bucket();

    try {
      const file = bucket.file(filePath);
      const [buffer] = await file.download();
      const base64Image = buffer.toString("base64");
      const mimeType = event.data.contentType || "image/jpeg";

      const model = getTextModel();
      const result = await model.generateContent([
        { text: CLOTH_CLASSIFICATION_PROMPT },
        {
          inlineData: {
            mimeType,
            data: base64Image,
          },
        },
      ]);

      const responseText = result.response.text();
      const classification = JSON.parse(responseText);

      await db
        .collection("users")
        .doc(userId)
        .collection("clothes")
        .doc(clothId)
        .set(
          {
            imageUrl: `gs://${bucket.name}/${filePath}`,
            category: classification.category || "미분류",
            subcategory: classification.subcategory || "",
            color: classification.color || [],
            season: classification.season || [],
            tags: classification.tags || [],
            createdAt: new Date(),
            isActive: true,
          },
          { merge: true }
        );

      functions.logger.info(`Classified cloth ${clothId} for user ${userId}`);
    } catch (error) {
      functions.logger.error("Classification failed:", error);

      await db
        .collection("users")
        .doc(userId)
        .collection("clothes")
        .doc(clothId)
        .set(
          {
            category: "미분류",
            subcategory: "",
            color: [],
            season: [],
            tags: [],
            createdAt: new Date(),
            isActive: true,
          },
          { merge: true }
        );
    }
  }
);
