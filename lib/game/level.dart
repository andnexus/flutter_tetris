class Level {
  final int id;
  final int speed;

  Level(this.id, this.speed);
}

Level getLevel(int rows) => _level[_getLevelIndex(rows)];

/// https://harddrop.com/wiki/Tetris_(Game_Boy)
const _levelFrameRate = [
  53,
  49,
  45,
  41,
  37,
  33,
  28,
  22,
  17,
  11,
  10,
  9,
  8,
  7,
  6,
  6,
  5,
  5,
  4,
  4,
  3,
];

final _level = List.generate(
  _levelFrameRate.length,
  (index) => Level(
    index + 1,
    _levelFrameRate[index],
  ),
);

int _getLevelIndex(int rows) {
  var level = (rows - rows % 10) ~/ 10;
  if (level >= _level.length) {
    level = _level.length - 1;
  }
  return level;
}
