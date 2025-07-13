import SwiftUI
import FirebaseFirestore

struct FirebaseTestView: View {
    @StateObject private var authService = AuthService()
    @State private var testResult = ""
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🔥 Firebase Connection Test")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Connection Status
                HStack {
                    Image(systemName: authService.isSignedIn ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(authService.isSignedIn ? .green : .red)
                    
                    Text(authService.isSignedIn ? "Connected to Firebase" : "Not Connected")
                        .fontWeight(.medium)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                if let user = authService.currentUser {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("User Info:")
                            .font(.headline)
                        Text("UID: \(user.uid)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        if let email = user.email {
                            Text("Email: \(email)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                }
                
                // Test Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        testFirebaseConnection()
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Text(isLoading ? "Testing..." : "Test Firebase Connection")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .disabled(isLoading)
                    
                    Button(action: {
                        Task {
                            await authService.signInAnonymously()
                        }
                    }) {
                        Text("Sign In Anonymously")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    if authService.isSignedIn {
                        Button(action: {
                            authService.signOut()
                        }) {
                            Text("Sign Out")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                
                // Test Results
                if !testResult.isEmpty {
                    ScrollView {
                        Text(testResult)
                            .font(.caption)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .frame(maxHeight: 200)
                }
                
                // Error Message
                if let error = authService.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Firebase Test")
        }
    }
    
    private func testFirebaseConnection() {
        isLoading = true
        testResult = ""
        
        // Test Firestore connection
        let db = Firestore.firestore()
        
        // Try to write a test document
        let testData = [
            "test": "Firebase connection test",
            "timestamp": FieldValue.serverTimestamp(),
            "app": "IndianFoodCalorieApp"
        ] as [String : Any]
        
        db.collection("test").addDocument(data: testData) { error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    testResult = "❌ Firestore Test Failed: \(error.localizedDescription)"
                } else {
                    testResult = "✅ Firestore Test Passed: Successfully wrote to database!\n\n"
                    testResult += "✅ Authentication: \(authService.isSignedIn ? "Working" : "Not connected")\n"
                    testResult += "✅ Firestore: Working\n"
                    testResult += "✅ Firebase is fully connected!\n\n"
                    testResult += "Your Indian Food Calorie App is ready for real data! 🎉"
                }
            }
        }
    }
}

#Preview {
    FirebaseTestView()
}