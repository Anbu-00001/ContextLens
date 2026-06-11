// ── ConsentLens Learning Sandbox (Pillar 3) ─────────────────────────────────
// One screen, four tabs: Lessons (3.1 + photo-misuse 1.3), Real vs Fake (3.3),
// Practice (3.2), Badges (3.4). Pure on-device, illustrated, narrated.

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../logic/i18n.dart';
import '../logic/learn_content.dart';
import '../logic/speech.dart';
import '../logic/store.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class LearnZoneScreen extends StatefulWidget {
  final String lang;
  const LearnZoneScreen({super.key, required this.lang});

  @override
  State<LearnZoneScreen> createState() => _LearnZoneScreenState();
}

class _LearnZoneScreenState extends State<LearnZoneScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 4, vsync: this);
  Set<String> _earned = {};

  @override
  void initState() {
    super.initState();
    Store.earnedBadges().then((e) => setState(() => _earned = e));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _award(String id) async {
    final isNew = await Store.awardBadge(id);
    _earned = await Store.earnedBadges();
    if (mounted) setState(() {});
    if (isNew && mounted) {
      final b = allBadges.firstWhere((x) => x.id == id);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(b.emoji, style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 8),
              Text(S.badgeEarned.of(widget.lang),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(b.name.of(widget.lang),
                  style: const TextStyle(
                      fontSize: 15, color: CLColors.pink)),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(S.gotIt.of(widget.lang))),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    return Scaffold(
      backgroundColor: CLColors.bg,
      appBar: AppBar(
        title: Text(S.learnZone.of(lang)),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          labelColor: CLColors.pink,
          unselectedLabelColor: CLColors.textMuted,
          indicatorColor: CLColors.pink,
          tabs: [
            Tab(text: S.lessons.of(lang)),
            Tab(text: S.library.of(lang)),
            Tab(text: S.practice.of(lang)),
            Tab(text: S.badges.of(lang)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _LessonsTab(lang: lang, onComplete: () => _award('safe_learner')),
          _LibraryTab(lang: lang),
          _PracticeTab(lang: lang, onPass: () => _award('scam_spotter')),
          _BadgesTab(lang: lang, earned: _earned),
        ],
      ),
    );
  }
}

// ── Lessons tab (3.1 + 1.3) ─────────────────────────────────────────────────
class _LessonsTab extends StatelessWidget {
  final String lang;
  final VoidCallback onComplete;
  const _LessonsTab({required this.lang, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: microLessons
          .map((l) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                child: ListTile(
                  leading: Text(l.emoji, style: const TextStyle(fontSize: 30)),
                  title: Text(l.title.of(lang),
                      style: const TextStyle(
                          fontSize: 14.5, fontWeight: FontWeight.w700)),
                  subtitle: Text('${l.cards.length} • ${S.tapToStart.of(lang)}',
                      style: const TextStyle(
                          fontSize: 11, color: CLColors.textMuted)),
                  trailing: const Icon(Icons.play_circle_fill_rounded,
                      color: CLColors.pink, size: 28),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => _StoryPlayer(
                            lesson: l, lang: lang, onDone: onComplete)),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _StoryPlayer extends StatefulWidget {
  final MicroLesson lesson;
  final String lang;
  final VoidCallback onDone;
  const _StoryPlayer(
      {required this.lesson, required this.lang, required this.onDone});

  @override
  State<_StoryPlayer> createState() => _StoryPlayerState();
}

class _StoryPlayerState extends State<_StoryPlayer> {
  int _i = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await Store.voiceOn()) {
        Speech.speak(widget.lesson.narration().of(widget.lang), widget.lang);
      }
    });
  }

  @override
  void dispose() {
    Speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.lesson;
    final lang = widget.lang;
    final last = _i >= l.cards.length - 1;
    final card = l.cards[_i];
    return Scaffold(
      backgroundColor: CLColors.bg,
      appBar: AppBar(
        title: Text(l.title.of(lang)),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up_rounded, color: CLColors.pink),
            onPressed: () =>
                Speech.speak(l.narration().of(lang), lang),
          ),
        ],
      ),
      body: Column(
        children: [
          // progress dots
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  l.cards.length,
                  (k) => Container(
                        width: 9,
                        height: 9,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: k <= _i ? CLColors.pink : CLColors.borderMid,
                        ),
                      )),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(card.emoji, style: const TextStyle(fontSize: 96)),
                  const SizedBox(height: 28),
                  Text(card.text.of(lang),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 19,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                          color: CLColors.textPrimary)),
                ],
              ),
            ),
          ),
          if (last)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                    color: CLColors.greenLight,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(S.whatToDo.of(lang).toUpperCase(),
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: CLColors.green)),
                    const SizedBox(height: 6),
                    ...l.steps.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('✅ ',
                                  style: TextStyle(fontSize: 13)),
                              Expanded(
                                  child: Text(s.of(lang),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          height: 1.4,
                                          color: CLColors.green))),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (last) {
                    widget.onDone();
                    Navigator.pop(context);
                  } else {
                    setState(() => _i++);
                  }
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(last ? S.gotIt.of(lang) : S.nextOne.of(lang)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Real vs Fake library tab (3.3) ──────────────────────────────────────────
class _LibraryTab extends StatelessWidget {
  final String lang;
  const _LibraryTab({required this.lang});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: scamLibrary.map((c) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(c.emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    Text(c.title.of(lang),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 10),
                _box(true, c.realExample.of(lang)),
                const SizedBox(height: 8),
                _box(false, c.fakeExample.of(lang)),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_rounded,
                        size: 16, color: CLColors.amber),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${S.theTell.of(lang)}: ${c.tell.of(lang)}',
                        style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: CLColors.textSec),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _box(bool real, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: real ? CLColors.greenLight : CLColors.redLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: real ? const Color(0xFFBFE0A0) : const Color(0xFFF3C2C2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
                color: real ? CLColors.green : CLColors.red,
                borderRadius: BorderRadius.circular(6)),
            child: Text(real ? S.real.of(lang) : S.fake.of(lang),
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: real ? CLColors.green : CLColors.redDark)),
          ),
        ],
      ),
    );
  }
}

// ── Practice tab (3.2) ──────────────────────────────────────────────────────
class _PracticeTab extends StatefulWidget {
  final String lang;
  final VoidCallback onPass;
  const _PracticeTab({required this.lang, required this.onPass});

  @override
  State<_PracticeTab> createState() => _PracticeTabState();
}

class _PracticeTabState extends State<_PracticeTab> {
  int _i = 0;
  int _score = 0;
  bool? _answeredCorrect;
  bool _done = false;

  void _answer(bool safe) {
    final q = practiceQuiz[_i];
    final correct = safe == q.isSafe;
    setState(() {
      _answeredCorrect = correct;
      if (correct) _score++;
    });
  }

  void _next() {
    if (_i >= practiceQuiz.length - 1) {
      setState(() => _done = true);
      if (_score >= (practiceQuiz.length * 0.6).ceil()) widget.onPass();
    } else {
      setState(() {
        _i++;
        _answeredCorrect = null;
      });
    }
  }

  void _restart() => setState(() {
        _i = 0;
        _score = 0;
        _answeredCorrect = null;
        _done = false;
      });

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    if (_done) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎯', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text(S.practiceDone.of(lang),
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('${S.youScored.of(lang)} $_score / ${practiceQuiz.length}',
                style: const TextStyle(fontSize: 16, color: CLColors.pink)),
            const SizedBox(height: 20),
            OutlinedButton(
                onPressed: _restart, child: Text(S.nextOne.of(lang))),
          ],
        ),
      );
    }

    final q = practiceQuiz[_i];
    final answered = _answeredCorrect != null;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('${_i + 1} / ${practiceQuiz.length}',
            style: const TextStyle(fontSize: 12, color: CLColors.textMuted)),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: CLColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: CLColors.border)),
          child: Column(
            children: [
              Text(q.emoji, style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              Text(q.scenario.of(lang),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16,
                      height: 1.45,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (!answered) ...[
          Text(S.isThisSafe.of(lang),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CLColors.textSec)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _answer(true),
                  icon: const Icon(Icons.check_circle_rounded,
                      color: CLColors.green),
                  label: Text(S.itsSafe.of(lang)),
                  style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _answer(false),
                  icon: const Icon(Icons.report_rounded, size: 18),
                  label: Text(S.itsScam.of(lang)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: CLColors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                ),
              ),
            ],
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: _answeredCorrect!
                    ? CLColors.greenLight
                    : CLColors.amberLight,
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    _answeredCorrect!
                        ? S.correct.of(lang)
                        : S.notQuite.of(lang),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: _answeredCorrect!
                            ? CLColors.green
                            : CLColors.amberDark)),
                const SizedBox(height: 6),
                Text(q.explain.of(lang),
                    style: const TextStyle(
                        fontSize: 13, height: 1.45, color: CLColors.textSec)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(S.nextOne.of(lang))),
          ),
        ],
      ],
    );
  }
}

// ── Badges tab (3.4) ────────────────────────────────────────────────────────
class _BadgesTab extends StatelessWidget {
  final String lang;
  final Set<String> earned;
  const _BadgesTab({required this.lang, required this.earned});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(16),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.82,
      children: allBadges.map((b) {
        final has = earned.contains(b.id);
        return GestureDetector(
          onTap: has
              ? () => Share.share(
                  '${b.emoji} I earned the "${b.name.of(lang)}" badge on ConsentLens! Stay safe online. — SheSafe')
              : null,
          child: Opacity(
            opacity: has ? 1 : 0.4,
            child: Container(
              decoration: BoxDecoration(
                color: CLColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: has ? CLColors.pink : CLColors.border,
                    width: has ? 1.5 : 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(has ? b.emoji : '🔒',
                      style: const TextStyle(fontSize: 40)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Text(b.name.of(lang),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 11.5, fontWeight: FontWeight.w700)),
                  ),
                  if (has)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(S.shareBadge.of(lang),
                          style: const TextStyle(
                              fontSize: 9, color: CLColors.pink)),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
