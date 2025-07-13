import SwiftUI
import FirebaseAuth

struct AuthView: View {
    @StateObject private var authService = AuthService()
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showingWelcome = true
    
    var body: some View {
        if showingWelcome {
            WelcomeView(showingWelcome: $showingWelcome)
        } else {
            authenticationView
        }
    }
    
    private var authenticationView: some View {
        NavigationView {
            VStack(spacing: 30) {
                // App Logo and Title
                VStack(spacing: 15) {
                    AppLogoView(size: 100, showText: false)
                    
                    Text("Indian Food Calorie App")
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text(isSignUp ? "Create your account to start tracking" : "Welcome back! Sign in to continue")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                // Form Fields
                VStack(spacing: 20) {
                    // Email Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.headline)
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.headline)
                        SecureField("Enter your password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Confirm Password (Sign Up only)
                    if isSignUp {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.headline)
                            SecureField("Confirm your password", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                }
                .padding(.horizontal)
                
                // Error Message
                if let errorMessage = authService.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }
                
                // Action Button
                VStack(spacing: 15) {
                    Button(action: {
                        if isSignUp {
                            signUp()
                        } else {
                            signIn()
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(isSignUp ? "Create Account" : "Sign In")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isLoading || !isFormValid)
                    .padding(.horizontal)
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3))
                        Text("or")
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 16)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3))
                    }
                    .padding(.horizontal)
                    
                    // Social Sign In Buttons
                    VStack(spacing: 12) {
                        // Google Sign In
                        Button(action: {
                            signInWithGoogle()
                        }) {
                            HStack {
                                Image(systemName: "globe")
                                    .font(.system(size: 18, weight: .medium))
                                Text("Continue with Google")
                                    .fontWeight(.medium)
                                Text("(Beta)")
                                    .font(.caption)
                                    .opacity(0.7)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                        .disabled(isLoading)
                        .padding(.horizontal)
                        
                        // Apple Sign In
                        Button(action: {
                            signInWithApple()
                        }) {
                            HStack {
                                Image(systemName: "applelogo")
                                    .font(.system(size: 18, weight: .medium))
                                Text("Continue with Apple")
                                    .fontWeight(.medium)
                                #if targetEnvironment(simulator)
                                Text("(Device Only)")
                                    .font(.caption)
                                    .opacity(0.7)
                                #else
                                Text("(Beta)")
                                    .font(.caption)
                                    .opacity(0.7)
                                #endif
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(isLoading)
                        .padding(.horizontal)
                        
                        // Anonymous Sign In (for testing)
                        Button(action: {
                            signInAnonymously()
                        }) {
                            Text("Continue as Guest")
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.primary)
                                .cornerRadius(10)
                        }
                        .disabled(isLoading)
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Toggle between Sign In / Sign Up
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isSignUp.toggle()
                        clearFields()
                    }
                }) {
                    HStack {
                        Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                            .foregroundColor(.secondary)
                        Text(isSignUp ? "Sign In" : "Sign Up")
                            .foregroundColor(.orange)
                            .fontWeight(.medium)
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationBarHidden(true)
        }
    }
    
    private var isFormValid: Bool {
        if isSignUp {
            return !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && password == confirmPassword && password.count >= 6
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    private func signIn() {
        isLoading = true
        Task {
            await authService.signIn(email: email, password: password)
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    private func signUp() {
        guard password == confirmPassword else {
            authService.errorMessage = "Passwords do not match"
            return
        }
        
        guard password.count >= 6 else {
            authService.errorMessage = "Password must be at least 6 characters"
            return
        }
        
        isLoading = true
        Task {
            await authService.signUp(email: email, password: password)
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    private func signInAnonymously() {
        isLoading = true
        Task {
            await authService.signInAnonymously()
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    private func signInWithGoogle() {
        isLoading = true
        Task {
            await authService.signInWithGoogle()
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    private func signInWithApple() {
        isLoading = true
        Task {
            await authService.signInWithApple()
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    private func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
        authService.errorMessage = nil
    }
}

#Preview {
    AuthView()
}