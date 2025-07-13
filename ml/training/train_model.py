#!/usr/bin/env python3
"""
Training script for Indian Food Recognition Model
"""

import os
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers
import json
from pathlib import Path
import cv2
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
import matplotlib.pyplot as plt

class IndianFoodTrainer:
    def __init__(self, data_dir, model_output_dir):
        self.data_dir = Path(data_dir)
        self.model_output_dir = Path(model_output_dir)
        self.image_size = (224, 224)
        self.batch_size = 32
        self.epochs = 50
        self.num_classes = None
        self.class_names = []
        
    def load_data(self):
        """Load and preprocess the image data"""
        print("📁 Loading data...")
        
        images = []
        labels = []
        
        # Assuming data is organized as: data_dir/class_name/image.jpg
        for class_dir in self.data_dir.iterdir():
            if class_dir.is_dir():
                class_name = class_dir.name
                self.class_names.append(class_name)
                
                for img_path in class_dir.glob("*.jpg"):
                    try:
                        # Load and preprocess image
                        img = cv2.imread(str(img_path))
                        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
                        img = cv2.resize(img, self.image_size)
                        img = img.astype(np.float32) / 255.0
                        
                        images.append(img)
                        labels.append(class_name)
                        
                    except Exception as e:
                        print(f"Error loading {img_path}: {e}")
        
        print(f"✅ Loaded {len(images)} images from {len(self.class_names)} classes")
        
        # Convert to numpy arrays
        X = np.array(images)
        y = np.array(labels)
        
        # Encode labels
        self.label_encoder = LabelEncoder()
        y_encoded = self.label_encoder.fit_transform(y)
        self.num_classes = len(self.class_names)
        
        # One-hot encode
        y_onehot = keras.utils.to_categorical(y_encoded, self.num_classes)
        
        return X, y_onehot
    
    def create_model(self):
        """Create the CNN model architecture"""
        print("🏗️  Creating model architecture...")
        
        # Use MobileNetV3 as base model for efficiency
        base_model = keras.applications.MobileNetV3Large(
            input_shape=(*self.image_size, 3),
            include_top=False,
            weights='imagenet'
        )
        
        # Freeze base model initially
        base_model.trainable = False
        
        # Add custom classification head
        model = keras.Sequential([
            base_model,
            layers.GlobalAveragePooling2D(),
            layers.Dropout(0.2),
            layers.Dense(128, activation='relu'),
            layers.BatchNormalization(),
            layers.Dropout(0.5),
            layers.Dense(self.num_classes, activation='softmax')
        ])
        
        return model
    
    def compile_model(self, model):
        """Compile the model with optimizer and loss function"""
        model.compile(
            optimizer=keras.optimizers.Adam(learning_rate=0.001),
            loss='categorical_crossentropy',
            metrics=['accuracy', 'top_3_accuracy']
        )
        return model
    
    def create_callbacks(self):
        """Create training callbacks"""
        callbacks = [
            keras.callbacks.EarlyStopping(
                patience=10,
                restore_best_weights=True,
                monitor='val_accuracy'
            ),
            keras.callbacks.ReduceLROnPlateau(
                factor=0.5,
                patience=5,
                min_lr=1e-7,
                monitor='val_loss'
            ),
            keras.callbacks.ModelCheckpoint(
                filepath=self.model_output_dir / 'best_model.h5',
                save_best_only=True,
                monitor='val_accuracy'
            )
        ]
        return callbacks
    
    def train_model(self, model, X_train, y_train, X_val, y_val):
        """Train the model"""
        print("🚀 Starting training...")
        
        # Data augmentation
        datagen = keras.preprocessing.image.ImageDataGenerator(
            rotation_range=20,
            width_shift_range=0.2,
            height_shift_range=0.2,
            horizontal_flip=True,
            zoom_range=0.2,
            shear_range=0.2,
            fill_mode='nearest'
        )
        
        # Create generators
        train_generator = datagen.flow(
            X_train, y_train,
            batch_size=self.batch_size,
            shuffle=True
        )
        
        # Train model
        history = model.fit(
            train_generator,
            epochs=self.epochs,
            validation_data=(X_val, y_val),
            callbacks=self.create_callbacks(),
            verbose=1
        )
        
        return history
    
    def fine_tune_model(self, model, X_train, y_train, X_val, y_val):
        """Fine-tune the model with unfrozen base layers"""
        print("🔧 Fine-tuning model...")
        
        # Unfreeze base model
        base_model = model.layers[0]
        base_model.trainable = True
        
        # Use lower learning rate for fine-tuning
        model.compile(
            optimizer=keras.optimizers.Adam(learning_rate=0.0001),
            loss='categorical_crossentropy',
            metrics=['accuracy', 'top_3_accuracy']
        )
        
        # Continue training
        history_fine = model.fit(
            X_train, y_train,
            batch_size=self.batch_size,
            epochs=20,
            validation_data=(X_val, y_val),
            callbacks=self.create_callbacks(),
            verbose=1
        )
        
        return history_fine
    
    def evaluate_model(self, model, X_test, y_test):
        """Evaluate the trained model"""
        print("📊 Evaluating model...")
        
        # Get predictions
        predictions = model.predict(X_test)
        predicted_classes = np.argmax(predictions, axis=1)
        true_classes = np.argmax(y_test, axis=1)
        
        # Calculate metrics
        accuracy = np.mean(predicted_classes == true_classes)
        
        # Top-3 accuracy
        top3_predictions = np.argsort(predictions, axis=1)[:, -3:]
        top3_accuracy = np.mean([true_class in top3_pred for true_class, top3_pred 
                                in zip(true_classes, top3_predictions)])
        
        print(f"✅ Test Accuracy: {accuracy:.4f}")
        print(f"✅ Top-3 Accuracy: {top3_accuracy:.4f}")
        
        return {
            'accuracy': accuracy,
            'top3_accuracy': top3_accuracy,
            'predictions': predictions,
            'predicted_classes': predicted_classes,
            'true_classes': true_classes
        }
    
    def save_model_for_coreml(self, model):
        """Save model in format suitable for Core ML conversion"""
        print("💾 Saving model for Core ML...")
        
        # Save in TensorFlow format
        model.save(self.model_output_dir / 'indian_food_model.h5')
        
        # Save model metadata
        metadata = {
            'model_name': 'IndianFoodClassifier',
            'version': '1.0.0',
            'classes': self.class_names,
            'num_classes': self.num_classes,
            'input_shape': [224, 224, 3],
            'preprocessing': {
                'resize': [224, 224],
                'normalize': [0, 1],
                'mean': [0.485, 0.456, 0.406],
                'std': [0.229, 0.224, 0.225]
            }
        }
        
        with open(self.model_output_dir / 'model_metadata.json', 'w') as f:
            json.dump(metadata, f, indent=2)
        
        print("✅ Model and metadata saved")
    
    def plot_training_history(self, history, fine_tune_history=None):
        """Plot training history"""
        plt.figure(figsize=(12, 4))
        
        # Plot accuracy
        plt.subplot(1, 2, 1)
        plt.plot(history.history['accuracy'], label='Training Accuracy')
        plt.plot(history.history['val_accuracy'], label='Validation Accuracy')
        
        if fine_tune_history:
            epochs_offset = len(history.history['accuracy'])
            plt.plot(range(epochs_offset, epochs_offset + len(fine_tune_history.history['accuracy'])),
                    fine_tune_history.history['accuracy'], label='Fine-tune Training')
            plt.plot(range(epochs_offset, epochs_offset + len(fine_tune_history.history['val_accuracy'])),
                    fine_tune_history.history['val_accuracy'], label='Fine-tune Validation')
        
        plt.title('Model Accuracy')
        plt.xlabel('Epoch')
        plt.ylabel('Accuracy')
        plt.legend()
        
        # Plot loss
        plt.subplot(1, 2, 2)
        plt.plot(history.history['loss'], label='Training Loss')
        plt.plot(history.history['val_loss'], label='Validation Loss')
        
        if fine_tune_history:
            epochs_offset = len(history.history['loss'])
            plt.plot(range(epochs_offset, epochs_offset + len(fine_tune_history.history['loss'])),
                    fine_tune_history.history['loss'], label='Fine-tune Training Loss')
            plt.plot(range(epochs_offset, epochs_offset + len(fine_tune_history.history['val_loss'])),
                    fine_tune_history.history['val_loss'], label='Fine-tune Validation Loss')
        
        plt.title('Model Loss')
        plt.xlabel('Epoch')
        plt.ylabel('Loss')
        plt.legend()
        
        plt.tight_layout()
        plt.savefig(self.model_output_dir / 'training_history.png')
        plt.show()
    
    def train_complete_pipeline(self):
        """Run the complete training pipeline"""
        print("🚀 Starting Indian Food Recognition Model Training")
        print("=" * 60)
        
        # Create output directory
        self.model_output_dir.mkdir(parents=True, exist_ok=True)
        
        # Load data
        X, y = self.load_data()
        
        # Split data
        X_train, X_temp, y_train, y_temp = train_test_split(
            X, y, test_size=0.3, random_state=42, stratify=y
        )
        X_val, X_test, y_val, y_test = train_test_split(
            X_temp, y_temp, test_size=0.5, random_state=42, stratify=y_temp
        )
        
        print(f"📊 Train: {len(X_train)}, Val: {len(X_val)}, Test: {len(X_test)}")
        
        # Create and compile model
        model = self.create_model()
        model = self.compile_model(model)
        
        print(f"🏗️  Model created with {model.count_params():,} parameters")
        
        # Initial training
        history = self.train_model(model, X_train, y_train, X_val, y_val)
        
        # Fine-tuning
        fine_tune_history = self.fine_tune_model(model, X_train, y_train, X_val, y_val)
        
        # Evaluate model
        results = self.evaluate_model(model, X_test, y_test)
        
        # Save model
        self.save_model_for_coreml(model)
        
        # Plot results
        self.plot_training_history(history, fine_tune_history)
        
        print("\n" + "=" * 60)
        print("✅ Training completed successfully!")
        print(f"📊 Final Test Accuracy: {results['accuracy']:.4f}")
        print(f"📊 Final Top-3 Accuracy: {results['top3_accuracy']:.4f}")
        print(f"💾 Model saved to: {self.model_output_dir}")

def main():
    """Main training function"""
    # Configuration
    data_dir = "../data/raw/images"  # Adjust path as needed
    model_output_dir = "../models"
    
    # Create trainer and run pipeline
    trainer = IndianFoodTrainer(data_dir, model_output_dir)
    trainer.train_complete_pipeline()

if __name__ == "__main__":
    main()