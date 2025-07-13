#!/usr/bin/env python3
"""
Core ML Model Training Script for Indian Food Recognition

This script trains a Core ML model using the downloaded Indian food dataset.
"""

import os
import json
import shutil
from pathlib import Path
import random
from collections import defaultdict

# Core ML and machine learning imports
try:
    import coremltools as ct
    import tensorflow as tf
    from tensorflow import keras
    from tensorflow.keras import layers, models
    from tensorflow.keras.preprocessing.image import ImageDataGenerator
    import numpy as np
    from PIL import Image
    print("✅ All ML libraries imported successfully")
except ImportError as e:
    print(f"❌ Missing required library: {e}")
    print("Please install: pip install coremltools tensorflow pillow")
    exit(1)

class IndianFoodModelTrainer:
    def __init__(self, dataset_path="datasets"):
        self.dataset_path = Path(dataset_path)
        self.raw_path = self.dataset_path / "raw"
        self.train_path = self.dataset_path / "train"
        self.val_path = self.dataset_path / "validation"
        self.test_path = self.dataset_path / "test"
        self.models_path = Path("models")
        
        # Training parameters
        self.img_size = (224, 224)
        self.batch_size = 32
        self.epochs = 20
        self.learning_rate = 0.001
        
        # Ensure directories exist
        self.models_path.mkdir(exist_ok=True)
        
    def analyze_dataset(self):
        """Analyze the raw dataset structure and statistics."""
        print("🔍 Analyzing dataset...")
        
        if not self.raw_path.exists():
            print(f"❌ Raw dataset path not found: {self.raw_path}")
            return
            
        categories = []
        category_counts = {}
        
        for category_dir in self.raw_path.iterdir():
            if category_dir.is_dir():
                category = category_dir.name
                image_files = list(category_dir.glob("*.jpg")) + list(category_dir.glob("*.png"))
                count = len(image_files)
                
                categories.append(category)
                category_counts[category] = count
                
        print(f"📊 Dataset Statistics:")
        print(f"   Total categories: {len(categories)}")
        print(f"   Total images: {sum(category_counts.values())}")
        print(f"   Average images per category: {sum(category_counts.values()) // len(categories)}")
        
        # Show categories with image counts
        print(f"\n📋 Categories found:")
        for category, count in sorted(category_counts.items()):
            print(f"   {category}: {count} images")
            
        return categories, category_counts
    
    def prepare_dataset_splits(self, train_ratio=0.7, val_ratio=0.2, test_ratio=0.1):
        """Split the raw dataset into train/validation/test sets."""
        print(f"\n📂 Preparing dataset splits (train: {train_ratio}, val: {val_ratio}, test: {test_ratio})...")
        
        categories, category_counts = self.analyze_dataset()
        
        # Clear existing split directories
        for split_dir in [self.train_path, self.val_path, self.test_path]:
            if split_dir.exists():
                shutil.rmtree(split_dir)
            split_dir.mkdir(parents=True)
            
        # Process each category
        for category in categories:
            category_raw_path = self.raw_path / category
            image_files = list(category_raw_path.glob("*.jpg")) + list(category_raw_path.glob("*.png"))
            
            # Skip categories with too few images
            if len(image_files) < 10:
                print(f"⚠️  Skipping {category}: only {len(image_files)} images")
                continue
                
            # Shuffle images
            random.shuffle(image_files)
            
            # Calculate split sizes
            total = len(image_files)
            train_size = int(total * train_ratio)
            val_size = int(total * val_ratio)
            
            # Split files
            train_files = image_files[:train_size]
            val_files = image_files[train_size:train_size + val_size]
            test_files = image_files[train_size + val_size:]
            
            # Create category directories in each split
            for split_name, files in [("train", train_files), ("validation", val_files), ("test", test_files)]:
                split_category_dir = getattr(self, f"{split_name}_path") / category
                split_category_dir.mkdir(exist_ok=True)
                
                # Copy files
                for file_path in files:
                    dst_path = split_category_dir / file_path.name
                    shutil.copy2(file_path, dst_path)
                    
            print(f"✅ {category}: {len(train_files)} train, {len(val_files)} val, {len(test_files)} test")
            
        print("✅ Dataset splits prepared successfully!")
        
    def create_data_generators(self):
        """Create data generators for training."""
        print("\n🔄 Creating data generators...")
        
        # Data augmentation for training
        train_datagen = ImageDataGenerator(
            rescale=1./255,
            rotation_range=20,
            width_shift_range=0.2,
            height_shift_range=0.2,
            shear_range=0.2,
            zoom_range=0.2,
            horizontal_flip=True,
            fill_mode='nearest'
        )
        
        # Only rescaling for validation
        val_datagen = ImageDataGenerator(rescale=1./255)
        
        # Create generators
        train_generator = train_datagen.flow_from_directory(
            self.train_path,
            target_size=self.img_size,
            batch_size=self.batch_size,
            class_mode='categorical'
        )
        
        val_generator = val_datagen.flow_from_directory(
            self.val_path,
            target_size=self.img_size,
            batch_size=self.batch_size,
            class_mode='categorical'
        )
        
        print(f"✅ Found {train_generator.samples} training images in {train_generator.num_classes} classes")
        print(f"✅ Found {val_generator.samples} validation images in {val_generator.num_classes} classes")
        
        # Save class indices for later use
        with open(self.models_path / "class_indices.json", "w") as f:
            json.dump(train_generator.class_indices, f, indent=2)
            
        return train_generator, val_generator
    
    def create_model(self, num_classes):
        """Create a MobileNetV2-based model for food classification."""
        print(f"\n🤖 Creating model for {num_classes} classes...")
        
        # Use MobileNetV2 as base model (pre-trained on ImageNet)
        base_model = keras.applications.MobileNetV2(
            weights='imagenet',
            include_top=False,
            input_shape=(*self.img_size, 3)
        )
        
        # Freeze base model initially
        base_model.trainable = False
        
        # Add custom classification head
        model = models.Sequential([
            base_model,
            layers.GlobalAveragePooling2D(),
            layers.Dropout(0.2),
            layers.Dense(128, activation='relu'),
            layers.Dropout(0.2),
            layers.Dense(num_classes, activation='softmax')
        ])
        
        # Compile model
        model.compile(
            optimizer=keras.optimizers.Adam(learning_rate=self.learning_rate),
            loss='categorical_crossentropy',
            metrics=['accuracy']
        )
        
        print("✅ Model created successfully!")
        print(f"   Total parameters: {model.count_params():,}")
        
        return model
    
    def train_model(self, model, train_generator, val_generator):
        """Train the model."""
        print(f"\n🚀 Starting training for {self.epochs} epochs...")
        
        # Callbacks
        callbacks = [
            keras.callbacks.EarlyStopping(
                monitor='val_accuracy',
                patience=5,
                restore_best_weights=True
            ),
            keras.callbacks.ReduceLROnPlateau(
                monitor='val_loss',
                factor=0.5,
                patience=3,
                min_lr=1e-7
            ),
            keras.callbacks.ModelCheckpoint(
                filepath=str(self.models_path / "best_model.h5"),
                monitor='val_accuracy',
                save_best_only=True,
                save_weights_only=False
            )
        ]
        
        # Train the model
        history = model.fit(
            train_generator,
            epochs=self.epochs,
            validation_data=val_generator,
            callbacks=callbacks,
            verbose=1
        )
        
        print("✅ Training completed!")
        return history
    
    def fine_tune_model(self, model, train_generator, val_generator):
        """Fine-tune the model by unfreezing some layers."""
        print("\n🔧 Fine-tuning model...")
        
        # Unfreeze the top layers of the base model
        base_model = model.layers[0]
        base_model.trainable = True
        
        # Fine-tune from this layer onwards
        fine_tune_at = 100
        
        # Freeze all the layers before fine_tune_at
        for layer in base_model.layers[:fine_tune_at]:
            layer.trainable = False
            
        # Use a lower learning rate for fine-tuning
        model.compile(
            optimizer=keras.optimizers.Adam(learning_rate=self.learning_rate/10),
            loss='categorical_crossentropy',
            metrics=['accuracy']
        )
        
        # Fine-tune for fewer epochs
        fine_tune_epochs = 10
        
        history_fine = model.fit(
            train_generator,
            epochs=fine_tune_epochs,
            validation_data=val_generator,
            verbose=1
        )
        
        print("✅ Fine-tuning completed!")
        return history_fine
    
    def convert_to_coreml(self, model, class_labels):
        """Convert the trained model to Core ML format."""
        print("\n🍎 Converting to Core ML format...")
        
        try:
            # Convert to Core ML
            coreml_model = ct.convert(
                model,
                inputs=[ct.ImageType(
                    name="input_image",
                    shape=(1, *self.img_size, 3),
                    bias=[-1, -1, -1],
                    scale=1/127.5
                )],
                classifier_config=ct.ClassifierConfig(class_labels)
            )
            
            # Set model metadata
            coreml_model.short_description = "Indian Food Classifier"
            coreml_model.author = "IndianFoodCalorieApp"
            coreml_model.license = "MIT"
            coreml_model.version = "1.0"
            
            # Set input/output descriptions
            coreml_model.input_description["input_image"] = "Input food image (224x224 RGB)"
            coreml_model.output_description["classLabel"] = "Predicted food category"
            coreml_model.output_description["classLabelProbs"] = "Probability for each food category"
            
            # Save the model
            model_path = self.models_path / "IndianFoodClassifier.mlmodel"
            coreml_model.save(str(model_path))
            
            print(f"✅ Core ML model saved: {model_path}")
            print(f"   Model size: {os.path.getsize(model_path) / (1024*1024):.1f} MB")
            
            return model_path
            
        except Exception as e:
            print(f"❌ Error converting to Core ML: {e}")
            return None
    
    def test_model(self, model_path):
        """Test the Core ML model with sample images."""
        print(f"\n🧪 Testing Core ML model...")
        
        if not model_path or not model_path.exists():
            print("❌ No model to test")
            return
            
        try:
            # Load the Core ML model
            import coremltools as ct
            model = ct.models.MLModel(str(model_path))
            
            # Test with a few random images from test set
            test_images = list(self.test_path.rglob("*.jpg"))[:5]
            
            for img_path in test_images:
                # Load and preprocess image
                img = Image.open(img_path).convert('RGB')
                img = img.resize(self.img_size)
                
                # Make prediction
                result = model.predict({"input_image": img})
                predicted_class = result["classLabel"]
                confidence = max(result["classLabelProbs"].values())
                actual_class = img_path.parent.name
                
                print(f"   {img_path.name}: {predicted_class} ({confidence:.2f}) [actual: {actual_class}]")
                
        except Exception as e:
            print(f"❌ Error testing model: {e}")
    
    def train_full_pipeline(self):
        """Run the complete training pipeline."""
        print("🍛 Indian Food Recognition Model Training")
        print("=" * 50)
        
        # Step 1: Analyze and prepare dataset
        if not self.train_path.exists() or len(list(self.train_path.iterdir())) == 0:
            self.prepare_dataset_splits()
        
        # Step 2: Create data generators
        train_gen, val_gen = self.create_data_generators()
        
        # Step 3: Create model
        model = self.create_model(train_gen.num_classes)
        
        # Step 4: Train model
        history = self.train_model(model, train_gen, val_gen)
        
        # Step 5: Fine-tune model
        self.fine_tune_model(model, train_gen, val_gen)
        
        # Step 6: Convert to Core ML
        class_labels = list(train_gen.class_indices.keys())
        model_path = self.convert_to_coreml(model, class_labels)
        
        # Step 7: Test the model
        if model_path:
            self.test_model(model_path)
            
        print("\n🎉 Training pipeline completed!")
        print(f"📱 Add {model_path} to your iOS app bundle to use the trained model")

def main():
    print("🤖 Indian Food Recognition Model Trainer")
    print("=" * 50)
    
    # Check if dataset exists
    if not Path("datasets/raw").exists():
        print("❌ Dataset not found at datasets/raw/")
        print("Please run: python3 download_datasets.py --setup")
        return
    
    # Initialize trainer
    trainer = IndianFoodModelTrainer()
    
    # Run training pipeline
    trainer.train_full_pipeline()

if __name__ == "__main__":
    main()