import 'package:flutter/services.dart' show rootBundle;

/// Represents a single Question & Answer dialogue pair in the interview ledger.
class QAPair {
  final String question;
  final String answer;

  const QAPair({required this.question, required this.answer});
}

/// Represents a chapter section within the interview ledger.
class LedgerChapter {
  final String title;
  final int chapterNumber;
  final String content;
  final List<QAPair> qaPairs;

  const LedgerChapter({
    required this.title,
    required this.chapterNumber,
    required this.content,
    required this.qaPairs,
  });
}

/// Represents an archival entity (Billy the Kid or The Jersey Devil)
/// with its associated dual-lane properties and extracted chapters.
class LedgerEntity {
  final String id;
  final String name;
  final String laneTitle;
  final String laneSubtitle;
  final String classification;
  final String plateCaption;
  final String imagePath;
  final String dataAssetPath;
  final String eraDate;

  String fullContent = '';
  String part1Narrative = '';
  String part2Interview = '';
  List<LedgerChapter> chapters = [];
  bool isLoaded = false;

  LedgerEntity({
    required this.id,
    required this.name,
    required this.laneTitle,
    required this.laneSubtitle,
    required this.classification,
    required this.plateCaption,
    required this.imagePath,
    required this.dataAssetPath,
    required this.eraDate,
  });

  /// The two default archival entries requested:
  static LedgerEntity billyTheKid = LedgerEntity(
    id: 'billy_the_kid',
    name: 'Billy the Kid',
    laneTitle: 'LANE 1: NON-FICTIONAL',
    laneSubtitle: 'The Lincoln County Ledger • William H. Bonney',
    classification: 'Non-Fictional Historical Record',
    plateCaption: 'ARCHIVAL PLATE I — FORT SUMNER DAGUERREOTYPE (c. 1879)',
    imagePath: 'assets/images/btk.jpg',
    dataAssetPath: 'assets/data/billy_the_kid.md',
    eraDate: 'Nov 23, 1859 — Jul 14, 1881',
  );

  static LedgerEntity jerseyDevil = LedgerEntity(
    id: 'the_jersey_devil',
    name: 'The Jersey Devil',
    laneTitle: 'LANE 2: FICTIONAL / MYTHIC',
    laneSubtitle: 'The Pine Barrens Cryptid • Folkloric Ledger',
    classification: 'Fictional & Mythic Entity Record',
    plateCaption: 'ARCHIVAL PLATE II — LEEDS APPARITION WOODCUT (c. 1909)',
    imagePath: 'assets/images/jersey_devil.jpg',
    dataAssetPath: 'assets/data/jersey_devil.md',
    eraDate: 'First Documented 1735 — Leeds Point, NJ',
  );

  /// Load and parse the markdown content from the asset file.
  Future<void> loadAsset() async {
    if (isLoaded) return;
    try {
      final raw = await rootBundle.loadString(dataAssetPath);
      fullContent = raw;
      _parseContent(raw);
      isLoaded = true;
    } catch (e) {
      // Fallback if asset load fails
      fullContent = 'Unable to open archival document: $e';
      part1Narrative = fullContent;
      part2Interview = '';
      isLoaded = true;
    }
  }

  void _parseContent(String text) {
    // Strip YAML frontmatter if present
    String body = text;
    if (body.startsWith('---')) {
      final secondIndex = body.indexOf('---', 3);
      if (secondIndex != -1) {
        body = body.substring(secondIndex + 3).trim();
      }
    }

    // Split into Part I and Part II
    final part2Pattern = RegExp(r'## Part II: The Interview', caseSensitive: false);
    final part2Match = part2Pattern.firstMatch(body);

    if (part2Match != null) {
      // Extract Part I
      final part1Raw = body.substring(0, part2Match.start).trim();
      final part1Pattern = RegExp(r'## Part I: First-Person Narrative', caseSensitive: false);
      final part1Match = part1Pattern.firstMatch(part1Raw);
      if (part1Match != null) {
        part1Narrative = part1Raw.substring(part1Match.end).trim();
      } else {
        part1Narrative = part1Raw;
      }
      // Remove trailing divider dashes if present
      if (part1Narrative.endsWith('---')) {
        part1Narrative = part1Narrative.substring(0, part1Narrative.length - 3).trim();
      }

      // Extract Part II
      final part2Raw = body.substring(part2Match.end).trim();
      part2Interview = part2Raw;

      // Parse chapters in Part II
      _parseChapters(part2Raw);
    } else {
      part1Narrative = body;
      part2Interview = '';
    }
  }

  void _parseChapters(String part2Text) {
    // Chapters follow "## Chapter X — Title"
    final chapterRegex = RegExp(r'## Chapter (\d+)\s*[—–-]\s*([^\n\r]+)');
    final matches = chapterRegex.allMatches(part2Text).toList();

    chapters = [];

    for (int i = 0; i < matches.length; i++) {
      final currentMatch = matches[i];
      final chapterNum = int.tryParse(currentMatch.group(1) ?? '0') ?? (i + 1);
      final chapterTitle = 'Chapter $chapterNum — ${currentMatch.group(2)?.trim() ?? ''}';

      final contentStart = currentMatch.end;
      final contentEnd = (i + 1 < matches.length)
          ? matches[i + 1].start
          : part2Text.length;

      final chapterBody = part2Text.substring(contentStart, contentEnd).trim();
      final qaList = _parseQAPairs(chapterBody);

      chapters.add(LedgerChapter(
        title: chapterTitle,
        chapterNumber: chapterNum,
        content: chapterBody,
        qaPairs: qaList,
      ));
    }
  }

  List<QAPair> _parseQAPairs(String text) {
    final List<QAPair> pairs = [];
    // Matches **Q:** ... followed by **A:** ...
    // Using a regex with lookaheads or iterative parsing
    final qaRegex = RegExp(
      r'\*\*Q:\*\*\s*(.*?)\s*\*\*A:\*\*\s*(.*?)(?=(\*\*Q:\*\*|$))',
      dotAll: true,
    );

    for (final match in qaRegex.allMatches(text)) {
      final q = match.group(1)?.trim() ?? '';
      final a = match.group(2)?.trim() ?? '';
      if (q.isNotEmpty || a.isNotEmpty) {
        pairs.add(QAPair(question: q, answer: a));
      }
    }

    return pairs;
  }
}
