# Quick Fix for Xcode Build Issues

## Current Issues:
1. Missing DGChartsDynamic.framework
2. InsightsViewSimple.swift reference

## Solution:

### Option A: Remove from Xcode UI
1. Delete InsightsViewSimple.swift from Xcode project navigator
2. Remove any Charts package dependencies
3. Clean build folder (Shift+Cmd+K)

### Option B: Create New Project
If issues persist:
1. Create a new Xcode project: "IndianFoodCalorieApp2"
2. Copy ONLY these files:
   - ContentView.swift
   - All files from Models/ folder
   - All files from Views/ folder (except any InsightsViewSimple)
   - All ViewModel files
   - ImagePicker.swift
   - CameraView.swift

### Option C: Temporary Workaround
Replace the problematic InsightsView with a simple version temporarily.

## Files That Should Be in Project:
✅ ContentView.swift
✅ Models/User.swift
✅ Models/FoodItem.swift
✅ Views/ScanView.swift
✅ Views/HistoryView.swift
✅ Views/InsightsView.swift (simplified version)
✅ Views/ProfileView.swift
✅ All ViewModel files
✅ ImagePicker.swift
✅ CameraView.swift

## Files to AVOID:
❌ InsightsViewSimple.swift
❌ Any Charts-related imports
❌ DGCharts references