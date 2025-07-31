import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'local_audio_scan_platform_interface.dart';

/// An implementation of [LocalAudioScanPlatform] that uses method channels.
class MethodChannelLocalAudioScan extends LocalAudioScanPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('local_audio_scan');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
