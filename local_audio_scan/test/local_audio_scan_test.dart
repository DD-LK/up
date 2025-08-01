import 'package:flutter_test/flutter_test.dart';
import 'package:local_audio_scan/local_audio_scan.dart';

void main() {
  test('scanTracks', () async {
    final LocalAudioScanner plugin = LocalAudioScanner();
    final List<AudioTrack> tracks = await plugin.scanTracks();
    expect(tracks, isNotNull);
  });
}
