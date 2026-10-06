import 'dart:async';

import 'package:flutter/material.dart';

import 'login_feature_slide.dart';

/// Swipeable tour of the app's features on the login screen, with a page
/// indicator tinted by the current feature's accent.
///
/// Advances on its own every [autoAdvanceInterval] until the user swipes;
/// a swipe restarts the countdown so it never yanks a page they're reading.
/// With `MediaQuery.disableAnimations` it holds still: no idle motion and
/// no auto-advance — the user swipes through it themselves.
class LoginFeatureCarousel extends StatefulWidget {
  const LoginFeatureCarousel({required this.features, super.key});

  final List<LoginFeature> features;

  /// How long each slide stays before moving to the next one.
  static const Duration autoAdvanceInterval = Duration(seconds: 4);

  @override
  State<LoginFeatureCarousel> createState() => _LoginFeatureCarouselState();
}

class _LoginFeatureCarouselState extends State<LoginFeatureCarousel>
    with SingleTickerProviderStateMixin {
  final _pageController = PageController();
  late final AnimationController _idle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  Timer? _autoAdvance;
  int _page = 0;
  bool _animationsDisabled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animationsDisabled = MediaQuery.disableAnimationsOf(context);
    if (_animationsDisabled) {
      _idle
        ..stop()
        ..value = 0;
      _autoAdvance?.cancel();
    } else {
      if (!_idle.isAnimating) _idle.repeat(reverse: true);
      _restartAutoAdvance();
    }
  }

  @override
  void dispose() {
    _autoAdvance?.cancel();
    _idle.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _restartAutoAdvance() {
    _autoAdvance?.cancel();
    if (_animationsDisabled) return;
    _autoAdvance = Timer(LoginFeatureCarousel.autoAdvanceInterval, _advance);
  }

  void _advance() {
    if (!_pageController.hasClients) return;
    final next = (_page + 1) % widget.features.length;
    _pageController.animateToPage(
      next,
      // Wrapping back to the first slide crosses every page, so give it
      // more time than a single step.
      duration: Duration(milliseconds: next == 0 ? 900 : 600),
      curve: Curves.easeInOutCubic,
    );
  }

  void _onPageChanged(int page) {
    setState(() => _page = page);
    _restartAutoAdvance();
  }

  /// Pauses auto-advance while a finger is on the carousel.
  bool _onScroll(ScrollNotification notification) {
    switch (notification) {
      case ScrollStartNotification(dragDetails: _?):
        _autoAdvance?.cancel();
      case ScrollEndNotification():
        _restartAutoAdvance();
    }
    return false;
  }

  /// Distance of slide [index] from the centered page, mid-swipe included.
  double _offsetOf(int index) {
    final page =
        _pageController.hasClients &&
            _pageController.position.hasContentDimensions
        ? _pageController.page ?? _page.toDouble()
        : _page.toDouble();
    return index - page;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.features.length,
              onPageChanged: _onPageChanged,
              itemBuilder: _buildSlide,
            ),
          ),
        ),
        _PageIndicator(
          count: widget.features.length,
          current: _page,
          color: widget.features[_page].color,
        ),
      ],
    );
  }

  Widget _buildSlide(BuildContext context, int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, _) => LoginFeatureSlide(
        feature: widget.features[index],
        offset: _offsetOf(index),
        idle: _idle,
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.count,
    required this.current,
    required this.color,
  });

  final int count;
  final int current;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == current ? 20 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: i == current ? color : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
      ],
    );
  }
}
