import { onCall, HttpsError } from "firebase-functions/v2/https";
import { getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { getImageModel } from "../shared/gemini";
import { buildOutfitImagePrompt } from "../shared/prompts";

export const generateOutfitImage = onCall(
  { region: "asia-northeast3", timeoutSeconds: 120 },
  async (request) => {
    const { userId, outfitId } = request.data as {
      userId: string;
      outfitId: string;
    };

    if (!userId || !outfitId) {
      throw new HttpsError(
        "invalid-argument",
        "userId and outfitId are required"
      );
    }

    const db = getFirestore();
    const bucket = getStorage().bucket();

    const outfitDoc = await db
      .collection("users")
      .doc(userId)
      .collection("outfits")
      .doc(outfitId)
      .get();

    if (!outfitDoc.exists) {
      throw new HttpsError("not-found", "Outfit not found");
    }

    const outfitData = outfitDoc.data()!;
    const clothIds = outfitData.clothIds as string[];

    const clothDocs = await Promise.all(
      clothIds.map((id) =>
        db
          .collection("users")
          .doc(userId)
          .collection("clothes")
          .doc(id)
          .get()
      )
    );

    const clothDescriptions = clothDocs
      .filter((doc) => doc.exists)
      .map((doc) => {
        const d = doc.data()!;
        return `${d.color?.join("/")} ${d.subcategory} (${d.category})`;
      });

    try {
      const model = getImageModel();
      const prompt = buildOutfitImagePrompt(
        clothDescriptions,
        outfitData.prompt
      );
      const result = await model.generateContent(prompt);
      const response = result.response;

      const parts = response.candidates?.[0]?.content?.parts || [];
      const imagePart = parts.find(
        (p: { inlineData?: { mimeType: string } }) => p.inlineData?.mimeType?.startsWith("image/")
      );

      if (imagePart?.inlineData) {
        const imageBuffer = Buffer.from(imagePart.inlineData.data, "base64");
        const filePath = `users/${userId}/outfits/${outfitId}/generated.png`;
        const file = bucket.file(filePath);

        await file.save(imageBuffer, {
          metadata: { contentType: imagePart.inlineData.mimeType },
        });

        const imageUrl = `gs://${bucket.name}/${filePath}`;

        await outfitDoc.ref.update({ generatedImageUrl: imageUrl });

        return { imageUrl };
      }

      throw new HttpsError("internal", "No image generated");
    } catch (error) {
      if (error instanceof HttpsError) throw error;
      throw new HttpsError("internal", "Failed to generate outfit image");
    }
  }
);
