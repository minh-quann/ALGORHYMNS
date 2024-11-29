import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class ReCord extends StatefulWidget {
  const ReCord({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ReCordState createState() => _ReCordState();
}

class _ReCordState extends State<ReCord> with SingleTickerProviderStateMixin {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  late Timer _timer;
  int _elapsedTime = 0;
  String? _filePath;
  late AnimationController _animationController;
  late Animation<double> _rippleAnimation;
  late Animation<Alignment> _gradientAnimation;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _rippleAnimation = Tween(begin: 0.0, end: 1.5).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Animation cho gradient chuyển động
    _gradientAnimation = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();
    if (await Permission.microphone.request().isGranted) {
      debugPrint("Microphone permission granted");
    } else {
      debugPrint("Microphone permission denied");
    }
  }

  Future<String> _getRecordingFilePath() async {
    Directory? directory = await getExternalStorageDirectory();
    String thuamDir = '${directory!.path}/record';
    Directory thuamDirectory = Directory(thuamDir);
    if (!thuamDirectory.existsSync()) {
      thuamDirectory.createSync(recursive: true);
    }
    return '$thuamDir/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
  }

  Future<void> _startRecording() async {
    _filePath = await _getRecordingFilePath();
    await _recorder.startRecorder(
      toFile: _filePath,
      codec: Codec.pcm16WAV,
    );

    setState(() {
      _isRecording = true;
      _elapsedTime = 0;
    });

    _animationController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime++;
      });
    });
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();

    setState(() {
      _isRecording = false;
    });

    _animationController.stop();
    _timer.cancel();

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "File thu âm của bạn đã được lưu thành công: $_elapsedTime giây"),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.grey[800],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    setState(() {
      _elapsedTime = 0;
    });

    debugPrint("File ghi âm lưu tại: $_filePath");
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _animationController.dispose();
    if (_timer.isActive) _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _gradientAnimation,
            builder: (context, child) {
              return AnimatedContainer(
                duration: const Duration(seconds: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isRecording
                        ? [Colors.purple, Colors.pink, Colors.red]
                        : [Colors.blueGrey, Colors.black],
                    begin: _gradientAnimation.value,
                    end: Alignment.bottomRight,
                  ),
                ),
              );
            },
          ),
          if (_isRecording)
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return CustomPaint(
                  painter: RippleEffectPainter(
                    progress: _rippleAnimation.value,
                  ),
                  child: Container(),
                );
              },
            ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Phát, hát hoặc ngân nga một bài hát",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    if (_isRecording) {
                      _stopRecording();
                    } else {
                      _startRecording();
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedOpacity(
                        opacity: _isRecording ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          width: 300,
                          height: 300,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.red.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      ScaleTransition(
                        scale: Tween(begin: 1.0, end: 1.5)
                            .animate(_animationController),
                        child: Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.redAccent.withOpacity(0.8),
                                blurRadius: 20,
                                spreadRadius: _isRecording ? 10 : 0,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            size: 40,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                if (_isRecording)
                  Text(
                    "Đang ghi âm: $_elapsedTime giây",
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class RippleEffectPainter extends CustomPainter {
  final double progress;

  RippleEffectPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.4;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 3; i++) {
      double radius = maxRadius * (progress + i * 0.3);
      radius = radius % maxRadius;

      paint.color = Colors.red.withOpacity(1.0 - (radius / maxRadius));
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RippleEffectPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
