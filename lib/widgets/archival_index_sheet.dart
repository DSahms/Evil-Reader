import 'package:flutter/material.dart';
import '../models/ledger_entity.dart';
import '../theme/ledger_theme.dart';

/// Archival Index modal sheet that lets the user jump to specific chapters or parts.
class ArchivalIndexSheet extends StatelessWidget {
  final LedgerEntity entity;
  final Function(int chapterIndex) onSelectChapter;
  final VoidCallback onSelectPart1;

  const ArchivalIndexSheet({
    super.key,
    required this.entity,
    required this.onSelectChapter,
    required this.onSelectPart1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1B0E07),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        border: Border(
          top: BorderSide(color: LedgerTheme.goldFoilDark, width: 2.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: LedgerTheme.goldFoil.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  color: LedgerTheme.goldFoilLight,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'TABLE OF ARCHIVAL FOLIOS',
                    style: LedgerTheme.goldHeadingStyle.copyWith(
                      fontSize: 16,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFFB39268)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF382313), height: 1),

          // Chapter List
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              children: [
                // Part I Option
                _buildIndexItem(
                  title: 'PART I: FIRST-PERSON PERSPECTIVE',
                  subtitle: 'Confession & Spoken Narrative',
                  icon: 'I',
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelectPart1();
                  },
                ),
                const SizedBox(height: 6),

                // Part II Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    'PART II: THE INTERVIEW CHAPTERS',
                    style: TextStyle(
                      fontFamily: 'serif',
                      color: LedgerTheme.goldFoil.withValues(alpha: 0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                // Chapters
                ...entity.chapters.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final chapter = entry.value;

                  return _buildIndexItem(
                    title: chapter.title,
                    subtitle: '${chapter.qaPairs.length} Archival Dialogues',
                    icon: '${chapter.chapterNumber}',
                    onTap: () {
                      Navigator.of(context).pop();
                      onSelectChapter(idx);
                    },
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndexItem({
    required String title,
    required String subtitle,
    required String icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF28150B),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: const Color(0xFF4A2A17),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Chapter Number Badge
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [
                    Color(0xFF6B1818),
                    Color(0xFF380808),
                  ],
                ),
                border: Border.all(
                  color: LedgerTheme.goldFoilDark,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    color: Color(0xFFFDE8A5),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Titles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      color: Color(0xFFF3E7D3),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'serif',
                      color: Color(0xFF9E8569),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF8C6D42),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
