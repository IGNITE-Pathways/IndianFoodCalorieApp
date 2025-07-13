import SwiftUI

struct AppIconView: View {
    let size: CGFloat
    
    init(size: CGFloat = 1024) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background with gradient
            RoundedRectangle(cornerRadius: size * 0.18)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.orange.opacity(0.9),
                            Color.orange,
                            Color.red.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            // Subtle pattern overlay
            RoundedRectangle(cornerRadius: size * 0.18)
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.1),
                            Color.clear,
                            Color.black.opacity(0.1)
                        ]),
                        center: .topLeading,
                        startRadius: size * 0.1,
                        endRadius: size * 0.8
                    )
                )
                .frame(width: size, height: size)
            
            // Main content
            VStack(spacing: size * 0.02) {
                // Food bowl icon with curry
                ZStack {
                    // Bowl base
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white,
                                    Color.gray.opacity(0.1)
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: size * 0.45, height: size * 0.45)
                        .shadow(color: .black.opacity(0.2), radius: size * 0.02, x: 0, y: size * 0.01)
                    
                    // Food content (curry/rice)
                    ZStack {
                        // Rice/base
                        Circle()
                            .fill(Color.yellow.opacity(0.8))
                            .frame(width: size * 0.35, height: size * 0.35)
                        
                        // Curry spots
                        ForEach(0..<8, id: \.self) { index in
                            Circle()
                                .fill(Color.red.opacity(0.7))
                                .frame(width: size * 0.04, height: size * 0.04)
                                .offset(
                                    x: cos(Double(index) * .pi / 4) * size * 0.08,
                                    y: sin(Double(index) * .pi / 4) * size * 0.08
                                )
                        }
                        
                        // Green herbs/cilantro
                        ForEach(0..<5, id: \.self) { index in
                            Circle()
                                .fill(Color.green.opacity(0.8))
                                .frame(width: size * 0.02, height: size * 0.02)
                                .offset(
                                    x: cos(Double(index) * .pi / 2.5) * size * 0.06,
                                    y: sin(Double(index) * .pi / 2.5) * size * 0.06
                                )
                        }
                    }
                }
                .offset(y: -size * 0.05)
                
                // Calorie indicator
                HStack(spacing: size * 0.01) {
                    // Flame icon for calories
                    Image(systemName: "flame.fill")
                        .font(.system(size: size * 0.08, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: size * 0.01)
                    
                    // Calorie text
                    Text("Cal")
                        .font(.system(size: size * 0.06, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: size * 0.01)
                }
                .offset(y: size * 0.05)
            }
            
            // Camera lens highlight in corner
            Circle()
                .stroke(Color.white.opacity(0.6), lineWidth: size * 0.008)
                .frame(width: size * 0.12, height: size * 0.12)
                .overlay(
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: size * 0.08, height: size * 0.08)
                )
                .offset(x: size * 0.3, y: -size * 0.3)
        }
    }
}

// Helper view for generating different icon sizes
struct AppIconGenerator: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Indian Food Calorie App Icons")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                // Different sizes for App Store Connect
                VStack(spacing: 20) {
                    Text("App Store Icon (1024x1024)")
                        .font(.headline)
                    AppIconView(size: 200) // Scaled down for preview
                        .scaleEffect(0.5)
                }
                
                VStack(spacing: 20) {
                    Text("iPhone Icons")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        VStack {
                            AppIconView(size: 60)
                            Text("60pt")
                                .font(.caption)
                        }
                        
                        VStack {
                            AppIconView(size: 80)
                            Text("80pt")
                                .font(.caption)
                        }
                        
                        VStack {
                            AppIconView(size: 100)
                            Text("100pt")
                                .font(.caption)
                        }
                    }
                }
                
                VStack(spacing: 20) {
                    Text("Alternative Design")
                        .font(.headline)
                    
                    AppIconViewAlternative(size: 120)
                }
                
                Spacer(minLength: 50)
            }
            .padding()
        }
    }
}

// Alternative app icon design
struct AppIconViewAlternative: View {
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: size * 0.18)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.green.opacity(0.8),
                            Color.orange,
                            Color.red.opacity(0.9)
                        ]),
                        startPoint: .topTrailing,
                        endPoint: .bottomLeading
                    )
                )
                .frame(width: size, height: size)
            
            // Leaf and food combination
            VStack(spacing: size * 0.05) {
                // Leaf icon for healthy eating
                Image(systemName: "leaf.fill")
                    .font(.system(size: size * 0.25, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: size * 0.02)
                
                // Food plate
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.9))
                        .frame(width: size * 0.35, height: size * 0.35)
                    
                    Text("🍛")
                        .font(.system(size: size * 0.2))
                }
                .shadow(color: .black.opacity(0.2), radius: size * 0.01)
            }
        }
    }
}

#Preview("App Icon Generator") {
    AppIconGenerator()
}

#Preview("Main Icon") {
    AppIconView(size: 200)
}

#Preview("Alternative Icon") {
    AppIconViewAlternative(size: 200)
}