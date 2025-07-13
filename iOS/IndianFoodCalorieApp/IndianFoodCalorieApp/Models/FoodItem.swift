import Foundation
import CoreLocation

struct FoodItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let calories: Int
    let protein: Double // grams
    let carbohydrates: Double // grams
    let fat: Double // grams
    let fiber: Double // grams
    let servingSize: String
    let confidence: Double // ML model confidence 0-1
    let imageURL: String?
    let scannedAt: Date
    let location: CLLocationCoordinate2D?
    let portionMultiplier: Double // user-adjusted portion size
    
    // Computed properties
    var adjustedCalories: Int {
        Int(Double(calories) * portionMultiplier)
    }
    
    var adjustedProtein: Double {
        protein * portionMultiplier
    }
    
    var adjustedCarbohydrates: Double {
        carbohydrates * portionMultiplier
    }
    
    var adjustedFat: Double {
        fat * portionMultiplier
    }
    
    var adjustedFiber: Double {
        fiber * portionMultiplier
    }
    
    // Custom initializer
    init(name: String, calories: Int, protein: Double, carbohydrates: Double, fat: Double, fiber: Double, servingSize: String, confidence: Double = 1.0, imageURL: String? = nil, location: CLLocationCoordinate2D? = nil, portionMultiplier: Double = 1.0) {
        self.id = UUID()
        self.name = name
        self.calories = calories
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fat = fat
        self.fiber = fiber
        self.servingSize = servingSize
        self.confidence = confidence
        self.imageURL = imageURL
        self.scannedAt = Date()
        self.location = location
        self.portionMultiplier = portionMultiplier
    }
    
    // CodingKeys for location handling
    enum CodingKeys: String, CodingKey {
        case id, name, calories, protein, carbohydrates, fat, fiber, servingSize, confidence, imageURL, scannedAt, portionMultiplier
        case latitude, longitude
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decode(String.self, forKey: .name)
        calories = try container.decode(Int.self, forKey: .calories)
        protein = try container.decode(Double.self, forKey: .protein)
        carbohydrates = try container.decode(Double.self, forKey: .carbohydrates)
        fat = try container.decode(Double.self, forKey: .fat)
        fiber = try container.decode(Double.self, forKey: .fiber)
        servingSize = try container.decode(String.self, forKey: .servingSize)
        confidence = try container.decode(Double.self, forKey: .confidence)
        imageURL = try container.decodeIfPresent(String.self, forKey: .imageURL)
        scannedAt = try container.decode(Date.self, forKey: .scannedAt)
        portionMultiplier = try container.decode(Double.self, forKey: .portionMultiplier)
        
        if let latitude = try container.decodeIfPresent(Double.self, forKey: .latitude),
           let longitude = try container.decodeIfPresent(Double.self, forKey: .longitude) {
            location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        } else {
            location = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(calories, forKey: .calories)
        try container.encode(protein, forKey: .protein)
        try container.encode(carbohydrates, forKey: .carbohydrates)
        try container.encode(fat, forKey: .fat)
        try container.encode(fiber, forKey: .fiber)
        try container.encode(servingSize, forKey: .servingSize)
        try container.encode(confidence, forKey: .confidence)
        try container.encodeIfPresent(imageURL, forKey: .imageURL)
        try container.encode(scannedAt, forKey: .scannedAt)
        try container.encode(portionMultiplier, forKey: .portionMultiplier)
        
        if let location = location {
            try container.encode(location.latitude, forKey: .latitude)
            try container.encode(location.longitude, forKey: .longitude)
        }
    }
}

// Sample Indian foods for development
extension FoodItem {
    static let sampleFoods: [FoodItem] = [
        FoodItem(name: "Chicken Biryani", calories: 650, protein: 25, carbohydrates: 75, fat: 18, fiber: 3, servingSize: "1 plate (200g)"),
        FoodItem(name: "Idli", calories: 140, protein: 4, carbohydrates: 28, fat: 1, fiber: 2, servingSize: "3 pieces"),
        FoodItem(name: "Dosa", calories: 168, protein: 4, carbohydrates: 30, fat: 3, fiber: 2, servingSize: "1 piece"),
        FoodItem(name: "Roti", calories: 120, protein: 3, carbohydrates: 22, fat: 2, fiber: 3, servingSize: "1 piece"),
        FoodItem(name: "Dal Tadka", calories: 180, protein: 9, carbohydrates: 25, fat: 6, fiber: 8, servingSize: "1 bowl (150ml)"),
        FoodItem(name: "Samosa", calories: 250, protein: 5, carbohydrates: 30, fat: 12, fiber: 3, servingSize: "1 piece"),
        FoodItem(name: "Chole Bhature", calories: 750, protein: 18, carbohydrates: 85, fat: 32, fiber: 12, servingSize: "1 serving"),
        FoodItem(name: "Paneer Butter Masala", calories: 320, protein: 14, carbohydrates: 12, fat: 25, fiber: 3, servingSize: "1 bowl (200g)"),
        FoodItem(name: "Rajma", calories: 215, protein: 13, carbohydrates: 35, fat: 3, fiber: 11, servingSize: "1 bowl (150g)"),
        FoodItem(name: "Masala Dosa", calories: 220, protein: 6, carbohydrates: 35, fat: 7, fiber: 3, servingSize: "1 piece")
    ]
}