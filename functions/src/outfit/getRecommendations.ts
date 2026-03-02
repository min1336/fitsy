import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore } from "firebase-admin/firestore";
import { getTextModel } from "../shared/gemini";
import { buildOutfitRecommendationPrompt } from "../shared/prompts";

export const getRecommendations = onCall(
  { region: "asia-northeast3" },
  async (request) => {
    const userId = request.data.userId as string;
    if (!userId) {
      throw new HttpsError("invalid-argument", "userId is required");
    }

    const db = getFirestore();

    const userDoc = await db.collection("users").doc(userId).get();
    const stylePreferences: string[] =
      userDoc.data()?.stylePreferences || [];

    const clothesSnapshot = await db
      .collection("users")
      .doc(userId)
      .collection("clothes")
      .where("isActive", "==", true)
      .get();

    if (clothesSnapshot.empty) {
      throw new HttpsError(
        "failed-precondition",
        "No clothes found in closet"
      );
    }

    const clothes = clothesSnapshot.docs.map((doc) => ({
      id: doc.id,
      category: doc.data().category as string,
      subcategory: doc.data().subcategory as string,
      color: doc.data().color as string[],
      tags: doc.data().tags as string[],
    }));

    try {
      const model = getTextModel();
      const prompt = buildOutfitRecommendationPrompt(clothes, stylePreferences);
      const result = await model.generateContent(prompt);
      const responseText = result.response.text();
      const outfits = JSON.parse(responseText);

      const savedOutfits = [];
      for (const outfit of outfits) {
        const outfitRef = db
          .collection("users")
          .doc(userId)
          .collection("outfits")
          .doc();

        const outfitData = {
          clothIds: outfit.clothIds,
          prompt: outfit.prompt,
          createdAt: new Date(),
        };

        await outfitRef.set(outfitData);
        savedOutfits.push({ id: outfitRef.id, ...outfitData });
      }

      return { outfits: savedOutfits };
    } catch (error) {
      throw new HttpsError("internal", "Failed to generate recommendations");
    }
  }
);
