import SwiftUI
import Combine

class ProfileViewModel: ObservableObject {
    @Published var user: User = User.sampleUser
    @Published var totalScans: Int = 247
    @Published var foodsTried: Int = 68
    @Published var currentStreak: Int = 12
    @Published var showingEditProfile: Bool = false
    
    init() {
        loadUserStats()
    }
    
    private func loadUserStats() {
        // In production, load from Firestore
        totalScans = user.totalScans
        currentStreak = user.currentStreak
        foodsTried = user.favoriteFoods.count
    }
    
    func updateProfile(name: String, age: Int, weight: Double, height: Double, activityLevel: User.ActivityLevel, goal: User.Goal) {
        user.name = name
        user.age = age
        user.weight = weight
        user.height = height
        user.activityLevel = activityLevel
        user.goal = goal
        user.updateTargets()
        
        // In production, save to Firestore
        saveProfile()
    }
    
    func updateDietaryRestrictions(_ restrictions: [User.DietaryRestriction]) {
        user.dietaryRestrictions = restrictions
        saveProfile()
    }
    
    private func saveProfile() {
        // Save to Firestore
        print("Saving profile for user: \(user.name)")
    }
    
    func exportUserData() {
        // Export user data
        print("Exporting user data...")
    }
    
    func deleteAllData() {
        // Delete all user data
        print("Deleting all user data...")
    }
}