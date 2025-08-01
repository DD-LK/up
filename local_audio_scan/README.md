# local_audio_scan

An Android-only Flutter package for scanning local audio files with album art extraction.

## Installation

Add `local_audio_scan` to your `pubspec.yaml`:

```yaml
dependencies:
  local_audio_scan: ^4.0.0
```

Then run `flutter pub get`.

## Permissions Setup

This plugin requires permissions to read audio files from the device's storage.

### Android

Add the following permissions to your `android/app/src/main/AndroidManifest.xml` file:

For Android 13 (API 33) and above:
```xml
<uses-permission android:name="android.permission.READ_MEDIA_AUDIO" />
```

For older versions (below Android 13):
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

## Basic Usage

Here's a quick example of how to use the plugin:

```dart
import 'package:local_audio_scan/local_audio_scan.dart';

// First, request permissions
bool hasPermission = await LocalAudioScanner().requestPermission();

if (hasPermission) {
  // Scan for audio tracks, filtering out junk audio
  List<AudioTrack> tracks = await LocalAudioScanner().scanTracks(filterJunkAudio: true);

  for (var track in tracks) {
    print('Title: ${track.title}, Artist: ${track.artist}');
  }
}
```

## Example Output

An `AudioTrack` object contains the following information:

```dart
AudioTrack({
  id: '123',
  title: 'Cool Song',
  artist: 'Awesome Artist',
  album: 'Greatest Hits',
  duration: 240000, // in milliseconds
  filePath: '/storage/emulated/0/Music/cool_song.mp3',
  mimeType: 'audio/mpeg',
  size: 5120000, // in bytes
  dateAdded: 2023-10-27 10:00:00.000Z,
  artwork: // Uint8List data for album art
});
```

## Note

This plugin only supports Android. Calling its methods on iOS will result in a `MissingPluginException`.