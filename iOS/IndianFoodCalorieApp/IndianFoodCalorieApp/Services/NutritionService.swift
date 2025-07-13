import Foundation

class NutritionService: ObservableObject {
    static let shared = NutritionService()
    
    private let baseURL = "https://api.api-ninjas.com/v1/nutrition"
    private var apiKey: String {
        // API Ninjas API key
        return "eEb3oAHyoG8FA9zh/fG3zw==Y0a2ByzOoNvCqdYK"
    }
    
    private init() {}
    
    // MARK: - Nutrition Data Models
    // API Ninjas returns an array directly, not wrapped in "items"
    typealias NutritionResponse = [NutritionItem]
    
    struct NutritionItem: Codable {
        let name: String
        let calories: String  // Can be number or "Only available for premium subscribers."
        let servingSizeG: String?
        let fatTotalG: Double
        let fatSaturatedG: Double?
        let proteinG: String  // Can be number or "Only available for premium subscribers."
        let sodiumMg: Double?
        let potassiumMg: Double?
        let cholesterolMg: Double?
        let carbohydratesTotalG: Double
        let fiberG: Double?
        let sugarG: Double?
        
        enum CodingKeys: String, CodingKey {
            case name, calories
            case servingSizeG = "serving_size_g"
            case fatTotalG = "fat_total_g"
            case fatSaturatedG = "fat_saturated_g"
            case proteinG = "protein_g"
            case sodiumMg = "sodium_mg"
            case potassiumMg = "potassium_mg"
            case cholesterolMg = "cholesterol_mg"
            case carbohydratesTotalG = "carbohydrates_total_g"
            case fiberG = "fiber_g"
            case sugarG = "sugar_g"
        }
    }
    
    // MARK: - API Methods
    func getNutritionInfo(for foodName: String) async throws -> NutritionItem? {
        guard !apiKey.contains("YOUR_") else {
            throw NutritionError.apiKeyNotSet
        }
        
        guard let url = URL(string: "\(baseURL)?query=\(foodName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") else {
            throw NutritionError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "X-Api-Key")
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NutritionError.invalidResponse
            }
            
            if httpResponse.statusCode == 401 {
                throw NutritionError.unauthorized
            }
            
            guard httpResponse.statusCode == 200 else {
                throw NutritionError.serverError(httpResponse.statusCode)
            }
            
            // Add debug logging
            if let responseString = String(data: data, encoding: .utf8) {
                print("📋 API Response: \(responseString)")
            }
            
            let nutritionResponse = try JSONDecoder().decode(NutritionResponse.self, from: data)
            return nutritionResponse.first
            
        } catch let error as NutritionError {
            throw error
        } catch {
            throw NutritionError.networkError(error)
        }
    }
    
    // MARK: - Convenience Methods for Indian Foods
    func searchIndianFood(_ foodName: String) async throws -> FoodItem? {
        let nutritionItem = try await getNutritionInfo(for: foodName)
        
        guard let item = nutritionItem else {
            throw NutritionError.foodNotFound
        }
        
        // Convert API response to our FoodItem model
        // Handle premium subscriber messages by extracting numbers or using fallback
        let calories = extractNumber(from: item.calories) ?? 0
        let protein = extractNumber(from: item.proteinG) ?? 0
        let servingSize = item.servingSizeG.flatMap { extractNumber(from: $0) } ?? 100
        
        return FoodItem(
            name: item.name.capitalized,
            calories: Int(calories),
            protein: protein,
            carbohydrates: item.carbohydratesTotalG,
            fat: item.fatTotalG,
            fiber: item.fiberG ?? 0,
            servingSize: "\(Int(servingSize))g",
            confidence: 0.8  // Lower confidence due to free tier limitations
        )
    }
    
    // MARK: - Batch Indian Food Search
    func searchMultipleIndianFoods(_ foodNames: [String]) async -> [FoodItem] {
        var results: [FoodItem] = []
        
        for foodName in foodNames {
            do {
                if let foodItem = try await searchIndianFood(foodName) {
                    results.append(foodItem)
                }
                // Add small delay to respect API rate limits
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            } catch {
                print("Error fetching nutrition for \(foodName): \(error)")
            }
        }
        
        return results
    }
    
    // MARK: - Helper Methods
    private func extractNumber(from string: String) -> Double? {
        // Try to convert string to Double directly
        if let number = Double(string) {
            return number
        }
        
        // If it contains "premium subscribers", return nil to use fallback
        if string.contains("premium subscribers") {
            return nil
        }
        
        // Try to extract numbers from string using regex
        let regex = try? NSRegularExpression(pattern: "\\d+\\.?\\d*", options: [])
        let range = NSRange(location: 0, length: string.utf16.count)
        if let match = regex?.firstMatch(in: string, options: [], range: range) {
            let numberString = (string as NSString).substring(with: match.range)
            return Double(numberString)
        }
        
        return nil
    }
    
    // MARK: - Common Indian Foods for Testing
    static let commonIndianFoods = [
        "biryani", "idli", "dosa", "roti", "naan", "dal", "samosa",
        "butter chicken", "tandoori chicken", "palak paneer", "rajma",
        "chole", "aloo gobi", "masala dosa", "upma", "poha"
    ]
}

// MARK: - Error Handling
enum NutritionError: LocalizedError {
    case apiKeyNotSet
    case invalidURL
    case invalidResponse
    case unauthorized
    case serverError(Int)
    case networkError(Error)
    case foodNotFound
    
    var errorDescription: String? {
        switch self {
        case .apiKeyNotSet:
            return "API key not configured. Please set your API Ninjas API key."
        case .invalidURL:
            return "Invalid URL for nutrition request."
        case .invalidResponse:
            return "Invalid response from nutrition API."
        case .unauthorized:
            return "Unauthorized. Please check your API key."
        case .serverError(let code):
            return "Server error: \(code)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .foodNotFound:
            return "Food not found in nutrition database."
        }
    }
}