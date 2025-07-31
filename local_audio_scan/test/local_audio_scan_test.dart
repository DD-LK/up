import 'package:flutter_test/flutter_test.dart';
import 'package:local_audio_scan/local_audio_scan.dart';
import 'package:local_audio_scan/local_audio_scan_platform_interface.dart';
import 'package:local_audio_scan/local_audio_scan_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockLocalAudioScanPlatform
    with MockPlatformInterfaceMixin
    implements LocalAudioScanPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final LocalAudioScanPlatform initialPlatform = LocalAudioScanPlatform.instance;

  test('$MethodChannelLocalAudioScan is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelLocalAudioScan>());
  });

  test('getPlatformVersion', () async {
    LocalAudioScan localAudioScanPlugin = LocalAudioScan();
    MockLocalAudioScanPlatform fakePlatform = MockLocalAudioScanPlatform();
    LocalAudioScanPlatform.instance = fakePlatform;

    expect(await localAudioScanPlugin.getPlatformVersion(), '42');
  });
}
