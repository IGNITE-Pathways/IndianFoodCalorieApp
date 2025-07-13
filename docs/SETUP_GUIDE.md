# Indian Food Calorie App - Complete Setup Guide

## Phase 1: Xcode Project Setup

### Step 1: Create Xcode Project
1. Open Xcode
2. Create new project → iOS → App
3. Product Name: `IndianFoodCalorieApp`
4. Interface: SwiftUI
5. Language: Swift
6. Team: Your Apple Developer Account
7. Bundle Identifier: `com.yourname.indianfoodcalorieapp`

### Step 2: Add Required Dependencies
Add these packages via Xcode → File → Add Package Dependencies:

1. **Firebase iOS SDK**:
   ```
   https://github.com/firebase/firebase-ios-sdk
   ```
   Select these products:
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseStorage
   - FirebaseFunctions
   - FirebaseAnalytics

2. **Swift Charts**:
   ```
   https://github.com/apple/swift-charts.git
   ```
   
3. **Alternative if Swift Charts unavailable**:
   ```
   https://github.com/danielgindi/Charts
   ```

### Step 3: Copy Source Files
1. Copy all files from `iOS/IndianFoodCalorieApp/` to your Xcode project
2. Add files to appropriate groups:
   - Views/ → Views group
   - Models/ → Models group
   - Services/ → Services group

### Step 4: Configure Info.plist
Add camera and photo library permissions:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan food items</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select food images</string>
```

## Phase 2: Firebase Setup

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create new project: "IndianFoodCalorieApp"
3. Enable Google Analytics (optional)

### Step 2: Add iOS App to Firebase
1. Click "Add app" → iOS
2. Bundle ID: `com.yourname.indianfoodcalorieapp`
3. Download `GoogleService-Info.plist`
4. Add to Xcode project root

### Step 3: Enable Firebase Services
1. **Authentication**: Email/Password, Google, Apple
2. **Firestore**: Start in test mode
3. **Storage**: Start in test mode
4. **Functions**: Enable
5. **Analytics**: Enable

## Phase 3: ML Model Development

### Step 1: Data Collection
1. Download Kaggle Indian Food Dataset
2. Set up data preprocessing pipeline
3. Augment data for better training

### Step 2: Model Training
1. Use TensorFlow/PyTorch for training
2. Convert to Core ML format
3. Test model accuracy

### Step 3: Integration
1. Add Core ML model to Xcode
2. Implement Vision framework integration
3. Test real-time inference

## Phase 4: API Integration

### Step 1: Nutrition Data APIs
1. Set up CalorieNinjas API key
2. Create nutrition service layer
3. Implement caching strategy

### Step 2: Firebase Functions
1. Deploy nutrition lookup functions
2. Set up image processing pipeline
3. Implement user data sync

## Phase 5: Testing & Deployment

### Step 1: Testing
1. Unit tests for models
2. UI tests for critical flows
3. Device testing on multiple iOS versions

### Step 2: App Store Preparation
1. App icons and screenshots
2. App Store Connect setup
3. TestFlight beta testing

Ready to start with Phase 1?