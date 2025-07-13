import Foundation
import FirebaseCore
@preconcurrency import FirebaseAuth
import Combine
import GoogleSignIn
import AuthenticationServices
import CryptoKit

class AuthService: ObservableObject {
    @Published var isSignedIn = false
    @Published var currentUser: FirebaseAuth.User?
    @Published var errorMessage: String?
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    init() {
        setupAuthStateListener()
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    private func setupAuthStateListener() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isSignedIn = user != nil
            }
        }
    }
    
    // MARK: - Sign Up
    func signUp(email: String, password: String) async {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            DispatchQueue.main.async {
                self.currentUser = result.user
                self.isSignedIn = true
                self.errorMessage = nil
                print("✅ Firebase: User created successfully: \(result.user.email ?? "")")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                print("❌ Firebase: Sign up error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Sign In
    func signIn(email: String, password: String) async {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            DispatchQueue.main.async {
                self.currentUser = result.user
                self.isSignedIn = true
                self.errorMessage = nil
                print("✅ Firebase: User signed in successfully: \(result.user.email ?? "")")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                print("❌ Firebase: Sign in error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Sign Out
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.currentUser = nil
                self.isSignedIn = false
                self.errorMessage = nil
                print("✅ Firebase: User signed out successfully")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                print("❌ Firebase: Sign out error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Google Sign In
    @MainActor
    func signInWithGoogle() async {
        // Check if Google Sign-In is properly configured
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            DispatchQueue.main.async {
                self.errorMessage = "Google Sign-In not configured. Please use email/password or guest sign-in."
            }
            return
        }
        
        // Configure Google Sign-In with the client ID
        let configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = configuration
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            DispatchQueue.main.async {
                self.errorMessage = "Could not find root view controller"
            }
            return
        }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = result.user.idToken?.tokenString else {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to get Google ID token"
                }
                return
            }
            
            let accessToken = result.user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            let authResult = try await Auth.auth().signIn(with: credential)
            DispatchQueue.main.async {
                self.currentUser = authResult.user
                self.isSignedIn = true
                self.errorMessage = nil
                print("✅ Firebase: Google user signed in: \(authResult.user.email ?? "")")
            }
        } catch {
            DispatchQueue.main.async {
                let errorMessage = self.handleGoogleSignInError(error)
                self.errorMessage = errorMessage
                print("❌ Firebase: Google sign in error: \(error.localizedDescription)")
            }
        }
    }
    
    private func handleGoogleSignInError(_ error: Error) -> String {
        let nsError = error as NSError
        
        // Handle specific Google Sign-In errors
        if nsError.domain == "com.google.GIDSignIn" {
            switch nsError.code {
            case -2: // User cancelled
                return "Google Sign-In was cancelled. Please try again or use another method."
            case -4: // No internet
                return "No internet connection. Please check your network and try again."
            case -5: // Invalid configuration
                return "Google Sign-In setup incomplete. Please use email/password or guest sign-in."
            default:
                return "Google Sign-In temporarily unavailable. Please use email/password or guest sign-in."
            }
        }
        
        // Handle OAuth errors - these typically indicate configuration issues
        if error.localizedDescription.contains("invalid_client") || error.localizedDescription.contains("401") {
            return "Google Sign-In requires additional setup. For now, please use email/password or guest sign-in."
        }
        
        // Handle network errors
        if error.localizedDescription.contains("network") || error.localizedDescription.contains("internet") {
            return "Network error. Please check your connection and try again."
        }
        
        return "Google Sign-In unavailable. Please use email/password or guest sign-in instead."
    }
    
    // MARK: - Apple Sign In
    func signInWithApple() async {
        // Check if running on simulator
        #if targetEnvironment(simulator)
        DispatchQueue.main.async {
            self.errorMessage = "Apple Sign-In is not available in iOS Simulator. Please test on a physical device or use another sign-in method."
        }
        return
        #endif
        
        // Check if Apple Sign-In is available on this device
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        
        // Check authorization status first
        if #available(iOS 13.0, *) {
            // Apple Sign-In is available, continue with implementation
        } else {
            DispatchQueue.main.async {
                self.errorMessage = "Apple Sign-In requires iOS 13 or later. Please use email/password or guest sign-in."
            }
            return
        }
        
        await withCheckedContinuation { continuation in
            let delegate = AppleSignInDelegate { result in
                Task {
                    switch result {
                    case .success(let credential):
                        do {
                            let authResult = try await Auth.auth().signIn(with: credential)
                            DispatchQueue.main.async {
                                self.currentUser = authResult.user
                                self.isSignedIn = true
                                self.errorMessage = nil
                                print("✅ Firebase: Apple user signed in: \(authResult.user.email ?? "")")
                            }
                        } catch {
                            DispatchQueue.main.async {
                                self.errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
                                print("❌ Firebase: Apple sign in error: \(error.localizedDescription)")
                            }
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            let nsError = error as NSError
                            if nsError.domain == "com.apple.AuthenticationServices.AuthorizationError" {
                                switch nsError.code {
                                case 1000:
                                    self.errorMessage = "Apple Sign-In was cancelled or failed. Please try again or use another sign-in method."
                                case 1001:
                                    self.errorMessage = "Apple Sign-In is not available. Please use email/password or guest sign-in."
                                case 1004:
                                    self.errorMessage = "Apple Sign-In failed. Please try again or use another sign-in method."
                                default:
                                    self.errorMessage = "Apple Sign-In temporarily unavailable. Please use email/password or guest sign-in."
                                }
                            } else if nsError.domain == "AKAuthenticationError" {
                                self.errorMessage = "Apple ID authentication failed. Please use email/password or guest sign-in."
                            } else {
                                self.errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
                            }
                            print("❌ Firebase: Apple sign in error: \(error.localizedDescription)")
                        }
                    }
                    continuation.resume()
                }
            }
            
            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = delegate.generateNonce()
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = delegate
            authorizationController.presentationContextProvider = delegate
            authorizationController.performRequests()
            
            // Keep delegate alive
            objc_setAssociatedObject(authorizationController, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Anonymous Sign In (for testing)
    func signInAnonymously() async {
        do {
            let result = try await Auth.auth().signInAnonymously()
            DispatchQueue.main.async {
                self.currentUser = result.user
                self.isSignedIn = true
                self.errorMessage = nil
                print("✅ Firebase: Anonymous user signed in: \(result.user.uid)")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                print("❌ Firebase: Anonymous sign in error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Apple Sign In Delegate
class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private let completion: (Result<AuthCredential, Error>) -> Void
    private var currentNonce: String?
    
    init(completion: @escaping (Result<AuthCredential, Error>) -> Void) {
        self.completion = completion
        super.init()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                completion(.failure(AuthError.invalidNonce))
                return
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                completion(.failure(AuthError.invalidCredential))
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                completion(.failure(AuthError.invalidToken))
                return
            }
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                    idToken: idTokenString,
                                                    rawNonce: nonce)
            completion(.success(credential))
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        completion(.failure(error))
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return UIWindow()
        }
        return window
    }
}

// MARK: - Auth Errors
enum AuthError: LocalizedError {
    case invalidNonce
    case invalidCredential
    case invalidToken
    
    var errorDescription: String? {
        switch self {
        case .invalidNonce:
            return "Invalid nonce for Apple Sign-In"
        case .invalidCredential:
            return "Invalid Apple ID credential"
        case .invalidToken:
            return "Invalid Apple ID token"
        }
    }
}

// MARK: - Nonce Generation
extension AppleSignInDelegate {
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func generateNonce() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        return sha256(nonce)
    }
}
