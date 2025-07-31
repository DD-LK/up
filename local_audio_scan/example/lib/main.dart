import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:local_audio_scan/local_audio_scan.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _localAudioScanner = LocalAudioScanner();
  List<AudioTrack> _audioTracks = [];
  bool _isLoading = false;
  String _status = 'Tap the button to scan for audio files.';

  Future<void> _scanAudioFiles() async {
    setState(() {
      _isLoading = true;
      _status = 'Scanning...';
    });

    try {
      final hasPermission = await _localAudioScanner.requestPermission();
      if (hasPermission) {
        final tracks = await _localAudioScanner.scanTracks();
        setState(() {
          _audioTracks = tracks;
          _status = 'Found ${_audioTracks.length} tracks.';
        });
      } else {
        setState(() {
          _status = 'Permission denied.';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Local Audio Scanner Example'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(_status),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _scanAudioFiles,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Scan Local Audio'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _audioTracks.length,
                itemBuilder: (context, index) {
                  final track = _audioTracks[index];
                  return ListTile(
                    leading: track.artwork != null
                        ? Image.memory(track.artwork as Uint8List)
                        : const Icon(Icons.music_note),
                    title: Text(track.title),
                    subtitle: Text(track.artist),
                    trailing: Text('${(track.duration / 1000).toStringAsFixed(2)}s'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}