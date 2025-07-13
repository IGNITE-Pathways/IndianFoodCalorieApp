import SwiftUI
import FirebaseAuth

// MARK: - Personal Information View
struct PersonalInfoView: View {
    @EnvironmentObject var authService: AuthService
    @State private var height = "170"
    @State private var weight = "70"
    @State private var age = "25"
    @State private var gender = 0
    @State private var activityLevel = 1
    
    private let genders = ["Male", "Female", "Other"]
    private let activityLevels = ["Sedentary", "Lightly Active", "Moderately Active", "Very Active", "Extremely Active"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Profile") {
                    HStack {
                        Text("Name")
                        Spacer()
                        Text(displayName)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Email")
                        Spacer()
                        Text(userEmail)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Physical Info") {
                    HStack {
                        Text("Height")
                        Spacer()
                        TextField("cm", text: $height)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Weight")
                        Spacer()
                        TextField("kg", text: $weight)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    HStack {
                        Text("Age")
                        Spacer()
                        TextField("years", text: $age)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Picker("Gender", selection: $gender) {
                        ForEach(0..<genders.count, id: \.self) { index in
                            Text(genders[index]).tag(index)
                        }
                    }
                }
                
                Section("Activity Level") {
                    Picker("Activity Level", selection: $activityLevel) {
                        ForEach(0..<activityLevels.count, id: \.self) { index in
                            Text(activityLevels[index]).tag(index)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                
                Section("Calculated Values") {
                    HStack {
                        Text("BMI")
                        Spacer()
                        Text(calculateBMI())
                            .foregroundColor(.orange)
                    }
                    
                    HStack {
                        Text("Daily Calorie Goal")
                        Spacer()
                        Text("\(calculateDailyCalories()) cal")
                            .foregroundColor(.orange)
                    }
                }
            }
            .navigationTitle("Personal Info")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var displayName: String {
        if let user = authService.currentUser {
            if user.isAnonymous {
                return "Guest User"
            } else if let displayName = user.displayName, !displayName.isEmpty {
                return displayName
            } else if let email = user.email {
                return email.components(separatedBy: "@").first?.capitalized ?? "User"
            }
        }
        return "User"
    }
    
    private var userEmail: String {
        if let user = authService.currentUser, !user.isAnonymous {
            return user.email ?? "No email"
        }
        return "Guest account"
    }
    
    private func calculateBMI() -> String {
        guard let h = Double(height), let w = Double(weight), h > 0 else {
            return "Enter height/weight"
        }
        let bmi = w / ((h/100) * (h/100))
        return String(format: "%.1f", bmi)
    }
    
    private func calculateDailyCalories() -> Int {
        guard let h = Double(height), let w = Double(weight), let a = Double(age) else {
            return 2000
        }
        
        // Basic BMR calculation (Mifflin-St Jeor)
        let bmr = gender == 0 ? 
            (10 * w + 6.25 * h - 5 * a + 5) : 
            (10 * w + 6.25 * h - 5 * a - 161)
        
        let activityMultipliers = [1.2, 1.375, 1.55, 1.725, 1.9]
        let dailyCalories = bmr * activityMultipliers[activityLevel]
        
        return Int(dailyCalories)
    }
}

// MARK: - Dietary Preferences View
struct DietaryPreferencesView: View {
    @State private var isVegetarian = false
    @State private var isVegan = false
    @State private var isGlutenFree = false
    @State private var isDairyFree = false
    @State private var isKeto = false
    @State private var allergies = ""
    @State private var customRestrictions = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Diet Type") {
                    Toggle("Vegetarian", isOn: $isVegetarian)
                    Toggle("Vegan", isOn: $isVegan)
                    Toggle("Keto/Low Carb", isOn: $isKeto)
                }
                
                Section("Allergies & Restrictions") {
                    Toggle("Gluten Free", isOn: $isGlutenFree)
                    Toggle("Dairy Free", isOn: $isDairyFree)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Known Allergies")
                            .font(.subheadline)
                        TextField("e.g., nuts, shellfish, soy", text: $allergies)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                
                Section("Custom Restrictions") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Other Dietary Needs")
                            .font(.subheadline)
                        TextField("Describe any other restrictions", text: $customRestrictions, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                    }
                }
                
                Section {
                    Button("Save Preferences") {
                        // Save to user defaults or Firebase
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.orange)
                }
            }
            .navigationTitle("Dietary Preferences")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Notification Settings View
struct NotificationSettingsView: View {
    @State private var dailyReminders = true
    @State private var mealReminders = false
    @State private var achievementNotifications = true
    @State private var weeklyReports = true
    @State private var reminderTime = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Meal Tracking") {
                    Toggle("Daily Tracking Reminders", isOn: $dailyReminders)
                    Toggle("Meal Time Reminders", isOn: $mealReminders)
                    
                    if dailyReminders || mealReminders {
                        DatePicker("Reminder Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    }
                }
                
                Section("Progress & Achievements") {
                    Toggle("Achievement Notifications", isOn: $achievementNotifications)
                    Toggle("Weekly Progress Reports", isOn: $weeklyReports)
                }
                
                Section("Push Notifications") {
                    HStack {
                        Text("App Notifications")
                        Spacer()
                        Button("Settings") {
                            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(settingsUrl)
                            }
                        }
                        .foregroundColor(.orange)
                    }
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Data Export View
struct DataExportView: View {
    @State private var showingExportAlert = false
    @State private var exportFormat = 0
    @State private var dateRange = 0
    
    private let formats = ["CSV", "JSON", "PDF Report"]
    private let ranges = ["Last 7 days", "Last 30 days", "Last 3 months", "All time"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Export Options") {
                    Picker("Format", selection: $exportFormat) {
                        ForEach(0..<formats.count, id: \.self) { index in
                            Text(formats[index]).tag(index)
                        }
                    }
                    
                    Picker("Date Range", selection: $dateRange) {
                        ForEach(0..<ranges.count, id: \.self) { index in
                            Text(ranges[index]).tag(index)
                        }
                    }
                }
                
                Section("Data Types") {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Food scan history")
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Nutrition data")
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Daily summaries")
                    }
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Personal preferences")
                    }
                }
                
                Section {
                    Button("Export My Data") {
                        showingExportAlert = true
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.orange)
                }
                
                Section(footer: Text("Your data will be exported in the selected format and can be shared via email or saved to Files app.")) {
                    EmptyView()
                }
            }
            .navigationTitle("Data Export")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Export Data", isPresented: $showingExportAlert) {
                Button("Export") {
                    // Implement data export
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Export \(ranges[dateRange].lowercased()) of data as \(formats[exportFormat])?")
            }
        }
    }
}

// MARK: - Help & Support View
struct HelpSupportView: View {
    var body: some View {
        NavigationView {
            List {
                Section("Getting Started") {
                    HelpItem(title: "How to scan food", description: "Learn how to use the camera to identify Indian foods")
                    HelpItem(title: "Understanding nutrition data", description: "How to read the nutrition information")
                    HelpItem(title: "Setting up your profile", description: "Customize your dietary preferences and goals")
                }
                
                Section("Features") {
                    HelpItem(title: "Manual food search", description: "Search for foods that weren't recognized")
                    HelpItem(title: "History tracking", description: "View and manage your food scan history")
                    HelpItem(title: "Daily insights", description: "Understanding your nutrition trends")
                }
                
                Section("Troubleshooting") {
                    HelpItem(title: "Camera not working", description: "Common camera issues and solutions")
                    HelpItem(title: "Food not recognized", description: "What to do when scanning doesn't work")
                    HelpItem(title: "Syncing issues", description: "Problems with data synchronization")
                }
                
                Section("Contact Us") {
                    Button(action: {
                        // Open email
                    }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.orange)
                            Text("Email Support")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        // Open FAQ website
                    }) {
                        HStack {
                            Image(systemName: "questionmark.circle.fill")
                                .foregroundColor(.orange)
                            Text("Online FAQ")
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Help & Support")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct HelpItem: View {
    let title: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Privacy Policy View
struct PrivacyPolicyView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        Text("Privacy Policy")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Last updated: \(DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .none))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("Data Collection")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("We collect information you provide directly to us, such as when you create an account, scan food items, or contact us for support. This includes:")
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Food scan history and nutrition data")
                            Text("• Personal dietary preferences")
                            Text("• Account information (email, name)")
                            Text("• Device information for app functionality")
                        }
                        .font(.subheadline)
                        .padding(.leading)
                        
                        Text("How We Use Your Data")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Your data is used to provide personalized nutrition tracking, improve our food recognition algorithms, and enhance your app experience. We do not sell your personal information to third parties.")
                        
                        Text("Data Security")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("We implement appropriate security measures to protect your personal information. All data is encrypted in transit and at rest using industry-standard security protocols.")
                        
                        Text("Your Rights")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("You have the right to access, update, or delete your personal data at any time. You can export your data through the app or contact us for assistance.")
                        
                        Text("Contact Information")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("If you have questions about this privacy policy, please contact us at privacy@indianfoodcalorieapp.com")
                    }
                }
                .padding()
            }
            .navigationTitle("Privacy Policy")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    PersonalInfoView()
        .environmentObject(AuthService())
}