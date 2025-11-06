# 🖼️ Screen Capture Detector

A Flutter plugin for **detecting screenshots** on Android and iOS devices.  
Get notified instantly when users take screenshots of your app’s content.

---

## ✨ Features

- 🔍 **Real-time screenshot detection**
- 📱 **Cross-platform support** (Android & iOS)
- 🎯 **Screenshot file path retrieval** *(Android only)*
- ⚡ **Simple stream-based API**
- 🔐 **Automatic permission handling**

---

## 🧩 Usage

import 'package:screen_capture_detector/screen_capture_detector.dart';

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ScreenCaptureDetector _detector = ScreenCaptureDetector();
  StreamSubscription<String?>? _subscription;

  @override
  void initState() {
    super.initState();
    _initializeDetector();
  }

  Future<void> _initializeDetector() async {
    // Start listening for screenshots
    final started = await _detector.startListening();
    
    if (started) {
      // Subscribe to screenshot events
      _subscription = _detector.screenshotStream.listen((path) {
        print('Screenshot detected!');
        if (path != null) {
          print('Screenshot saved at: $path');
        }
        
        // Show a message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Screenshot detected!')),
        );
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _detector.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Screenshot Detection')),
        body: Center(child: Text('Take a screenshot to test')),
      ),
    );
  }
}

🧠 Note:
On iOS, the plugin detects when a screenshot is taken but cannot provide the file path due to platform limitations.


🛠️ Manual Permission Request (Optional)

final detector = ScreenCaptureDetector();

// Request permissions manually
final hasPermission = await detector.requestPermissions();

if (hasPermission) {
  await detector.startListening();
} else {
  print('Permissions denied');
}

✅ On Android 13+, the plugin requests Permission.photos
✅ On older Android versions, it requests Permission.storage
✅ On iOS, no permission is required



# 🤝 Contributing 
Contributions are welcome! Please feel free to submit a Pull Request.



# 📄 License 
This project is licensed under the MIT License - see the LICENSE file for details.



