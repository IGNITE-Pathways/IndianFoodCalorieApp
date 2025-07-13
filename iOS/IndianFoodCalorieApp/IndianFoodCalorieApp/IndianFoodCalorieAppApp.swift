//
//  IndianFoodCalorieAppApp.swift
//  IndianFoodCalorieApp
//
//  Created by rajeev on 7/13/25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct IndianFoodCalorieAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            MainAppView()
        }
    }
}
