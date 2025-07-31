import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'local_audio_scan_method_channel.dart';

abstract class LocalAudioScanPlatform extends PlatformInterface {
  /// Constructs a LocalAudioScanPlatform.
  LocalAudioScanPlatform() : super(token: _token);

  static final Object _token = Object();

  static LocalAudioScanPlatform _instance = MethodChannelLocalAudioScan();

  /// The default instance of [LocalAudioScanPlatform] to use.
  ///
  /// Defaults to [MethodChannelLocalAudioScan].
  static LocalAudioScanPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [LocalAudioScanPlatform] when
  /// they register themselves.
  static set instance(LocalAudioScanPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
