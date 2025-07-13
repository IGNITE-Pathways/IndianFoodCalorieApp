import SwiftUI

struct InsightsView: View {
    @StateObject private var viewModel = InsightsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Weekly Calorie Trend (without Charts for now)
                    VStack(alignment: .leading) {
                        Text("Weekly Calorie Trend")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Simple bar chart representation (no external dependencies)
                        HStack(alignment: .bottom, spacing: 8) {
                            ForEach(viewModel.weeklyData) { data in
                                VStack {
                                    Rectangle()
                                        .fill(Color.orange)
                                        .frame(width: 30, height: CGFloat(data.calories) / 50)
                                    Text(data.day)
                                        .font(.caption)
                                }
                            }
                        }
                        .frame(height: 200)
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Nutritional Balance
                    VStack(alignment: .leading) {
                        Text("Nutritional Balance")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        HStack(spacing: 15) {
                            NutrientPieChart(title: "Protein", percentage: 25, color: .blue)
                            NutrientPieChart(title: "Carbs", percentage: 45, color: .green)
                            NutrientPieChart(title: "Fat", percentage: 30, color: .red)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Most Scanned Foods
                    VStack(alignment: .leading) {
                        Text("Most Scanned Foods")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 10) {
                            FoodRankingItem(rank: 1, name: "Chicken Biryani", count: 15, calories: 650)
                            FoodRankingItem(rank: 2, name: "Idli", count: 12, calories: 140)
                            FoodRankingItem(rank: 3, name: "Roti", count: 10, calories: 120)
                            FoodRankingItem(rank: 4, name: "Dal Tadka", count: 8, calories: 180)
                            FoodRankingItem(rank: 5, name: "Samosa", count: 6, calories: 250)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Achievement Section
                    VStack(alignment: .leading) {
                        Text("Achievements")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                AchievementBadge(title: "Scanner Pro", description: "100 scans completed", icon: "camera.fill", isUnlocked: true)
                                AchievementBadge(title: "Health Tracker", description: "7 day streak", icon: "heart.fill", isUnlocked: true)
                                AchievementBadge(title: "Food Explorer", description: "Try 50 different foods", icon: "star.fill", isUnlocked: false)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Insights")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Export") {
                        viewModel.exportInsights()
                    }
                }
            }
        }
    }
}

struct NutrientPieChart: View {
    let title: String
    let percentage: Int
    let color: Color
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: Double(percentage) / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                
                Text("\(percentage)%")
                    .font(.caption)
                    .fontWeight(.bold)
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct FoodRankingItem: View {
    let rank: Int
    let name: String
    let count: Int
    let calories: Int
    
    var body: some View {
        HStack {
            Text("#\(rank)")
                .font(.headline)
                .foregroundColor(.orange)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("\(count) times scanned")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text("\(calories) cal")
                .font(.subheadline)
                .foregroundColor(.orange)
        }
        .padding(.vertical, 5)
    }
}

struct AchievementBadge: View {
    let title: String
    let description: String
    let icon: String
    let isUnlocked: Bool
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(isUnlocked ? .orange : .gray)
                .frame(width: 60, height: 60)
                .background(isUnlocked ? Color.orange.opacity(0.2) : Color.gray.opacity(0.2))
                .cornerRadius(30)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(width: 100)
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

#Preview {
    InsightsView()
}