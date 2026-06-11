// ── ConsentLens Safe Handoff / Kids Mode (Feature 5.2) ─────────────────────
// A simple, friendly full-screen cover for handing the phone to a child.
// Best-effort screen pinning makes leaving harder; a 4-digit PIN (set by the
// parent) is required to exit. Honest scoping: without device-owner this is a
// deterrent, not an unbreakable kiosk.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/i18n.dart';
import '../logic/native.dart';
import '../logic/store.dart';
import '../theme.dart';

class KidsModeScreen extends StatefulWidget {
  final String lang;
  const KidsModeScreen({super.key, required this.lang});

  @override
  State<KidsModeScreen> createState() => _KidsModeScreenState();
}

class _KidsModeScreenState extends State<KidsModeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => Native.startScreenPinning());
  }

  Future<bool> _tryExit() async {
    final pin = await Store.kidsPin();
    if (!mounted) return false;
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PinDialog(lang: widget.lang, expected: pin),
    );
    if (ok == true) {
      await Native.stopScreenPinning();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _tryExit() && mounted) Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF5B3FA8),
        body: SafeArea(
          child: Column(
            children: [
              // Top bar with a discreet exit (PIN-gated).
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.lock_rounded, color: Colors.white70),
                  onPressed: () async {
                    if (await _tryExit() && mounted) Navigator.pop(context);
                  },
                ),
              ),
              const Spacer(),
              const Text('🧸', style: TextStyle(fontSize: 96)),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(S.kidsHi.of(lang),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
              ),
              const SizedBox(height: 30),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _toy('🎨'),
                  _toy('🔢'),
                  _toy('⭐'),
                  _toy('🐱'),
                  _toy('🎈'),
                  _toy('🚗'),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(S.kidsModeNote.of(lang),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 11, height: 1.4, color: Colors.white60)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Simple tappable toys — pop a friendly reaction (zero-risk play).
  Widget _toy(String emoji) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('$emoji  Yay!'),
          duration: const Duration(milliseconds: 700))),
      child: Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(18)),
        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 38))),
      ),
    );
  }
}

class _PinDialog extends StatefulWidget {
  final String lang;
  final String? expected;
  const _PinDialog({required this.lang, required this.expected});

  @override
  State<_PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<_PinDialog> {
  final _ctrl = TextEditingController();
  bool _error = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.enterPin.of(widget.lang)),
      content: TextField(
        controller: _ctrl,
        keyboardType: TextInputType.number,
        obscureText: true,
        maxLength: 4,
        autofocus: true,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          errorText: _error ? S.wrongPin.of(widget.lang) : null,
        ),
        onChanged: (v) {
          if (v.length == 4) {
            if (v == widget.expected) {
              Navigator.pop(context, true);
            } else {
              setState(() => _error = true);
              _ctrl.clear();
            }
          }
        },
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel')),
      ],
    );
  }
}
