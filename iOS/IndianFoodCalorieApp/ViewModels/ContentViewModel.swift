import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
    @Published var selectedTab: Int = 0
    @Published var isUserAuthenticated: Bool = false
    @Published var currentUser: User?
    
    init() {
        // Initialize with sample data for development
        setupSampleUser()
    }
    
    private func setupSampleUser() {
        // For development purposes, use sample user
        currentUser = User.sampleUser
        isUserAuthenticated = true
    }
    
    func selectTab(_ index: Int) {
        selectedTab = index
    }
    
    func signOut() {
        isUserAuthenticated = false
        currentUser = nil
    }
}