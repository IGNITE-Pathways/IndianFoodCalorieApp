import SwiftUI
import Combine

class InsightsViewModel: ObservableObject {
    @Published var weeklyData: [WeeklyCalorieData] = []
    @Published var nutritionBalance: NutritionBalance = NutritionBalance()
    @Published var topFoods: [FoodRanking] = []
    @Published var achievements: [Achievement] = []
    
    init() {
        loadWeeklyData()
        loadTopFoods()
        loadAchievements()
    }
    
    private func loadWeeklyData() {
        let calendar = Calendar.current
        let today = Date()
        
        weeklyData = (0..<7).compactMap { dayOffset in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { return nil }
            let dayName = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
            
            // Mock data - in production, load from user's actual data
            let calories = Int.random(in: 1500...2500)
            
            return WeeklyCalorieData(day: dayName, calories: calories, date: date)
        }.reversed()
    }
    
    private func loadTopFoods() {
        topFoods = [
            FoodRanking(rank: 1, name: "Chicken Biryani", scanCount: 15, averageCalories: 650),
            FoodRanking(rank: 2, name: "Idli", scanCount: 12, averageCalories: 140),
            FoodRanking(rank: 3, name: "Roti", scanCount: 10, averageCalories: 120),
            FoodRanking(rank: 4, name: "Dal Tadka", scanCount: 8, averageCalories: 180),
            FoodRanking(rank: 5, name: "Samosa", scanCount: 6, averageCalories: 250)
        ]
    }
    
    private func loadAchievements() {
        achievements = Achievement.allAchievements
    }
    
    func exportInsights() {
        // Export insights data
        print("Exporting insights data...")
    }
}

struct WeeklyCalorieData: Identifiable {
    let id = UUID()
    let day: String
    let calories: Int
    let date: Date
}

struct NutritionBalance {
    let proteinPercentage: Int = 25
    let carbsPercentage: Int = 45
    let fatPercentage: Int = 30
}

struct FoodRanking: Identifiable {
    let id = UUID()
    let rank: Int
    let name: String
    let scanCount: Int
    let averageCalories: Int
}