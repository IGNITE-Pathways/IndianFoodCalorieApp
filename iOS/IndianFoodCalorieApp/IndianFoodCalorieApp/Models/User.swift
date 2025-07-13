import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    var name: String
    var email: String
    var age: Int
    var weight: Double // kg
    var height: Double // cm
    var gender: Gender
    var activityLevel: ActivityLevel
    var goal: Goal
    var dailyCalorieTarget: Int = 2000
    var proteinTarget: Double = 150.0 // grams
    var carbTarget: Double = 250.0 // grams
    var fatTarget: Double = 65.0 // grams
    var dietaryRestrictions: [DietaryRestriction]
    var joinDate: Date
    var totalScans: Int
    var currentStreak: Int
    var longestStreak: Int
    var favoriteFoods: [String] // food names
    var achievements: [Achievement]
    
    enum Gender: String, CaseIterable, Codable {
        case male = "Male"
        case female = "Female"
        case other = "Other"
        case preferNotToSay = "Prefer not to say"
    }
    
    enum ActivityLevel: String, CaseIterable, Codable {
        case sedentary = "Sedentary"
        case lightlyActive = "Lightly Active"
        case moderatelyActive = "Moderately Active"
        case veryActive = "Very Active"
        case extremelyActive = "Extremely Active"
        
        var multiplier: Double {
            switch self {
            case .sedentary: return 1.2
            case .lightlyActive: return 1.375
            case .moderatelyActive: return 1.55
            case .veryActive: return 1.725
            case .extremelyActive: return 1.9
            }
        }
    }
    
    enum Goal: String, CaseIterable, Codable {
        case loseWeight = "Lose Weight"
        case maintainWeight = "Maintain Weight"
        case gainWeight = "Gain Weight"
        case buildMuscle = "Build Muscle"
        case improveHealth = "Improve Health"
        
        var calorieAdjustment: Double {
            switch self {
            case .loseWeight: return -500 // 500 cal deficit
            case .maintainWeight: return 0
            case .gainWeight: return 300 // 300 cal surplus
            case .buildMuscle: return 200 // 200 cal surplus
            case .improveHealth: return 0
            }
        }
    }
    
    enum DietaryRestriction: String, CaseIterable, Codable {
        case vegetarian = "Vegetarian"
        case vegan = "Vegan"
        case glutenFree = "Gluten Free"
        case dairyFree = "Dairy Free"
        case nutFree = "Nut Free"
        case jain = "Jain"
        case halal = "Halal"
        case diabetic = "Diabetic"
        case lowSodium = "Low Sodium"
    }
    
    // Calculated BMR using Mifflin-St Jeor Equation
    var bmr: Double {
        let baseBMR: Double
        switch gender {
        case .male:
            baseBMR = 10 * weight + 6.25 * height - 5 * Double(age) + 5
        case .female:
            baseBMR = 10 * weight + 6.25 * height - 5 * Double(age) - 161
        case .other, .preferNotToSay:
            // Use average of male/female calculation
            let maleBMR = 10 * weight + 6.25 * height - 5 * Double(age) + 5
            let femaleBMR = 10 * weight + 6.25 * height - 5 * Double(age) - 161
            baseBMR = (maleBMR + femaleBMR) / 2
        }
        return baseBMR
    }
    
    // Total Daily Energy Expenditure
    var tdee: Double {
        return bmr * activityLevel.multiplier
    }
    
    // Calculated daily calorie target based on goal
    var calculatedCalorieTarget: Int {
        return Int(tdee + goal.calorieAdjustment)
    }
    
    init(name: String, email: String, age: Int, weight: Double, height: Double, gender: Gender, activityLevel: ActivityLevel, goal: Goal, dietaryRestrictions: [DietaryRestriction] = []) {
        self.id = UUID()
        self.name = name
        self.email = email
        self.age = age
        self.weight = weight
        self.height = height
        self.gender = gender
        self.activityLevel = activityLevel
        self.goal = goal
        self.dietaryRestrictions = dietaryRestrictions
        self.joinDate = Date()
        self.totalScans = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.favoriteFoods = []
        self.achievements = []
        
        // Calculate targets
        self.dailyCalorieTarget = calculatedCalorieTarget
        
        // Macro targets (as percentage of calories)
        let proteinPercent = 0.25 // 25% of calories from protein
        let fatPercent = 0.30 // 30% of calories from fat
        let carbPercent = 0.45 // 45% of calories from carbs
        
        self.proteinTarget = Double(dailyCalorieTarget) * proteinPercent / 4 // 4 cal per gram
        self.fatTarget = Double(dailyCalorieTarget) * fatPercent / 9 // 9 cal per gram
        self.carbTarget = Double(dailyCalorieTarget) * carbPercent / 4 // 4 cal per gram
    }
    
    mutating func updateTargets() {
        dailyCalorieTarget = calculatedCalorieTarget
        let proteinPercent = 0.25
        let fatPercent = 0.30
        let carbPercent = 0.45
        
        proteinTarget = Double(dailyCalorieTarget) * proteinPercent / 4
        fatTarget = Double(dailyCalorieTarget) * fatPercent / 9
        carbTarget = Double(dailyCalorieTarget) * carbPercent / 4
    }
    
    mutating func addScan() {
        totalScans += 1
    }
    
    mutating func updateStreak(scannedToday: Bool) {
        if scannedToday {
            currentStreak += 1
            longestStreak = max(longestStreak, currentStreak)
        } else {
            currentStreak = 0
        }
    }
    
    mutating func addAchievement(_ achievement: Achievement) {
        if !achievements.contains(where: { $0.id == achievement.id }) {
            achievements.append(achievement)
        }
    }
}

struct Achievement: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let iconName: String
    let unlockedDate: Date
    let category: Category
    
    init(title: String, description: String, iconName: String, unlockedDate: Date, category: Category) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.iconName = iconName
        self.unlockedDate = unlockedDate
        self.category = category
    }
    
    enum Category: String, CaseIterable, Codable {
        case scanning = "Scanning"
        case streak = "Streak"
        case exploration = "Exploration"
        case health = "Health"
        case social = "Social"
    }
    
    static let allAchievements: [Achievement] = [
        Achievement(title: "First Scan", description: "Complete your first food scan", iconName: "camera.fill", unlockedDate: Date(), category: .scanning),
        Achievement(title: "Scanner Pro", description: "Complete 100 food scans", iconName: "camera.badge.ellipsis", unlockedDate: Date(), category: .scanning),
        Achievement(title: "Weekly Warrior", description: "Scan food for 7 consecutive days", iconName: "calendar", unlockedDate: Date(), category: .streak),
        Achievement(title: "Food Explorer", description: "Try 50 different Indian dishes", iconName: "star.fill", unlockedDate: Date(), category: .exploration),
        Achievement(title: "Health Tracker", description: "Meet your calorie goal for 30 days", iconName: "heart.fill", unlockedDate: Date(), category: .health)
    ]
}

// Sample user for development
extension User {
    static let sampleUser = User(
        name: "John Doe",
        email: "john.doe@example.com",
        age: 28,
        weight: 70.0,
        height: 175.0,
        gender: .male,
        activityLevel: .moderatelyActive,
        goal: .maintainWeight,
        dietaryRestrictions: [.vegetarian]
    )
}