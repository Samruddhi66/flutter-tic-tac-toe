/// Short game sound effects.
///
/// The web build synthesises little tones with the browser audio API, mobile
/// and desktop use the system click plus haptics, and tests get a silent
/// implementation. No audio files or extra packages are needed.
library;

export 'game_sound_stub.dart'
    if (dart.library.js_interop) 'game_sound_web.dart'
    if (dart.library.io) 'game_sound_io.dart';
