# CapsiCAM

**Chili Pepper Leaf Disease Classification Mobile Application**

CapsiCAM is an Android application developed as part of an undergraduate thesis on chili pepper leaf disease classification. It uses a deep learning model deployed with TensorFlow Lite to classify leaf images and display visual explanations of predictions.

## Features

- Classify chili pepper leaf images captured with the camera or selected from the gallery.
- Identify one of three classes: **Bacterial Leaf Spot**, **Cercospora Leaf Spot**, or **Healthy**.
- View class predictions and visual heatmaps highlighting image regions associated with the model's prediction.
- Sign in to an account and access saved scan history using Supabase.
- Run model inference on the Android device. An internet connection is needed for cloud-backed account and scan-history features.

## Technologies

| Component | Technology |
|---|---|
| Mobile application | Flutter / Dart |
| On-device inference | TensorFlow Lite |
| Model research | MobileNetV2 and ResNet50 |
| Authentication | Supabase Auth |
| Scan data and cloud storage | Supabase (PostgreSQL and Storage) |
| APK distribution | Docker Hub |

The research compares MobileNetV2 and ResNet50. The Android application uses a mobile-deployed TensorFlow Lite model; the comparison does not mean that both architectures are selectable within the app.

## Download and install CapsiCAM

There are two ways to obtain the Android APK: download it directly from Google Drive or extract it from the published Docker Hub image. Both methods install the application on an **Android device**, not inside Docker.

### Option 1: Direct APK download (Google Drive)

**[CapsiCAM APK — Google Drive folder](https://drive.google.com/drive/folders/1V03XhuP_IPTtJatqeIDOZxXKFEIWid-z?usp=sharing)**

1. Open the Google Drive folder and download the CapsiCAM APK to your Android phone (or download it on a computer and transfer it to the phone).
2. Open the APK using the phone's file manager.
3. If prompted, allow installation from the app or source used to open the APK.
4. Install and launch CapsiCAM, then sign in.

### Option 2: Download via Docker Hub

**Published image:** [`capsicam/capsicam-apk:latest`](https://hub.docker.com/r/capsicam/capsicam-apk)

The Docker image **contains the Android APK for distribution**. Docker does **not** run CapsiCAM on a phone. Extract the APK from the image and install it on an Android device.

**Requirements:** Docker Desktop or Docker Engine on the computer used to extract the APK; an Android phone; optionally Android SDK Platform Tools (ADB) for USB installation.

**1. Pull the image:**

```bash
docker pull capsicam/capsicam-apk:latest
```

**2. Extract the APK** into the current directory:

```bash
docker create --name capsicam-download capsicam/capsicam-apk:latest
docker cp capsicam-download:/app/CapsiCAM.apk ./CapsiCAM.apk
docker rm capsicam-download
```

**3. Install on Android:** Transfer `CapsiCAM.apk` to your phone, open it with the file manager, and approve installation if prompted. Alternatively, connect the phone with USB debugging enabled and run:

```bash
adb install -r CapsiCAM.apk
```

If replacing an existing installation fails because of a signing mismatch, uninstalling the old app may remove locally stored data. Back up anything important before uninstalling.

### Demo account (for evaluators)

- **Email:** `janedoe@gmail.com`
- **Password:** `password123`

## Build the Android APK from source

For developers who want to build the Flutter application instead of downloading the published APK:

1. Clone the repository:

   ```bash
   git clone https://github.com/hrspnd/CapsiCAM.git
   cd CapsiCAM
   ```

2. Install the Flutter SDK and Android development tools, then check your environment:

   ```bash
   flutter doctor
   flutter pub get
   ```

3. Configure any required project-specific Supabase settings using the configuration mechanism in the source code. Use only public client credentials in the Android app; keep privileged keys private.

4. Build the release APK:

   ```bash
   flutter build apk --release
   ```

   Output: `build/app/outputs/flutter-apk/app-release.apk`

A local build may require the project's Android signing configuration. For the tested installer, use the published Docker Hub image.

## Rebuild the Docker distribution image

The repository includes `apk-distribution/Dockerfile`. The APK itself is not tracked in Git; build it from source first.

From the repository root:

```bash
cp build/app/outputs/flutter-apk/app-release.apk apk-distribution/CapsiCAM.apk
docker build -t capsicam-apk:latest ./apk-distribution
```

On Windows Command Prompt, use `copy` instead of `cp`:

```cmd
copy "build\app\outputs\flutter-apk\app-release.apk" "apk-distribution\CapsiCAM.apk"
```

The Dockerfile copies the APK to `/app/CapsiCAM.apk` inside the image. The published image is maintained at [`capsicam/capsicam-apk`](https://hub.docker.com/r/capsicam/capsicam-apk).

## Scope and limitations

- The classifier supports **Bacterial Leaf Spot**, **Cercospora Leaf Spot**, and **Healthy** leaf images only.
- Predictions are based on images of leaves, not stems, roots, or fruits.
- Accuracy can vary with lighting, image clarity, background, and conditions outside the training data.
- The distributed APK is intended for Android; it is not an iOS installer.
- Classification is an assistive tool and should not be treated as a definitive plant disease diagnosis.

## Source code and distribution

- **GitHub:** https://github.com/hrspnd/CapsiCAM
- **Docker Hub:** https://hub.docker.com/r/capsicam/capsicam-apk
- **Google Drive APK:** https://drive.google.com/drive/folders/1V03XhuP_IPTtJatqeIDOZxXKFEIWid-z?usp=sharing

*Developed for an undergraduate thesis project.*
