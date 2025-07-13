import SwiftUI
import AVFoundation
import Vision
import Combine

class ScanViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var recognizedFood: FoodItem?
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String?
    @Published var recentScans: [FoodItem] = []
    @Published var showingResult: Bool = false
    
    init() {
        loadRecentScans()
    }
    
    func processImage(_ image: UIImage) {
        print("✅ Processing image of size: \(image.size)")
        isProcessing = true
        errorMessage = nil
        
        Task {
            do {
                // Step 1: Basic image recognition (using mock for now)
                let recognizedFoodName = await recognizeFoodFromImage(image)
                print("✅ Recognized food: \(recognizedFoodName)")
                
                // Step 2: Get nutrition data from API with fallback
                if let nutritionData = await NutritionService.shared.searchWithFallback(recognizedFoodName) {
                    DispatchQueue.main.async {
                        self.recognizedFood = nutritionData
                        self.recentScans.insert(nutritionData, at: 0)
                        self.isProcessing = false
                        self.showingResult = true
                        print("✅ Food processing completed: \(nutritionData.name)")
                    }
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage = "Could not find nutrition data for \(recognizedFoodName)"
                        self.isProcessing = false
                        print("❌ No nutrition data found for: \(recognizedFoodName)")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Error processing image: \(error.localizedDescription)"
                    self.isProcessing = false
                    print("❌ Image processing error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func recognizeFoodFromImage(_ image: UIImage) async -> String {
        // Use ML service for food recognition
        let result = await MLFoodRecognitionService.shared.recognizeFood(in: image)
        
        print("🤖 ML Recognition Result:")
        print("   Food: \(result.displayName)")
        print("   Confidence: \(result.confidencePercentage)%")
        print("   Indian Food: \(result.isIndianFood)")
        print("   Fallback Used: \(result.fallbackUsed)")
        
        return result.displayName
    }
    
    private func loadRecentScans() {
        // Load sample data initially, will be updated by Firestore listener
        recentScans = Array(FoodItem.sampleFoods.prefix(5))
        
        // Listen for Firestore updates
        Task { @MainActor in
            if !FirestoreService.shared.userFoodHistory.isEmpty {
                recentScans = Array(FirestoreService.shared.userFoodHistory.prefix(5))
            }
        }
    }
    
    func clearResults() {
        selectedImage = nil
        recognizedFood = nil
        showingResult = false
        errorMessage = nil
    }
    
    func saveToHistory() {
        guard let food = recognizedFood else { return }
        
        Task {
            await FirestoreService.shared.saveFoodScan(food)
        }
        
        print("Saving to history: \(food.name)")
    }
    
    // Manual food search for user corrections
    func searchFood(_ foodName: String) {
        isProcessing = true
        errorMessage = nil
        
        Task {
            if let nutritionData = await NutritionService.shared.searchWithFallback(foodName) {
                DispatchQueue.main.async {
                    self.recognizedFood = nutritionData
                    self.recentScans.insert(nutritionData, at: 0)
                    self.isProcessing = false
                    self.showingResult = true
                }
            } else {
                DispatchQueue.main.async {
                    self.errorMessage = "Could not find nutrition data for '\(foodName)'"
                    self.isProcessing = false
                }
            }
        }
    }
}