// ignore_for_file: deprecated_member_use

import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HOW TO USE
//
// Push this page and await the result to get the selected emotion string:
//
//   final emotion = await Navigator.push<String>(
//     context,
//     MaterialPageRoute(builder: (_) => const EmotionPickerPage()),
//   );
//   if (emotion != null) {
//     // e.g. store in your Entry: entry.emotion = emotion;
//   }
//
// The widget returns null if the user presses the back button without
// selecting, so always null-check the result.
// ─────────────────────────────────────────────────────────────────────────────

// ── Data model ───────────────────────────────────────────────────────────────

class EmotionData {
  const EmotionData({
    required this.name,
    required this.description,
    required this.color,
    required this.size,
    this.featured = false,
  });

  final String name;
  final String description;
  final Color color;

  /// Diameter of the bubble in canvas pixels.
  final double size;

  /// Featured bubbles are slightly larger and use a bolder label.
  final bool featured;
}

class EmotionZone {
  const EmotionZone({
    required this.buttonLabel,
    required this.centerX,
    required this.centerY,
    required this.accentColor,
    required this.emotions,
  });

  final String buttonLabel;
  final double centerX;
  final double centerY;
  final Color accentColor;
  final List<EmotionData> emotions;
}

// ── Zone definitions ──────────────────────────────────────────────────────────

const List<EmotionZone> _kZones = [
  EmotionZone(
    buttonLabel: 'Stressed',
    centerX: 200,
    centerY: 200,
    accentColor: Color(0xFFEF5350),
    emotions: [
      EmotionData(name: 'Terrified',  description: 'Overwhelmed by intense fear',           color: Color(0xFFE53935), size: 58),
      EmotionData(name: 'Frightened', description: 'Afraid of something threatening',        color: Color(0xFFEF5350), size: 76, featured: true),
      EmotionData(name: 'Anxious',    description: 'Worried about uncertain outcomes',       color: Color(0xFFE57373), size: 62),
      EmotionData(name: 'Angry',      description: 'Strong displeasure or hostility',        color: Color(0xFFFF7043), size: 65),
      EmotionData(name: 'Livid',      description: 'Furiously beyond normal upset',          color: Color(0xFFF4511E), size: 54),
      EmotionData(name: 'Disgusted',  description: 'Strong aversion to something',           color: Color(0xFFBF360C), size: 58),
      EmotionData(name: 'Stressed',   description: 'Overwhelmed by demands or pressure',     color: Color(0xFFFF5722), size: 72, featured: true),
      EmotionData(name: 'Jealous',    description: 'Threatened by a rival or loss',          color: Color(0xFFE64A19), size: 56),
    ],
  ),
  EmotionZone(
    buttonLabel: 'Sad',
    centerX: 200,
    centerY: 600,
    accentColor: Color(0xFF5C6BC0),
    emotions: [
      EmotionData(name: 'Sad',         description: 'A heavy feeling of sorrow',               color: Color(0xFF5C6BC0), size: 72, featured: true),
      EmotionData(name: 'Lonely',      description: 'Aching absence of connection',             color: Color(0xFF7E57C2), size: 60),
      EmotionData(name: 'Vulnerable',  description: 'Open and emotionally exposed',             color: Color(0xFFAB47BC), size: 74, featured: true),
      EmotionData(name: 'Ashamed',     description: 'Painful awareness of having done wrong',   color: Color(0xFFEC407A), size: 60),
      EmotionData(name: 'Guilty',      description: 'Responsibility for a mistake weighing on you', color: Color(0xFFAD1457), size: 54),
      EmotionData(name: 'Hopeless',    description: 'Belief that nothing can improve',          color: Color(0xFF4527A0), size: 62),
      EmotionData(name: 'Depressed',   description: 'Persistent low mood and energy',           color: Color(0xFF283593), size: 58),
      EmotionData(name: 'Numb',        description: 'Absence of feeling or emotion',            color: Color(0xFF37474F), size: 56),
    ],
  ),
  EmotionZone(
    buttonLabel: 'Happy',
    centerX: 600,
    centerY: 200,
    accentColor: Color(0xFF66BB6A),
    emotions: [
      EmotionData(name: 'Excited',    description: 'Energised anticipation of something great', color: Color(0xFFCDDC39), size: 64),
      EmotionData(name: 'Happy',      description: 'A warm feeling of pleasure and contentment',color: Color(0xFF66BB6A), size: 76, featured: true),
      EmotionData(name: 'Motivated',  description: 'Driven with purpose toward a goal',         color: Color(0xFF8BC34A), size: 70, featured: true),
      EmotionData(name: 'Proud',      description: 'Satisfaction in your own achievement',      color: Color(0xFF4CAF50), size: 62),
      EmotionData(name: 'Confident',  description: 'Assured trust in your own ability',         color: Color(0xFF43A047), size: 60),
      EmotionData(name: 'Joyful',     description: 'A bright feeling of great delight',         color: Color(0xFFFDD835), size: 66),
      EmotionData(name: 'Inspired',   description: 'Filled with creative energy',               color: Color(0xFFFFB300), size: 58),
      EmotionData(name: 'Hopeful',    description: 'Optimistic about what is coming',           color: Color(0xFF26A69A), size: 56),
    ],
  ),
  EmotionZone(
    buttonLabel: 'Calm',
    centerX: 600,
    centerY: 600,
    accentColor: Color(0xFF29B6F6),
    emotions: [
      EmotionData(name: 'Calm',       description: 'Serene, undisturbed, at ease',              color: Color(0xFF29B6F6), size: 74, featured: true),
      EmotionData(name: 'Content',    description: 'Peaceful satisfaction with how things are', color: Color(0xFF26A69A), size: 70, featured: true),
      EmotionData(name: 'Relaxed',    description: 'Free from tension or worry',                color: Color(0xFF4DD0E1), size: 64),
      EmotionData(name: 'Grateful',   description: 'Deep appreciation for what you have',       color: Color(0xFF80CBC4), size: 60),
      EmotionData(name: 'Accepted',   description: 'Feeling welcomed and valued by others',     color: Color(0xFF4DB6AC), size: 66),
      EmotionData(name: 'Safe',       description: 'Free from threat or danger',                color: Color(0xFF0097A7), size: 56),
      EmotionData(name: 'Fulfilled',  description: 'A sense of meaningful completion',          color: Color(0xFF00838F), size: 62),
      EmotionData(name: 'Peaceful',   description: 'Deep inner stillness and ease',             color: Color(0xFF006064), size: 58),
    ],
  ),
];

// ── Internal bubble placement ─────────────────────────────────────────────────

class _PlacedBubble {
  _PlacedBubble({
    required this.emotion,
    required this.x,
    required this.y,
    required this.zoneIndex,
  });

  final EmotionData emotion;
  final double x;
  final double y;
  final int zoneIndex;

  double scale = 1.0;

  double get radius => emotion.size / 2;
}

// ── Page ──────────────────────────────────────────────────────────────────────

class EmotionPickerPage extends StatefulWidget {
  const EmotionPickerPage({super.key});

  @override
  State<EmotionPickerPage> createState() => _EmotionPickerPageState();
}

class _EmotionPickerPageState extends State<EmotionPickerPage>
    with TickerProviderStateMixin {

  static const double _kCanvasSize  = 800.0;
  static const double _kNavHeight   = 70.0;
  static const double _kSpread      = 160.0;
  static const double _kBubbleGap   = 5.0;
  static const double _kZoomedScale = 1.5;

  // Camera state — stored as plain numbers so we can lerp them trivially.
  double _scale = 0.5;
  double _tx    = 0.0;
  double _ty    = 0.0;

  // Zoom animation
  late AnimationController _zoomCtrl;
  late Animation<double>    _zoomAnim;
  double _fromScale = 0.5, _toScale = 0.5;
  double _fromTx    = 0.0, _toTx    = 0.0;
  double _fromTy    = 0.0, _toTy    = 0.0;

  // Pan gesture
  Offset? _panStartScreen;
  double  _panStartTx = 0.0;
  double  _panStartTy = 0.0;

  List<_PlacedBubble> _bubbles     = [];
  _PlacedBubble?      _hovered;
  int                 _activeZone  = -1;

  @override
  void initState() {
    super.initState();
    _zoomCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _zoomAnim = CurvedAnimation(parent: _zoomCtrl, curve: Curves.easeOutCubic)
      ..addListener(_onZoomTick);
    _packBubbles();

    // Set initial camera once layout is known.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final size = MediaQuery.of(context).size;
      final vH   = size.height - _kNavHeight;
      final s    = math.min(size.width / _kCanvasSize, vH / _kCanvasSize) * 0.92;
      setState(() {
        _scale = s;
        _tx    = (size.width  - _kCanvasSize * s) / 2;
        _ty    = (vH          - _kCanvasSize * s) / 2;
      });
    });
  }

  @override
  void dispose() {
    _zoomCtrl.dispose();
    super.dispose();
  }

  // ── Bubble packing ──────────────────────────────────────────────────────────

  void _packBubbles() {
    final rng     = math.Random(42); // fixed seed → deterministic layout
    final placed  = <_PlacedBubble>[];

    for (int zi = 0; zi < _kZones.length; zi++) {
      final zone        = _kZones[zi];
      final zonePlaced  = <_PlacedBubble>[];

      for (final emotion in zone.emotions) {
        final r = emotion.size / 2;
        double x = 0, y = 0;
        bool   ok = false;
        int    tries = 0;

        while (!ok && tries < 800) {
          final angle = rng.nextDouble() * math.pi * 2;
          final dist  = rng.nextDouble() * (_kSpread - r - _kBubbleGap);
          x = zone.centerX + math.cos(angle) * dist;
          y = zone.centerY + math.sin(angle) * dist;
          x = x.clamp(r + _kBubbleGap, _kCanvasSize - r - _kBubbleGap);
          y = y.clamp(r + _kBubbleGap, _kCanvasSize - r - _kBubbleGap);

          bool noOverlapZone = zonePlaced.every((p) {
            final dx = p.x - x, dy = p.y - y;
            return math.sqrt(dx * dx + dy * dy) > p.radius + r + _kBubbleGap;
          });
          bool noOverlapAll = placed.every((p) {
            final dx = p.x - x, dy = p.y - y;
            return math.sqrt(dx * dx + dy * dy) > p.radius + r + _kBubbleGap;
          });
          ok = noOverlapZone && noOverlapAll;
          tries++;
        }

        final b = _PlacedBubble(emotion: emotion, x: x, y: y, zoneIndex: zi);
        zonePlaced.add(b);
        placed.add(b);
      }
    }

    _bubbles = placed;
  }

  // ── Camera helpers ──────────────────────────────────────────────────────────

  Matrix4 get _matrix => Matrix4.identity()
    ..translate(_tx, _ty)
    ..scale(_scale);

  /// Convert a point from screen space into canvas space.
  Offset _toCanvas(Offset screen) => Offset(
    (screen.dx - _tx) / _scale,
    (screen.dy - _ty) / _scale,
  );

  void _zoomToZone(int index) {
    final size = MediaQuery.of(context).size;
    final vW   = size.width;
    final vH   = size.height - _kNavHeight;
    final zone = _kZones[index];

    _fromScale = _scale;
    _fromTx    = _tx;
    _fromTy    = _ty;
    _toScale   = _kZoomedScale;
    _toTx      = vW / 2 - zone.centerX * _kZoomedScale;
    _toTy      = vH / 2 - zone.centerY * _kZoomedScale;

    _zoomCtrl.forward(from: 0);
  }

  void _onZoomTick() {
    final t = _zoomAnim.value;
    setState(() {
      _scale = _fromScale + (_toScale - _fromScale) * t;
      _tx    = _fromTx    + (_toTx    - _fromTx)    * t;
      _ty    = _fromTy    + (_toTy    - _fromTy)    * t;
    });
  }

  // ── Touch tracking ──────────────────────────────────────────────────────────

  void _updateHover(Offset screenPos) {
    final cp     = _toCanvas(screenPos);
    _PlacedBubble? found;
    double bestDist = double.infinity;

    bool changed = false;
    for (final b in _bubbles) {
      final dx   = b.x - cp.dx;
      final dy   = b.y - cp.dy;
      final dist = math.sqrt(dx * dx + dy * dy);
      final hR   = b.radius + 20 / _scale; // hover region grows as we zoom out
      final newScale = dist < hR
          ? 1.0 + (1 - dist / hR) * 0.22
          : 1.0;
      if ((newScale - b.scale).abs() > 0.001) {
        b.scale = newScale;
        changed = true;
      }
      if (dist < b.radius && dist < bestDist) {
        found     = b;
        bestDist  = dist;
      }
    }

    if (found != _hovered || changed) {
      setState(() => _hovered = found);
    }
  }

  void _clearHover() {
    bool changed = false;
    for (final b in _bubbles) {
      if (b.scale != 1.0) { b.scale = 1.0; changed = true; }
    }
    if (_hovered != null || changed) setState(() => _hovered = null);
  }

  // ── Interaction handlers ────────────────────────────────────────────────────

  void _onTapUp(TapUpDetails details) {
    final cp = _toCanvas(details.localPosition);
    for (final b in _bubbles) {
      final dx = b.x - cp.dx;
      final dy = b.y - cp.dy;
      if (math.sqrt(dx * dx + dy * dy) < b.radius) {
        Navigator.of(context).pop(b.emotion.name);
        return;
      }
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size         = MediaQuery.of(context).size;
    final canvasAreaH  = size.height - _kNavHeight;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          // ── Zoomable / pannable canvas ──────────────────────
          SizedBox(
            width:  size.width,
            height: canvasAreaH,
            child: GestureDetector(
              onTapUp: _onTapUp,
              onPanStart: (d) {
                _panStartScreen = d.localPosition;
                _panStartTx     = _tx;
                _panStartTy     = _ty;
              },
              onPanUpdate: (d) {
                if (_panStartScreen == null) return;
                final dx = d.localPosition.dx - _panStartScreen!.dx;
                final dy = d.localPosition.dy - _panStartScreen!.dy;
                setState(() {
                  _tx = _panStartTx + dx;
                  _ty = _panStartTy + dy;
                });
                _updateHover(d.localPosition);
              },
              onPanEnd: (_) => _panStartScreen = null,
              child: ClipRect(
                child: Transform(
                  transform: _matrix,
                  child: SizedBox(
                    width:  _kCanvasSize,
                    height: _kCanvasSize,
                    child: Stack(
                      children: [
                        // Subtle zone tint circles
                        ..._kZones.map((z) => Positioned(
                          left: z.centerX - 190,
                          top:  z.centerY - 190,
                          child: IgnorePointer(
                            child: Container(
                              width:  380,
                              height: 380,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: z.accentColor.withOpacity(0.05),
                              ),
                            ),
                          ),
                        )),

                        // Emotion bubbles
                        ..._bubbles.map((b) => Positioned(
                          left: b.x - b.radius,
                          top:  b.y - b.radius,
                          child: AnimatedScale(
                            scale:    b.scale,
                            duration: const Duration(milliseconds: 120),
                            child: Container(
                              width:  b.emotion.size,
                              height: b.emotion.size,
                              decoration: BoxDecoration(
                                color: b.emotion.color,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              padding: const EdgeInsets.all(4),
                              child: Text(
                                b.emotion.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize:   b.emotion.featured ? 13 : 10,
                                  fontWeight: FontWeight.w700,
                                  color:      Colors.black.withOpacity(0.7),
                                  height:     1.2,
                                ),
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Hint (visible before first zone tap) ───────────
          if (_activeZone == -1)
            Positioned(
              top:   MediaQuery.of(context).padding.top + 14,
              left:  0,
              right: 0,
              child: const IgnorePointer(
                child: Text(
                  'Tap a category to explore',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:    Color(0x55FFFFFF),
                    fontSize: 12,
                  ),
                ),
              ),
            ),

          // ── Tooltip ─────────────────────────────────────────
          Positioned(
            bottom: _kNavHeight + 8,
            left:   16,
            right:  16,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity:  _hovered != null ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 180),
                child: Center(
                  child: Container(
                    padding:    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color:        Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                      border:       Border.all(
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _hovered?.emotion.name ?? '',
                          style: const TextStyle(
                            color:      Colors.white,
                            fontSize:   15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _hovered?.emotion.description ?? '',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:    Colors.white.withOpacity(0.65),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom nav ───────────────────────────────────────
          Positioned(
            bottom: 0,
            left:   0,
            right:  0,
            child:  _buildNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildNav() {
    return Container(
      height:     _kNavHeight,
      decoration: BoxDecoration(
        color: const Color(0xF20D0D0D),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: Row(
        children: List.generate(_kZones.length, (i) {
          final isActive = _activeZone == i;
          final zone     = _kZones[i];
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() => _activeZone = i);
                _zoomToZone(i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin:   const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                decoration: BoxDecoration(
                  color:        isActive
                      ? Colors.white.withOpacity(0.07)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border:       Border.all(
                    color: isActive
                        ? Colors.white.withOpacity(0.15)
                        : Colors.transparent,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width:  8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: zone.accentColor.withOpacity(isActive ? 1.0 : 0.35),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      zone.buttonLabel,
                      style: TextStyle(
                        color:      Colors.white.withOpacity(isActive ? 1.0 : 0.35),
                        fontSize:   11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}