import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/ledger_entity.dart';
import 'services/tts_service.dart';
import 'theme/ledger_theme.dart';
import 'widgets/archival_index_sheet.dart';
import 'widgets/immersive_audio_view.dart';
import 'widgets/leather_frame.dart';
import 'widgets/parchment_reader.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: LedgerTheme.leatherDarkest,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const EvilReaderApp());
}

class EvilReaderApp extends StatelessWidget {
  const EvilReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Reader: Interviews with Evil',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: LedgerTheme.leatherDarkest,
        primaryColor: LedgerTheme.goldFoil,
        colorScheme: const ColorScheme.dark(
          primary: LedgerTheme.goldFoil,
          secondary: LedgerTheme.waxSealRed,
          surface: LedgerTheme.leatherBase,
        ),
      ),
      home: const LedgerMainScreen(),
    );
  }
}

class LedgerMainScreen extends StatefulWidget {
  const LedgerMainScreen({super.key});

  @override
  State<LedgerMainScreen> createState() => _LedgerMainScreenState();
}

class _LedgerMainScreenState extends State<LedgerMainScreen> {
  // Current active lane: 0 = Billy the Kid (Non-Fiction), 1 = The Jersey Devil (Mythic/Fiction)
  int _activeLaneIndex = 0;

  late final LedgerEntity _billyEntity;
  late final LedgerEntity _jerseyEntity;

  final ScrollController _billyScrollController = ScrollController();
  final ScrollController _jerseyScrollController = ScrollController();

  final TtsService _tts = TtsService();
  bool _isAudioModeActive = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _billyEntity = LedgerEntity.billyTheKid;
    _jerseyEntity = LedgerEntity.jerseyDevil;
    _tts.addListener(_onTtsStateChange);
    _loadAllEntities();
  }

  void _onTtsStateChange() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadAllEntities() async {
    await Future.wait([
      _billyEntity.loadAsset(),
      _jerseyEntity.loadAsset(),
    ]);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tts.removeListener(_onTtsStateChange);
    _billyScrollController.dispose();
    _jerseyScrollController.dispose();
    super.dispose();
  }

  LedgerEntity get _currentEntity =>
      _activeLaneIndex == 0 ? _billyEntity : _jerseyEntity;

  ScrollController get _currentScrollController =>
      _activeLaneIndex == 0 ? _billyScrollController : _jerseyScrollController;

  void _startAudioForEntity(LedgerEntity entity) {
    _tts.startReading(
      entityId: entity.id,
      title: entity.name,
      fullText: entity.fullContent,
    );
    setState(() {
      _isAudioModeActive = true;
    });
  }

  void _startAudioForSection(String title, String text) {
    _tts.startReading(
      entityId: _currentEntity.id,
      title: title,
      fullText: text,
    );
    setState(() {
      _isAudioModeActive = true;
    });
  }

  void _toggleAudioMode() {
    if (!_isAudioModeActive) {
      if (_tts.isStopped) {
        _tts.startReading(
          entityId: _currentEntity.id,
          title: _currentEntity.name,
          fullText: _currentEntity.fullContent,
        );
      }
      setState(() {
        _isAudioModeActive = true;
      });
    } else {
      setState(() {
        _isAudioModeActive = false;
      });
    }
  }

  void _openChapterIndex() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ArchivalIndexSheet(
        entity: _currentEntity,
        onSelectPart1: () {
          _currentScrollController.animateTo(
            320.0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        onSelectChapter: (chapterIndex) {
          // Scroll toward estimated chapter position
          final targetOffset = 500.0 + (chapterIndex * 480.0);
          _currentScrollController.animateTo(
            targetOffset.clamp(
              0.0,
              _currentScrollController.position.maxScrollExtent,
            ),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isAudioModeActive) {
      return ImmersiveAudioView(
        entity: _currentEntity,
        onClose: () {
          setState(() {
            _isAudioModeActive = false;
          });
        },
      );
    }

    return Scaffold(
      backgroundColor: LedgerTheme.leatherDarkest,
      body: SafeArea(
        child: LeatherFrame(
          child: Column(
            children: [
              // Top Archival Header
              ArchivalLedgerHeader(
                title: 'The Reader: Interviews with Evil',
                subtitle: 'Ancient Archaeologist Ledger • Secret Archive',
                onIndexTap: _openChapterIndex,
                onPlayAudio: _toggleAudioMode,
                isAudioPlaying: _tts.isPlaying,
              ),

              // Dual-Lane Switcher Tabs
              _buildDualLaneSelector(),

              // Active Mini Player Bar if background TTS is active
              if (_tts.isPlaying || _tts.isPaused)
                _buildMiniAudioBar(),

              // Main Reading Area
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: LedgerTheme.goldFoil,
                        ),
                      )
                    : AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        child: ParchmentReader(
                          key: ValueKey<int>(_activeLaneIndex),
                          entity: _currentEntity,
                          scrollController: _currentScrollController,
                          onOpenIndex: _openChapterIndex,
                          onTriggerAudio: () => _startAudioForEntity(_currentEntity),
                          onPlaySectionAudio: _startAudioForSection,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniAudioBar() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isAudioModeActive = true;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2B160A),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: LedgerTheme.goldFoilDark, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(
              Icons.graphic_eq_rounded,
              color: LedgerTheme.goldFoilLight,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'VOICE RECITATION: ${_tts.currentTitle.toUpperCase()}',
                style: const TextStyle(
                  fontFamily: 'serif',
                  color: Color(0xFFF9E498),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(
                _tts.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: LedgerTheme.goldFoilLight,
                size: 20,
              ),
              onPressed: () {
                if (_tts.isPlaying) {
                  _tts.pause();
                } else {
                  _tts.resume();
                }
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.open_in_full_rounded,
                color: Color(0xFFDCC8A0),
                size: 16,
              ),
              tooltip: 'Expand Immersive Audio Mode',
              onPressed: () {
                setState(() {
                  _isAudioModeActive = true;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Dual-lane switchable interface separating "Non-Fictional" and "Fictional" entities.
  Widget _buildDualLaneSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF160D07),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF4A2A14),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Lane 1: Billy the Kid (Non-Fictional)
          Expanded(
            child: _buildLaneTab(
              laneNumber: 'LANE I',
              category: 'NON-FICTIONAL',
              title: 'Billy the Kid',
              isSelected: _activeLaneIndex == 0,
              icon: Icons.history_edu_rounded,
              onTap: () {
                if (_activeLaneIndex != 0) {
                  setState(() => _activeLaneIndex = 0);
                }
              },
            ),
          ),
          const SizedBox(width: 6),
          // Lane 2: The Jersey Devil (Fictional / Mythic)
          Expanded(
            child: _buildLaneTab(
              laneNumber: 'LANE II',
              category: 'FICTIONAL / MYTH',
              title: 'The Jersey Devil',
              isSelected: _activeLaneIndex == 1,
              icon: Icons.auto_awesome_rounded,
              onTap: () {
                if (_activeLaneIndex != 1) {
                  setState(() => _activeLaneIndex = 1);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaneTab({
    required String laneNumber,
    required String category,
    required String title,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4B2A15),
                    Color(0xFF331B0B),
                    Color(0xFF261205),
                  ],
                )
              : null,
          color: isSelected ? null : const Color(0xFF1E1108),
          border: Border.all(
            color: isSelected
                ? LedgerTheme.goldFoil
                : const Color(0xFF3B2312),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: LedgerTheme.goldFoilDark.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 13,
                  color: isSelected
                      ? LedgerTheme.goldFoilLight
                      : const Color(0xFF8C7359),
                ),
                const SizedBox(width: 4),
                Text(
                  '$laneNumber • $category',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                    color: isSelected
                        ? const Color(0xFFF9E498)
                        : const Color(0xFF8C7359),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
                color: isSelected
                    ? Colors.white
                    : const Color(0xFFB59E87),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
