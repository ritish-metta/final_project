import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceBotApp extends StatefulWidget {
  const VoiceBotApp({super.key});

  @override
  _VoiceBotAppState createState() => _VoiceBotAppState();
}

class _VoiceBotAppState extends State {
  final List<Map<String, String>> _messages = [];
  bool _isListening = false;
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final bool _isConnected = true;
  String _errorMessage = '';
  String _liveText = '';
  final List<String> _transcriptionHistory = [];
  bool _showTranscription = false;
  Timer? _silenceTimer;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _speech.cancel();
    super.dispose();
  }

  Future<void> _initializeSpeech() async {
  PermissionStatus status = await Permission.microphone.request();
  if (status.isGranted) {
    try {
      bool available = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
        debugLogging: true,
      );
      setState(() => _isInitialized = available);
    } catch (e) {
      print('Speech initialization error: $e');
      setState(() => _errorMessage = 'Failed to initialize speech recognition');
    }
  } else {
    setState(() => _errorMessage = 'Microphone permission is required.');
  }
}
  

  void _onSpeechStatus(String status) {
    print('Speech status: $status');
    if (status == 'done' && _isListening) {
      _restartListening();
    }
  }

  void _onSpeechError(dynamic error) {
    print('Speech error: $error');
    if (_isListening) {
      _restartListening();
    }
  }

  void _startListening() async {
    if (!_isInitialized) {
      await _initializeSpeech();
    }

    if (_isInitialized) {
      setState(() {
        _isListening = true;
        _showTranscription = true;
        _errorMessage = '';
      });

      try {
        await _speech.listen(
          onResult: _onSpeechResult,
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          cancelOnError: false,
          listenMode: stt.ListenMode.confirmation,
        );
      } catch (e) {
        print('Listen error: $e');
        _stopListening();
      }
    } else {
      setState(() => _errorMessage = 'Speech recognition not available');
    }
  }

  void _restartListening() async {
    if (_isListening) {
      try {
        await _speech.listen(
          onResult: _onSpeechResult,
          listenFor: const Duration(hours: 1),
          pauseFor: const Duration(minutes: 1),
          partialResults: true,
          cancelOnError: false,
          listenMode: stt.ListenMode.confirmation,
        );
      } catch (e) {
        print('Restart listening error: $e');
        _stopListening();
      }
    }
  }

  void _onSpeechResult(stt.SpeechRecognitionResult result) {
    setState(() {
      _liveText = result.recognizedWords;
    });

    _silenceTimer?.cancel();
    if (result.finalResult) {
      if (_liveText.isNotEmpty) {
        setState(() {
          _transcriptionHistory.add(_liveText);
        });
      }
      
      _silenceTimer = Timer(const Duration(milliseconds: 500), () {
        if (_isListening) {
          _restartListening();
        }
      });
    }
  }

  void _stopListening() async {
    _silenceTimer?.cancel();
    setState(() => _isListening = false);
    
    try {
      await _speech.stop();
      if (_liveText.isNotEmpty && !_transcriptionHistory.contains(_liveText)) {
        setState(() {
          _transcriptionHistory.add(_liveText);
          _liveText = '';
        });
      }
    } catch (e) {
      print('Stop listening error: $e');
    }
  }

  void _generatePDF() {
    // TODO: Implement PDF generation using the _transcriptionHistory
    print('Generating PDF with transcriptions: $_transcriptionHistory');
  }

  void _clearTranscriptions() {
    setState(() {
      _transcriptionHistory.clear();
      _showTranscription = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isUser = message['role'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.white : Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.yellowAccent.shade700,
                                blurRadius: isUser ? 5 : 0,
                                spreadRadius: isUser ? 1 : 0,
                              )
                            ],
                          ),
                          child: Text(
                            message['message']!,
                            style: TextStyle(
                              color: isUser ? Colors.black : Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        margin: const EdgeInsets.only(top: 10),
                        height: _isListening ? 70 : 60,
                        width: _isListening ? 70 : 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: _isListening
                              ? [
                                  BoxShadow(
                                    color: Colors.yellowAccent.shade700,
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  )
                                ]
                              : [],
                          gradient: RadialGradient(
                            colors: [Colors.yellow.shade700, Colors.black],
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(_isListening ? Icons.mic : Icons.mic_none, size: 30, color: Colors.white),
                          onPressed: _isListening ? _stopListening : _startListening,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 15, right: 10),
                            child: ElevatedButton(
                              onPressed: _transcriptionHistory.isNotEmpty ? _generatePDF : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade900,
                                foregroundColor: Colors.yellow.shade700,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: Colors.yellow.shade700),
                                ),
                              ),
                              child: const Text(
                                "Go with the PDF",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 15),
                            child: ElevatedButton(
                              onPressed: _clearTranscriptions,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade900,
                                foregroundColor: Colors.red.shade400,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: Colors.red.shade400),
                                ),
                              ),
                              child: const Text(
                                "Clear",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_showTranscription)
              Center(
                child: Container(
                  width: 300,
                  height: 300,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellowAccent.shade700,
                        blurRadius: 10,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _isListening ? "Listening..." : "Transcription",
                            style: TextStyle(
                              color: Colors.yellow.shade100,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!_isListening)
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => setState(() => _showTranscription = false),
                            ),
                        ],
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_isListening)
                                Text(
                                  _liveText,
                                  style: TextStyle(
                                    color: Colors.yellow.shade100,
                                    fontSize: 14,
                                  ),
                                ),
                              ..._transcriptionHistory.map((text) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  text,
                                  style: TextStyle(
                                    color: Colors.yellow.shade100,
                                    fontSize: 14,
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}