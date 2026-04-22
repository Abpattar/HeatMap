import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'kpi_card.dart';

class CardData {
  final bool isAlert;
  final String title;
  final String? subtitle;
  final String? badgeText;
  final IconData? icon;
  final VoidCallback onTap;

  CardData({
    required this.isAlert,
    required this.title,
    this.subtitle,
    this.badgeText,
    this.icon,
    required this.onTap,
  });
}

class StackedKpiCards extends StatefulWidget {
  final List<CardData> cards;
  final VoidCallback? onSwipeStart;
  final VoidCallback? onSwipeEnd;

  const StackedKpiCards({
    super.key, 
    required this.cards,
    this.onSwipeStart,
    this.onSwipeEnd,
  });

  @override
  State<StackedKpiCards> createState() => _StackedKpiCardsState();
}

class _StackedKpiCardsState extends State<StackedKpiCards> with SingleTickerProviderStateMixin {
  // Static map to persist swiped state across unmounts/rebuilds
  static final Map<Key, int> _swipeOffsets = {};

  late List<CardData> _cardStack;
  late AnimationController _animationController;
  
  Offset _dragOffset = Offset.zero;
  Offset? _startPosition;
  bool _isSwiping = false;
  bool _isCompletingSwipe = false;
  bool _hasLockedParent = false;
  
  // Animation values to avoid creating new Tween objects every frame
  Offset _swipeStartOffset = Offset.zero;
  Offset _swipeEndOffset = Offset.zero;
  double _rotateStart = 0.0;
  double _rotateEnd = 0.0;

  int get _persistedOffset => widget.key != null ? (_swipeOffsets[widget.key!] ?? 0) : 0;
  
  void _incrementPersistedOffset() {
    if (widget.key != null) {
      _swipeOffsets[widget.key!] = _persistedOffset + 1;
    }
  }

  void _syncCardStack() {
    if (widget.cards.isEmpty) {
      _cardStack = [];
      return;
    }
    _cardStack = List.from(widget.cards);
    int offset = _persistedOffset % _cardStack.length;
    for (int i = 0; i < offset; i++) {
      _cardStack.add(_cardStack.removeAt(0));
    }
  }

  @override
  void initState() {
    super.initState();
    _syncCardStack();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_isCompletingSwipe) {
          _onSwipeComplete();
        } else {
          _onAbortComplete();
        }
      }
    });
  }

  @override
  void didUpdateWidget(StackedKpiCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Use the persisted offset to gracefully sync any changes from the parent 
    // widget while always maintaining the correct rotated order.
    setState(() {
      _syncCardStack();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (_isSwiping) return;
    _startPosition = details.globalPosition;
    _dragOffset = Offset.zero;
    _hasLockedParent = false;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isSwiping || _startPosition == null) return;
    
    final currentPos = details.globalPosition;
    final totalDelta = currentPos - _startPosition!;
    
    if (!_hasLockedParent) {
      // Sensitivity threshold
      if (totalDelta.dx.abs() > 10 && totalDelta.dx.abs() > totalDelta.dy.abs()) {
        _hasLockedParent = true;
        widget.onSwipeStart?.call();
        HapticFeedback.selectionClick();
      }
    }

    if (_hasLockedParent) {
      setState(() {
        // Apply some resistance to the drag
        _dragOffset = Offset(totalDelta.dx, totalDelta.dy * 0.2);
      });
    }
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isSwiping || _startPosition == null) return;
    
    if (!_hasLockedParent) {
      _startPosition = null;
      _dragOffset = Offset.zero;
      return;
    }

    final double velocity = details.velocity.pixelsPerSecond.dx;
    final double dragDistance = _dragOffset.dx;

    if (dragDistance.abs() > 100 || velocity.abs() > 600) {
      // Success swipe
      _swipeStartOffset = _dragOffset;
      _swipeEndOffset = Offset(dragDistance.sign * 600, _dragOffset.dy);
      _rotateStart = _dragOffset.dx / 1000;
      _rotateEnd = dragDistance.sign * 0.4;
      
      setState(() {
        _isSwiping = true;
        _isCompletingSwipe = true;
      });
      
      HapticFeedback.mediumImpact();
      _animationController.forward(from: 0);
    } else {
      // Abort / Return to center
      _swipeStartOffset = _dragOffset;
      _swipeEndOffset = Offset.zero;
      _rotateStart = _dragOffset.dx / 1000;
      _rotateEnd = 0.0;
      
      setState(() {
        _isSwiping = true;
        _isCompletingSwipe = false;
      });
      
      _animationController.forward(from: 0);
    }
  }

  void _onSwipeComplete() {
    if (mounted) {
      setState(() {
        if (_cardStack.isNotEmpty) {
          _incrementPersistedOffset();
          _syncCardStack();
        }
        _dragOffset = Offset.zero;
        _startPosition = null;
        _isSwiping = false;
        _isCompletingSwipe = false;
        _hasLockedParent = false;
      });
      widget.onSwipeEnd?.call();
      _animationController.reset();
    }
  }

  void _onAbortComplete() {
    if (mounted) {
      setState(() {
        _dragOffset = Offset.zero;
        _startPosition = null;
        _isSwiping = false;
        _isCompletingSwipe = false;
        _hasLockedParent = false;
      });
      widget.onSwipeEnd?.call();
      _animationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cardStack.isEmpty) return const SizedBox();

    return SizedBox(
        height: 160,
        width: double.infinity,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Background cards (rendered first, so they are behind)
            for (int i = 2; i > 0; i--)
              if (_cardStack.length > i)
                _buildBackgroundCard(i),
            
            // Front card (rendered last, on top)
            _buildFrontCard(),
          ],
        ),
      );
  }

  Widget _buildBackgroundCard(int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Only move background cards up if we are actually COMPLETING a swipe
        // During an abort or normal drag, they should stay in place
        double t = _isCompletingSwipe ? _animationController.value : 0.0;
        
        // Base positions for the current index and the next index (one step closer to front)
        double currentTop = index * 10.0;
        double nextTop = (index - 1) * 10.0;
        double top = currentTop + (t * (nextTop - currentTop));

        double currentScale = 1.0 - (index * 0.05);
        double nextScale = 1.0 - ((index - 1) * 0.05);
        double scale = currentScale + (t * (nextScale - currentScale));

        double currentOpacity = (1.0 - (index * 0.2)).clamp(0.0, 1.0);
        double nextOpacity = (1.0 - ((index - 1) * 0.2)).clamp(0.0, 1.0);
        double opacity = currentOpacity + (t * (nextOpacity - currentOpacity));

        return Positioned(
          top: top,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.bottomCenter,
              child: Opacity(
                opacity: opacity,
                child: _renderCard(_cardStack[index]),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFrontCard() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        Offset offset;
        double rotation;

        if (_isSwiping) {
          // Use animation controller to interpolate
          final double t = _animationController.value;
          // Smooth curves for different animation types
          Curve curve = _isCompletingSwipe ? Curves.easeInCubic : Curves.elasticOut;
          double curvedT = curve.transform(t);
          
          offset = Offset.lerp(_swipeStartOffset, _swipeEndOffset, curvedT)!;
          rotation = lerpDouble(_rotateStart, _rotateEnd, curvedT)!;
        } else {
          offset = _dragOffset;
          rotation = _dragOffset.dx / 1000;
        }

        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            behavior: HitTestBehavior.opaque,
            child: Transform.translate(
              offset: offset,
              child: Transform.rotate(
                angle: rotation,
                child: _renderCard(_cardStack[0]),
              ),
            ),
          ),
        );
      },
    );
  }

  double? lerpDouble(double a, double b, double t) {
    return a + (b - a) * t;
  }

  Widget _renderCard(CardData data) {
    return KpiCard(
      isAlert: data.isAlert,
      title: data.title,
      subtitle: data.subtitle,
      badgeText: data.badgeText,
      icon: data.icon,
      onTap: data.onTap,
    );
  }
}

