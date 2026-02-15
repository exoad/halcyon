import 'package:flutter/widgets.dart';

void doNothing() {}

final class Shared {
  Shared._();

  static const double radiusValue = 5;
  static const Radius radius = Radius.circular(radiusValue);
  static const BorderRadius borderRadius = BorderRadius.all(radius);
  static const RoundedRectangleBorder borderShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(radius),
  );
}
