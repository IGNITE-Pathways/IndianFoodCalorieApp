import Foundation
import FirebaseFirestore
import FirebaseAuth
import Combine

@MainActor
class FirestoreService: ObservableObject {
    static let shared = FirestoreService()
    
    private let db = Firestore.firestore()
    @Published var userFoodHistory: [FoodItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var listenerRegistration: ListenerRegistration?
    
    private init() {}
    
    deinit {
        listenerRegistration?.remove()
    }
    
    // MARK: - Save Food Scan
    func saveFoodScan(_ foodItem: FoodItem) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }
        
        do {
            isLoading = true
            
            // Convert FoodItem to dictionary for Firestore
            let foodData = try foodItem.toDictionary()
            
            // Save to user's food collection
            try await db.collection("users")
                .document(userId)
                .collection("foodHistory")
                .document(foodItem.id.uuidString)
                .setData(foodData)
            
            print("✅ Food scan saved to Firestore: \(foodItem.name)")
            errorMessage = nil
            
            // Add to local array if not already present
            if !userFoodHistory.contains(where: { $0.id == foodItem.id }) {
                userFoodHistory.insert(foodItem, at: 0)
            }
            
        } catch {
            print("❌ Error saving food scan: \(error.localizedDescription)")
            errorMessage = "Failed to save food scan: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Load User's Food History
    func loadUserFoodHistory() async {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }
        
        do {
            isLoading = true
            
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("foodHistory")
                .order(by: "scannedAt", descending: true)
                .limit(to: 50) // Load last 50 scans
                .getDocuments()
            
            let foodItems = snapshot.documents.compactMap { document -> FoodItem? in
                do {
                    return try FoodItem.fromDictionary(document.data())
                } catch {
                    print("❌ Error parsing food item: \(error)")
                    return nil
                }
            }
            
            userFoodHistory = foodItems
            print("✅ Loaded \(foodItems.count) food items from Firestore")
            errorMessage = nil
            
        } catch {
            print("❌ Error loading food history: \(error.localizedDescription)")
            errorMessage = "Failed to load food history: \(error.localizedDescription)"
            
            // Load sample data as fallback
            userFoodHistory = Array(FoodItem.sampleFoods.prefix(5))
        }
        
        isLoading = false
    }
    
    // MARK: - Real-time Listener
    func startRealtimeListener() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("❌ Cannot start listener: User not authenticated")
            return
        }
        
        // Remove existing listener
        listenerRegistration?.remove()
        
        listenerRegistration = db.collection("users")
            .document(userId)
            .collection("foodHistory")
            .order(by: "scannedAt", descending: true)
            .limit(to: 50)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Firestore listener error: \(error.localizedDescription)")
                    Task { @MainActor in
                        self.errorMessage = "Real-time sync error: \(error.localizedDescription)"
                    }
                    return
                }
                
                guard let snapshot = snapshot else { return }
                
                let foodItems = snapshot.documents.compactMap { document -> FoodItem? in
                    do {
                        return try FoodItem.fromDictionary(document.data())
                    } catch {
                        print("❌ Error parsing food item: \(error)")
                        return nil
                    }
                }
                
                Task { @MainActor in
                    self.userFoodHistory = foodItems
                    print("🔄 Real-time update: \(foodItems.count) food items")
                }
            }
    }
    
    func stopRealtimeListener() {
        listenerRegistration?.remove()
        listenerRegistration = nil
    }
    
    // MARK: - Delete Food Item
    func deleteFoodItem(_ foodItem: FoodItem) async {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not authenticated"
            return
        }
        
        do {
            try await db.collection("users")
                .document(userId)
                .collection("foodHistory")
                .document(foodItem.id.uuidString)
                .delete()
            
            userFoodHistory.removeAll { $0.id == foodItem.id }
            print("✅ Food item deleted: \(foodItem.name)")
            
        } catch {
            print("❌ Error deleting food item: \(error.localizedDescription)")
            errorMessage = "Failed to delete food item: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Get Daily Statistics
    func getDailyStats(for date: Date = Date()) async -> DailyStats {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? Date()
        
        let todaysFoods = userFoodHistory.filter { food in
            food.scannedAt >= startOfDay && food.scannedAt < endOfDay
        }
        
        let totalCalories = todaysFoods.reduce(0) { $0 + $1.adjustedCalories }
        let totalProtein = todaysFoods.reduce(0.0) { $0 + $1.adjustedProtein }
        let totalCarbs = todaysFoods.reduce(0.0) { $0 + $1.adjustedCarbohydrates }
        let totalFat = todaysFoods.reduce(0.0) { $0 + $1.adjustedFat }
        let totalFiber = todaysFoods.reduce(0.0) { $0 + $1.adjustedFiber }
        
        return DailyStats(
            date: date,
            totalCalories: totalCalories,
            totalProtein: totalProtein,
            totalCarbohydrates: totalCarbs,
            totalFat: totalFat,
            totalFiber: totalFiber,
            foodCount: todaysFoods.count
        )
    }
}

// MARK: - Daily Statistics Model
struct DailyStats {
    let date: Date
    let totalCalories: Int
    let totalProtein: Double
    let totalCarbohydrates: Double
    let totalFat: Double
    let totalFiber: Double
    let foodCount: Int
}

// MARK: - FoodItem Firestore Extensions
extension FoodItem {
    func toDictionary() throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(self)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        return json as? [String: Any] ?? [:]
    }
    
    static func fromDictionary(_ data: [String: Any]) throws -> FoodItem {
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(FoodItem.self, from: jsonData)
    }
}