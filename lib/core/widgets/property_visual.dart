import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PropertyVisual extends StatelessWidget {
  final String propertyType;
  final int visualIndex;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final String? customTag;
  final String? customImageBase64;
  final String? imageUrl;

  const PropertyVisual({
    super.key,
    required this.propertyType,
    this.visualIndex = 0,
    this.width,
    this.height,
    this.borderRadius,
    this.fit = BoxFit.cover,
    this.customTag,
    this.customImageBase64,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(12);

    return ClipRRect(
      borderRadius: br,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (customImageBase64 != null && customImageBase64!.isNotEmpty)
              Image.memory(
                base64Decode(customImageBase64!),
                fit: fit,
                errorBuilder: (context, error, stackTrace) =>
                    (imageUrl != null && imageUrl!.isNotEmpty)
                        ? _buildNetworkImage()
                        : _buildAssetOrPainter(),
              )
            else if (imageUrl != null && imageUrl!.isNotEmpty)
              _buildNetworkImage()
            else
              _buildAssetOrPainter(),
            // Subtle ambient gradient for depth & readability of text over images
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.45),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
            if (customTag != null)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  child: Text(
                    customTag!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkImage() {
    return Image.network(
      imageUrl!,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: AppColors.surfaceAlt,
          child: const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildAssetOrPainter(),
    );
  }

  Widget _buildAssetOrPainter() {
    final assetPath = _getAssetForPropertyType(propertyType, visualIndex);
    return Image.asset(
      assetPath,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => CustomPaint(
        painter: _ArchitecturalPropertyPainter(
          propertyType: propertyType,
          index: visualIndex,
        ),
      ),
    );
  }

  String _getAssetForPropertyType(String type, int index) {
    final lower = type.toLowerCase();
    if (lower.contains('farm') ||
        lower.contains('தோட்டம்') ||
        lower.contains('விவசாய') ||
        lower.contains('plots') ||
        lower.contains('plot')) {
      return 'assets/images/cat_farm.png';
    } else if (lower.contains('land') ||
        lower.contains('மனை') ||
        lower.contains('நிலம்')) {
      return 'assets/images/cat_land.png';
    } else if (lower.contains('apartment') ||
        lower.contains('flat') ||
        lower.contains('அபார்ட்மெண்ட்')) {
      return 'assets/images/cat_apartment.png';
    } else if (lower.contains('rent') || lower.contains('வாடகை')) {
      return 'assets/images/cat_rental.png';
    } else if (lower.contains('commercial') ||
        lower.contains('legal') ||
        lower.contains('சட்ட')) {
      return 'assets/images/cat_legal.png';
    } else {
      if (index % 3 == 1) return 'assets/images/cat_land.png';
      if (index % 3 == 2) return 'assets/images/cat_farm.png';
      return 'assets/images/cat_house.png';
    }
  }
}

class _ArchitecturalPropertyPainter extends CustomPainter {
  final String propertyType;
  final int index;

  _ArchitecturalPropertyPainter({
    required this.propertyType,
    required this.index,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final type = propertyType.toLowerCase();

    if (type.contains('land') || type.contains('farm')) {
      _paintFarmLand(canvas, size);
    } else if (type.contains('plot')) {
      _paintGatedPlot(canvas, size);
    } else if (type.contains('apartment')) {
      _paintModernApartment(canvas, size);
    } else if (type.contains('commercial') || type.contains('office')) {
      _paintCommercialBuilding(canvas, size);
    } else if (type.contains('shop')) {
      _paintRetailShop(canvas, size);
    } else {
      // Independent House / Villa / Rental default
      _paintIndependentHouse(canvas, size);
    }
  }

  void _paintIndependentHouse(Canvas canvas, Size size) {
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: index % 2 == 0
            ? const [Color(0xFF2B5876), Color(0xFF4E4376)]
            : const [Color(0xFF134E5E), Color(0xFF71B280)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Sun / Moon glow
    final sunGlow = Paint()..color = Colors.white.withValues(alpha: 0.2);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.25), size.height * 0.18, sunGlow);
    final sunCore = Paint()..color = const Color(0xFFFFF9E6).withValues(alpha: 0.8);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.25), size.height * 0.08, sunCore);

    // Ground / Lawn
    final groundPaint = Paint()..color = const Color(0xFF244A29);
    final groundPath = Path()
      ..moveTo(0, size.height * 0.72)
      ..lineTo(size.width, size.height * 0.70)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(groundPath, groundPaint);

    // Main House Structure
    final housePaint = Paint()..color = const Color(0xFFF3EFE6);
    final houseRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(size.width * 0.2, size.height * 0.42, size.width * 0.6, size.height * 0.35),
      topLeft: const Radius.circular(4),
      topRight: const Radius.circular(4),
    );
    canvas.drawRRect(houseRect, housePaint);

    // Architectural second tier
    final upperPaint = Paint()..color = const Color(0xFFE5DDD0);
    final upperRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(size.width * 0.26, size.height * 0.28, size.width * 0.48, size.height * 0.18),
      topLeft: const Radius.circular(4),
      topRight: const Radius.circular(4),
    );
    canvas.drawRRect(upperRect, upperPaint);

    // Modern flat roof overhang
    final roofPaint = Paint()..color = const Color(0xFF2C3E50);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.23, size.height * 0.25, size.width * 0.54, size.height * 0.04),
        const Radius.circular(3),
      ),
      roofPaint,
    );

    // Terrace overhang
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.17, size.height * 0.40, size.width * 0.66, size.height * 0.03),
        const Radius.circular(3),
      ),
      roofPaint,
    );

    // Glass balcony & large windows
    final glassPaint = Paint()
      ..color = const Color(0xFF5DADE2).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    // Upper balcony glass
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.32, size.height * 0.31, size.width * 0.22, size.height * 0.09),
        const Radius.circular(2),
      ),
      glassPaint,
    );
    // Lower window
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.26, size.height * 0.48, size.width * 0.20, size.height * 0.14),
        const Radius.circular(2),
      ),
      glassPaint,
    );

    // Warm wooden entrance door
    final doorPaint = Paint()..color = const Color(0xFF8B4513);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(size.width * 0.54, size.height * 0.48, size.width * 0.14, size.height * 0.25),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      ),
      doorPaint,
    );

    // Warm porch light glow
    final lightGlow = Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.3);
    canvas.drawCircle(Offset(size.width * 0.61, size.height * 0.55), size.width * 0.08, lightGlow);

    // Palm tree / landscaping on side
    _drawTree(canvas, Offset(size.width * 0.12, size.height * 0.72), size.height * 0.35);
    _drawTree(canvas, Offset(size.width * 0.88, size.height * 0.74), size.height * 0.30);
  }

  void _paintModernApartment(Canvas canvas, Size size) {
    // Dusk / sunset sky gradient
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1A2A6C), Color(0xFFB21F1F), Color(0xFFFDBB2D)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Distant tower silhouettes
    final distantTower = Paint()..color = const Color(0xFF2C3E50).withValues(alpha: 0.45);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.08, size.height * 0.35, size.width * 0.22, size.height * 0.55), distantTower);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.72, size.height * 0.28, size.width * 0.22, size.height * 0.60), distantTower);

    // Main luxury high-rise tower
    final towerPaint = Paint()..color = const Color(0xFF2C3E50);
    final mainTower = Rect.fromLTWH(size.width * 0.24, size.height * 0.15, size.width * 0.52, size.height * 0.85);
    canvas.drawRect(mainTower, towerPaint);

    // Roof crown architecture
    final crownPath = Path()
      ..moveTo(size.width * 0.24, size.height * 0.15)
      ..lineTo(size.width * 0.35, size.height * 0.08)
      ..lineTo(size.width * 0.65, size.height * 0.08)
      ..lineTo(size.width * 0.76, size.height * 0.15)
      ..close();
    canvas.drawPath(crownPath, Paint()..color = const Color(0xFF1E2B37));

    // Floor balconies and glowing windows grid
    final winLit = Paint()..color = const Color(0xFFFFE082).withValues(alpha: 0.85);
    final winDim = Paint()..color = const Color(0xFF90CAF9).withValues(alpha: 0.7);

    for (int row = 0; row < 7; row++) {
      final y = size.height * 0.20 + (row * size.height * 0.085);
      // Left balcony
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.28, y, size.width * 0.18, size.height * 0.045),
          const Radius.circular(2),
        ),
        (row % 2 == 0) ? winLit : winDim,
      );
      // Right balcony
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * 0.52, y, size.width * 0.18, size.height * 0.045),
          const Radius.circular(2),
        ),
        (row % 3 == 0) ? winLit : winDim,
      );
    }

    // Street foreground with lighting
    final roadPaint = Paint()..color = const Color(0xFF18232D);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.88, size.width, size.height * 0.12), roadPaint);
    final roadGlow = Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.4);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.87, size.width, 3), roadGlow);
  }

  void _paintCommercialBuilding(Canvas canvas, Size size) {
    // High-tech glass facade sky
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Modern glass tech park building
    final bldgPaint = Paint()..color = const Color(0xFF1E3C4E);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(size.width * 0.15, size.height * 0.18, size.width * 0.70, size.height * 0.82),
        topLeft: const Radius.circular(12),
        topRight: const Radius.circular(12),
      ),
      bldgPaint,
    );

    // Glass panel stripes
    final glassPanel = Paint()..color = const Color(0xFF4CA1AF).withValues(alpha: 0.35);
    for (int col = 0; col < 6; col++) {
      final x = size.width * 0.18 + (col * size.width * 0.11);
      canvas.drawRect(Rect.fromLTWH(x, size.height * 0.22, size.width * 0.08, size.height * 0.65), glassPanel);
    }

    // Entrance canopy with gold touch
    final canopy = Paint()..color = AppColors.accentGold;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.35, size.height * 0.75, size.width * 0.30, size.height * 0.03),
        const Radius.circular(3),
      ),
      canopy,
    );
  }

  void _paintFarmLand(Canvas canvas, Size size) {
    // Lush countryside sky & emerald farm
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF659990), Color(0xFFC0DE82)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Distant hills
    final hillPaint1 = Paint()..color = const Color(0xFF477659);
    final hill1 = Path()
      ..moveTo(0, size.height * 0.52)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.38, size.width * 0.65, size.height * 0.50)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.44, size.width, size.height * 0.48)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(hill1, hillPaint1);

    // Lush farmland field
    final farmPaint = Paint()..color = const Color(0xFF2E6334);
    final farmPath = Path()
      ..moveTo(0, size.height * 0.58)
      ..lineTo(size.width, size.height * 0.54)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(farmPath, farmPaint);

    // Crop cultivation rows (perspective lines)
    final rowPaint = Paint()
      ..color = const Color(0xFF1E4623).withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 7; i++) {
      final startX = size.width * 0.50;
      final startY = size.height * 0.56;
      final endX = (i / 6.0) * size.width;
      final endY = size.height;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), rowPaint);
    }

    // Coconut palms on the boundary
    _drawPalmTree(canvas, Offset(size.width * 0.82, size.height * 0.55), size.height * 0.40);
    _drawPalmTree(canvas, Offset(size.width * 0.92, size.height * 0.58), size.height * 0.35);
  }

  void _paintGatedPlot(Canvas canvas, Size size) {
    // Clear blue sunny sky
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF3A7BD5), Color(0xFF3A6073)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Land surface
    final landPaint = Paint()..color = const Color(0xFF3F6D43);
    canvas.drawRect(Rect.fromLTWH(0, size.height * 0.45, size.width, size.height * 0.55), landPaint);

    // Paved layout black-top road
    final roadPaint = Paint()..color = const Color(0xFF37474F);
    final roadPath = Path()
      ..moveTo(size.width * 0.40, size.height * 0.45)
      ..lineTo(size.width * 0.55, size.height * 0.45)
      ..lineTo(size.width * 0.75, size.height)
      ..lineTo(size.width * 0.15, size.height)
      ..close();
    canvas.drawPath(roadPath, roadPaint);

    // Plot boundary grid markers (white dashed lines)
    final plotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Left plot layout
    canvas.drawRect(Rect.fromLTWH(size.width * 0.05, size.height * 0.55, size.width * 0.30, size.height * 0.35), plotPaint);
    // Right plot layout
    canvas.drawRect(Rect.fromLTWH(size.width * 0.65, size.height * 0.55, size.width * 0.30, size.height * 0.35), plotPaint);

    // Plot number badges
    final badgePaint = Paint()..color = AppColors.accentGold;
    canvas.drawCircle(Offset(size.width * 0.20, size.height * 0.72), 12, badgePaint);
    canvas.drawCircle(Offset(size.width * 0.80, size.height * 0.72), 12, badgePaint);

    // Trees along avenue
    _drawTree(canvas, Offset(size.width * 0.03, size.height * 0.55), size.height * 0.25);
    _drawTree(canvas, Offset(size.width * 0.95, size.height * 0.55), size.height * 0.25);
  }

  void _paintRetailShop(Canvas canvas, Size size) {
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Commercial retail facade
    final shopPaint = Paint()..color = const Color(0xFFECEFF1);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.15, size.height * 0.30, size.width * 0.70, size.height * 0.70), shopPaint);

    // Shop Canopy (striped red/white or green/white)
    final canopyPaint = Paint()..color = AppColors.primary;
    final canopyPath = Path()
      ..moveTo(size.width * 0.12, size.height * 0.40)
      ..lineTo(size.width * 0.88, size.height * 0.40)
      ..lineTo(size.width * 0.85, size.height * 0.48)
      ..lineTo(size.width * 0.15, size.height * 0.48)
      ..close();
    canvas.drawPath(canopyPath, canopyPaint);

    // Large glass showroom display
    final glassPaint = Paint()..color = const Color(0xFF81D4FA).withValues(alpha: 0.7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.20, size.height * 0.52, size.width * 0.60, size.height * 0.35),
        const Radius.circular(4),
      ),
      glassPaint,
    );
  }

  void _drawTree(Canvas canvas, Offset base, double treeHeight) {
    // Trunk
    final trunkPaint = Paint()..color = const Color(0xFF5D4037);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(base.dx, base.dy - treeHeight * 0.25), width: 6, height: treeHeight * 0.5),
      trunkPaint,
    );
    // Foliage
    final foliagePaint = Paint()..color = const Color(0xFF2E7D32);
    canvas.drawCircle(Offset(base.dx, base.dy - treeHeight * 0.55), treeHeight * 0.35, foliagePaint);
    final lightFoliage = Paint()..color = const Color(0xFF43A047);
    canvas.drawCircle(Offset(base.dx - 4, base.dy - treeHeight * 0.60), treeHeight * 0.25, lightFoliage);
  }

  void _drawPalmTree(Canvas canvas, Offset base, double height) {
    final trunkPaint = Paint()
      ..color = const Color(0xFF4E342E)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;
    final trunkPath = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(base.dx - 10, base.dy - height * 0.5, base.dx - 5, base.dy - height);
    canvas.drawPath(trunkPath, trunkPaint);

    // Fronds
    final frondPaint = Paint()
      ..color = const Color(0xFF1B5E20)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final head = Offset(base.dx - 5, base.dy - height);
    for (int i = 0; i < 6; i++) {
      final angle = (i * 35.0 - 90.0) * (math.pi / 180.0);
      final dest = Offset(head.dx + math.cos(angle) * 35, head.dy + math.sin(angle) * 25 + 5);
      canvas.drawLine(head, dest, frondPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ArchitecturalPropertyPainter oldDelegate) {
    return oldDelegate.propertyType != propertyType || oldDelegate.index != index;
  }
}
