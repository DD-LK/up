import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_audio_scan/local_audio_scan_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelLocalAudioScan platform = MethodChannelLocalAudioScan();
  const MethodChannel channel = MethodChannel('local_audio_scan');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
