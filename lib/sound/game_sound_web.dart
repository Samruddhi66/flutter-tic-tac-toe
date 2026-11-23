import 'dart:js_interop';

/// Sound effects for the web build, synthesised with Web Audio so no audio
/// files have to be downloaded.
class GameSound {
  /// Whether effects are allowed to play.
  bool enabled = true;

  _AudioContext? _context;

  void tap() => _play(const <_Note>[_Note(880, 0, 0.07)]);

  void win() => _play(const <_Note>[
        _Note(523.25, 0, 0.12),
        _Note(659.25, 0.10, 0.12),
        _Note(783.99, 0.20, 0.20),
      ]);

  void draw() => _play(const <_Note>[
        _Note(329.63, 0, 0.14),
        _Note(261.63, 0.12, 0.24),
      ]);

  void matchWin() => _play(const <_Note>[
        _Note(523.25, 0, 0.12),
        _Note(659.25, 0.12, 0.12),
        _Note(783.99, 0.24, 0.12),
        _Note(1046.50, 0.36, 0.34),
      ]);

  void _play(List<_Note> notes) {
    if (!enabled) return;
    final _AudioContext? context = _ensureContext();
    if (context == null) return;

    try {
      final double now = context.currentTime;
      for (final _Note note in notes) {
        final _OscillatorNode oscillator = context.createOscillator();
        final _GainNode gain = context.createGain();
        final double start = now + note.start;
        final double end = start + note.duration;

        oscillator.type = 'sine'.toJS;
        oscillator.frequency.setValueAtTime(note.frequency, start);
        gain.gain.setValueAtTime(0.0001, start);
        gain.gain.exponentialRampToValueAtTime(0.16, start + 0.01);
        gain.gain.exponentialRampToValueAtTime(0.0001, end);

        oscillator.connect(gain);
        gain.connect(context.destination);
        oscillator.start(start);
        oscillator.stop(end + 0.02);
      }
    } catch (_) {
      // Audio is a nice-to-have; never let it break the game.
    }
  }

  _AudioContext? _ensureContext() {
    try {
      final _AudioContext context = _context ??= _AudioContext();
      if (context.state.toDart == 'suspended') {
        context.resume();
      }
      return context;
    } catch (_) {
      return null;
    }
  }
}

class _Note {
  const _Note(this.frequency, this.start, this.duration);

  final double frequency;
  final double start;
  final double duration;
}

@JS('AudioContext')
extension type _AudioContext._(JSObject _) implements JSObject {
  external factory _AudioContext();

  external _OscillatorNode createOscillator();

  external _GainNode createGain();

  external JSObject get destination;

  external double get currentTime;

  external JSString get state;

  external JSPromise<JSAny?> resume();
}

extension type _OscillatorNode._(JSObject _) implements JSObject {
  external set type(JSString value);

  external _AudioParam get frequency;

  external void connect(JSObject node);

  external void start(double when);

  external void stop(double when);
}

extension type _GainNode._(JSObject _) implements JSObject {
  external _AudioParam get gain;

  external void connect(JSObject node);
}

extension type _AudioParam._(JSObject _) implements JSObject {
  external void setValueAtTime(double value, double time);

  external void exponentialRampToValueAtTime(double value, double time);
}
