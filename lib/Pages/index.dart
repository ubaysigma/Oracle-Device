import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Widget/index_logo.dart';
import '../Widget/scramble_text.dart';
import '../controller/indexcontroller.dart';
import '../services/audio_service.dart';

class TheCommand extends StatefulWidget {
  const TheCommand({super.key});

  @override
  State<TheCommand> createState() => _TheCommandState();
}

class _TheCommandState extends State<TheCommand> with WidgetsBindingObserver {
  late final AppLifecycleListener _lifecycleListener;
  final PrescriptAudioService _audioService = PrescriptAudioService();
  final GlobalKey<ScrambleTextState> _scrambleKey = GlobalKey<ScrambleTextState>();
  final IndexController _controller = Get.put(IndexController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Stop audio immediately when switching tabs / minimizing / leaving the app
    _lifecycleListener = AppLifecycleListener(
      onHide: () => _audioService.stopAll(),
      onPause: () => _audioService.stopAll(),
      onInactive: () => _audioService.stopAll(),
      onDetach: () => _audioService.stopAll(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _audioService.stopAll();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lifecycleListener.dispose();
    _audioService.stopAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: SizedBox.expand(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ========================================================
                    // 1. ICON (Top / Upper Center)
                    // Loaded from assets with fallback
                    // ========================================================
                    _buildIcon(),

                    const SizedBox(height: 38),

                    // ========================================================
                    // 2. TEKS (Bottom / Lower Center)
                    // Button (Initial) or Glowing Cyan Pixel Scramble Text (Active)
                    // ========================================================
                    _buildTextStage(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Icon widget loaded from assets/index_icon.png
  Widget _buildIcon() {
    return GestureDetector(
      onDoubleTap: () {
        // Double-tap shortcut to reset for testing
        _audioService.stopAll();
        _controller.resetForTesting();
      },
      child: Container(
        width: 120,
        height: 120,
        alignment: Alignment.center,
        child: Image.asset(
          'assets/index_icon.png',
          width: 120,
          height: 120,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            // Fallback in case asset is missing
            return const IndexLogo(size: 110);
          },
        ),
      ),
    );
  }

  /// Text Stage: Initial Button or Active Scramble Text
  Widget _buildTextStage() {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const SizedBox.shrink();
      }

      if (!_controller.hasReceived.value) {
        // Initial State: Click to Receive Button in Cyan Pixel Font
        return _CyanPixelReceiveButton(
          onPressed: () {
            _controller.receive();
          },
        );
      }

      // Active State: Glowing Light Blue / Cyan Pixel Scramble Text
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => _scrambleKey.currentState?.replay(),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Tooltip(
                message: 'Click to replay directive transmission',
                child: ScrambleText(
                  key: _scrambleKey,
                  text: _controller.prescriptText.value,
                  textAlign: TextAlign.center,
                  duration: const Duration(milliseconds: 2200),
                  onStart: () {
                    _audioService.playScramble();
                  },
                  onComplete: () {
                    _audioService.playResolved();
                  },
                  // Dominant Glowing Light Blue / Cyan Pixel Font
                  style: GoogleFonts.vt323(
                    fontSize: 28,
                    height: 1.45,
                    letterSpacing: 1.4,
                    color: const Color(0xFF00F0FF),
                    shadows: const [
                      Shadow(color: Color(0xFF00F0FF), blurRadius: 10),
                      Shadow(color: Color(0xFF00A2FF), blurRadius: 22),
                      Shadow(color: Color(0xFF0066FF), blurRadius: 36),
                    ],
                  ),
                  scrambleStyle: GoogleFonts.vt323(
                    fontSize: 28,
                    height: 1.45,
                    letterSpacing: 1.4,
                    color: const Color(0xFF087C8F),
                    shadows: const [
                      Shadow(color: Color(0xFF054550), blurRadius: 8),
                    ],
                  ),
                  frontierStyle: GoogleFonts.vt323(
                    fontSize: 29,
                    height: 1.45,
                    letterSpacing: 1.4,
                    color: const Color(0xFFE6FFFF),
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(color: Color(0xFFFFFFFF), blurRadius: 12),
                      Shadow(color: Color(0xFF00F0FF), blurRadius: 26),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Mandatory Execution tag in glowing cyan pixel font
          Text(
            'EXECUTION IS MANDATORY.',
            textAlign: TextAlign.center,
            style: GoogleFonts.silkscreen(
              fontSize: 11,
              letterSpacing: 3.5,
              color: const Color(0xFF00D2EA),
              shadows: const [
                Shadow(color: Color(0xFF00D2EA), blurRadius: 8),
                Shadow(color: Color(0xFF0088FF), blurRadius: 16),
              ],
            ),
          ),
        ],
      );
    });
  }
}

/// Cyan Pixel Button matching the wireframe and style
class _CyanPixelReceiveButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _CyanPixelReceiveButton({required this.onPressed});

  @override
  State<_CyanPixelReceiveButton> createState() => _CyanPixelReceiveButtonState();
}

class _CyanPixelReceiveButtonState extends State<_CyanPixelReceiveButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          decoration: BoxDecoration(
            color: _isHovered ? const Color(0xFF00222B) : Colors.transparent,
            border: Border.all(
              color: _isHovered ? const Color(0xFF00FFFF) : const Color(0xFF00A8C6).withValues(alpha: 0.6),
              width: 1.2,
            ),
            boxShadow: _isHovered
                ? const [
                    BoxShadow(
                      color: Color(0x5500FFFF),
                      blurRadius: 16,
                      spreadRadius: 1,
                    ),
                  ]
                : [],
          ),
          child: Text(
            '- CLICK TO RECEIVE -',
            textAlign: TextAlign.center,
            style: GoogleFonts.silkscreen(
              fontSize: 13,
              letterSpacing: _isHovered ? 2.8 : 2.0,
              color: _isHovered ? const Color(0xFFE0FFFF) : const Color(0xFF00F0FF),
              fontWeight: FontWeight.bold,
              shadows: const [
                Shadow(color: Color(0xFF00F0FF), blurRadius: 10),
                Shadow(color: Color(0xFF0088FF), blurRadius: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
