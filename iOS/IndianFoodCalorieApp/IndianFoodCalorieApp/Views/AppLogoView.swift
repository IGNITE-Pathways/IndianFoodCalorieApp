import SwiftUI

struct AppLogoView: View {
    let size: CGFloat
    let showText: Bool
    
    init(size: CGFloat = 120, showText: Bool = true) {
        self.size = size
        self.showText = showText
    }
    
    var body: some View {
        VStack(spacing: size * 0.1) {
            // Logo Icon
            logoIcon
            
            // App Name
            if showText {
                logoText
            }
        }
    }
    
    private var logoIcon: some View {
        ZStack {
            // Outer circle with gradient
            Circle()
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
                .shadow(color: .orange.opacity(0.3), radius: size * 0.1, x: 0, y: size * 0.05)
            
            // Inner glow effect
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.3),
                            Color.clear
                        ]),
                        center: .topLeading,
                        startRadius: size * 0.1,
                        endRadius: size * 0.4
                    )
                )
                .frame(width: size * 0.9, height: size * 0.9)
            
            // Main content
            VStack(spacing: size * 0.02) {
                // Traditional Indian bowl/thali
                ZStack {
                    // Bowl rim
                    Circle()
                        .stroke(Color.white.opacity(0.8), lineWidth: size * 0.015)
                        .frame(width: size * 0.55, height: size * 0.55)
                    
                    // Bowl base
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.95),
                                    Color.gray.opacity(0.1)
                                ]),
                                center: .center,
                                startRadius: size * 0.1,
                                endRadius: size * 0.25
                            )
                        )
                        .frame(width: size * 0.5, height: size * 0.5)
                    
                    // Food content - Indian curry with rice
                    ZStack {
                        // Rice base (white/yellow)
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.yellow.opacity(0.7),
                                        Color.white.opacity(0.8)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: size * 0.38, height: size * 0.38)
                        
                        // Curry/dal spots (orange/red)
                        ForEach(0..<6, id: \.self) { index in
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.red.opacity(0.8),
                                            Color.orange.opacity(0.6)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: size * 0.06, height: size * 0.06)
                                .offset(
                                    x: cos(Double(index) * .pi / 3) * size * 0.08,
                                    y: sin(Double(index) * .pi / 3) * size * 0.08
                                )
                        }
                        
                        // Green herbs/vegetables (coriander/mint)
                        ForEach(0..<4, id: \.self) { index in
                            Capsule()
                                .fill(Color.green.opacity(0.8))
                                .frame(width: size * 0.02, height: size * 0.04)
                                .rotationEffect(.degrees(Double(index) * 45))
                                .offset(
                                    x: cos(Double(index) * .pi / 2) * size * 0.1,
                                    y: sin(Double(index) * .pi / 2) * size * 0.1
                                )
                        }
                        
                        // Small spice dots
                        ForEach(0..<8, id: \.self) { index in
                            Circle()
                                .fill(Color.brown.opacity(0.6))
                                .frame(width: size * 0.015, height: size * 0.015)
                                .offset(
                                    x: cos(Double(index) * .pi / 4) * size * 0.12,
                                    y: sin(Double(index) * .pi / 4) * size * 0.12
                                )
                        }
                    }
                }
                
                // Nutrition indicator at bottom
                HStack(spacing: size * 0.02) {
                    // Calorie flame
                    Image(systemName: "flame.fill")
                        .font(.system(size: size * 0.08, weight: .bold))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: size * 0.01)
                    
                    // Healthy leaf
                    Image(systemName: "leaf.fill")
                        .font(.system(size: size * 0.07, weight: .bold))
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.3), radius: size * 0.01)
                }
                .offset(y: size * 0.15)
            }
            
            // Camera lens accent in top-right
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: size * 0.15, height: size * 0.15)
                
                Circle()
                    .stroke(Color.white.opacity(0.6), lineWidth: size * 0.008)
                    .frame(width: size * 0.12, height: size * 0.12)
                
                Circle()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: size * 0.05, height: size * 0.05)
            }
            .offset(x: size * 0.28, y: -size * 0.28)
        }
    }
    
    private var logoText: some View {
        VStack(spacing: size * 0.03) {
            // Main app name
            Text("Indian Food")
                .font(.system(size: size * 0.16, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.orange,
                            Color.red.opacity(0.8)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Calorie App")
                .font(.system(size: size * 0.12, weight: .semibold, design: .rounded))
                .foregroundColor(.gray.opacity(0.8))
        }
    }
}

// Simplified logo for small spaces
struct AppLogoMini: View {
    let size: CGFloat
    
    init(size: CGFloat = 40) {
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.orange,
                            Color.red.opacity(0.8)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            // Simple bowl icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: size * 0.6, height: size * 0.6)
                
                // Food content
                Circle()
                    .fill(Color.yellow.opacity(0.8))
                    .frame(width: size * 0.45, height: size * 0.45)
                
                // Curry spot
                Circle()
                    .fill(Color.red.opacity(0.7))
                    .frame(width: size * 0.15, height: size * 0.15)
                    .offset(x: size * 0.05, y: -size * 0.05)
                
                // Green herb
                Circle()
                    .fill(Color.green.opacity(0.8))
                    .frame(width: size * 0.08, height: size * 0.08)
                    .offset(x: -size * 0.08, y: size * 0.06)
            }
        }
    }
}

// Logo showcase for different contexts
struct AppLogoShowcase: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                Text("Indian Food Calorie App Logo")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                // Main logo
                VStack(spacing: 20) {
                    Text("Main Logo")
                        .font(.headline)
                    AppLogoView(size: 150, showText: true)
                }
                
                // Icon only
                VStack(spacing: 20) {
                    Text("Icon Only")
                        .font(.headline)
                    HStack(spacing: 30) {
                        AppLogoView(size: 100, showText: false)
                        AppLogoView(size: 80, showText: false)
                        AppLogoView(size: 60, showText: false)
                    }
                }
                
                // Mini versions
                VStack(spacing: 20) {
                    Text("Mini Versions")
                        .font(.headline)
                    HStack(spacing: 20) {
                        AppLogoMini(size: 50)
                        AppLogoMini(size: 40)
                        AppLogoMini(size: 30)
                        AppLogoMini(size: 24)
                    }
                }
                
                // Different backgrounds
                VStack(spacing: 20) {
                    Text("On Different Backgrounds")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        // Dark background
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.black)
                                .frame(width: 120, height: 120)
                            AppLogoMini(size: 60)
                        }
                        
                        // Light background
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 120, height: 120)
                            AppLogoMini(size: 60)
                        }
                        
                        // Gradient background
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            AppLogoMini(size: 60)
                        }
                    }
                }
                
                Spacer(minLength: 50)
            }
            .padding()
        }
    }
}

#Preview("Logo Showcase") {
    AppLogoShowcase()
}

#Preview("Main Logo") {
    AppLogoView(size: 150)
}

#Preview("Mini Logo") {
    AppLogoMini(size: 60)
}