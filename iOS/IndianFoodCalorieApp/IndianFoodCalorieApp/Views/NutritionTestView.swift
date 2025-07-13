import SwiftUI

struct NutritionTestView: View {
    @State private var searchText = "chicken biryani"
    @State private var nutritionResult: FoodItem?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var testResults: [FoodItem] = []
    
    let indianFoods = ["biryani", "idli", "dosa", "samosa", "dal tadka", "butter chicken", "naan"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    Text("🍛 Nutrition API Test")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // API Status
                    HStack {
                        Image(systemName: nutritionResult != nil ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(nutritionResult != nil ? .green : .gray)
                        
                        Text(nutritionResult != nil ? "API Working" : "Not Tested")
                            .fontWeight(.medium)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    // Search Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Search Food:")
                            .font(.headline)
                        
                        TextField("Enter food name (e.g., chicken biryani)", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: {
                            searchFood()
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                                Text(isLoading ? "Searching..." : "Search Nutrition")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(isLoading || searchText.isEmpty)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    
                    // Quick Test Buttons
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Quick Tests:")
                            .font(.headline)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                            ForEach(indianFoods, id: \.self) { food in
                                Button(action: {
                                    searchText = food
                                    searchFood()
                                }) {
                                    Text(food.capitalized)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundColor(.blue)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    
                    // Results Section
                    if let result = nutritionResult {
                        NutritionResultCard(foodItem: result)
                    }
                    
                    // Error Message
                    if let error = errorMessage {
                        VStack(alignment: .leading) {
                            Text("Error:")
                                .font(.headline)
                                .foregroundColor(.red)
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                    }
                    
                    // Batch Test
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Batch Test Results:")
                            .font(.headline)
                        
                        Button(action: {
                            batchTestFoods()
                        }) {
                            Text("Test Multiple Indian Foods")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .disabled(isLoading)
                        
                        if !testResults.isEmpty {
                            Text("✅ Found \(testResults.count) foods")
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Nutrition API")
        }
    }
    
    private func searchFood() {
        isLoading = true
        errorMessage = nil
        nutritionResult = nil
        
        Task {
            // Try API with fallback
            let result = await NutritionService.shared.searchWithFallback(searchText)
            
            DispatchQueue.main.async {
                if let result = result {
                    self.nutritionResult = result
                    self.errorMessage = nil
                } else {
                    self.errorMessage = "Food not found in database"
                }
                self.isLoading = false
            }
        }
    }
    
    private func batchTestFoods() {
        isLoading = true
        testResults = []
        
        Task {
            let results = await NutritionService.shared.searchMultipleIndianFoods(Array(indianFoods.prefix(3)))
            
            DispatchQueue.main.async {
                self.testResults = results
                self.isLoading = false
            }
        }
    }
}

struct NutritionResultCard: View {
    let foodItem: FoodItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("✅ Food Found!")
                .font(.headline)
                .foregroundColor(.green)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(foodItem.name)
                        .font(.title3)
                        .fontWeight(.bold)
                    Spacer()
                    Text("\(foodItem.calories) cal")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                
                Text("Serving: \(foodItem.servingSize)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 20) {
                    NutrientInfo(title: "Protein", value: "\(String(format: "%.1f", foodItem.protein))g", color: .blue)
                    NutrientInfo(title: "Carbs", value: "\(String(format: "%.1f", foodItem.carbohydrates))g", color: .green)
                    NutrientInfo(title: "Fat", value: "\(String(format: "%.1f", foodItem.fat))g", color: .red)
                }
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(15)
    }
}

struct NutrientInfo: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack {
            Text(value)
                .font(.headline)
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NutritionTestView()
}