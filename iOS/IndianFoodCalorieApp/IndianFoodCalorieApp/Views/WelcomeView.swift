import SwiftUI

struct WelcomeView: View {
    @Binding var showingWelcome: Bool
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App Logo and Title
            VStack(spacing: 20) {
                AppLogoView(size: 120, showText: false)
                
                Text("Welcome to")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("Indian Food Calorie App")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
            }
            
            // Features
            VStack(spacing: 20) {
                FeatureCard(
                    icon: "camera.fill",
                    title: "Scan Food",
                    description: "Take a photo of any Indian dish and get instant nutrition information"
                )
                
                FeatureCard(
                    icon: "chart.bar.fill",
                    title: "Track Progress",
                    description: "Monitor your daily calorie intake and nutritional goals"
                )
                
                FeatureCard(
                    icon: "heart.fill",
                    title: "Stay Healthy",
                    description: "Make informed choices about your favorite Indian foods"
                )
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Get Started Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showingWelcome = false
                }
            }) {
                Text("Get Started")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(15)
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.orange.opacity(0.1), Color.clear]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.orange)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    WelcomeView(showingWelcome: .constant(true))
}