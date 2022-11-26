const _frameRate = 60;

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

final _levelSpeed = [
  _levelFrameRate[0] / _frameRate,
  _levelFrameRate[1] / _frameRate,
  _levelFrameRate[2] / _frameRate,
  _levelFrameRate[3] / _frameRate,
  _levelFrameRate[4] / _frameRate,
  _levelFrameRate[5] / _frameRate,
  _levelFrameRate[6] / _frameRate,
  _levelFrameRate[7] / _frameRate,
  _levelFrameRate[8] / _frameRate,
  _levelFrameRate[9] / _frameRate,
  _levelFrameRate[10] / _frameRate,
  _levelFrameRate[11] / _frameRate,
  _levelFrameRate[12] / _frameRate,
  _levelFrameRate[13] / _frameRate,
  _levelFrameRate[14] / _frameRate,
  _levelFrameRate[15] / _frameRate,
  _levelFrameRate[16] / _frameRate,
  _levelFrameRate[17] / _frameRate,
  _levelFrameRate[18] / _frameRate,
  _levelFrameRate[19] / _frameRate,
  _levelFrameRate[20] / _frameRate,
];

final _level = _levelSpeed
    .map((e) => Level(
        _levelSpeed.indexOf(e) + 1, Duration(milliseconds: (e * 1000).round())))
    .toList();

Level getLevel(int rows) {
  int level = (rows - rows % 10) ~/ 10;
  if (level >= _level.length) {
    level = _level.length - 1;
  }
  return _level[level];
}

class Level {
  final int id;
  final Duration speed;

  Level(this.id, this.speed);
}
