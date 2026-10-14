import 'package:flutter/material.dart';
import '../models/ledger_entity.dart';
import '../theme/ledger_theme.dart';
import 'vintage_portrait_plate.dart';

/// The aged parchment scrollable reading surface.
/// Features sepia parchment gradients, archival margin line,
/// gold-foil headers, ornamental chapter dividers, drop caps,
/// and distinctive Q&A dialogue formatting.
class ParchmentReader extends StatefulWidget {
  final LedgerEntity entity;
  final ScrollController scrollController;
  final VoidCallback onOpenIndex;
  final VoidCallback onTriggerAudio;
  final Function(String title, String text) onPlaySectionAudio;

  const ParchmentReader({
    super.key,
    required this.entity,
    required this.scrollController,
    required this.onOpenIndex,
    required this.onTriggerAudio,
    required this.onPlaySectionAudio,
  });

  @override
  State<ParchmentReader> createState() => _ParchmentReaderState();
}

class _ParchmentReaderState extends State<ParchmentReader> {
  // 0 = All Sections, 1 = Part I (Narrative), 2 = Part II (Interview Q&A)
  int _selectedFilter = 0;
  double _fontScale = 1.0;

  @override
  Widget build(BuildContext context) {
    final entity = widget.entity;

    return Container(
      decoration: BoxDecoration(
        color: LedgerTheme.parchmentPage,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: LedgerTheme.parchmentEdge,
          width: 1.5,
        ),
        boxShadow: LedgerTheme.ledgerDepthShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            // Aged parchment background texture gradient
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LedgerTheme.parchmentGradient,
                ),
              ),
            ),

            // Left archival red ledger margin line
            Positioned(
              left: 28,
              top: 0,
              bottom: 0,
              child: Container(
                width: 1,
                color: LedgerTheme.parchmentRedMargin,
              ),
            ),

            // Scrollable Content
            Column(
              children: [
                // Reader Tooling Bar (Filter & Font Size Adjusters)
                _buildReaderControlBar(),

                // Scrollable Ledger Pages
                Expanded(
                  child: Scrollbar(
                    controller: widget.scrollController,
                    thumbVisibility: false,
                    child: ListView(
                      controller: widget.scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
                      children: [
                        // Entity Archival Portrait Mounted Plate
                        VintagePortraitPlate(entity: entity),

                        const SizedBox(height: 16),

                        // Parchment Document Title Banner
                        _buildArchivalBanner(entity),

                        const SizedBox(height: 24),

                        // Render Content based on filter
                        if (_selectedFilter == 0 || _selectedFilter == 1) ...[
                          _buildPart1Section(entity),
                          if (_selectedFilter == 0) ...[
                            const SizedBox(height: 32),
                            _buildSectionSeparator(),
                            const SizedBox(height: 32),
                          ],
                        ],

                        if (_selectedFilter == 0 || _selectedFilter == 2) ...[
                          _buildPart2Section(entity),
                        ],

                        const SizedBox(height: 48),
                        _buildLedgerSealFooter(entity),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Controls bar for switching between Full Ledger / Narrative / Q&A and adjusting font size.
  Widget _buildReaderControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE9DCBF),
        border: Border(
          bottom: BorderSide(
            color: LedgerTheme.parchmentEdge,
            width: 1.2,
          ),
        ),
      ),
      child: Row(
        children: [
          // Filter Tabs (All / Narrative / Interview)
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildFilterPill('FULL LEDGER', 0),
                _buildFilterPill('PART I: NARRATIVE', 1),
                _buildFilterPill('PART II: INTERVIEW', 2),
              ],
            ),
          ),

          // Font Scaling Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIconButton(
                icon: Icons.remove,
                tooltip: 'Decrease text size',
                onPressed: () {
                  if (_fontScale > 0.85) {
                    setState(() => _fontScale -= 0.1);
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  '${(_fontScale * 100).toInt()}%',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: LedgerTheme.umberInk,
                  ),
                ),
              ),
              _buildIconButton(
                icon: Icons.add,
                tooltip: 'Increase text size',
                onPressed: () {
                  if (_fontScale < 1.45) {
                    setState(() => _fontScale += 0.1);
                  }
                },
              ),
              const SizedBox(width: 4),
              // Audio Mode button
              _buildIconButton(
                icon: Icons.volume_up_rounded,
                tooltip: 'Listen to Archival Recitation',
                highlighted: true,
                onPressed: widget.onTriggerAudio,
              ),
              const SizedBox(width: 2),
              // Index button
              _buildIconButton(
                icon: Icons.list_alt_rounded,
                tooltip: 'Table of Contents',
                onPressed: widget.onOpenIndex,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String label, int index) {
    final isSelected = _selectedFilter == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B2113) : const Color(0xFFDFCEAE),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: isSelected ? LedgerTheme.goldFoilDark : const Color(0xFFB59D77),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: isSelected ? const Color(0xFFFDE8A5) : const Color(0xFF4A341E),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    bool highlighted = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(3),
      child: Container(
        padding: const EdgeInsets.all(4),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: highlighted ? const Color(0xFF2E170A) : const Color(0xFFDFCFAF),
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: highlighted ? LedgerTheme.goldFoil : const Color(0xFFB89E77),
            width: highlighted ? 1.2 : 0.8,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: highlighted ? LedgerTheme.goldFoilLight : const Color(0xFF362010),
        ),
      ),
    );
  }

  Widget _buildArchivalBanner(LedgerEntity entity) {
    return Column(
      children: [
        Text(
          'ARCHAEOLOGICAL DOSSIER',
          style: TextStyle(
            fontFamily: 'serif',
            color: LedgerTheme.umberInk.withValues(alpha: 0.8),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 3.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          entity.name.toUpperCase(),
          style: TextStyle(
            fontFamily: 'serif',
            color: const Color(0xFF2E170B),
            fontSize: 26 * _fontScale,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
            shadows: const [
              Shadow(
                color: Color(0x33000000),
                offset: Offset(0, 1.5),
                blurRadius: 2,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          entity.laneSubtitle,
          style: TextStyle(
            fontFamily: 'serif',
            fontStyle: FontStyle.italic,
            color: LedgerTheme.fadedInk,
            fontSize: 13 * _fontScale,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        const Text(
          '── ❖ ──',
          style: TextStyle(
            color: Color(0xFF8B6B38),
            fontSize: 16,
            letterSpacing: 4.0,
          ),
        ),
      ],
    );
  }

  /// Renders Part I: First-Person Narrative with drop cap styling.
  Widget _buildPart1Section(LedgerEntity entity) {
    final text = entity.part1Narrative;
    if (text.isEmpty) return const SizedBox.shrink();

    final paragraphs = text
        .split('\n\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'PART I: FIRST-PERSON PERSPECTIVE',
          subtitle: 'Original Archival Recording / Spoken Account',
          onPlay: () => widget.onPlaySectionAudio(
            'PART I: FIRST-PERSON PERSPECTIVE',
            text,
          ),
        ),
        const SizedBox(height: 16),

        // Paragraphs with drop cap on the very first paragraph
        ...paragraphs.asMap().entries.map((entry) {
          final index = entry.key;
          final paragraph = entry.value;

          if (index == 0 && paragraph.isNotEmpty) {
            return _buildDropCapParagraph(paragraph);
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: Text(
              paragraph,
              style: LedgerTheme.parchmentBodyStyle.copyWith(
                fontSize: 16 * _fontScale,
                height: 1.7,
              ),
            ),
          );
        }),
      ],
    );
  }

  /// Renders Part II: The Interview Q&A with magazine/editorial formatting.
  Widget _buildPart2Section(LedgerEntity entity) {
    if (entity.chapters.isEmpty) {
      // Fallback if not parsed into chapters
      return Text(
        entity.part2Interview,
        style: LedgerTheme.parchmentBodyStyle.copyWith(fontSize: 16 * _fontScale),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'PART II: THE INTERVIEW',
          subtitle: 'Complete Archival Transcripts & Dialogues',
        ),
        const SizedBox(height: 20),

        // Chapters
        ...entity.chapters.map((chapter) => _buildChapterView(chapter)),
      ],
    );
  }

  Widget _buildChapterView(LedgerChapter chapter) {
    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chapter Header Plaque
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEADBBE),
              borderRadius: BorderRadius.circular(3),
              border: Border(
                left: BorderSide(
                  color: LedgerTheme.interrogatorRed,
                  width: 3.5,
                ),
                bottom: BorderSide(
                  color: LedgerTheme.parchmentEdge,
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    chapter.title.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'serif',
                      fontSize: 14 * _fontScale,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: const Color(0xFF381F0E),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => widget.onPlaySectionAudio(
                    chapter.title,
                    chapter.content,
                  ),
                  borderRadius: BorderRadius.circular(3),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E170A),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: LedgerTheme.goldFoilDark,
                        width: 0.8,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_arrow_rounded,
                          size: 13,
                          color: LedgerTheme.goldFoilLight,
                        ),
                        SizedBox(width: 2),
                        Text(
                          'PLAY',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: LedgerTheme.goldFoilLight,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Q&A Pairs
          if (chapter.qaPairs.isNotEmpty) ...[
            ...chapter.qaPairs.map((qa) => _buildQABlock(qa)),
          ] else ...[
            // In case raw text without Q&A markers
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                chapter.content,
                style: LedgerTheme.parchmentBodyStyle.copyWith(
                  fontSize: 16 * _fontScale,
                  height: 1.7,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Formats an individual Question & Answer dialogue block.
  Widget _buildQABlock(QAPair qa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Row
          if (qa.question.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(right: 8, top: 1),
                    decoration: BoxDecoration(
                      color: LedgerTheme.interrogatorRed,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Text(
                      'Q',
                      style: TextStyle(
                        fontFamily: 'serif',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      qa.question,
                      style: LedgerTheme.questionStyle.copyWith(
                        fontSize: 15.5 * _fontScale,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Answer Row with left ledger accent line
          if (qa.answer.isNotEmpty)
            Container(
              padding: const EdgeInsets.only(left: 12, top: 2, bottom: 4),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: Color(0xFFC8B38E),
                    width: 2.0,
                  ),
                ),
              ),
              child: Text(
                qa.answer,
                style: LedgerTheme.answerStyle.copyWith(
                  fontSize: 16 * _fontScale,
                  height: 1.72,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Renders a decorative drop cap on the opening letter of a paragraph.
  Widget _buildDropCapParagraph(String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    final firstChar = text.substring(0, 1);
    final restOfText = text.substring(1);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drop cap letter
          Container(
            padding: const EdgeInsets.only(right: 6, bottom: 2),
            child: Text(
              firstChar,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 48 * _fontScale,
                fontWeight: FontWeight.bold,
                height: 0.85,
                color: LedgerTheme.interrogatorRed,
                shadows: const [
                  Shadow(
                    color: Color(0x33000000),
                    offset: Offset(1, 1),
                    blurRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          // Remaining text of the paragraph
          Expanded(
            child: Text(
              restOfText,
              style: LedgerTheme.parchmentBodyStyle.copyWith(
                fontSize: 16 * _fontScale,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    VoidCallback? onPlay,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2C160B),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: LedgerTheme.goldFoilDark,
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    color: LedgerTheme.goldFoilLight,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (onPlay != null)
                InkWell(
                  onTap: onPlay,
                  borderRadius: BorderRadius.circular(3),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F0F06),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: LedgerTheme.goldFoil,
                        width: 0.8,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.volume_up_rounded,
                          size: 13,
                          color: LedgerTheme.goldFoilLight,
                        ),
                        SizedBox(width: 3),
                        Text(
                          'LISTEN',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: LedgerTheme.goldFoilLight,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'serif',
              color: Color(0xFFC7B194),
              fontSize: 11,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSeparator() {
    return const Center(
      child: Text(
        '══ ❖ ⚜ ❖ ══',
        style: TextStyle(
          color: Color(0xFF9C7D4A),
          fontSize: 16,
          letterSpacing: 4.0,
        ),
      ),
    );
  }

  Widget _buildLedgerSealFooter(LedgerEntity entity) {
    return Column(
      children: [
        const Text(
          '⚜ ❦ ⚜',
          style: TextStyle(
            color: Color(0xFF8B6B38),
            fontSize: 22,
            letterSpacing: 6.0,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'ARCHIVAL REPOSITORY SEAL • CONFIDENTIAL',
          style: TextStyle(
            fontFamily: 'serif',
            color: LedgerTheme.fadedInk.withValues(alpha: 0.7),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Document ID: ${entity.id.toUpperCase()} • All Rights Reserved',
          style: TextStyle(
            fontFamily: 'serif',
            color: LedgerTheme.fadedInk.withValues(alpha: 0.6),
            fontSize: 9,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }
}
