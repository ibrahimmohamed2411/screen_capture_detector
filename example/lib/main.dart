import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:screen_capture_detector/screen_capture_detector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screenshot Detector Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScreenCaptureDetector _detector = ScreenCaptureDetector();
  StreamSubscription<String?>? _subscription;
  final _screenshots = <String>[];
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
  }

  void _startDetection() async {
    final isScreenshotDetectorStarted = await _detector.startListening();
    if (isScreenshotDetectorStarted) {
      _subscription = _detector.screenshotStream.listen((String? path) {
        setState(() {
          _screenshots.insert(0, path ?? 'Unknown path');
          _isListening = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Screenshot detected: ${path?.split('/').last}'),
            duration: const Duration(seconds: 2),
          ),
        );
      });

      setState(() {
        _isListening = true;
      });
    }
  }

  void _stopDetection() {
    _subscription?.cancel();
    _detector.stopListening();

    setState(() {
      _isListening = false;
    });
  }

  @override
  void dispose() {
    _stopDetection();
    _detector.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screenshot Detector'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _isListening ? null : _startDetection,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Detection'),
                ),
                ElevatedButton.icon(
                  onPressed: _isListening ? _stopDetection : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop Detection'),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: _isListening ? Colors.green[100] : Colors.red[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isListening ? Icons.circle : Icons.circle_outlined,
                  color: _isListening ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _isListening ? 'Detection Active' : 'Detection Inactive',
                  style: TextStyle(
                    color: _isListening ? Colors.green[900] : Colors.red[900],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Screenshots Detected: ${_screenshots.length}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: _screenshots.isEmpty
                ? const Center(
                    child: Text(
                      'No screenshots detected yet.\nTake a screenshot to test!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _screenshots.length,
                    itemBuilder: (context, index) {
                      final path = _screenshots[index];
                      return ListTile(
                        leading: const Icon(Icons.screenshot),
                        title: Text(path.split('/').last),
                        subtitle: Text(
                          path,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: path));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Path copied to clipboard'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
