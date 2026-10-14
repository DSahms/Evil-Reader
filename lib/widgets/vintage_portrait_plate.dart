import 'package:flutter/material.dart';
import '../models/ledger_entity.dart';
import '../theme/ledger_theme.dart';

/// A vintage archival daguerreotype plate mount for entity portraits.
/// Recreates the look of an antique photographic plate fixed onto
/// an archaeologist's field ledger with brass photo corners and an
/// engraved specimen plaque.
class VintagePortraitPlate extends StatelessWidget {
  final LedgerEntity entity;

  const VintagePortraitPlate({
    super.key,
    required this.entity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF23160D),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF5A391F),
          width: 2,
        ),
        boxShadow: LedgerTheme.plateShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Archival Top Tag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ARCHIVE SPECIMEN',
                  style: TextStyle(
                    fontFamily: 'serif',
                    color: LedgerTheme.goldFoil.withValues(alpha: 0.8),
                    fontSize: 10,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  entity.eraDate,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    color: Color(0xFFB89E7E),
                    fontSize: 10,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Photographic Plate Frame
            Stack(
              children: [
                // Inner Mount Bevel
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF140D08),
                    border: Border.all(
                      color: const Color(0xFF8B6B38),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.7),
                        blurRadius: 6,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: AspectRatio(
                    aspectRatio: 4 / 5,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Image with sepia / aged tint and uncropped BoxFit.contain
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: ColorFiltered(
                              colorFilter: const ColorFilter.mode(
                                Color(0x188B5A2B),
                                BlendMode.colorBurn,
                              ),
                              child: Image.asset(
                                entity.imagePath,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: const Color(0xFF2A1C12),
                                    child: const Center(
                                      child: Icon(
                                        Icons.portrait_rounded,
                                        size: 60,
                                        color: Color(0xFF8B6B38),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        // Vignette & distressed lens shadow
                        Container(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: 0.85,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.4),
                                Colors.black.withValues(alpha: 0.75),
                              ],
                              stops: const [0.5, 0.8, 1.0],
                            ),
                          ),
                        ),

                        // Subtle plate gloss reflection
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: 50,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.12),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Vintage Photo Mount Corners (Triangle tabs)
                const Positioned(
                  top: 0,
                  left: 0,
                  child: _PhotoMountCorner(isTop: true, isLeft: true),
                ),
                const Positioned(
                  top: 0,
                  right: 0,
                  child: _PhotoMountCorner(isTop: true, isLeft: false),
                ),
                const Positioned(
                  bottom: 0,
                  left: 0,
                  child: _PhotoMountCorner(isTop: false, isLeft: true),
                ),
                const Positioned(
                  bottom: 0,
                  right: 0,
                  child: _PhotoMountCorner(isTop: false, isLeft: false),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Stamped Brass Engraved Plaque
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                gradient: LedgerTheme.goldPlateGradient,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: const Color(0xFF634A1B),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Brass rivet left
                  _buildPlaqueRivet(),
                  const SizedBox(width: 8),

                  // Engraved text
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          entity.name.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'serif',
                            color: Color(0xFF1E1106),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.5,
                            shadows: [
                              Shadow(
                                color: Color(0x77FFFFFF),
                                offset: Offset(0, 1),
                                blurRadius: 0.5,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entity.plateCaption,
                          style: const TextStyle(
                            fontFamily: 'serif',
                            color: Color(0xFF38230D),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),
                  // Brass rivet right
                  _buildPlaqueRivet(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaqueRivet() {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF4A3414),
        border: Border.all(color: const Color(0xFF2E1C06), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66FFFFFF),
            offset: Offset(0, 0.8),
            blurRadius: 0.5,
          ),
        ],
      ),
    );
  }
}

/// A triangular brass corner mount for vintage photograph plates.
class _PhotoMountCorner extends StatelessWidget {
  final bool isTop;
  final bool isLeft;

  const _PhotoMountCorner({required this.isTop, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(18, 18),
      painter: _CornerTabPainter(isTop: isTop, isLeft: isLeft),
    );
  }
}

class _CornerTabPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;

  _CornerTabPainter({required this.isTop, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6B4B1B)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = const Color(0xFFC59F48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path();
    if (isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
    } else if (isTop && !isLeft) {
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(0, 0);
    } else {
      path.moveTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.lineTo(size.width, 0);
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _CornerTabPainter oldDelegate) => false;
}
