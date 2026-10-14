import 'package:flutter/material.dart';
import '../models/ledger_entity.dart';
import '../services/tts_service.dart';
import '../theme/ledger_theme.dart';
import 'leather_frame.dart';

/// Immersive Audio Player Mode centered in the ancient leather-and-parchment theme.
/// Displays the active entity portrait cleanly centered without full-screen stretching,
/// showing real-time spoken text snippets and sticky brass & wax-seal audio controls.
class ImmersiveAudioView extends StatefulWidget {
  final LedgerEntity entity;
  final VoidCallback onClose;

  const ImmersiveAudioView({
    super.key,
    required this.entity,
    required this.onClose,
  });

  @override
  State<ImmersiveAudioView> createState() => _ImmersiveAudioViewState();
}

class _ImmersiveAudioViewState extends State<ImmersiveAudioView>
    with SingleTickerProviderStateMixin {
  final TtsService _tts = TtsService();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _tts.addListener(_onTtsUpdate);
  }

  void _onTtsUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tts.removeListener(_onTtsUpdate);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entity = widget.entity;
    final isPlaying = _tts.isPlaying;

    return Scaffold(
      backgroundColor: LedgerTheme.leatherDarkest,
      body: SafeArea(
        child: LeatherFrame(
          showSpine: false,
          child: Column(
            children: [
              // Top Header Bar
              _buildTopBar(entity),

              // Centered Visual Area (Portrait + Spoken Subtitle)
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Centered Entity Portrait Plate
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: isPlaying ? _pulseAnimation.value : 1.0,
                              child: child,
                            );
                          },
                          child: _buildCenteredPortraitPlate(entity, isPlaying),
                        ),

                        const SizedBox(height: 16),

                        // Section / Track Title
                        Text(
                          _tts.currentTitle.isNotEmpty
                              ? _tts.currentTitle.toUpperCase()
                              : 'ARCHIVAL AUDIO FOLIO',
                          style: const TextStyle(
                            fontFamily: 'serif',
                            color: LedgerTheme.goldFoilLight,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.8,
                            shadows: [
                              Shadow(
                                color: Colors.black,
                                blurRadius: 4,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 12),

                        // Spoken Text Parchment Capsule
                        _buildCurrentSpokenTextCapsule(),
                      ],
                    ),
                  ),
                ),
              ),

              // Sticky Bottom Audio Controls Bar
              _buildStickyControlBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(LedgerEntity entity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LedgerTheme.leatherAppBarGradient,
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFF4A3414),
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: LedgerTheme.goldFoil,
              size: 20,
            ),
            tooltip: 'Return to Ledger Reader',
            onPressed: widget.onClose,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'IMMERSIVE AUDIO ARCHIVE',
                  style: TextStyle(
                    fontFamily: 'serif',
                    color: LedgerTheme.goldFoil,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                Text(
                  entity.name,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    color: Color(0xFFDCC8A0),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Speed button
          PopupMenuButton<double>(
            initialValue: _tts.speechRate,
            tooltip: 'Playback Pace',
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2B180D),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: LedgerTheme.goldFoilDark),
              ),
              child: Text(
                '${(_tts.speechRate * 2).toStringAsFixed(1)}x',
                style: const TextStyle(
                  fontFamily: 'serif',
                  color: LedgerTheme.goldFoilLight,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            color: const Color(0xFF1B0E07),
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 0.38, child: Text('0.8x (Gothic / Slow)')),
              const PopupMenuItem(value: 0.48, child: Text('1.0x (Historical Pace)')),
              const PopupMenuItem(value: 0.58, child: Text('1.2x (Brisk Pace)')),
            ],
            onSelected: (rate) => _tts.setSpeechRate(rate),
          ),
        ],
      ),
    );
  }

  /// Prominently focused portrait plate in the center, framed cleanly without stretching
  Widget _buildCenteredPortraitPlate(LedgerEntity entity, bool isPlaying) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 290,
        maxHeight: 330,
      ),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F120A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isPlaying ? LedgerTheme.goldFoil : const Color(0xFF5A391F),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isPlaying
                ? LedgerTheme.goldFoilDark.withValues(alpha: 0.35)
                : Colors.black.withValues(alpha: 0.7),
            blurRadius: isPlaying ? 16 : 10,
            spreadRadius: isPlaying ? 2 : 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Photographic Plate Container with BoxFit.contain
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF120B06),
                border: Border.all(
                  color: const Color(0xFF7E6030),
                  width: 1.2,
                ),
              ),
              child: Center(
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
                        return const Center(
                          child: Icon(
                            Icons.portrait_rounded,
                            size: 80,
                            color: Color(0xFF7E6030),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Antique Brass Plaque
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              gradient: LedgerTheme.goldPlateGradient,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: const Color(0xFF634A1B),
                width: 1.0,
              ),
            ),
            child: Column(
              children: [
                Text(
                  entity.name.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'serif',
                    color: Color(0xFF1E1106),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  entity.plateCaption,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    color: Color(0xFF38230D),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Spoken text caption area styled on aged parchment
  Widget _buildCurrentSpokenTextCapsule() {
    final text = _tts.currentChunkText;
    final total = _tts.totalChunks;
    final current = total > 0 ? _tts.currentChunkIndex + 1 : 0;

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: LedgerTheme.parchmentPage,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: LedgerTheme.parchmentEdge,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'VOICE TRANSCRIPTION',
                style: TextStyle(
                  fontFamily: 'serif',
                  color: LedgerTheme.interrogatorRed.withValues(alpha: 0.9),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              if (total > 0)
                Text(
                  'Folio $current of $total',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    color: LedgerTheme.fadedInk,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            text.isNotEmpty
                ? text
                : 'Press the golden Play button below to initiate spoken voice recitation from the archival record.',
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 14,
              height: 1.5,
              color: LedgerTheme.charcoalInk,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Sticky audio controls anchored cleanly at the bottom
  Widget _buildStickyControlBar() {
    final isPlaying = _tts.isPlaying;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF140A05),
        border: const Border(
          top: BorderSide(
            color: Color(0xFF4A3414),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.8),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Previous Paragraph
          _buildControlButton(
            icon: Icons.skip_previous_rounded,
            tooltip: 'Previous Paragraph',
            size: 42,
            iconSize: 22,
            bgColor: const Color(0xFF26140A),
            borderColor: const Color(0xFF5A381C),
            iconColor: const Color(0xFFDCC8A0),
            onPressed: () => _tts.previousChunk(),
          ),

          // Stop Button (Crimson Wax Seal Style)
          _buildControlButton(
            icon: Icons.stop_rounded,
            tooltip: 'Stop Recitation',
            size: 48,
            iconSize: 24,
            bgColor: LedgerTheme.waxSealRed,
            borderColor: const Color(0xFFC59F48),
            iconColor: const Color(0xFFF9E498),
            onPressed: () => _tts.stop(),
          ),

          // Primary Play / Pause Button (Embossed Antique Gold)
          _buildPrimaryPlayButton(isPlaying),

          // Next Paragraph
          _buildControlButton(
            icon: Icons.skip_next_rounded,
            tooltip: 'Next Paragraph',
            size: 42,
            iconSize: 22,
            bgColor: const Color(0xFF26140A),
            borderColor: const Color(0xFF5A381C),
            iconColor: const Color(0xFFDCC8A0),
            onPressed: () => _tts.nextChunk(),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryPlayButton(bool isPlaying) {
    return GestureDetector(
      onTap: () {
        if (isPlaying) {
          _tts.pause();
        } else if (_tts.isPaused) {
          _tts.resume();
        } else {
          // Start from current entity text
          _tts.startReading(
            entityId: widget.entity.id,
            title: widget.entity.name,
            fullText: widget.entity.fullContent,
          );
        }
      },
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LedgerTheme.goldPlateGradient,
          border: Border.all(
            color: const Color(0xFF5A3F10),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: LedgerTheme.goldFoil.withValues(alpha: 0.45),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            size: 34,
            color: const Color(0xFF1E1005),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String tooltip,
    required double size,
    required double iconSize,
    required Color bgColor,
    required Color borderColor,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
      ),
    );
  }
}
