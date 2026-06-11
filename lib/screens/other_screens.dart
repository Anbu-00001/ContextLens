import 'package:flutter/material.dart';

import '../logic/i18n.dart';
import '../logic/native.dart';
import '../logic/risk_engine.dart';
import '../logic/speech.dart';
import '../logic/store.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

// ── Permissions screen: every installed app, scored locally ────────────────
class PermissionsScreen extends StatefulWidget {
  final String lang;
  const PermissionsScreen({super.key, required this.lang});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  List<AppReport>? _reports;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final apps = await Native.listApps();
    final reports =
        apps.map((a) => buildReport(a.packageName, a.label, a.permissions)).toList()
          ..sort((a, b) {
            if (a.overallHigh != b.overallHigh) return a.overallHigh ? -1 : 1;
            return b.categories.length.compareTo(a.categories.length);
          });
    if (mounted) setState(() => _reports = reports);
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final reports = _reports;
    return Scaffold(
      backgroundColor: CLColors.bg,
      appBar: AppBar(title: Text(S.permissions.of(lang))),
      body: reports == null
          ? const Center(child: CircularProgressIndicator(color: CLColors.pink))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SectionLabel(
                      '${reports.length} ${S.installedApps.of(lang)}'),
                  ...reports.map((r) => Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        child: ListTile(
                          dense: true,
                          title: Text(r.appName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            r.categories
                                .map((c) => c.emojis.first)
                                .take(8)
                                .join(' '),
                            style: const TextStyle(fontSize: 13),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: r.overallHigh
                                  ? CLColors.redLight
                                  : CLColors.greenLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              r.overallLabel.of(lang),
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: r.overallHigh
                                      ? CLColors.redDark
                                      : CLColors.green),
                            ),
                          ),
                          onTap: () => _showReport(context, r, lang),
                        ),
                      )),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  void _showReport(BuildContext context, AppReport r, String lang) async {
    final mode = await Store.userMode();
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CLColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        builder: (_, controller) => ListView(
          controller: controller,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(r.appName,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: r.overallHigh
                          ? CLColors.redLight
                          : CLColors.greenLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${S.overallRisk.of(lang)}: ${r.overallLabel.of(lang)}',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: r.overallHigh
                              ? CLColors.redDark
                              : CLColors.green),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded,
                        color: CLColors.pink),
                    onPressed: () => Speech.speak(
                      S.ttsSummary
                          .of(lang)
                          .replaceAll('{app}', r.appName)
                          .replaceAll('{n}', '${r.categories.length}')
                          .replaceAll('{risk}', r.overallLabel.of(lang)),
                      lang,
                    ),
                  ),
                ],
              ),
            ),
            SectionLabel(S.suitableFor.of(lang)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                      child: FitChip(
                          label: S.kids.of(lang), fit: r.kidsFit, lang: lang)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: FitChip(
                          label: S.teens.of(lang),
                          fit: r.teensFit,
                          lang: lang)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: FitChip(
                          label: S.adults.of(lang),
                          fit: r.adultsFit,
                          lang: lang)),
                ],
              ),
            ),
            SectionLabel('${r.categories.length} ${S.permsDetected.of(lang)}'),
            if (r.categories.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(S.noRiskyPerms.of(lang),
                    style: CLTextStyles.body, textAlign: TextAlign.center),
              ),
            ...r.categories
                .map((c) => CategoryCard(category: c, lang: lang, userMode: mode)),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── History screen ──────────────────────────────────────────────────────────
class HistoryScreen extends StatefulWidget {
  final String lang;
  const HistoryScreen({super.key, required this.lang});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with WidgetsBindingObserver {
  List<HistoryEntry> _items = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    final items = await Store.history();
    if (mounted) setState(() => _items = items);
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final high = _items.where((h) => h.high).length;
    final low = _items.length - high;

    return Scaffold(
      backgroundColor: CLColors.bg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.history.of(lang)),
            Text(S.storedLocally.of(lang),
                style: const TextStyle(
                    fontSize: 11,
                    color: CLColors.textMuted,
                    fontWeight: FontWeight.w400)),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                      child: _StatCard(
                          number: '$high',
                          label: S.riskHigh.of(lang),
                          color: CLColors.redDark)),
                  const SizedBox(width: 8),
                  Expanded(
                      child: _StatCard(
                          number: '$low',
                          label: S.riskLow.of(lang),
                          color: CLColors.green)),
                ],
              ),
            ),
            SectionLabel(S.recentAlerts.of(lang)),
            if (_items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(S.noAlerts.of(lang), style: CLTextStyles.body),
              )
            else
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: _items
                      .map((item) => _HistoryRow(item: item, lang: lang))
                      .toList(),
                ),
              ),
            const SizedBox(height: 12),
            const PrivacyChipsStrip(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String number;
  final String label;
  final Color color;
  const _StatCard(
      {required this.number, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(number,
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(fontSize: 11, color: CLColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final HistoryEntry item;
  final String lang;
  const _HistoryRow({required this.item, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.high ? CLColors.red : CLColors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.appName,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CLColors.textPrimary),
                    overflow: TextOverflow.ellipsis),
                Text('${item.catCount} ${S.permissions.of(lang).toLowerCase()}',
                    style: const TextStyle(
                        fontSize: 11, color: CLColors.textMuted)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: item.high ? CLColors.redLight : CLColors.greenLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              (item.high ? S.riskHigh : S.riskLow).of(lang),
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: item.high ? CLColors.redDark : CLColors.green),
            ),
          ),
          const SizedBox(width: 8),
          Text(item.timeAgo(),
              style: const TextStyle(fontSize: 11, color: Color(0xFFBBBBBB))),
        ],
      ),
    );
  }
}

// ── Settings screen ─────────────────────────────────────────────────────────
class SettingsScreen extends StatefulWidget {
  final String lang;
  final ValueChanged<String> onLanguageChanged;
  const SettingsScreen(
      {super.key, required this.lang, required this.onLanguageChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  bool _voiceOn = true;
  String _mode = 'adult';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  Future<void> _load() async {
    final voice = await Store.voiceOn();
    final mode = await Store.userMode();
    if (mounted) {
      setState(() {
        _voiceOn = voice;
        _mode = mode;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    return Scaffold(
      backgroundColor: CLColors.bg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(S.settings.of(lang)),
            const Text('ConsentLens v1.0',
                style: TextStyle(
                    fontSize: 11,
                    color: CLColors.textMuted,
                    fontWeight: FontWeight.w400)),
          ],
        ),
      ),
      body: ListView(
        children: [
          // ── Language ──
          SectionLabel(S.language.of(lang)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                _SegmentButton(
                  label: 'English',
                  selected: lang == 'en',
                  onTap: () => _setLang('en'),
                ),
                const SizedBox(width: 8),
                _SegmentButton(
                  label: 'हिन्दी',
                  selected: lang == 'hi',
                  onTap: () => _setLang('hi'),
                ),
                const SizedBox(width: 8),
                _SegmentButton(
                  label: 'ಕನ್ನಡ',
                  selected: lang == 'kn',
                  onTap: () => _setLang('kn'),
                ),
              ],
            ),
          ),

          // ── Current user mode ──
          SectionLabel(S.currentUser.of(lang)),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  ModeBadge(mode: _mode, lang: lang),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(S.verifySub.of(lang),
                        style: const TextStyle(
                            fontSize: 11,
                            color: CLColors.textMuted,
                            height: 1.4)),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Native.verifyNow();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: CLColors.pink,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(S.verifyNow.of(lang),
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          ),

          // ── Mode preview (severity differs per age) ──
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _ModePreview(mode: _mode, lang: lang, key: ValueKey(_mode)),
          ),

          // ── Accessibility ──
          SectionLabel(S.voiceNarration.of(lang)),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            child: SettingToggleRow(
              icon: Icons.volume_up_rounded,
              iconBg: CLColors.pinkLight,
              iconFg: CLColors.pink,
              title: S.voiceNarration.of(lang),
              subtitle: S.voiceNarrationSub.of(lang),
              value: _voiceOn,
              onChanged: (v) async {
                await Store.setVoiceOn(v);
                setState(() => _voiceOn = v);
                if (v) Speech.speak(S.voiceNarration.of(lang), lang);
              },
            ),
          ),

          // ── Safety & help (always available) ──
          SectionLabel(S.safetyHelp.of(lang)),
          HelpResourcesList(lang: lang),

          // ── Privacy ──
          SectionLabel('Privacy'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: [
                _PrivacyRow(
                  icon: Icons.laptop_rounded,
                  iconBg: CLColors.greenLight,
                  iconFg: CLColors.green,
                  title: S.localOnly.of(lang),
                  subtitle: S.localOnlySub.of(lang),
                  trailing:
                      const Icon(Icons.check_rounded, color: CLColors.green),
                ),
                const Divider(height: 1, indent: 58),
                _PrivacyRow(
                  icon: Icons.delete_outline_rounded,
                  iconBg: CLColors.amberLight,
                  iconFg: CLColors.amber,
                  title: S.clearHistory.of(lang),
                  subtitle: S.storedLocally.of(lang),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: CLColors.textMuted),
                  onTap: () => _confirmClear(context, lang),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _setLang(String lang) async {
    await Store.setLanguage(lang);
    widget.onLanguageChanged(lang);
  }

  void _confirmClear(BuildContext context, String lang) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.clearHistory.of(lang)),
        content: Text(S.storedLocally.of(lang)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await Store.clearHistory();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(S.clearHistory.of(lang)),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;
  const _SegmentButton(
      {required this.label, this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: CLColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? CLColors.pink : CLColors.borderMid,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 15,
                    color: selected ? CLColors.pink : CLColors.textMuted),
                const SizedBox(width: 5),
              ],
              Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? CLColors.pink : CLColors.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModePreview extends StatelessWidget {
  final String mode;
  final String lang;
  const _ModePreview({super.key, required this.mode, required this.lang});

  @override
  Widget build(BuildContext context) {
    final loc = categoryById('location')!;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CLColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CLColors.border),
      ),
      child: mode == 'adult'
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${loc.title.of(lang)} · ${S.risksAsAdult.of(lang)}',
                    style: const TextStyle(
                        fontSize: 11, color: CLColors.textMuted)),
                const SizedBox(height: 8),
                Text('${loc.consequence.of(lang)} ${loc.adultRisk.of(lang)}',
                    style: const TextStyle(
                        fontSize: 13,
                        color: CLColors.textPrimary,
                        height: 1.55)),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📍🏠🏫', style: TextStyle(fontSize: 22)),
                const SizedBox(height: 6),
                Text('${loc.title.of(lang)} · ${S.risksAsKid.of(lang)}',
                    style: const TextStyle(
                        fontSize: 11, color: CLColors.textMuted)),
                const SizedBox(height: 8),
                Text('${loc.kidRisk.of(lang)} ${S.childAlert.of(lang)} 🙅',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: CLColors.purple,
                        height: 1.6)),
              ],
            ),
    );
  }
}

class _PrivacyRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _PrivacyRow(
      {required this.icon,
      required this.iconBg,
      required this.iconFg,
      required this.title,
      required this.subtitle,
      required this.trailing,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(9)),
              child: Icon(icon, color: iconFg, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: CLColors.textPrimary)),
                  Text(subtitle, style: CLTextStyles.label),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
