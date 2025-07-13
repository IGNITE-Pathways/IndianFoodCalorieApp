#!/usr/bin/env python3
"""
Indian Food Dataset Downloader and Preparation Script

This script helps download and prepare Indian food datasets for training
a Core ML model for food recognition.

Datasets that can be used:
1. Indian Food Images Dataset (Kaggle)
2. Food-101 (subset of Indian foods)
3. Custom Indian food images from web scraping

Usage:
    python3 download_datasets.py --dataset indian_food_kaggle
    python3 download_datasets.py --dataset food101_indian_subset
    python3 download_datasets.py --scrape_images --max_images 100
"""

import os
import argparse
from pathlib import Path
import json

def setup_directories():
    """Create necessary directories for dataset storage."""
    directories = [
        'datasets/raw',
        'datasets/processed',
        'datasets/train',
        'datasets/validation',
        'datasets/test',
        'models'
    ]
    
    for directory in directories:
        Path(directory).mkdir(parents=True, exist_ok=True)
        print(f"✅ Created directory: {directory}")

def download_kaggle_dataset():
    """Download Indian Food Images dataset from Kaggle."""
    print("📁 Downloading Indian Food Images dataset from Kaggle...")
    
    # Instructions for manual download (requires Kaggle API setup)
    print("""
    To download the Indian Food Images dataset:
    
    1. Install Kaggle API: pip install kaggle
    2. Setup Kaggle credentials: https://github.com/Kaggle/kaggle-api#api-credentials
    3. Run: kaggle datasets download -d nehaprabhavalkar/indian-food-images
    4. Extract to: datasets/raw/indian_food_images/
    
    Popular Indian food datasets on Kaggle:
    - nehaprabhavalkar/indian-food-images
    - ravirajsinh45/indian-food-images-dataset
    - satyajitdas/indian-food-dataset
    """)

def download_food101_subset():
    """Download Food-101 dataset and extract Indian food categories."""
    print("🍛 Downloading Food-101 Indian food subset...")
    
    indian_food_categories = [
        'chicken_curry', 'samosa', 'naan', 'biryani', 'dal'
    ]
    
    print(f"Indian food categories in Food-101: {indian_food_categories}")
    print("""
    To get Food-101 dataset:
    1. Download from: https://data.vision.ee.ethz.ch/cvl/datasets_extra/food-101/
    2. Extract Indian food categories from the dataset
    3. Place in: datasets/raw/food101_indian/
    """)

def create_dataset_structure():
    """Create the dataset structure for Core ML training."""
    
    indian_food_classes = [
        'biryani', 'dosa', 'idli', 'samosa', 'butter_chicken', 'naan', 'roti',
        'dal', 'curry', 'paneer', 'tandoori_chicken', 'masala_dosa', 'pulao',
        'paratha', 'poha', 'upma', 'vada', 'uttapam', 'dhokla', 'kachori',
        'pav_bhaji', 'chole', 'rajma', 'aloo_gobi', 'palak_paneer'
    ]
    
    # Create class directories
    for split in ['train', 'validation', 'test']:
        for food_class in indian_food_classes:
            class_dir = Path(f'datasets/{split}/{food_class}')
            class_dir.mkdir(parents=True, exist_ok=True)
    
    print(f"✅ Created dataset structure for {len(indian_food_classes)} Indian food classes")
    
    # Create dataset info file
    dataset_info = {
        'classes': indian_food_classes,
        'num_classes': len(indian_food_classes),
        'splits': ['train', 'validation', 'test'],
        'description': 'Indian Food Recognition Dataset for Core ML',
        'created_for': 'IndianFoodCalorieApp'
    }
    
    with open('datasets/dataset_info.json', 'w') as f:
        json.dump(dataset_info, f, indent=2)
    
    print("✅ Created dataset_info.json")

def create_training_script():
    """Create a Python script for training the Core ML model."""
    
    training_script = '''#!/usr/bin/env python3
"""
Core ML Model Training Script for Indian Food Recognition

This script trains a Core ML model using CreateML to recognize Indian foods.
"""

import coremltools as ct
from coremltools.models.neural_network import quantization_utils
import os

def train_indian_food_model():
    """Train Core ML model for Indian food recognition."""
    
    print("🤖 Starting Indian Food Recognition model training...")
    
    # Note: This requires actual training implementation
    # For now, providing the structure and instructions
    
    print("""
    To train the model:
    
    1. Install required packages:
       pip install coremltools tensorflow createml-community
    
    2. Prepare your dataset in the datasets/ directory
    
    3. Use CreateML or TensorFlow to train the model:
       - Input: 224x224 RGB images
       - Output: Indian food class predictions
       - Architecture: MobileNetV3 or EfficientNet (optimized for mobile)
    
    4. Convert to Core ML format:
       - Save as 'IndianFoodClassifier.mlmodel'
       - Include in iOS app bundle
    
    5. Test the model with sample images
    """)

if __name__ == "__main__":
    train_indian_food_model()
'''
    
    with open('train_model.py', 'w') as f:
        f.write(training_script)
    
    print("✅ Created train_model.py")

def main():
    parser = argparse.ArgumentParser(description='Download and prepare Indian food datasets')
    parser.add_argument('--dataset', choices=['indian_food_kaggle', 'food101_indian_subset'], 
                       help='Dataset to download')
    parser.add_argument('--setup', action='store_true', help='Setup directory structure')
    
    args = parser.parse_args()
    
    print("🍛 Indian Food Dataset Preparation Tool")
    print("=" * 50)
    
    if args.setup or not args.dataset:
        setup_directories()
        create_dataset_structure()
        create_training_script()
    
    if args.dataset == 'indian_food_kaggle':
        download_kaggle_dataset()
    elif args.dataset == 'food101_indian_subset':
        download_food101_subset()
    
    print("\n🎯 Next Steps:")
    print("1. Download the actual datasets using the instructions above")
    print("2. Organize images into train/validation/test splits")
    print("3. Run train_model.py to train the Core ML model")
    print("4. Add the trained model to your iOS app bundle")
    print("5. Update MLFoodRecognitionService to load the custom model")

if __name__ == "__main__":
    main()