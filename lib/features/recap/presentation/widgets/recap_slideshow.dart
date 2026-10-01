import 'package:flutter/material.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_theme.dart';
import '../recap_slide_data.dart';
import 'recap_progress_bars.dart';
import 'recap_slide.dart';

/// Story-style player for the recap [slides]: auto-advances every
/// [slideDuration], tap the right side to skip ahead or the left to go
/// back, swipe between slides, hold to pause.
///
/// With [MediaQuery.disableAnimations] on it never auto-advances — the
/// user moves through it by tapping/swiping only.
class RecapSlideshow extends StatefulWidget {
  const RecapSlideshow({
    required this.slides,
    required this.onClose,
    super.key,
  });

  final List<RecapSlideData> slides;

  /// Called from the close button and the last slide's "Done".
  final VoidCallback onClose;

  /// How long each slide stays up before auto-advancing.
  static const Duration slideDuration = Duration(seconds: 7);

  @override
  State<RecapSlideshow> createState() => _RecapSlideshowState();
}

class _RecapSlideshowState extends State<RecapSlideshow>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final AnimationController _progress = AnimationController(
    vsync: this,
    duration: RecapSlideshow.slideDuration,
  )..addStatusListener(_onProgressStatus);
  int _page = 0;
  bool _autoAdvance = true;

  bool get _isLast => _page == widget.slides.length - 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _autoAdvance = !MediaQuery.disableAnimationsOf(context);
    if (!_autoAdvance) {
      _progress.value = 1;
    } else if (!_progress.isAnimating && _progress.value == 0) {
      _progress.forward();
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onProgressStatus(AnimationStatus status) {
    // Without auto-advance the bar is only ever set full, never played.
    if (!_autoAdvance || status != AnimationStatus.completed || _isLast) return;
    _goTo(_page + 1);
  }

  void _goTo(int page) {
    if (page < 0 || page >= widget.slides.length) return;
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPageChanged(int page) {
    setState(() => _page = page);
    if (_autoAdvance) _progress.forward(from: 0);
  }

  void _onTapUp(TapUpDetails details) {
    final width = MediaQuery.sizeOf(context).width;
    _goTo(details.globalPosition.dx < width / 3 ? _page - 1 : _page + 1);
  }

  void _pause() => _progress.stop();

  void _resume() {
    if (_autoAdvance) _progress.forward();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.sm,
              Spacing.sm,
              0,
            ),
            child: _TopBar(
              count: widget.slides.length,
              current: _page,
              progress: _progress,
              onClose: widget.onClose,
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: _onTapUp,
              onLongPressStart: (_) => _pause(),
              onLongPressEnd: (_) => _resume(),
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.slides.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) => _ScrollableSlide(
                  data: widget.slides[index],
                  onDone: widget.onClose,
                ),
              ),
            ),
          ),
          _TapHint(visible: !_isLast),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.count,
    required this.current,
    required this.progress,
    required this.onClose,
  });

  final int count;
  final int current;
  final Animation<double> progress;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RecapProgressBars(
            count: count,
            current: current,
            progress: progress,
          ),
        ),
        IconButton(
          tooltip: context.l10n.recapClose,
          onPressed: onClose,
          icon: const Icon(Icons.close, color: Colors.white70),
        ),
      ],
    );
  }
}

/// Centers the slide, but lets it scroll on a short screen (or with large
/// text) instead of overflowing.
class _ScrollableSlide extends StatelessWidget {
  const _ScrollableSlide({required this.data, required this.onDone});

  final RecapSlideData data;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(
            child: RecapSlide(data: data, onDone: onDone),
          ),
        ),
      ),
    );
  }
}

class _TapHint extends StatelessWidget {
  const _TapHint({required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) {
    final glass = Theme.of(context).extension<GlassTheme>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          context.l10n.recapTapHint,
          style: TextStyle(color: glass.textHint, fontSize: 12),
        ),
      ),
    );
  }
}
