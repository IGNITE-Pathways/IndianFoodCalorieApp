import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import axios from "axios";
import * as cors from "cors";

// Initialize Firebase Admin
admin.initializeApp();

const corsHandler = cors({origin: true});

// Nutrition API Function
export const getNutritionData = functions.https.onRequest((request, response) => {
  return corsHandler(request, response, async () => {
    try {
      const {foodName} = request.body;
      
      if (!foodName) {
        response.status(400).json({error: "Food name is required"});
        return;
      }

      // Call CalorieNinjas API
      const apiKey = functions.config().calorie_ninjas.api_key;
      const nutritionResponse = await axios.get(
        `https://api.calorieninjas.com/v1/nutrition?query=${encodeURIComponent(foodName)}`,
        {
          headers: {
            "X-Api-Key": apiKey,
          },
        }
      );

      const nutritionData = nutritionResponse.data;
      
      // Store in Firestore for caching
      await admin.firestore().collection("nutrition").doc(foodName.toLowerCase()).set({
        ...nutritionData,
        cachedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      response.json(nutritionData);
    } catch (error) {
      console.error("Error fetching nutrition data:", error);
      response.status(500).json({error: "Failed to fetch nutrition data"});
    }
  });
});

// Food Recognition Function
export const recognizeFood = functions.https.onRequest((request, response) => {
  return corsHandler(request, response, async () => {
    try {
      const {imageBase64, userId} = request.body;
      
      if (!imageBase64 || !userId) {
        response.status(400).json({error: "Image data and user ID are required"});
        return;
      }

      // In production, this would call your ML model
      // For now, return mock data
      const mockRecognition = {
        foodName: "Chicken Biryani",
        confidence: 0.92,
        calories: 650,
        protein: 25,
        carbohydrates: 75,
        fat: 18,
        fiber: 3,
        servingSize: "1 plate (200g)",
      };

      // Save scan to user's history
      await admin.firestore()
        .collection("users")
        .doc(userId)
        .collection("foodScans")
        .add({
          ...mockRecognition,
          scannedAt: admin.firestore.FieldValue.serverTimestamp(),
          imageUrl: "", // Would be the uploaded image URL
        });

      response.json(mockRecognition);
    } catch (error) {
      console.error("Error recognizing food:", error);
      response.status(500).json({error: "Failed to recognize food"});
    }
  });
});

// User Profile Function
export const updateUserProfile = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError("unauthenticated", "User must be authenticated");
  }

  const userId = context.auth.uid;
  const {name, age, weight, height, activityLevel, goal} = data;

  try {
    // Calculate TDEE and targets
    const bmr = calculateBMR(weight, height, age, "male"); // Default to male for now
    const tdee = bmr * getActivityMultiplier(activityLevel);
    const calorieTarget = Math.round(tdee + getGoalAdjustment(goal));

    const userProfile = {
      name,
      age,
      weight,
      height,
      activityLevel,
      goal,
      dailyCalorieTarget: calorieTarget,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await admin.firestore().collection("users").doc(userId).update(userProfile);

    return {success: true, calorieTarget};
  } catch (error) {
    console.error("Error updating user profile:", error);
    throw new functions.https.HttpsError("internal", "Failed to update profile");
  }
});

// Helper Functions
function calculateBMR(weight: number, height: number, age: number, gender: string): number {
  if (gender === "male") {
    return 10 * weight + 6.25 * height - 5 * age + 5;
  } else {
    return 10 * weight + 6.25 * height - 5 * age - 161;
  }
}

function getActivityMultiplier(level: string): number {
  const multipliers: {[key: string]: number} = {
    "sedentary": 1.2,
    "lightly_active": 1.375,
    "moderately_active": 1.55,
    "very_active": 1.725,
    "extremely_active": 1.9,
  };
  return multipliers[level] || 1.55;
}

function getGoalAdjustment(goal: string): number {
  const adjustments: {[key: string]: number} = {
    "lose_weight": -500,
    "maintain_weight": 0,
    "gain_weight": 300,
    "build_muscle": 200,
    "improve_health": 0,
  };
  return adjustments[goal] || 0;
}

// Scheduled function to update food database
export const updateFoodDatabase = functions.pubsub
  .schedule("0 2 * * *") // Daily at 2 AM
  .onRun(async () => {
    try {
      // Update nutrition data for popular foods
      const popularFoods = [
        "biryani", "idli", "dosa", "roti", "dal", "samosa", 
        "chole bhature", "paneer butter masala", "rajma", "masala dosa"
      ];

      const batch = admin.firestore().batch();
      
      for (const food of popularFoods) {
        const nutritionRef = admin.firestore().collection("foods").doc(food);
        
        // In production, fetch real nutrition data
        const mockData = {
          name: food,
          lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
          verified: true,
        };
        
        batch.set(nutritionRef, mockData, {merge: true});
      }

      await batch.commit();
      console.log("Food database updated successfully");
    } catch (error) {
      console.error("Error updating food database:", error);
    }
  });

// Achievement System
export const checkAchievements = functions.firestore
  .document("users/{userId}/foodScans/{scanId}")
  .onCreate(async (snap, context) => {
    const userId = context.params.userId;
    const userRef = admin.firestore().collection("users").doc(userId);
    
    try {
      // Get user's total scans
      const scansSnapshot = await admin.firestore()
        .collection("users")
        .doc(userId)
        .collection("foodScans")
        .get();
      
      const totalScans = scansSnapshot.size;
      
      // Check for achievements
      const achievements = [];
      
      if (totalScans === 1) {
        achievements.push({
          title: "First Scan",
          description: "Complete your first food scan",
          unlockedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
      
      if (totalScans === 100) {
        achievements.push({
          title: "Scanner Pro",
          description: "Complete 100 food scans",
          unlockedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
      
      // Save achievements
      const batch = admin.firestore().batch();
      achievements.forEach((achievement, index) => {
        const achievementRef = admin.firestore()
          .collection("users")
          .doc(userId)
          .collection("achievements")
          .doc(`scan_${totalScans}_${index}`);
        batch.set(achievementRef, achievement);
      });
      
      if (achievements.length > 0) {
        await batch.commit();
        console.log(`Awarded ${achievements.length} achievements to user ${userId}`);
      }
    } catch (error) {
      console.error("Error checking achievements:", error);
    }
  });