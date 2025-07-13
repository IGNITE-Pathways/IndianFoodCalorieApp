import SwiftUI
import FirebaseAuth

struct MainAppView: View {
    @StateObject private var authService = AuthService()
    
    var body: some View {
        Group {
            if authService.isSignedIn {
                // User is signed in - show main app
                ContentView()
                    .environmentObject(authService)
            } else {
                // User is not signed in - show authentication
                AuthView()
                    .environmentObject(authService)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: authService.isSignedIn)
    }
}

#Preview {
    MainAppView()
}