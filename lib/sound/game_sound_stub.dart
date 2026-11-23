/// Silent fallback used where no sound backend is available.
class GameSound {
  /// Whether effects are allowed to play.
  bool enabled = true;

  void tap() {}

  void win() {}

  void draw() {}

  void matchWin() {}
}
