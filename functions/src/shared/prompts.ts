export const CLOTH_CLASSIFICATION_PROMPT = `
You are a fashion AI assistant. Analyze the clothing item in this image and return a JSON object with the following fields:
- category: one of ["상의", "하의", "외투", "신발", "악세서리"]
- subcategory: specific type (e.g., "반팔티", "청바지", "운동화", "후드집업")
- color: array of colors detected (in Korean, e.g., ["검정", "흰색"])
- season: array of suitable seasons (from ["봄", "여름", "가을", "겨울"])
- tags: array of style tags (e.g., ["캐주얼", "스포티", "데일리"])

Return ONLY valid JSON, no markdown or explanation.
`;

export function buildOutfitRecommendationPrompt(
  clothes: Array<{ id: string; category: string; subcategory: string; color: string[]; tags: string[] }>,
  stylePreferences: string[]
): string {
  return `
You are a Korean fashion stylist AI. Create 3-5 outfit combinations from the user's wardrobe.

User's style preferences: ${stylePreferences.join(", ")}

Available clothes:
${JSON.stringify(clothes, null, 2)}

For each outfit, return a JSON array of objects with:
- clothIds: array of cloth IDs that form the outfit
- prompt: a short Korean description of the outfit style (e.g., "캐주얼한 데일리 룩")

Return ONLY a valid JSON array, no markdown or explanation.
`;
}

export function buildOutfitImagePrompt(
  clothDescriptions: string[],
  style: string
): string {
  return `
Create a flat-lay style fashion image showing these clothing items arranged together:
${clothDescriptions.join("\n")}

Style: ${style}
The image should look like a professional fashion magazine flat-lay photo with a clean white background.
`;
}
