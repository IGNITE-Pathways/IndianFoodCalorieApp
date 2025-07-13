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
        isProcessing = true
        errorMessage = nil
        
        // Simulate ML processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Mock food recognition - in production, this would call your ML model
            let mockResult = self.mockFoodRecognition()
            self.recognizedFood = mockResult
            self.recentScans.insert(mockResult, at: 0)
            self.isProcessing = false
            self.showingResult = true
        }
    }
    
    private func mockFoodRecognition() -> FoodItem {
        let sampleFoods = FoodItem.sampleFoods
        return sampleFoods.randomElement() ?? sampleFoods[0]
    }
    
    private func loadRecentScans() {
        // Load from local storage or sample data
        recentScans = Array(FoodItem.sampleFoods.prefix(5))
    }
    
    func clearResults() {
        selectedImage = nil
        recognizedFood = nil
        showingResult = false
        errorMessage = nil
    }
    
    func saveToHistory() {
        guard let food = recognizedFood else { return }
        // In production, save to Firestore
        print("Saving to history: \(food.name)")
    }
}