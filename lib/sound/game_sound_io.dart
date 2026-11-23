import 'package:flutter/services.dart';

/// Sound effects for mobile and desktop: the platform click sound plus haptic
/// feedback. Kept timer-free so widget tests stay deterministic.
class GameSound {
  /// Whether effects are allowed to play.
  bool enabled = true;

  void tap() {
    if (!enabled) return;
    SystemSound.play(SystemSoundType.click);
  }

  void win() {
    if (!enabled) return;
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
  }

  void draw() {
    if (!enabled) return;
    HapticFeedback.selectionClick();
    SystemSound.play(SystemSoundType.click);
  }

  void matchWin() {
    if (!enabled) return;
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.click);
  }
}
