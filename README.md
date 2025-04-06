# YTMp3 - YouTube to MP3 Converter 🎵

*Convert your favorite YouTube videos to high-quality MP3 files with ease!*

YTMp3 is a sleek, user-friendly Flutter app that allows you to download audio from YouTube videos and convert them to MP3 format. With a modern dark-themed UI, customizable audio quality, and seamless integration with your device’s Downloads folder, YTMp3 makes it simple to enjoy your music offline.

## ✨ Features

- YouTube Audio Extraction: Download audio from any YouTube video by simply pasting the URL.

- MP3 Conversion: Convert audio to MP3 format using CloudConvert API with selectable quality (64K to 320K).

- Device Integration: Saves MP3 files directly to your /Internal Storage/Downloads folder and notifies the media scanner for instant access in music apps.

- Progress Tracking: Real-time download and conversion progress with a sleek progress bar.

- Permission Handling: Gracefully handles storage permissions with user-friendly prompts.

- Cross-Platform: Built with Flutter, supporting Android (iOS support **can** be added with minimal changes).

## 🚀 Getting Started

- Flutter SDK: Ensure you have Flutter installed (version 3.0.0 or higher recommended). [Install Flutter](https://docs.flutter.dev/get-started/install/windows)

- CloudConvert API Key: Sign up at [CloudConvert](https://cloudconvert.com/) to get your API key for audio conversion.

- Android Device/Emulator: For testing the app on Android.

### Installation

1. Install Dependencies:
 
    ```
    flutter pub get
    ```

2. Set Up the CloudConvert API Key:
    - Open `lib/main.dart`.
    - Replace the placeholder API key with your own:

    ```
    final String _apiKey = 'YOUR_CLOUDCONVERT_API_KEY_HERE';
    ```

3. Generate App Icon and Splash Screen:
    - Ensure your icon `(assets/icon.png)` and splash image `(assets/splash.png)` are in place.

    ```
    flutter pub run flutter_launcher_icons
    flutter pub runflutter_native_splash:create
    ```

4. Build and Run:
    - Connect your Android device or start an emulator.
    - Build the release APK:

    ```
    flutter build apk --release
    ```
    - Install the APK on your device `(located at build/app/outputs/flutter-apk/app-release.apk)`.

## 📖 Usage

1. Launch the App:

2. Grant Permissions:
    - The app will request storage permissions to save MP3 files. Grant the permission when prompted, or go to Settings > Apps > YTMp3 > Permissions to enable it.

3. Download a Song:
    - Copy the URL of a youtube video (eg. `https://www.youtube.com/watch?v=dQw4w9WgXcQ`)

    - Paste the URL into the "Enter YouTube URL" field.

    - Select your desired audio quality (64K to 320K) from the dropdown.
    - Tap the "Download" button.

4. Enjoy Your Music:

    - Once complete, the MP3 file will be saved to /Internal Storage/Downloads.

    - Open your music app (e.g., Samsung Music) to find and play the file.

## 📝 Notes

- **Android 13+**: The app uses MANAGE_EXTERNAL_STORAGE for Android 13+ devices. You may need to enable "All files access" in app settings.

- **CloudConvert API**: Ensure your API key has sufficient credits for conversions. Free accounts have limited usage.

- **YouTube Terms**: Be mindful of YouTube’s Terms of Service when downloading audio. This app is for educational purposes and personal use only.

## 🌟 Acknowledgments
- Flutter for the amazing framework.

- CloudConvert for the audio conversion API.

- youtube_explode_dart for YouTube audio extraction.

- The open-source community for their awesome packages and support.


