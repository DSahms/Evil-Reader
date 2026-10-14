import 'package:flutter/material.dart';
import '../theme/ledger_theme.dart';

/// An ancient leather-bound frame that encases the archaeologist's ledger.
/// Features dark weathered leather gradients, golden stitching lines,
/// antique brass corner brackets, and archival studs.
class LeatherFrame extends StatelessWidget {
  final Widget child;
  final bool showSpine;

  const LeatherFrame({
    super.key,
    required this.child,
    this.showSpine = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LedgerTheme.leatherGradient,
      ),
      child: Stack(
        children: [
          // Inner ledger body
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: child,
            ),
          ),

          // Antique Brass Corner Brackets & Rivets
          const Positioned(
            top: 2,
            left: 2,
            child: AntiqueCornerBracket(isTop: true, isLeft: true),
          ),
          const Positioned(
            top: 2,
            right: 2,
            child: AntiqueCornerBracket(isTop: true, isLeft: false),
          ),
          const Positioned(
            bottom: 2,
            left: 2,
            child: AntiqueCornerBracket(isTop: false, isLeft: true),
          ),
          const Positioned(
            bottom: 2,
            right: 2,
            child: AntiqueCornerBracket(isTop: false, isLeft: false),
          ),
        ],
      ),
    );
  }
}

/// Renders a vintage ornamental brass corner plate with rivet for leather bindings.
class AntiqueCornerBracket extends StatelessWidget {
  final bool isTop;
  final bool isLeft;

  const AntiqueCornerBracket({
    super.key,
    required this.isTop,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(26, 26),
      painter: _CornerBracketPainter(isTop: isTop, isLeft: isLeft),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;

  _CornerBracketPainter({required this.isTop, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC59F48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final brassFill = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFDE8A5), Color(0xFFB3892F), Color(0xFF5E4515)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final shadowPath = Path();

    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);

      shadowPath.moveTo(1, size.height);
      shadowPath.lineTo(1, 1);
      shadowPath.lineTo(size.width, 1);

      // Rivet stud
      canvas.drawCircle(const Offset(6, 6), 3, brassFill);
      canvas.drawCircle(const Offset(6, 6), 3, shadowPaint..strokeWidth = 0.8);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);

      // Rivet stud
      canvas.drawCircle(Offset(size.width - 6, 6), 3, brassFill);
      canvas.drawCircle(Offset(size.width - 6, 6), 3, shadowPaint..strokeWidth = 0.8);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);

      // Rivet stud
      canvas.drawCircle(Offset(6, size.height - 6), 3, brassFill);
      canvas.drawCircle(Offset(6, size.height - 6), 3, shadowPaint..strokeWidth = 0.8);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);

      // Rivet stud
      canvas.drawCircle(Offset(size.width - 6, size.height - 6), 3, brassFill);
      canvas.drawCircle(Offset(size.width - 6, size.height - 6), 3, shadowPaint..strokeWidth = 0.8);
    }

    canvas.drawPath(shadowPath, shadowPaint..color = Colors.black45);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerBracketPainter oldDelegate) => false;
}

/// A decorative archival header banner styled like an embossed brass nameplate.
class ArchivalLedgerHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onIndexTap;
  final VoidCallback? onPlayAudio;
  final bool isAudioPlaying;

  const ArchivalLedgerHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.onIndexTap,
    this.onPlayAudio,
    this.isAudioPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LedgerTheme.leatherAppBarGradient,
        border: Border(
          bottom: BorderSide(
            color: LedgerTheme.brassShadow,
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Archaic Wax Seal Emblem / Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [
                  LedgerTheme.waxSealRed,
                  LedgerTheme.waxSealDark,
                  Color(0xFF2C0606),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFC59F48),
                width: 1.2,
              ),
            ),
            child: const Center(
              child: Text(
                '𝕰',
                style: TextStyle(
                  color: Color(0xFFF9E498),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Titles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'serif',
                    color: LedgerTheme.goldFoilLight,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.8,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 3,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    color: Color(0xFFC7B299),
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onPlayAudio != null)
            IconButton(
              icon: Icon(
                isAudioPlaying ? Icons.graphic_eq_rounded : Icons.headset_rounded,
                color: isAudioPlaying ? LedgerTheme.goldFoilLight : LedgerTheme.goldFoil,
                size: 24,
              ),
              tooltip: isAudioPlaying ? 'Active Audio Recitation' : 'Immersive Audio Mode',
              onPressed: onPlayAudio,
            ),
          if (onIndexTap != null)
            IconButton(
              icon: const Icon(
                Icons.menu_book_rounded,
                color: LedgerTheme.goldFoil,
                size: 24,
              ),
              tooltip: 'Chapter Index',
              onPressed: onIndexTap,
            ),
        ],
      ),
    );
  }
}
