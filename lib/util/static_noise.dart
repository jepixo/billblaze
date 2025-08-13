import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

AudioPlayer? _whiteNoisePlayer;

Future<void> startWhiteNoise() async {
  final sampleRate = 44100;
  final durationSeconds = 10; // One second loop
  final totalSamples = (sampleRate * durationSeconds).toInt();

  final buffer = BytesBuilder();
  buffer.add(_wavHeader(totalSamples, sampleRate));

  final rnd = Random();
  for (int i = 0; i < totalSamples; i++) {
    final sample = ((rnd.nextDouble() * 2 - 1) * 32767).toInt();
    buffer.addByte(sample & 0xFF);
    buffer.addByte((sample >> 8) & 0xFF);
  }

  _whiteNoisePlayer = AudioPlayer();
  await _whiteNoisePlayer!.play(
    BytesSource(buffer.toBytes()),
    volume: 1.0,
    ctx: AudioContext(), // optional: make sure it works across platforms
  );

  // Loop forever
  _whiteNoisePlayer!.setReleaseMode(ReleaseMode.loop);
}

Future<void> stopWhiteNoise() async {
  await _whiteNoisePlayer?.stop();
  _whiteNoisePlayer = null;
}

List<int> _wavHeader(int samples, int sampleRate) {
  final byteRate = sampleRate * 2;
  final dataSize = samples * 2;
  final chunkSize = 36 + dataSize;

  return [
    ...'RIFF'.codeUnits,
    chunkSize & 0xFF,
    (chunkSize >> 8) & 0xFF,
    (chunkSize >> 16) & 0xFF,
    (chunkSize >> 24) & 0xFF,
    ...'WAVE'.codeUnits,
    ...'fmt '.codeUnits,
    16, 0, 0, 0,
    1, 0,
    1, 0,
    sampleRate & 0xFF,
    (sampleRate >> 8) & 0xFF,
    (sampleRate >> 16) & 0xFF,
    (sampleRate >> 24) & 0xFF,
    byteRate & 0xFF,
    (byteRate >> 8) & 0xFF,
    (byteRate >> 16) & 0xFF,
    (byteRate >> 24) & 0xFF,
    2, 0,
    16, 0,
    ...'data'.codeUnits,
    dataSize & 0xFF,
    (dataSize >> 8) & 0xFF,
    (dataSize >> 16) & 0xFF,
    (dataSize >> 24) & 0xFF,
  ];
}
