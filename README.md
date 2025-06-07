# SkinSync

Your AI-Powered Skincare Companion

---

## Overview

SkinSync revolutionizes skincare management by combining habit tracking with AI-powered analysis.

Our mobile solution helps users:

- Build consistent skincare routines through gamified streaks 🏆  
- Receive instant AI analysis of skin conditions  
- Create a custom routine with detailed name and description, with notifications  
- Share skin analysis results with friends  

---

## Key Features

### Core Functionality

- **Custom Routine Creation**  
  Create your daily skincare routine and get timely reminders.  
- **AI Skin Analysis**  
  Instant skin analysis using a dermatology-trained ML model.  
- **Daily Streaks** *(In Development)*  
  Snapchat-style streak tracking to encourage routine consistency.  
- **Social Sharing**  
  Share results on social media via custom-generated reports.  
- **Analysis History** *(In Development)*  
  Cloud-synced storage of all skin assessments.  
- **Progress Tracking** *(In Development)*  
  Visual charts showing skin health improvements over time.  

### Advanced Capabilities

- Smart image recognition with automatic skin region detection  
- Quality validation for analysis-ready images  
- EXIF data sanitization for privacy  
- AI-powered insights including real-time risk assessment matrix  

---

## AI Model Overview

- **Model Type:** Convolutional Neural Network (CNN)  
- **Training Dataset:** HAM10000 (10,000+ dermatoscopic images)  

### Classes Detected

- Melanocytic nevi (Benign)  
- Melanoma (Malignant)  
- Benign keratosis  
- Basal cell carcinoma  
- Actinic keratoses  

### Technical Specs

- Input: 224x224 RGB images  
- Architecture: MobileNetV2 (optimized for mobile)  
- Accuracy: 85% on validation set  
- Inference Time: <200ms on Snapdragon 835  

---

## Future Roadmap

- Multi-factor analysis:  
  - Skin type detection (Dry/Oily/Combination)  
  - Acne severity scoring  
  - Pigmentation analysis  
  - Wrinkle detection  
- Personalized care:  
  - Product recommendations based on analysis  
  - Routine optimization engine based on skin condition  
  - Pre-available skincare routine templates categorized by gender, age, lifestyle  

---

## Technical Stack

| Category       | Technology                  |
| -------------- | ---------------------------|
| Framework      | Flutter 3.13               |
| Backend        | Firebase (Auth, Firestore, Storage) |
| Machine Learning | TensorFlow Lite, TF-Lite Flutter |
| State Management | GetX                      |
| Analytics      | Firebase Analytics, Crashlytics |

### Key Dependencies

- `tflite_flutter`: ML model execution  
- `image_picker`: Camera/Gallery integration  
- `share_plus`: Social media sharing  
- `camera`: Real-time skin analysis  

---

## Authentication (Development Only)

- Phone: +91 72504 97748  
- OTP: 123456  

*Note: Dummy authentication for development purposes only.*

---

## Contribution Guidelines

We welcome any suggestions to improve the app — whether functionality, UI, codebase, or anything else!

---

## License

This project is licensed under the MIT License. See [LICENSE.md](LICENSE.md) for details.

---

## Disclaimer

SkinSync provides informational content only, not medical advice. Always consult a dermatologist for professional diagnosis.
