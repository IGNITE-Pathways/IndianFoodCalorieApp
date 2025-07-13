import SwiftUI
import Combine

class HistoryViewModel: ObservableObject {
    @Published var todaysMeals: [Meal] = []
    @Published var totalCalories: Int = 1850
    @Published var calorieGoal: Int = 2400
    @Published var proteinConsumed: Double = 85
    @Published var carbsConsumed: Double = 220
    @Published var fatConsumed: Double = 65
    
    var calorieProgress: Double {
        Double(totalCalories) / Double(calorieGoal)
    }
    
    init() {
        loadTodaysMeals()
    }
    
    private func loadTodaysMeals() {
        // Sample meal data
        todaysMeals = [
            Meal(
                id: UUID(),
                type: .breakfast,
                time: Calendar.current.date(bySettingHour: 8, minute: 30, second: 0, of: Date()) ?? Date(),
                foods: [
                    FoodItem(name: "Idli", calories: 140, protein: 4, carbohydrates: 28, fat: 1, fiber: 2, servingSize: "3 pieces"),
                    FoodItem(name: "Sambar", calories: 120, protein: 6, carbohydrates: 15, fat: 4, fiber: 5, servingSize: "1 bowl"),
                    FoodItem(name: "Coconut Chutney", calories: 160, protein: 2, carbohydrates: 8, fat: 15, fiber: 1, servingSize: "2 tbsp")
                ]
            ),
            Meal(
                id: UUID(),
                type: .lunch,
                time: Calendar.current.date(bySettingHour: 13, minute: 15, second: 0, of: Date()) ?? Date(),
                foods: [
                    FoodItem(name: "Chicken Biryani", calories: 650, protein: 25, carbohydrates: 75, fat: 18, fiber: 3, servingSize: "1 plate"),
                    FoodItem(name: "Raita", calories: 80, protein: 3, carbohydrates: 6, fat: 5, fiber: 1, servingSize: "1 small bowl")
                ]
            ),
            Meal(
                id: UUID(),
                type: .snack,
                time: Calendar.current.date(bySettingHour: 16, minute: 30, second: 0, of: Date()) ?? Date(),
                foods: [
                    FoodItem(name: "Samosa", calories: 250, protein: 5, carbohydrates: 30, fat: 12, fiber: 3, servingSize: "2 pieces")
                ]
            ),
            Meal(
                id: UUID(),
                type: .dinner,
                time: Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date(),
                foods: [
                    FoodItem(name: "Roti", calories: 240, protein: 6, carbohydrates: 44, fat: 4, fiber: 6, servingSize: "2 pieces"),
                    FoodItem(name: "Dal Tadka", calories: 180, protein: 9, carbohydrates: 25, fat: 6, fiber: 8, servingSize: "1 bowl"),
                    FoodItem(name: "Mixed Vegetables", calories: 80, protein: 3, carbohydrates: 12, fat: 3, fiber: 4, servingSize: "1 serving")
                ]
            )
        ]
    }
    
    func exportData() {
        // Export functionality
        print("Exporting food history data...")
    }
    
    func clearHistory() {
        todaysMeals.removeAll()
        totalCalories = 0
        proteinConsumed = 0
        carbsConsumed = 0
        fatConsumed = 0
    }
}

struct Meal: Identifiable {
    let id: UUID
    let type: MealType
    let time: Date
    let foods: [FoodItem]
    
    var totalCalories: Int {
        foods.reduce(0) { $0 + $1.adjustedCalories }
    }
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
}

enum MealType: String, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case snack = "Snack"
    case dinner = "Dinner"
}