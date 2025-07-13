# Indian Food Recognition ML Model Training

This directory contains tools and scripts for training a Core ML model to recognize Indian foods.

## Quick Start

```bash
# 1. Setup the dataset structure
python3 download_datasets.py --setup

# 2. Download Indian food datasets (follow the instructions)
python3 download_datasets.py --dataset indian_food_kaggle

# 3. Train the model (after preparing dataset)
python3 train_model.py
```

## Dataset Sources

### 1. Kaggle Indian Food Datasets
- **nehaprabhavalkar/indian-food-images** - Comprehensive Indian food images
- **ravirajsinh45/indian-food-images-dataset** - Categorized Indian foods
- **satyajitdas/indian-food-dataset** - Nutrition data + images

### 2. Food-101 Dataset
- Contains 5 Indian food categories: chicken_curry, samosa, naan, biryani, dal
- Download from: https://data.vision.ee.ethz.ch/cvl/datasets_extra/food-101/

## Supported Indian Food Classes (25)

- **Rice Dishes**: biryani, pulao
- **Bread**: naan, roti, paratha
- **South Indian**: dosa, idli, masala_dosa, uttapam, vada
- **Snacks**: samosa, dhokla, kachori
- **Curries**: butter_chicken, dal, curry, paneer, tandoori_chicken
- **Regional**: pav_bhaji, chole, rajma, aloo_gobi, palak_paneer
- **Breakfast**: poha, upma

## Directory Structure

```
MLModelTraining/
├── download_datasets.py      # Dataset preparation script
├── train_model.py            # Model training script
├── README.md                 # This file
└── datasets/                 # Created by script
    ├── raw/                  # Downloaded datasets
    ├── processed/            # Preprocessed images
    ├── train/               # Training split (70%)
    ├── validation/          # Validation split (20%)
    ├── test/                # Test split (10%)
    └── dataset_info.json    # Dataset metadata
```

## Training Requirements

### Software Dependencies
```bash
pip install coremltools
pip install tensorflow
pip install kaggle
pip install pillow
pip install numpy
```

### Hardware Recommendations
- **macOS** with Apple Silicon (M1/M2) for optimal Core ML performance
- **16GB+ RAM** for training with large datasets
- **SSD storage** for fast data loading

## Model Specifications

### Input
- **Format**: RGB images
- **Size**: 224x224 pixels
- **Preprocessing**: Normalization, augmentation

### Output
- **Classes**: 25 Indian food categories
- **Format**: Probability distribution
- **Confidence**: 0.0 to 1.0

### Architecture Options
1. **MobileNetV3** - Optimized for mobile devices
2. **EfficientNet-B0** - Good accuracy/size balance
3. **ResNet50** - Higher accuracy, larger model

## Training Process

1. **Data Collection**: Gather 1000+ images per food class
2. **Data Preprocessing**: Resize, normalize, augment images
3. **Model Training**: Use transfer learning from ImageNet
4. **Validation**: Test on held-out validation set
5. **Core ML Conversion**: Convert trained model to .mlmodel format
6. **iOS Integration**: Add model to app bundle

## Expected Performance

### Target Metrics
- **Top-1 Accuracy**: >80% on Indian foods
- **Top-3 Accuracy**: >95% on Indian foods
- **Model Size**: <50MB for mobile deployment
- **Inference Time**: <100ms on iPhone

### Real-world Considerations
- **Lighting conditions**: Train with varied lighting
- **Camera angles**: Include multiple perspectives
- **Food variations**: Account for regional differences
- **Mixed dishes**: Handle complex food combinations

## Integration with iOS App

After training, the model integrates automatically:

1. **Model File**: Save as `IndianFoodClassifier.mlmodel`
2. **App Bundle**: Add to iOS project resources
3. **Loading**: `MLFoodRecognitionService` detects and loads the model
4. **Fallback**: Intelligent fallback when model unavailable

## Testing the Model

```bash
# Test with sample images
python3 test_model.py --model models/IndianFoodClassifier.mlmodel --image test_images/biryani.jpg

# Batch testing
python3 test_model.py --model models/IndianFoodClassifier.mlmodel --batch datasets/test/
```

## Continuous Improvement

### Data Collection
- **User feedback**: Collect correction data from app usage
- **Active learning**: Identify uncertain predictions for manual review
- **Dataset expansion**: Add new food categories based on user requests

### Model Updates
- **Periodic retraining**: Update model with new data quarterly
- **A/B testing**: Test model versions against current production
- **Performance monitoring**: Track accuracy metrics in production

## Troubleshooting

### Common Issues

1. **Low accuracy**: Need more diverse training data
2. **Large model size**: Use quantization or smaller architecture
3. **Slow inference**: Optimize model with Core ML tools
4. **Memory issues**: Reduce batch size or image resolution

### Debug Tips
- Check dataset balance (equal images per class)
- Validate data quality (correct labels, clear images)
- Monitor training curves (loss, accuracy over epochs)
- Test on diverse real-world images

## Resources

- [Core ML Documentation](https://developer.apple.com/documentation/coreml)
- [CreateML Tutorial](https://developer.apple.com/documentation/createml)
- [Food Recognition Papers](https://paperswithcode.com/task/food-recognition)
- [Indian Food Dataset Research](https://www.kaggle.com/datasets?search=indian+food)