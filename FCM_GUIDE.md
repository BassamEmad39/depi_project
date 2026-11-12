# LearnSpace — Firebase Notifications (Android)

## Implemented
- Firebase Messaging permission request (`requestPermission`).
- FCM registration token via `getToken`, and refreshed tokens via `onTokenRefresh`.
- Reads `message.notification.title` and `.body` in the foreground, with `data['title']`, `data['name']` and `data['body']` fallbacks.
- Displays a system notification when the app is open using `flutter_local_notifications`.
- Uses Android's automatic notification display when the app is in the background or terminated (for FCM notification payloads).
- Handles notification taps by logging their data; deep-link navigation has NOT been implemented.

## Firebase Console
Your existing Firebase Cloud Messaging API (V1) is **Enabled**. Nothing else has to be enabled for basic Android token-based tests.

1. Install the app on an **Android emulator with Google Play Services** (or an Android phone).
2. `flutter pub get` (downloads the dependencies and updates `pubspec.lock`), then `flutter run`.
3. Approve the notification permission prompt if it appears (Android 13+).
4. Look for `FCM TOKEN:` in Debug Console. Do not expose this token publicly.
5. Firebase Console > DevOps & Engagement > Messaging > Create campaign > Firebase Notification messages.
6. Fill notification Title and Text. Click **Send test message**, paste the **FCM registration token**, then Test.
7. Try once with the app in foreground and once with it in background.

**Expected behavior:** Foreground shows a local notification using the received Title/Body. Background/terminated displays an Android-managed notification for standard Firebase notification messages. The handler doesn't create a second local notification in the background, avoiding duplicate alerts.

**Note:** This project targets Android for the notification implementation. Other platforms need their own notification and permission setup before claiming support.

## Troubleshooting
- If the Android build asks for Android SDK 36, install Android API level 36 in Android Studio > SDK Manager.
- For a Dart/Gradle issue run `flutter clean`, `flutter pub get`, then `flutter run`, and inspect the error.
- Make sure Android emulator image includes Google Play Services, and notifications are allowed under Settings > Apps > LearnSpace > Notifications.
- If you see `FCM TOKEN: null`, verify Firebase configuration and Google Play Services on the emulator.
- Firebase Console message content has **Title** and **Text/Body** fields. `name` is NOT a standard FCM notification field; it is optional custom data and is only used as a fallback.
- Don't send push notifications from the Flutter client with an API/service-account key. Use Firebase Console for tests or a trusted backend/Cloud Functions for production.
