import SwiftUI
import AVFoundation

struct ScanView: View {
    @StateObject private var firestoreService = FirestoreService.shared
    @StateObject private var nutritionService = NutritionService.shared
    @StateObject private var mlService = MLFoodRecognitionService.shared
    
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingManualSearch = false
    @State private var manualSearchText = ""
    @State private var selectedImage: UIImage?
    @State private var isProcessing = false
    @State private var recognizedFood: FoodItem?
    @State private var showingResult = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                // Camera Preview Area
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 400)
                    
                    VStack {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Point camera at Indian food")
                            .font(.headline)
                            .padding(.top)
                        
                        Text("Tap camera button to scan")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                
                // Action Buttons
                HStack(spacing: 40) {
                    Button(action: {
                        showingImagePicker = true
                    }) {
                        VStack {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 24))
                            Text("Gallery")
                                .font(.caption)
                        }
                        .frame(width: 80, height: 80)
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(40)
                    }
                    
                    Button(action: {
                        showingCamera = true
                    }) {
                        VStack {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 30))
                            Text("Capture")
                                .font(.caption)
                        }
                        .frame(width: 100, height: 100)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(50)
                    }
                    
                    Button(action: {
                        showingManualSearch = true
                    }) {
                        VStack {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 24))
                            Text("Search")
                                .font(.caption)
                        }
                        .frame(width: 80, height: 80)
                        .background(Color.orange.opacity(0.1))
                        .foregroundColor(.orange)
                        .cornerRadius(40)
                    }
                }
                
                // Processing/Results Section
                if isProcessing {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Analyzing food...")
                            .font(.headline)
                            .padding(.top)
                        Text("Getting nutrition data")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                
                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                
                // Results
                if let recognizedFood = recognizedFood, showingResult {
                    FoodResultCard(food: recognizedFood) {
                        saveToHistory()
                        clearResults()
                    }
                    .padding(.horizontal)
                }
                
                // Recent Scans
                VStack(alignment: .leading) {
                    HStack {
                        Text("Recent Scans")
                            .font(.headline)
                        Spacer()
                        NavigationLink("See All", destination: HistoryView())
                            .foregroundColor(.orange)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            if firestoreService.userFoodHistory.isEmpty {
                                Text("No recent scans")
                                    .foregroundColor(.secondary)
                                    .padding()
                            } else {
                                ForEach(firestoreService.userFoodHistory.prefix(5), id: \.id) { food in
                                    RecentScanCard(food: food)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Scan Food")
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .onChange(of: selectedImage) { image in
                if let image = image {
                    processImage(image)
                }
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraView { capturedImage in
                    processImage(capturedImage)
                }
            }
            .sheet(isPresented: $showingManualSearch) {
                ManualSearchView(searchText: $manualSearchText) { foodName in
                    searchFood(foodName)
                    showingManualSearch = false
                }
            }
            .onAppear {
                firestoreService.startRealtimeListener()
            }
            .onDisappear {
                firestoreService.stopRealtimeListener()
            }
        }
    }
    
    // MARK: - Processing Functions
    private func processImage(_ image: UIImage) {
        Task {
            isProcessing = true
            errorMessage = nil
            
            do {
                // Step 1: ML Food Recognition
                let mlResult = await mlService.recognizeFood(in: image)
                print("🤖 ML Recognition: \(mlResult.displayName) (\(mlResult.confidencePercentage)%)")
                
                // Step 2: Get nutrition data
                if let nutritionFoodItem = try await nutritionService.searchIndianFood(mlResult.foodName) {
                    // Step 3: Use ML recognition name but nutrition service data
                    let foodItem = FoodItem(
                        name: mlResult.displayName, // Use ML recognized name
                        calories: nutritionFoodItem.calories,
                        protein: nutritionFoodItem.protein,
                        carbohydrates: nutritionFoodItem.carbohydrates,
                        fat: nutritionFoodItem.fat,
                        fiber: nutritionFoodItem.fiber,
                        servingSize: nutritionFoodItem.servingSize,
                        confidence: mlResult.confidence
                    )
                    
                    recognizedFood = foodItem
                    showingResult = true
                } else {
                    // Fallback to local nutrition data
                    let fallbackService = FallbackNutritionService()
                    if let fallbackItem = fallbackService.getNutritionData(for: mlResult.foodName) {
                        let foodItem = FoodItem(
                            name: mlResult.displayName,
                            calories: fallbackItem.calories,
                            protein: fallbackItem.protein,
                            carbohydrates: fallbackItem.carbohydrates,
                            fat: fallbackItem.fat,
                            fiber: fallbackItem.fiber,
                            servingSize: fallbackItem.servingSize,
                            confidence: mlResult.confidence * 0.8 // Lower confidence for fallback
                        )
                        
                        recognizedFood = foodItem
                        showingResult = true
                    } else {
                        throw NutritionError.foodNotFound
                    }
                }
                
            } catch {
                errorMessage = "Failed to analyze food: \(error.localizedDescription)"
                print("❌ Food processing error: \(error)")
            }
            
            isProcessing = false
        }
    }
    
    private func searchFood(_ foodName: String) {
        Task {
            isProcessing = true
            errorMessage = nil
            
            do {
                if let nutritionFoodItem = try await nutritionService.searchIndianFood(foodName) {
                    let foodItem = FoodItem(
                        name: foodName.capitalized,
                        calories: nutritionFoodItem.calories,
                        protein: nutritionFoodItem.protein,
                        carbohydrates: nutritionFoodItem.carbohydrates,
                        fat: nutritionFoodItem.fat,
                        fiber: nutritionFoodItem.fiber,
                        servingSize: nutritionFoodItem.servingSize,
                        confidence: 0.8 // Manual search confidence
                    )
                    
                    recognizedFood = foodItem
                    showingResult = true
                } else {
                    // Fallback to local nutrition data
                    let fallbackService = FallbackNutritionService()
                    if let fallbackItem = fallbackService.getNutritionData(for: foodName) {
                        let foodItem = FoodItem(
                            name: foodName.capitalized,
                            calories: fallbackItem.calories,
                            protein: fallbackItem.protein,
                            carbohydrates: fallbackItem.carbohydrates,
                            fat: fallbackItem.fat,
                            fiber: fallbackItem.fiber,
                            servingSize: fallbackItem.servingSize,
                            confidence: 0.6 // Lower confidence for manual + fallback
                        )
                        
                        recognizedFood = foodItem
                        showingResult = true
                    } else {
                        throw NutritionError.foodNotFound
                    }
                }
                
            } catch {
                errorMessage = "Failed to find food: \(error.localizedDescription)"
                print("❌ Manual search error: \(error)")
            }
            
            isProcessing = false
        }
    }
    
    private func saveToHistory() {
        guard let food = recognizedFood else { return }
        
        Task {
            await firestoreService.saveFoodScan(food)
            clearResults()
        }
    }
    
    private func clearResults() {
        recognizedFood = nil
        showingResult = false
        selectedImage = nil
        errorMessage = nil
    }
}

struct RecentScanCard: View {
    let food: FoodItem
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 80, height: 60)
                .overlay(
                    Text("🍛")
                        .font(.title2)
                )
            
            Text(food.name)
                .font(.caption)
                .lineLimit(1)
            
            Text("\(food.calories) cal")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 80)
    }
}

struct FoodResultCard: View {
    let food: FoodItem
    let onSave: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text(food.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(food.servingSize)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text("\(food.calories)")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                + Text(" cal")
                    .font(.headline)
                    .foregroundColor(.orange)
            }
            
            // Nutrition breakdown
            HStack(spacing: 20) {
                NutrientPill(label: "Protein", value: "\(String(format: "%.1f", food.protein))g", color: .blue)
                NutrientPill(label: "Carbs", value: "\(String(format: "%.1f", food.carbohydrates))g", color: .green)
                NutrientPill(label: "Fat", value: "\(String(format: "%.1f", food.fat))g", color: .red)
            }
            
            // Action buttons
            HStack(spacing: 15) {
                Button("Save to History") {
                    onSave()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Edit Portion") {
                    // TODO: Add portion editing
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray.opacity(0.2))
                .foregroundColor(.primary)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

struct NutrientPill: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.headline)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .cornerRadius(20)
    }
}

struct ManualSearchView: View {
    @Binding var searchText: String
    let onSearch: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Can't find your food?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                Text("Search manually for nutrition data")
                    .foregroundColor(.secondary)
                
                TextField("Enter food name (e.g., chicken biryani)", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button("Search") {
                    if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        onSearch(searchText)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.horizontal)
                .disabled(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                
                Spacer()
            }
            .navigationTitle("Manual Search")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ScanView()
}