import 'dart:ui';

Path drawHeart(Size size) {
  final Path path = Path();
  double width = size.width;
  double height = size.height;

  path.moveTo(width / 2, height / 4);

  path.cubicTo(
    5 * width / 14,
    0,
    0,
    height / 15,
    width / 28,
    2 * height / 5,
  );

  path.cubicTo(
    width / 14,
    2 * height / 3,
    3 * width / 7,
    5 * height / 6,
    width / 2,
    height,
  );

  path.cubicTo(
    4 * width / 7,
    5 * height / 6,
    13 * width / 14,
    2 * height / 3,
    27 * width / 28,
    2 * height / 5,
  );

  path.cubicTo(
    width,
    height / 15,
    9 * width / 14,
    0,
    width / 2,
    height / 4,
  );

  path.close();
  return path;
}
