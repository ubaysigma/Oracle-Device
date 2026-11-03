import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The official emblem of The Index from Project Moon (Limbus Company / Library of Ruina).
/// Features:
/// - A golden crescent arc encircling the base
/// - A stylized hand with the index finger pointed straight up
/// - A 5-petal glowing cyan flower/star resting at the tip of the index finger
class IndexLogo extends StatelessWidget {
  final double size;

  const IndexLogo({
    super.key,
    this.size = 110,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _IndexLogoPainter(),
      ),
    );
  }
}

class _IndexLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2 + (h * 0.05);

    // Color definitions matching the screenshot
    const Color goldColor = Color(0xFFF6D896);
    const Color goldGlow = Color(0xFFFFE082);
    const Color cyanColor = Color(0xFF00F0FF);
    const Color cyanGlow = Color(0xFF2EE9FF);

    // =========================================================================
    // 1. GOLDEN CRESCENT ARC
    // =========================================================================
    final Paint crescentGlowPaint = Paint()
      ..color = goldGlow.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.075
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final Paint crescentPaint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round;

    final Rect crescentRect = Rect.fromCenter(
      center: Offset(cx, cy + h * 0.02),
      width: w * 0.72,
      height: h * 0.72,
    );

    // Arc sweeps from ~140 degrees down to ~400 degrees (leaving the top open)
    const double startAngle = 0.75 * math.pi;
    const double sweepAngle = 1.50 * math.pi;

    canvas.drawArc(crescentRect, startAngle, sweepAngle, false, crescentGlowPaint);
    canvas.drawArc(crescentRect, startAngle, sweepAngle, false, crescentPaint);

    // Double inner thin ring on crescent
    final Rect innerCrescentRect = Rect.fromCenter(
      center: Offset(cx, cy + h * 0.02),
      width: w * 0.60,
      height: h * 0.60,
    );
    final Paint innerCrescentPaint = Paint()
      ..color = goldColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.015;
    canvas.drawArc(innerCrescentRect, startAngle + 0.1, sweepAngle - 0.2, false, innerCrescentPaint);

    // =========================================================================
    // 2. STYLIZED HAND WITH INDEX FINGER POINTING UP
    // =========================================================================
    final Paint handGlowPaint = Paint()
      ..color = goldGlow.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

    final Paint handPaint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.032
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Paint handFillPaint = Paint()
      ..color = const Color(0xFF13100B)
      ..style = PaintingStyle.fill;

    // Hand Path
    final Path handPath = Path();
    final double wristLeft = cx - w * 0.10;
    final double wristRight = cx + w * 0.10;
    final double wristY = cy + h * 0.28;
    final double palmTopY = cy + h * 0.02;
    final double fingerTipY = cy - h * 0.22;

    handPath.moveTo(wristLeft, wristY);
    // Left palm contour (outer thumb side)
    handPath.cubicTo(
      cx - w * 0.18, cy + h * 0.18,
      cx - w * 0.18, cy + h * 0.05,
      cx - w * 0.08, palmTopY,
    );
    // Index finger going straight up
    handPath.lineTo(cx - w * 0.04, fingerTipY);
    handPath.arcToPoint(
      Offset(cx + w * 0.04, fingerTipY),
      radius: Radius.circular(w * 0.04),
    );
    handPath.lineTo(cx + w * 0.04, palmTopY - h * 0.02);

    // Folded fingers on right side (middle, ring, pinky)
    handPath.cubicTo(
      cx + w * 0.16, palmTopY,
      cx + w * 0.17, cy + h * 0.15,
      wristRight, wristY,
    );
    handPath.close();

    canvas.drawPath(handPath, handFillPaint);
    canvas.drawPath(handPath, handGlowPaint);
    canvas.drawPath(handPath, handPaint);

    // Detail lines on hand (folded knuckles / thumb clasp)
    final Path knucklePath = Path();
    knucklePath.moveTo(cx - w * 0.08, cy + h * 0.05);
    knucklePath.quadraticBezierTo(cx, cy + h * 0.08, cx + w * 0.10, cy + h * 0.04);
    knucklePath.moveTo(cx - w * 0.04, cy + h * 0.12);
    knucklePath.quadraticBezierTo(cx + w * 0.02, cy + h * 0.14, cx + w * 0.12, cy + h * 0.10);
    final Paint detailPaint = Paint()
      ..color = goldColor.withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.018;
    canvas.drawPath(knucklePath, detailPaint);

    // =========================================================================
    // 3. GLOWING CYAN 5-PETAL FLOWER AT THE INDEX FINGER TIP
    // =========================================================================
    final Offset flowerCenter = Offset(cx, fingerTipY - h * 0.08);
    final double petalRadius = w * 0.075;

    // Outer cyan bloom
    final Paint bloomPaint = Paint()
      ..color = cyanGlow.withOpacity(0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(flowerCenter, petalRadius * 1.6, bloomPaint);

    final Paint flowerGlowPaint = Paint()
      ..color = cyanGlow
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final Paint flowerFillPaint = Paint()
      ..color = cyanColor
      ..style = PaintingStyle.fill;

    final Paint flowerCorePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw 5 petals
    final Path flowerPath = Path();
    const int petalCount = 5;
    for (int i = 0; i < petalCount; i++) {
      // Start pointing straight up (-pi / 2)
      final double angle = -math.pi / 2 + (i * 2 * math.pi / petalCount);
      final double petalDist = petalRadius * 0.95;
      final double px = flowerCenter.dx + petalDist * math.cos(angle);
      final double py = flowerCenter.dy + petalDist * math.sin(angle);

      final double pWidth = petalRadius * 0.55;
      final double pHeight = petalRadius * 0.75;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(angle + math.pi / 2);
      final Rect petalRect = Rect.fromCenter(
        center: Offset.zero,
        width: pWidth,
        height: pHeight,
      );
      canvas.drawOval(petalRect, flowerFillPaint);
      canvas.drawOval(petalRect, flowerGlowPaint);
      canvas.restore();
    }

    // Flower center core with bright white glow
    canvas.drawCircle(flowerCenter, petalRadius * 0.35, flowerFillPaint);
    canvas.drawCircle(flowerCenter, petalRadius * 0.20, flowerCorePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

