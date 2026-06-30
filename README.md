# 🌿 HerbalRx

>Herbal RX: Herbal Remedy Extraction and Recommendation Using Deep Learning and Image Processing

---

## 📖 Overview

HerbalRx is a cross-platform Flutter application that identifies medicinal plants from leaf images using a TensorFlow Lite deep learning model. After identifying the plant, the application provides medicinal uses, preparation methods, symptoms treated, safety warnings, and scientific information.

The application also allows users to search medicinal plants by plant name or by symptoms and maintains a personalized prediction history using Firebase.

---

## ✨ Features

- 📷 Camera & Gallery image support
- 🔊 Text-to-Speech for prediction and plant information
- 🔍 Search medicinal plants by name
- ❤️ Search plants by symptoms
- 📚 Detailed medicinal information
- ⚠ Safety warnings and precautions
- 📜 Preparation methods
- 📈 Prediction confidence score
- ☁ Firebase Authentication
- 🔥 Firestore prediction history
- 📱 Modern Flutter UI

---

## 🖼 Application Screens

### Login & Signup

| Login                      | Signup                       |
|----------------------------|------------------------------|
| ![](screenshots/login.jpg) | ![](screenshots/sign_up.jpg) |

---

### Search Plants

| By Plant | History                      |
|----------|------------------------------|
| ![](screenshots/by_plant.jpg) | ![](screenshots/history.jpg) |

---

### AI Plant Identification

| Before Prediction | Prediction |
|------------------|------------|
| ![](screenshots/identify.jpg) | ![](screenshots/prediction.jpg) |

---

### Plant Details

| Information                    | Preparation & Safety           |
|--------------------------------|--------------------------------|
| ![](screenshots/details_1.jpg) | ![](screenshots/details_2.jpg) |

---

[//]: # (### Prediction History)

[//]: # ()
[//]: # (![]&#40;screenshots/history.jpg&#41;)

---

### Search Plants by Symptoms

| By symptoms_1                     | By Symptom_2                      |
|-----------------------------------|-----------------------------------|
| ![](screenshots/by_symptom_1.jpg) | ![](screenshots/by_symptom_2.jpg) |

## 🏗 System Architecture

![](screenshots/sys_architecture.png)

---

## 🤖 Machine Learning

- Model: TensorFlow Lite
- Image Size: 224×224
- Dataset: Medicinal Plant Leaf Dataset
- Classes: 80 Plant Species
- Framework: TensorFlow
- Mobile Inference: TensorFlow Lite

---

## 🛠 Technology Stack

| Technology | Purpose |
|------------|---------|
| Flutter | Mobile App |
| Dart | Programming Language |
| TensorFlow Lite | Plant Identification |
| Firebase Authentication | User Login |
| Cloud Firestore | Plant & History Storage |
| Firebase Storage | Image Storage |
| JSON Dataset | Offline Plant Information |

---

## 📂 Project Structure

```
lib/
│
├── screens/
├── widgets/
├── services/
├── models/
├── utils/
│
assets/
│
├── plants.json
├── images/
├── ml_model/
```

---

## 🚀 Installation

Clone the repository

```bash
git clone https://github.com/Harishit-123/HerbalRx.git
```

Move into project

```bash
cd HerbalRx
```

Install dependencies

```bash
flutter pub get
```

Run the application

```bash
flutter run
```

---

## 📊 Dataset

- 80 Medicinal Plant Classes
- Leaf Image Dataset
- Offline medicinal information stored in JSON
- TensorFlow Lite model for mobile inference

---

## 🔮 Future Enhancements

- integration of Explainable AI features such as Grad-CAM or visual heatmaps.
- expanding the model to recognize various plant parts such as flowers, stems, bark, and fruits
- live camera-based detection with bounding boxes

---

## 👨‍💻 Developer

**Harishit**

GitHub:
https://github.com/Harishit-123

---

## 📄 License

This project is developed for educational and research purposes.