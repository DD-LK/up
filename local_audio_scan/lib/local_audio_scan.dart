import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class AudioTrack {
  final String id;
  final String title;
  final String artist;
  final String album;
  final int duration;
  final String filePath;
  final String mimeType;
  final int size;
  final DateTime dateAdded;
  final Uint8List? artwork;

  AudioTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.filePath,
    required this.mimeType,
    required this.size,
    required this.dateAdded,
    this.artwork,
  });
}

class LocalAudioScanner {
  static const MethodChannel _channel = MethodChannel('local_audio_scan');

  /// Request necessary permissions
  Future<bool> requestPermission() async {
    return await _channel.invokeMethod('requestPermission');
  }

  /// Check if permission is granted
  Future<bool> checkPermission() async {
    return await _channel.invokeMethod('checkPermission');
  }

  /// Scan all audio tracks (optionally include artwork)
  Future<List<AudioTrack>> scanTracks({bool includeArtwork = true}) async {
    final List<dynamic>? result = await _channel.invokeMethod('scanTracks', {'includeArtwork': includeArtwork});
    return result?.map((e) => AudioTrack(
      id: e['id'],
      title: e['title'],
      artist: e['artist'],
      album: e['album'],
      duration: e['duration'],
      filePath: e['filePath'],
      mimeType: e['mimeType'],
      size: e['size'],
      dateAdded: DateTime.fromMillisecondsSinceEpoch(e['dateAdded']),
      artwork: e['artwork'],
    )).toList() ?? [];
  }
}