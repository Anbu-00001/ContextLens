// ── Shared-Device Quick Hide (Feature 1.2) ──────────────────────────────────
// One tap on the shield instantly covers the app with a working calculator —
// a neutral, non-suspicious screen for shared-device households. Long-press the
// calculator display to return; the app is exactly where it was left.

import 'package:flutter/material.dart';

import '../theme.dart';

/// Floating shield button — always visible, one tap to hide.
class QuickHideShield extends StatelessWidget {
  final VoidCallback onHide;
  const QuickHideShield({super.key, required this.onHide});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onHide,
        customBorder: const CircleBorder(),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: CLColors.pinkDark.withValues(alpha: 0.92),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.shield_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}

/// A fully working calculator that doubles as the decoy cover.
/// Long-press the display to dismiss and return to ConsentLens.
class CalculatorDecoy extends StatefulWidget {
  final VoidCallback onUnhide;
  const CalculatorDecoy({super.key, required this.onUnhide});

  @override
  State<CalculatorDecoy> createState() => _CalculatorDecoyState();
}

class _CalculatorDecoyState extends State<CalculatorDecoy> {
  String _display = '0';
  double? _acc;
  String? _op;
  bool _fresh = true;

  void _input(String key) {
    setState(() {
      switch (key) {
        case 'C':
          _display = '0';
          _acc = null;
          _op = null;
          _fresh = true;
          break;
        case '+':
        case '−':
        case '×':
        case '÷':
          _applyPending();
          _op = key;
          _fresh = true;
          break;
        case '=':
          _applyPending();
          _op = null;
          _fresh = true;
          break;
        case '%':
          _display = _fmt((double.tryParse(_display) ?? 0) / 100);
          break;
        case '.':
          if (!_display.contains('.')) _display += '.';
          _fresh = false;
          break;
        default: // digit
          if (_fresh || _display == '0') {
            _display = key;
            _fresh = false;
          } else {
            _display += key;
          }
      }
    });
  }

  void _applyPending() {
    final cur = double.tryParse(_display) ?? 0;
    if (_op == null || _acc == null) {
      _acc = cur;
    } else {
      switch (_op) {
        case '+':
          _acc = _acc! + cur;
          break;
        case '−':
          _acc = _acc! - cur;
          break;
        case '×':
          _acc = _acc! * cur;
          break;
        case '÷':
          _acc = cur == 0 ? 0 : _acc! / cur;
          break;
      }
    }
    _display = _fmt(_acc!);
  }

  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(6).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['C', '%', '÷', '×'],
      ['7', '8', '9', '−'],
      ['4', '5', '6', '+'],
      ['1', '2', '3', '='],
      ['0', '.'],
    ];
    return Material(
      color: const Color(0xFF1C1C1E),
      child: SafeArea(
        child: Column(
          children: [
            // Display — long-press to return to ConsentLens.
            Expanded(
              child: GestureDetector(
                onLongPress: widget.onUnhide,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(28),
                  child: Text(
                    _display,
                    maxLines: 1,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 72,
                        fontWeight: FontWeight.w300),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  for (final row in keys)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(
                        children: [
                          for (final k in row)
                            Expanded(
                              flex: k == '0' ? 2 : 1,
                              child: _key(k),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _key(String k) {
    final isOp = ['÷', '×', '−', '+', '='].contains(k);
    final isTop = ['C', '%'].contains(k);
    final Color bg = isOp
        ? const Color(0xFFFF9F0A)
        : isTop
            ? const Color(0xFFA5A5A5)
            : const Color(0xFF333336);
    final Color fg = isTop ? Colors.black : Colors.white;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: AspectRatio(
        aspectRatio: k == '0' ? 2.1 : 1,
        child: Material(
          color: bg,
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () => _input(k),
            child: Center(
              child: Text(k,
                  style: TextStyle(
                      color: fg, fontSize: 28, fontWeight: FontWeight.w500)),
            ),
          ),
        ),
      ),
    );
  }
}
