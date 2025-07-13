import Foundation

class FallbackNutritionService {
    static let shared = FallbackNutritionService()
    
    private init() {}
    
    // Fallback Indian food nutrition data - using lazy initialization
    private lazy var indianFoodDatabase: [String: FoodItem] = [
        "biryani": FoodItem(name: "Chicken Biryani", calories: 490, protein: 23, carbohydrates: 58, fat: 16, fiber: 3, servingSize: "1 cup (200g)", confidence: 0.8),
        "chicken biryani": FoodItem(name: "Chicken Biryani", calories: 490, protein: 23, carbohydrates: 58, fat: 16, fiber: 3, servingSize: "1 cup (200g)", confidence: 0.8),
        "idli": FoodItem(name: "Idli", calories: 39, protein: 1.7, carbohydrates: 8.2, fat: 0.2, fiber: 0.8, servingSize: "1 piece (30g)", confidence: 0.8),
        "dosa": FoodItem(name: "Plain Dosa", calories: 112, protein: 2.5, carbohydrates: 20, fat: 2, fiber: 1.2, servingSize: "1 piece (60g)", confidence: 0.8),
        "masala dosa": FoodItem(name: "Masala Dosa", calories: 168, protein: 4, carbohydrates: 30, fat: 3, fiber: 2, servingSize: "1 piece (100g)", confidence: 0.8),
        "samosa": FoodItem(name: "Samosa", calories: 154, protein: 3.5, carbohydrates: 18, fat: 7.5, fiber: 2, servingSize: "1 piece (50g)", confidence: 0.8),
        "dal tadka": FoodItem(name: "Dal Tadka", calories: 104, protein: 6.2, carbohydrates: 17, fat: 1.5, fiber: 4.8, servingSize: "1 bowl (100ml)", confidence: 0.8),
        "dal": FoodItem(name: "Dal", calories: 104, protein: 6.2, carbohydrates: 17, fat: 1.5, fiber: 4.8, servingSize: "1 bowl (100ml)", confidence: 0.8),
        "butter chicken": FoodItem(name: "Butter Chicken", calories: 438, protein: 30, carbohydrates: 6, fat: 33, fiber: 1, servingSize: "1 cup (200g)", confidence: 0.8),
        "naan": FoodItem(name: "Naan", calories: 262, protein: 8.7, carbohydrates: 45, fat: 5.1, fiber: 2.3, servingSize: "1 piece (90g)", confidence: 0.8),
        "roti": FoodItem(name: "Roti", calories: 104, protein: 3.5, carbohydrates: 18, fat: 2.5, fiber: 2.7, servingSize: "1 piece (40g)", confidence: 0.8),
        "chapati": FoodItem(name: "Chapati", calories: 104, protein: 3.5, carbohydrates: 18, fat: 2.5, fiber: 2.7, servingSize: "1 piece (40g)", confidence: 0.8),
        "chole": FoodItem(name: "Chole", calories: 164, protein: 8.9, carbohydrates: 27, fat: 2.6, fiber: 7.6, servingSize: "1 cup (150g)", confidence: 0.8),
        "rajma": FoodItem(name: "Rajma", calories: 127, protein: 8.7, carbohydrates: 23, fat: 0.5, fiber: 6.4, servingSize: "1 cup (180g)", confidence: 0.8),
        "palak paneer": FoodItem(name: "Palak Paneer", calories: 270, protein: 14, carbohydrates: 8, fat: 21, fiber: 3, servingSize: "1 cup (200g)", confidence: 0.8),
        "paneer butter masala": FoodItem(name: "Paneer Butter Masala", calories: 325, protein: 14, carbohydrates: 12, fat: 26, fiber: 3, servingSize: "1 cup (200g)", confidence: 0.8),
        "aloo gobi": FoodItem(name: "Aloo Gobi", calories: 158, protein: 4.2, carbohydrates: 24, fat: 6.1, fiber: 4.5, servingSize: "1 cup (150g)", confidence: 0.8),
        "upma": FoodItem(name: "Upma", calories: 96, protein: 2.8, carbohydrates: 16, fat: 2.4, fiber: 1.2, servingSize: "1 cup (100g)", confidence: 0.8),
        "poha": FoodItem(name: "Poha", calories: 76, protein: 1.8, carbohydrates: 17, fat: 0.2, fiber: 0.2, servingSize: "1 cup (80g)", confidence: 0.8),
        "vada": FoodItem(name: "Medu Vada", calories: 85, protein: 3.5, carbohydrates: 9, fat: 4, fiber: 1.5, servingSize: "1 piece (30g)", confidence: 0.8),
        "tandoori chicken": FoodItem(name: "Tandoori Chicken", calories: 220, protein: 31, carbohydrates: 2, fat: 9, fiber: 0, servingSize: "1 piece (100g)", confidence: 0.8)
    ]
    
    func searchFood(_ query: String) -> FoodItem? {
        let lowercaseQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Direct match
        if let food = indianFoodDatabase[lowercaseQuery] {
            return food
        }
        
        // Partial match
        for (key, food) in indianFoodDatabase {
            if key.contains(lowercaseQuery) || lowercaseQuery.contains(key) {
                return food
            }
        }
        
        return nil
    }
    
    func getAllFoods() -> [FoodItem] {
        return Array(indianFoodDatabase.values)
    }
    
    func searchMultipleFoods(_ queries: [String]) -> [FoodItem] {
        return queries.compactMap { searchFood($0) }
    }
}

// Update the main nutrition service to use fallback
extension NutritionService {
    func searchWithFallback(_ foodName: String) async -> FoodItem? {
        do {
            // Try API first
            if let apiResult = try await searchIndianFood(foodName) {
                // If API returned data but calories/protein are 0 (premium fields), enhance with fallback
                if apiResult.calories == 0 || apiResult.protein == 0 {
                    if let fallbackFood = FallbackNutritionService.shared.searchFood(foodName) {
                        print("🔄 Enhancing API data with fallback nutrition values")
                        return FoodItem(
                            name: apiResult.name,
                            calories: apiResult.calories > 0 ? apiResult.calories : fallbackFood.calories,
                            protein: apiResult.protein > 0 ? apiResult.protein : fallbackFood.protein,
                            carbohydrates: apiResult.carbohydrates,  // Use API value (available in free tier)
                            fat: apiResult.fat,  // Use API value (available in free tier)
                            fiber: apiResult.fiber > 0 ? apiResult.fiber : fallbackFood.fiber,
                            servingSize: apiResult.servingSize,
                            confidence: 0.9  // High confidence - hybrid data
                        )
                    }
                }
                    
                return apiResult
            } else {
                // API returned nil, use fallback
                return FallbackNutritionService.shared.searchFood(foodName)
            }
        } catch {
            print("🔄 API failed, using fallback: \(error.localizedDescription)")
            // Use pure fallback
            return FallbackNutritionService.shared.searchFood(foodName)
        }
    }
}
