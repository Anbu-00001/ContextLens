// ── ConsentLens Safe Browser ────────────────────────────────────────────────
// In-app WebView that intercepts EVERY website permission request and runs it
// through ConsentLens before the site is granted anything. Also blocks known
// dangerous domains. This is the 100%-reliable fallback to the Chrome
// accessibility watcher.

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../logic/i18n.dart';
import '../logic/risk_engine.dart';
import '../logic/speech.dart';
import '../logic/store.dart';
import '../logic/threat.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class SafeBrowserScreen extends StatefulWidget {
  final String lang;
  const SafeBrowserScreen({super.key, required this.lang});

  @override
  State<SafeBrowserScreen> createState() => _SafeBrowserScreenState();
}

class _SafeBrowserScreenState extends State<SafeBrowserScreen> {
  late final WebViewController _controller;
  final TextEditingController _urlCtrl = TextEditingController();
  String _currentHost = '';
  bool _loading = false;
  bool _blocked = false;
  // Allowlist gate: unknown (not commonly used) sites get a warning first.
  bool _warning = false;
  String _pendingUrl = '';
  bool _childMode = false;
  final Set<String> _allowedHosts = {}; // "continue once" for this session

  @override
  void initState() {
    super.initState();
    Store.userMode().then((m) => _childMode = m == 'child');
    _controller = WebViewController(onPermissionRequest: _onPermissionRequest)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            final host = hostOf(url);
            setState(() {
              _loading = true;
              _currentHost = host;
              _urlCtrl.text = host;
            });
          },
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: (req) {
            if (!req.isMainFrame) return NavigationDecision.navigate;
            return _gate(req.url)
                ? NavigationDecision.navigate
                : NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.google.com'));
  }

  /// Allowlist gate for main-frame navigations. True = let it load.
  bool _gate(String url) {
    switch (siteTrust(url)) {
      case SiteTrust.shady:
        setState(() => _blocked = true);
        _warnThreat(hostOf(url), assessDomain(url));
        return false;
      case SiteTrust.trusted:
        return true;
      case SiteTrust.unknown:
        if (_allowedHosts.contains(hostOf(url))) return true;
        setState(() {
          _warning = true;
          _pendingUrl = url;
          _currentHost = hostOf(url); // badge reflects the warned site
        });
        return false;
    }
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _onPermissionRequest(WebViewPermissionRequest request) async {
    final perms = request.types.map((t) {
      switch (t) {
        case WebViewPermissionResourceType.camera:
          return 'camera';
        case WebViewPermissionResourceType.microphone:
          return 'microphone';
        default:
          return 'storage';
      }
    }).toList();

    final granted = await _showConsequenceSheet(_currentHost, perms);
    if (granted) {
      await request.grant();
    } else {
      await request.deny();
    }
  }

  void _go() {
    var input = _urlCtrl.text.trim();
    if (input.isEmpty) return;
    final looksLikeDomain = input.contains('.') && !input.contains(' ');
    final url = looksLikeDomain
        ? (input.startsWith('http') ? input : 'https://$input')
        : 'https://www.google.com/search?q=${Uri.encodeComponent(input)}';
    if (_gate(url)) _controller.loadRequest(Uri.parse(url));
  }

  void _warnThreat(String host, ThreatVerdict verdict) async {
    final lang = widget.lang;
    if (await Store.voiceOn()) Speech.speak(S.ttsThreat.of(lang), lang);
  }

  Future<bool> _showConsequenceSheet(String site, List<String> perms) async {
    final lang = widget.lang;
    final mode = await Store.userMode();
    if (!mounted) return false;
    final report = buildWebReport(site, perms);

    await Store.addHistory(HistoryEntry(
      pkg: site,
      appName: site,
      high: report.overallHigh,
      catCount: report.categories.length,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    ));
    if (await Store.voiceOn()) {
      Speech.speak(
        S.ttsSummary
            .of(lang)
            .replaceAll('{app}', site)
            .replaceAll('{n}', '${report.categories.length}')
            .replaceAll('{risk}', report.overallLabel.of(lang)),
        lang,
      );
    }

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: CLColors.bg,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        builder: (_, controller) => Column(
          children: [
            Expanded(
              child: ListView(
                controller: controller,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        const Text('🌐', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(site,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: report.overallHigh
                                ? CLColors.redLight
                                : CLColors.greenLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(report.overallLabel.of(lang),
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: report.overallHigh
                                      ? CLColors.redDark
                                      : CLColors.green)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Text(S.websiteWants.of(lang),
                        style: const TextStyle(
                            fontSize: 12, color: CLColors.textMuted)),
                  ),
                  SectionLabel(S.suitableFor.of(lang)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Expanded(
                            child: FitChip(
                                label: S.kids.of(lang),
                                fit: report.kidsFit,
                                lang: lang)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: FitChip(
                                label: S.teens.of(lang),
                                fit: report.teensFit,
                                lang: lang)),
                        const SizedBox(width: 8),
                        Expanded(
                            child: FitChip(
                                label: S.adults.of(lang),
                                fit: report.adultsFit,
                                lang: lang)),
                      ],
                    ),
                  ),
                  ...report.categories.map((c) =>
                      CategoryCard(category: c, lang: lang, userMode: mode)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
              decoration: const BoxDecoration(
                color: CLColors.white,
                border: Border(top: BorderSide(color: CLColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: CLColors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(S.block.of(lang)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12)),
                      child: Text(S.allowOnce.of(lang)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    return Scaffold(
      backgroundColor: CLColors.bg,
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: CLColors.bgAlt,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                  isTrustedSite(_currentHost)
                      ? Icons.verified_rounded
                      : Icons.lock_rounded,
                  size: 14,
                  color: isTrustedSite(_currentHost)
                      ? CLColors.green
                      : Colors.amber),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: _urlCtrl,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (_) => _go(),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: S.enterUrl.of(lang),
                    hintStyle: const TextStyle(
                        fontSize: 13, color: CLColors.textMuted),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              if (_loading)
                const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: CLColors.pink)),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_warning) _unknownSiteOverlay(lang),
          if (_blocked) _blockedOverlay(lang),
        ],
      ),
    );
  }

  // Warning page for sites that are not on the commonly-used trusted list.
  // Adults may continue once; in child mode the site stays closed.
  Widget _unknownSiteOverlay(String lang) {
    final host = hostOf(_pendingUrl);
    return Container(
      color: CLColors.bg,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚠️', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text(S.unknownSiteTitle.of(lang),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: CLColors.redDark)),
          const SizedBox(height: 6),
          Text(host,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: CLColors.textSec)),
          const SizedBox(height: 8),
          Text(
              _childMode
                  ? S.unknownSiteChild.of(lang)
                  : S.unknownSiteBody.of(lang),
              textAlign: TextAlign.center,
              style: CLTextStyles.body),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() {
                _warning = false;
                _pendingUrl = '';
              }),
              child: Text(S.goBack.of(lang)),
            ),
          ),
          if (!_childMode) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  final url = _pendingUrl;
                  _allowedHosts.add(hostOf(url));
                  setState(() {
                    _warning = false;
                    _pendingUrl = '';
                  });
                  _controller.loadRequest(Uri.parse(url));
                },
                child: Text(S.proceedAnyway.of(lang)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _blockedOverlay(String lang) {
    return Container(
      color: CLColors.bg,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🛑', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text(S.siteBlockedTitle.of(lang),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: CLColors.redDark)),
          const SizedBox(height: 8),
          Text(S.threatWarn.of(lang),
              textAlign: TextAlign.center, style: CLTextStyles.body),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _blocked = false),
              child: Text(S.goBack.of(lang)),
            ),
          ),
        ],
      ),
    );
  }
}
