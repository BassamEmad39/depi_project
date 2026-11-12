# LearnSpace — Firebase Cloud Messaging (Stage 1)

النسخة دي بتضيف استقبال إشعارات Firebase على Android في الخلفية، من غير تغيير الـ Authentication أو Firestore أو واجهات التطبيق.

## التشغيل

1. فك الضغط وافتح مجلد `depi_project` في VS Code أو Android Studio.
2. شغّل محاكي Android بنسخة Google Play (لازم Google Play Services).
3. افتح Terminal ونفّذ:

```bash
flutter pub get
flutter run
```

4. وافق على صلاحية الإشعارات لما يطلبها التطبيق (Android 13+).
5. في Debug Console دور على سطر `FCM device token:`. انسخ الـ Token واحتفظ به بشكل خاص لأنه خاص بتثبيت التطبيق على الجهاز.
6. خلّي التطبيق في الخلفية (اضغط Home في المحاكي، من غير Force stop).
7. افتح Firebase Console > Messaging > Create Campaign (أو New campaign) > Notifications، وأنشئ رسالة واختار Send test message واستخدم الـ Token.
8. المفروض الإشعار يظهر في إشعارات الجهاز. عند فتح التطبيق هتلاقي رسائل Debug عند الضغط على الإشعار.

### ملحوظات
- مرحلة 1: لو التطبيق مفتوح في المقدمة، هتشوف استقبال الإشعار في Debug Console فقط، مش Banner ظاهر. لإظهار Banner في المقدمة، بنحتاج إضافة local notifications في مرحلة لاحقة.
- لا ترسل FCM Token بشكل عام أو تشاركه في صور منشورة.
- لم نتمكن من تشغيل `flutter analyze` أو `flutter run` داخل بيئة التعديل هنا، فجرّب محليًا، وإذا ظهر Error شاركنا نصه.
- تم تثبيت `firebase_messaging` على السلسلة `^16.7.0` المناسبة لعائلة مكتبات FlutterFire الموجودة في مشروعك؛ `flutter pub get` هيتولى تحديث lockfile.
