import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject var authService: AuthService
    @State private var showingSettings = false
    @State private var showingSignOutAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Header
                    VStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.orange)
                        
                        Text(displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(memberSinceText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if isAnonymousUser {
                            Text("Guest User")
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 4)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    
                    // Quick Stats
                    HStack(spacing: 20) {
                        StatCard(title: "Total Scans", value: "247", icon: "camera.fill")
                        StatCard(title: "Foods Tried", value: "68", icon: "fork.knife")
                        StatCard(title: "Streak", value: "12 days", icon: "flame.fill")
                    }
                    .padding(.horizontal)
                    
                    // Goals Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Daily Goals")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            GoalItem(title: "Calorie Target", current: 1850, target: 2400, unit: "cal")
                            GoalItem(title: "Protein Goal", current: 85, target: 120, unit: "g")
                            GoalItem(title: "Water Intake", current: 6, target: 8, unit: "glasses")
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Menu Options
                    VStack(spacing: 0) {
                        NavigationLink(destination: PersonalInfoView()) {
                            HStack {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.orange)
                                    .frame(width: 30)
                                
                                Text("Personal Information")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                        
                        NavigationLink(destination: DietaryPreferencesView()) {
                            HStack {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.orange)
                                    .frame(width: 30)
                                
                                Text("Dietary Preferences")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                        
                        NavigationLink(destination: NotificationSettingsView()) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.orange)
                                    .frame(width: 30)
                                
                                Text("Notifications")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                        
                        NavigationLink(destination: DataExportView()) {
                            HStack {
                                Image(systemName: "square.and.arrow.up.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.orange)
                                    .frame(width: 30)
                                
                                Text("Data Export")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                        
                        NavigationLink(destination: HelpSupportView()) {
                            HStack {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.orange)
                                    .frame(width: 30)
                                
                                Text("Help & Support")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                        
                        NavigationLink(destination: PrivacyPolicyView()) {
                            HStack {
                                Image(systemName: "shield.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.orange)
                                    .frame(width: 30)
                                
                                Text("Privacy Policy")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                        
                        NavigationLink(destination: FirebaseTestView()) {
                            HStack {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.orange)
                                    .frame(width: 30)
                                
                                Text("Test Firebase Connection")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                        
                        // Sign Out Button
                        Button(action: {
                            showingSignOutAlert = true
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                    .font(.system(size: 18))
                                    .foregroundColor(.red)
                                    .frame(width: 30)
                                
                                Text("Sign Out")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                            .padding()
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                        
                        NavigationLink(destination: NutritionTestView()) {
                            HStack {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.green)
                                    .frame(width: 30)
                                
                                Text("Test Nutrition API")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                        
                        NavigationLink(destination: AppIconGenerator()) {
                            HStack {
                                Image(systemName: "app.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.purple)
                                    .frame(width: 30)
                                
                                Text("App Icon Preview")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                        
                        NavigationLink(destination: AppLogoShowcase()) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.yellow)
                                    .frame(width: 30)
                                
                                Text("App Logo Showcase")
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Version Info
                    Text("Version 1.0.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    authService.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
    
    // MARK: - Computed Properties
    private var displayName: String {
        if let user = authService.currentUser {
            if user.isAnonymous {
                return "Guest User"
            } else if let displayName = user.displayName, !displayName.isEmpty {
                return displayName  // Google/Apple provided name
            } else if let email = user.email {
                return email.components(separatedBy: "@").first?.capitalized ?? "User"
            }
        }
        return "User"
    }
    
    private var memberSinceText: String {
        if let user = authService.currentUser {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            if user.isAnonymous {
                return "Temporary session"
            } else {
                let creationDate = user.metadata.creationDate ?? Date()
                return "Member since \(formatter.string(from: creationDate))"
            }
        }
        return "Member since today"
    }
    
    private var isAnonymousUser: Bool {
        authService.currentUser?.isAnonymous ?? false
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.orange)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct GoalItem: View {
    let title: String
    let current: Int
    let target: Int
    let unit: String
    
    var progress: Double {
        min(Double(current) / Double(target), 1.0)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text("\(current)/\(target) \(unit)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .orange))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
    }
}

struct MenuOption: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.orange)
                    .frame(width: 30)
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("App Settings") {
                    HStack {
                        Text("Units")
                        Spacer()
                        Text("Metric")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Camera Quality")
                        Spacer()
                        Text("High")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Auto Flash")
                        Spacer()
                        Toggle("", isOn: .constant(true))
                    }
                }
                
                Section("Data & Privacy") {
                    Button("Clear Cache") { }
                    Button("Reset All Data") { }
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthService())
}