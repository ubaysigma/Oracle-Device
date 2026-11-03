import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';

/// A widget that reveals text with a cyberpunk / retro terminal scramble decoding effect.
class ScrambleText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextStyle? scrambleStyle;
  final TextStyle? frontierStyle;
  final TextAlign textAlign;
  final Duration duration;
  final Duration delay;
  final String chars;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;
  final bool autoStart;

  const ScrambleText({
    super.key,
    required this.text,
    this.style,
    this.scrambleStyle,
    this.frontierStyle,
    this.textAlign = TextAlign.center,
    this.duration = const Duration(milliseconds: 2200),
    this.delay = Duration.zero,
    this.chars = r'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_+-=[]{}|;:,.<>?/~',
    this.onStart,
    this.onComplete,
    this.autoStart = true,
  });

  @override
  State<ScrambleText> createState() => ScrambleTextState();
}

class ScrambleTextState extends State<ScrambleText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _delayTimer;
  Timer? _tickTimer;
  final math.Random _random = math.Random();

  bool _isStarted = false;
  bool _isCompleted = false;

  final Map<int, String> _scrambleCharMap = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _stopTickTimer();
        // Cut off scramble sound immediately the instant animation completes
        PrescriptAudioService().stopScramble();
        if (mounted) {
          setState(() {
            _isCompleted = true;
          });
        }
        widget.onComplete?.call();
      }
    });

    if (widget.autoStart) {
      _scheduleStart();
    }
  }

  void _scheduleStart() {
    if (widget.delay == Duration.zero) {
      _start();
    } else {
      _delayTimer?.cancel();
      _delayTimer = Timer(widget.delay, () {
        if (mounted) _start();
      });
    }
  }

  void _start() {
    _delayTimer?.cancel();
    if (!mounted) return;
    _regenerateRandomChars();
    setState(() {
      _isStarted = true;
      _isCompleted = false;
    });
    _controller.reset();
    _controller.forward();
    _startTickTimer();
    widget.onStart?.call();
  }

  /// Public method to replay the scramble animation
  void replay() {
    PrescriptAudioService().stopScramble();
    _start();
  }

  void _startTickTimer() {
    _stopTickTimer();
    // Rapidly randomize characters every 40ms during animation
    _tickTimer = Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (mounted && _controller.isAnimating) {
        _regenerateRandomChars();
        setState(() {});
      }
    });
  }

  void _stopTickTimer() {
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  void _regenerateRandomChars() {
    final chars = widget.chars;
    final length = widget.text.length;
    for (int i = 0; i < length; i++) {
      _scrambleCharMap[i] = chars[_random.nextInt(chars.length)];
    }
  }

  String _getScrambleChar(int index) {
    if (!_scrambleCharMap.containsKey(index)) {
      final chars = widget.chars;
      _scrambleCharMap[index] = chars[_random.nextInt(chars.length)];
    }
    return _scrambleCharMap[index]!;
  }

  @override
  void didUpdateWidget(ScrambleText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _scheduleStart();
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    _stopTickTimer();
    PrescriptAudioService().stopScramble();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If waiting for delay, keep transparent placeholder to maintain dimensions
    if (!_isStarted) {
      return Opacity(
        opacity: 0.0,
        child: Text(
          widget.text,
          textAlign: widget.textAlign,
          style: widget.style,
        ),
      );
    }

    // When completed or empty, display standard clean text
    if (_isCompleted || widget.text.isEmpty) {
      return Text(
        widget.text,
        textAlign: widget.textAlign,
        style: widget.style,
      );
    }

    final fullText = widget.text;
    final int length = fullText.length;
    final double progress = _animation.value;

    // Phased reveal:
    // 0.00 to 0.12: Full encrypted cipher scramble
    // 0.12 to 0.94: Progressive left-to-right decode sweep
    // 0.94 to 1.00: Final lock into target text
    final double sweepProgress = ((progress - 0.10) / 0.84).clamp(0.0, 1.0);
    final int resolvedCount = (sweepProgress * length).floor();

    final TextStyle resolvedStyle = widget.style ??
        GoogleFonts.vt323(
          fontSize: 24,
          color: const Color(0xFF00F0FF),
          shadows: const [
            Shadow(color: Color(0xFF00F0FF), blurRadius: 10),
            Shadow(color: Color(0xFF0099FF), blurRadius: 20),
          ],
        );

    final TextStyle scrambleStyle = widget.scrambleStyle ??
        resolvedStyle.copyWith(
          color: const Color(0xFF0B788A),
          shadows: const [
            Shadow(color: Color(0xFF054550), blurRadius: 8),
          ],
        );

    final TextStyle frontierStyle = widget.frontierStyle ??
        resolvedStyle.copyWith(
          color: const Color(0xFFE0FFFF),
          fontWeight: FontWeight.bold,
          shadows: const [
            Shadow(color: Color(0xFFE0FFFF), blurRadius: 14),
            Shadow(color: Color(0xFF00F0FF), blurRadius: 24),
          ],
        );

    final List<TextSpan> spans = [];

    // 1. Resolved characters
    if (resolvedCount > 0) {
      spans.add(
        TextSpan(
          text: fullText.substring(0, resolvedCount),
          style: resolvedStyle,
        ),
      );
    }

    // 2. Decoding Frontier (1-2 characters right at the sweep edge)
    final int frontierEnd = math.min(length, resolvedCount + 2);
    if (resolvedCount < length && resolvedCount < frontierEnd) {
      final buffer = StringBuffer();
      for (int i = resolvedCount; i < frontierEnd; i++) {
        final char = fullText[i];
        if (char == ' ' || char == '\n' || char == '\t') {
          buffer.write(char);
        } else {
          buffer.write(_getScrambleChar(i));
        }
      }
      spans.add(
        TextSpan(
          text: buffer.toString(),
          style: frontierStyle,
        ),
      );
    }

    // 3. Unresolved scrambled characters
    if (frontierEnd < length) {
      final buffer = StringBuffer();
      for (int i = frontierEnd; i < length; i++) {
        final char = fullText[i];
        if (char == ' ' || char == '\n' || char == '\t') {
          buffer.write(char);
        } else {
          buffer.write(_getScrambleChar(i));
        }
      }
      spans.add(
        TextSpan(
          text: buffer.toString(),
          style: scrambleStyle,
        ),
      );
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: widget.textAlign,
    );
  }
}
