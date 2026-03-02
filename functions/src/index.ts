import { initializeApp } from "firebase-admin/app";

initializeApp();

export { onClothUploaded } from "./closet/onClothUploaded";
export { getRecommendations } from "./outfit/getRecommendations";
export { generateOutfitImage } from "./outfit/generateOutfitImage";
