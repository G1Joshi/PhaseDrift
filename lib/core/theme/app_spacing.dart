import 'package:material_ui/material_ui.dart';

abstract final class AppSpacing {
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  static const EdgeInsets insetsXs = EdgeInsets.all(xs);
  static const EdgeInsets insetsSm = EdgeInsets.all(sm);
  static const EdgeInsets insetsMd = EdgeInsets.all(md);
  static const EdgeInsets insetsLg = EdgeInsets.all(lg);
  static const EdgeInsets insetsXl = EdgeInsets.all(xl);

  static const EdgeInsets insetsCard = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  static const EdgeInsets insetsHud = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  static const EdgeInsets insetsButton = EdgeInsets.symmetric(
    horizontal: 20.0,
    vertical: md,
  );

  static const SizedBox vGapXxs = SizedBox(height: xxs);
  static const SizedBox vGapXs = SizedBox(height: xs);
  static const SizedBox vGapSm = SizedBox(height: sm);
  static const SizedBox vGapMd = SizedBox(height: md);
  static const SizedBox vGapLg = SizedBox(height: lg);
  static const SizedBox vGapXl = SizedBox(height: xl);
  static const SizedBox vGapXxl = SizedBox(height: xxl);

  static const SizedBox hGapXxs = SizedBox(width: xxs);
  static const SizedBox hGapXs = SizedBox(width: xs);
  static const SizedBox hGapSm = SizedBox(width: sm);
  static const SizedBox hGapMd = SizedBox(width: md);
  static const SizedBox hGapLg = SizedBox(width: lg);
  static const SizedBox hGapXl = SizedBox(width: xl);
  static const SizedBox hGapXxl = SizedBox(width: xxl);
}
