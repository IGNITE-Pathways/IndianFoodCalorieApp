import SwiftUI
import GoogleSignIn
import FirebaseCore

struct GoogleSignInTestView: View {
    @State private var isSignedIn = false
    @State private var userEmail = ""
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Google Sign-In Test")
                .font(.title)
                .fontWeight(.bold)
            
            if isSignedIn {
                VStack {
                    Text("✅ Successfully signed in!")
                        .foregroundColor(.green)
                    Text("Email: \(userEmail)")
                        .font(.subheadline)
                    
                    Button("Sign Out") {
                        signOut()
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            } else {
                Button("Sign in with Google") {
                    signInWithGoogle()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            // Configuration Info
            VStack(alignment: .leading, spacing: 10) {
                Text("Configuration Status:")
                    .font(.headline)
                
                Text("Firebase configured: \(FirebaseApp.app() != nil ? "✅" : "❌")")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
    }
    
    private func signInWithGoogle() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            errorMessage = "Could not find root view controller"
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Sign-in error: \(error.localizedDescription)"
                }
                return
            }
            
            guard let user = result?.user else {
                DispatchQueue.main.async {
                    self.errorMessage = "No user data received"
                }
                return
            }
            
            DispatchQueue.main.async {
                self.isSignedIn = true
                self.userEmail = user.profile?.email ?? "No email"
                self.errorMessage = ""
            }
        }
    }
    
    private func signOut() {
        GIDSignIn.sharedInstance.signOut()
        DispatchQueue.main.async {
            self.isSignedIn = false
            self.userEmail = ""
            self.errorMessage = ""
        }
    }
}

#Preview {
    GoogleSignInTestView()
} 