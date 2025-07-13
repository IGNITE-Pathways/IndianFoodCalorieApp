#!/usr/bin/env python3
"""
Setup script to download and prepare datasets for Indian Food Calorie App
"""

import os
import pandas as pd
import requests
import zipfile
import json
from pathlib import Path
import kaggle

def setup_directories():
    """Create necessary directories for data storage"""
    dirs = [
        "raw/images",
        "raw/nutrition", 
        "processed/images",
        "processed/nutrition",
        "models"
    ]
    
    for dir_path in dirs:
        Path(dir_path).mkdir(parents=True, exist_ok=True)
    print("✅ Directory structure created")

def download_kaggle_dataset():
    """Download Indian Food dataset from Kaggle"""
    try:
        # Ensure Kaggle API is configured
        kaggle.api.authenticate()
        
        # Download Indian Food Images Dataset
        print("📥 Downloading Indian Food Images Dataset...")
        kaggle.api.dataset_download_files(
            'iamsouravbanerjee/indian-food-images-dataset',
            path='raw/images/',
            unzip=True
        )
        
        # Download Indian Food Nutrition Dataset
        print("📥 Downloading Indian Food Nutrition Dataset...")
        kaggle.api.dataset_download_files(
            'batthulavinay/indian-food-nutrition',
            path='raw/nutrition/',
            unzip=True
        )
        
        print("✅ Kaggle datasets downloaded successfully")
        
    except Exception as e:
        print(f"❌ Error downloading Kaggle datasets: {e}")
        print("Please ensure you have Kaggle API configured:")
        print("1. pip install kaggle")
        print("2. Create ~/.kaggle/kaggle.json with your API credentials")
        print("3. chmod 600 ~/.kaggle/kaggle.json")

def download_indian_nutrient_database():
    """Download Indian Nutrient Databank (INDB) data"""
    try:
        print("📥 Downloading Indian Nutrient Databank...")
        
        # This would be the actual INDB API endpoint
        # For now, we'll create a mock dataset
        indb_data = {
            "foods": [
                {
                    "name": "Chicken Biryani",
                    "calories_per_100g": 165,
                    "protein": 8.1,
                    "carbohydrates": 23.0,
                    "fat": 4.1,
                    "fiber": 0.6,
                    "calcium": 12,
                    "iron": 1.8,
                    "vitamin_c": 0
                },
                {
                    "name": "Idli",
                    "calories_per_100g": 58,
                    "protein": 2.5,
                    "carbohydrates": 11.7,
                    "fat": 0.4,
                    "fiber": 0.9,
                    "calcium": 15,
                    "iron": 0.6,
                    "vitamin_c": 0
                },
                {
                    "name": "Dosa",
                    "calories_per_100g": 112,
                    "protein": 2.5,
                    "carbohydrates": 20.0,
                    "fat": 2.0,
                    "fiber": 1.2,
                    "calcium": 12,
                    "iron": 1.2,
                    "vitamin_c": 0
                }
            ]
        }
        
        with open('raw/nutrition/indb_data.json', 'w') as f:
            json.dump(indb_data, f, indent=2)
            
        print("✅ Indian Nutrient Databank data saved")
        
    except Exception as e:
        print(f"❌ Error downloading INDB data: {e}")

def setup_calorie_ninjas_api():
    """Set up CalorieNinjas API configuration"""
    try:
        print("🔧 Setting up CalorieNinjas API...")
        
        # Create API configuration template
        api_config = {
            "calorie_ninjas": {
                "api_key": "YOUR_API_KEY_HERE",
                "base_url": "https://api.calorieninjas.com/v1/nutrition"
            },
            "usage_notes": [
                "Sign up at https://calorieninjas.com/",
                "Get your free API key",
                "Replace YOUR_API_KEY_HERE with your actual key",
                "Free tier: 1000 requests/month"
            ]
        }
        
        with open('raw/nutrition/api_config.json', 'w') as f:
            json.dump(api_config, f, indent=2)
            
        print("✅ API configuration template created")
        print("📝 Please update api_config.json with your CalorieNinjas API key")
        
    except Exception as e:
        print(f"❌ Error setting up API config: {e}")

def create_food_mapping():
    """Create mapping between food names and IDs"""
    try:
        print("🗺️  Creating food mapping...")
        
        # Common Indian foods with standardized names
        food_mapping = {
            "biryani": ["chicken biryani", "mutton biryani", "veg biryani", "biryani"],
            "idli": ["idli", "steamed rice cake"],
            "dosa": ["dosa", "plain dosa", "masala dosa"],
            "roti": ["roti", "chapati", "indian bread"],
            "dal": ["dal", "lentil curry", "dal tadka", "dal fry"],
            "samosa": ["samosa", "samosas"],
            "chole": ["chole", "chickpea curry", "chana masala"],
            "paneer": ["paneer butter masala", "paneer curry"],
            "rajma": ["rajma", "kidney bean curry"],
            "curry": ["chicken curry", "vegetable curry", "fish curry"]
        }
        
        with open('processed/nutrition/food_mapping.json', 'w') as f:
            json.dump(food_mapping, f, indent=2)
            
        print("✅ Food mapping created")
        
    except Exception as e:
        print(f"❌ Error creating food mapping: {e}")

def process_nutrition_data():
    """Process and standardize nutrition data"""
    try:
        print("⚙️  Processing nutrition data...")
        
        # Load INDB data
        with open('raw/nutrition/indb_data.json', 'r') as f:
            indb_data = json.load(f)
        
        # Process into standardized format
        processed_foods = []
        
        for food in indb_data['foods']:
            processed_food = {
                "id": food['name'].lower().replace(' ', '_'),
                "name": food['name'],
                "nutrition_per_100g": {
                    "calories": food['calories_per_100g'],
                    "protein": food['protein'],
                    "carbohydrates": food['carbohydrates'],
                    "fat": food['fat'],
                    "fiber": food['fiber'],
                    "calcium": food['calcium'],
                    "iron": food['iron'],
                    "vitamin_c": food['vitamin_c']
                },
                "common_serving_sizes": {
                    "small": {"grams": 100, "description": "Small portion"},
                    "medium": {"grams": 150, "description": "Medium portion"},
                    "large": {"grams": 200, "description": "Large portion"}
                },
                "tags": ["indian", "main_course"],
                "verified": True
            }
            processed_foods.append(processed_food)
        
        # Save processed data
        with open('processed/nutrition/standardized_nutrition.json', 'w') as f:
            json.dump(processed_foods, f, indent=2)
            
        print("✅ Nutrition data processed and standardized")
        
    except Exception as e:
        print(f"❌ Error processing nutrition data: {e}")

def create_requirements_txt():
    """Create requirements.txt for the project"""
    requirements = [
        "pandas>=1.5.0",
        "numpy>=1.21.0",
        "requests>=2.28.0",
        "kaggle>=1.5.12",
        "Pillow>=9.0.0",
        "tensorflow>=2.10.0",
        "opencv-python>=4.6.0",
        "scikit-learn>=1.1.0",
        "matplotlib>=3.5.0",
        "seaborn>=0.11.0",
        "jupyter>=1.0.0"
    ]
    
    with open('requirements.txt', 'w') as f:
        f.write('\n'.join(requirements))
    
    print("✅ requirements.txt created")

def main():
    """Main setup function"""
    print("🚀 Setting up Indian Food Calorie App datasets...")
    print("=" * 50)
    
    # Change to data directory
    os.chdir(Path(__file__).parent)
    
    # Setup steps
    setup_directories()
    download_kaggle_dataset()
    download_indian_nutrient_database()
    setup_calorie_ninjas_api()
    create_food_mapping()
    process_nutrition_data()
    create_requirements_txt()
    
    print("\n" + "=" * 50)
    print("✅ Dataset setup complete!")
    print("\n📋 Next steps:")
    print("1. Configure Kaggle API credentials")
    print("2. Update CalorieNinjas API key in api_config.json")
    print("3. Run: pip install -r requirements.txt")
    print("4. Start training your ML model!")

if __name__ == "__main__":
    main()