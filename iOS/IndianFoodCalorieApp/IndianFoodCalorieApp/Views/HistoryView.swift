import SwiftUI

struct HistoryView: View {
    @StateObject private var firestoreService = FirestoreService.shared
    @State private var dailyStats: DailyStats?
    @State private var showingDeleteAlert = false
    @State private var foodToDelete: FoodItem?
    
    var body: some View {
        NavigationView {
            VStack {
                if firestoreService.isLoading {
                    ProgressView("Loading history...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Today's Summary Card
                    if let stats = dailyStats {
                        DailySummaryCard(stats: stats)
                    }
                    
                    // Food History List
                    if firestoreService.userFoodHistory.isEmpty {
                        EmptyHistoryView()
                    } else {
                        List {
                            Section("Recent Scans") {
                                ForEach(firestoreService.userFoodHistory) { food in
                                    FoodHistoryRow(food: food) {
                                        foodToDelete = food
                                        showingDeleteAlert = true
                                    }
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                
                if let errorMessage = firestoreService.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .navigationTitle("Food History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Refresh") {
                            Task {
                                await firestoreService.loadUserFoodHistory()
                                await updateDailyStats()
                            }
                        }
                        Button("Export Data") { 
                            // TODO: Implement export
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .task {
                await firestoreService.loadUserFoodHistory()
                await updateDailyStats()
                firestoreService.startRealtimeListener()
            }
            .onDisappear {
                firestoreService.stopRealtimeListener()
            }
            .alert("Delete Food Item", isPresented: $showingDeleteAlert) {
                Button("Delete", role: .destructive) {
                    if let food = foodToDelete {
                        Task {
                            await firestoreService.deleteFoodItem(food)
                            await updateDailyStats()
                        }
                    }
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this food item from your history?")
            }
        }
    }
    
    private func updateDailyStats() async {
        dailyStats = await firestoreService.getDailyStats()
    }
}

struct CircularProgressView: View {
    let progress: Double
    let goal: Int
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                .frame(width: 80, height: 80)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.orange, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 80, height: 80)
                .rotationEffect(.degrees(-90))
            
            VStack {
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
                Text("of \(goal)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct MacroItem: View {
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

// MARK: - New Views for Firestore Integration

struct DailySummaryCard: View {
    let stats: DailyStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Today's Summary")
                    .font(.headline)
                Spacer()
                Text(stats.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("\(stats.totalCalories)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("Calories consumed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                CircularProgressView(
                    progress: min(Double(stats.totalCalories) / 2000.0, 1.0), 
                    goal: 2000
                )
            }
            
            // Macro breakdown
            HStack(spacing: 20) {
                MacroItem(title: "Protein", value: "\(Int(stats.totalProtein))g", color: .blue)
                MacroItem(title: "Carbs", value: "\(Int(stats.totalCarbohydrates))g", color: .green)
                MacroItem(title: "Fat", value: "\(Int(stats.totalFat))g", color: .red)
            }
            
            Text("\(stats.foodCount) items scanned today")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

struct FoodHistoryRow: View {
    let food: FoodItem
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(food.name)
                    .font(.headline)
                
                Text(food.scannedAt.formatted(date: .omitted, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(food.servingSize)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(food.adjustedCalories) cal")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                HStack(spacing: 8) {
                    Text("P: \(Int(food.adjustedProtein))g")
                        .font(.caption2)
                        .foregroundColor(.blue)
                    Text("C: \(Int(food.adjustedCarbohydrates))g")
                        .font(.caption2)
                        .foregroundColor(.green)
                    Text("F: \(Int(food.adjustedFat))g")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
            }
        }
        .swipeActions(edge: .trailing) {
            Button("Delete", role: .destructive) {
                onDelete()
            }
        }
        .padding(.vertical, 4)
    }
}

struct EmptyHistoryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No food history yet")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Start scanning food to see your nutrition history here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}

#Preview {
    HistoryView()
}