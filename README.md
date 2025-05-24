SkinSync -
Your AI-Powered Skincare Companion

📱 Overview
SkinSync revolutionizes skincare management by combining habit tracking with AI-powered analysis. Our mobile solution helps users:

- Build consistent skincare routines through gamified streaks 🏆
- Receive instant AI analysis of skin conditions 🤖
- Create a Custom Routine with a detailed name and description, and get notified at the time and date
- Share the skin analysis result with friends.👥

**✨ Key Features**
**Core Functionality - Feature	Description**
Custom Routine Creation- Create your daily skin care routine and get reminded by the app!
📸 AI Skin Analysis	- Instant analysis using dermatology-trained ML model
🔄 Daily Streaks - Snapchat-style streak tracking for routine consistency (In Development)
🌐 Social Sharing	- Share results via social media with custom-generated reports
🗃️ Analysis History	- Cloud-synced storage of all skin assessments (In Development)
📊 Progress Tracking - Visual charts showing skin health improvements over time (In Development)

**Advanced Capabilities**
- Smart Image Recognition
- Automatic skin region detection
- Quality validation for analysis-ready images
- EXIF data sanitization for privacy
- AI-Powered Insights
- Real-time risk assessment matrix

**🤖 AI Model Overview**
Current Implementation
Model Type: **Convolutional Neural Network (CNN)**

Training Dataset:** HAM10000 (10,000+ dermatoscopic images)**

**Classes Detected:**

1. Melanocytic nevi (Benign)
2. Melanoma (Malignant)
3. Benign keratosis
4. Basal cell carcinoma
5. Actinic keratoses

Technical Specs:
- Input: 224x224 RGB images
- Architecture: MobileNetV2 (Optimised for mobile)
- Accuracy: 85% on validation set
- Inference Time: <200ms (SD835)

**Future Roadmap**
Multi-Factor Analysis
1. Skin type detection (Dry/Oily/Combination)
2. Acne severity scoring
3. Pigmentation analysis
4. Wrinkle detection
5. Personalised Care
6. Product recommendations based on analysis
7. Routine optimisation engine (based on Skin Condition)
8. Preavailable Skin Care Routine template from the popular and most rated skin care routine (categorized by gender, age, and lifestyle)

🛠️ Technical Stack
Core Technologies
Category- Technologies
Framework	- Flutter 3.13
Backend	- Firebase (Auth, Firestore, Storage)
ML	- TensorFlow Lite, TF-Lite Flutter
State	- GetX
Analytics	- Firebase Analytics, Crashlytics

Key Dependencies
- tflite_flutter: ML model execution
- image_picker: Camera/Gallery integration
- share_plus: Social media sharing
- camera: Real-time skin analysis

Authentication: 
Phone: +91 72504 97748  
OTP: 123456  
Note: Dummy authentication for development purposes only

🤝 Contribution Guidelines
We welcome any suggestions to improve the app (functionality, UI, code bases, anything)! 

📄 License
This project is licensed under the MIT License - see LICENSE.md for details.

Disclaimer: **SkinSync provides informational content only, not medical advice. Always consult a dermatologist for a professional diagnosis.**
