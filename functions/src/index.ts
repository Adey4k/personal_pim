import { onCall, HttpsError } from "firebase-functions/v2/https";
import { GoogleGenerativeAI } from "@google/generative-ai";

export const askGemini = onCall({ 
    secrets: ["GEMINI_API_KEY"],
    maxInstances: 5, 
    timeoutSeconds: 30
}, async (request) => {
    if (!request.auth) {
        throw new HttpsError("unauthenticated", "Authenification required.");
    }

    const prompt = request.data.prompt;
    if (!prompt) {
         throw new HttpsError("invalid-argument", "Lacks text.");
    }

    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY as string);
    const model = genAI.getGenerativeModel({ model: "gemini-flash-latest" });

    try {
        const result = await model.generateContent(prompt);
        return { text: result.response.text() };
    } catch (error) {
        console.error("Gemini API Error:", error);
        throw new HttpsError("internal", "Reply generation error.");
    }
});