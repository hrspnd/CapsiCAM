# Kita — Chili Pepper Leaf Disease Classifier

> Comparative Analysis of Machine Learning Algorithms for Chili Pepper Leaf Disease Classification

A mobile application for real-time chili pepper leaf disease classification using deep learning, built as part of an undergraduate thesis study.

---

## Overview

This system classifies chili pepper leaf diseases through two modes:
- **Live Camera** — real-time classification using the device camera
- **Image Upload** — classification from gallery or captured photo

The app compares two convolutional neural network architectures — **MobileNetV2** and **ResNet50** — evaluated on classification accuracy, inference speed, and computational efficiency for mobile deployment.

### Supported Classes
| Class | Description |
|---|---|
| Bacterial Leaf Spot | Caused by bacterial infection |
| Cercospora Leaf Spot | Caused by *Cercospora* fungal infection |
| Healthy | No disease detected |

### Supported Varieties
- Siling Labuyo (*Capsicum frutescens*)
- Siling Haba (*Capsicum annuum* var. *longum*)
- Bell Pepper (*Capsicum annuum*)

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter |
| Model Training | TensorFlow / Keras |
| On-device Inference | TensorFlow Lite (TFLite) |
| Points of Interest | EigenCAM |
| Local Storage | SQLite (sqflite) |
| Cloud Database | Supabase (PostgreSQL) |
| Authentication | Supabase Auth |
| Cloud Storage | Supabase Storage |

---

## Repository Structure

```
thesis-app/
├── app/                        # Flutter mobile application
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/
│   │   │   ├── auth/
│   │   │   │   ├── login_screen.dart
│   │   │   │   └── signup_screen.dart
│   │   │   ├── dashboard_screen.dart
│   │   │   ├── camera_screen.dart
│   │   │   ├── results_screen.dart
│   │   │   ├── history_screen.dart
│   │   │   └── account/
│   │   │       ├── account_screen.dart
│   │   │       └── my_account_screen.dart
│   │   ├── models/
│   │   │   ├── classifier.dart
│   │   │   └── scan_result.dart
│   │   └── services/
│   │       ├── supabase_service.dart
│   │       └── eigencam_service.dart
│   ├── assets/
│   │   ├── kita_mobilenet.tflite
│   │   └── labels.txt
│   └── pubspec.yaml
│
├── model/                      # Training scripts
│   ├── train_keras.py          # Main training script (MobileNetV2 / ResNet50)
│   ├── requirements.txt
│   └── results/
│       ├── confusion_matrix_mobilenet.png
│       ├── confusion_matrix_resnet.png
│       ├── training_curves_mobilenet.png
│       └── training_curves_resnet.png
│
└── README.md
```

---

## Getting Started

### Prerequisites
- Flutter SDK 3.x
- Python 3.10+
- Android Studio (for Android SDK)
- A physical Android or iOS device

### Model Training

1. Install Python dependencies:
```bash
cd model
pip install -r requirements.txt
```

2. Set your dataset path in `train_keras.py`:
```python
DATASET_DIR = r"path/to/your/datasets"
```

3. Train MobileNetV2:
```python
MODEL = "mobilenet"
```
```bash
python train_keras.py
```

4. Train ResNet50:
```python
MODEL = "resnet"
```
```bash
python train_keras.py
```

The script automatically converts the best model to TFLite after training.


## Dataset

| Class | Image Count |
|---|---|
| Bacterial Leaf Spot | 856 |
| Cercospora Leaf Spot | 226 |
| Healthy | 1,271 |
| **Total** | **2,353** |

> Note: Current dataset consists of Bell Pepper (*Capsicum annuum*) images sourced from publicly available plant disease datasets. Additional data for Siling Labuyo and Siling Haba is pending collection.

### Dataset Split
| Split | Percentage | Images |
|---|---|---|
| Train | 70% | ~1,647 |
| Validation | 15% | ~353 |
| Test | 15% | ~353 |

---

## Model Results (Preliminary — Bell Pepper only)

### MobileNetV2
| Metric | Value |
|---|---|
| Best Validation Accuracy | ~88% |
| Test Accuracy | ~87% |
| Avg. Inference Time (device) | ~150ms |

### ResNet50
| Metric | Value |
|---|---|
| Best Validation Accuracy | ~68% |
| Test Accuracy | ~66% |
| Avg. Inference Time (device) | TBD |

> Results are preliminary and based on Bell Pepper data only. Final results will be updated upon completion of the full dataset.

---

## Study Limitations

- Classification is limited to three labels: Bacterial Leaf Spot, Cercospora Leaf Spot, and Healthy
- The system focuses solely on leaf image analysis and does not consider stems, roots, or fruits
- Comparison is limited to MobileNetV2 and ResNet50 only
- The application is developed for Android and iOS smartphones only
- System performance may vary depending on image quality and environmental conditions

---

