import { GoogleGenerativeAI } from "@google/generative-ai";
import { defineString } from "firebase-functions/params";

const geminiApiKey = defineString("GEMINI_API_KEY");

let genAI: GoogleGenerativeAI | null = null;

export function getGeminiClient(): GoogleGenerativeAI {
  if (!genAI) {
    genAI = new GoogleGenerativeAI(geminiApiKey.value());
  }
  return genAI;
}

export function getTextModel() {
  return getGeminiClient().getGenerativeModel({ model: "gemini-2.0-flash" });
}

export function getImageModel() {
  return getGeminiClient().getGenerativeModel({ model: "gemini-2.0-flash" });
}
