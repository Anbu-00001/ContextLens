// ── ConsentLens logic tests ────────────────────────────────────────────────
// Pure-Dart tests for the safety-critical on-device engines: the scam
// scanner, the domain threat heuristics, and the learning-content integrity.
// Run with: flutter test

import 'package:flutter_test/flutter_test.dart';

import 'package:consentlens/logic/scam_engine.dart';
import 'package:consentlens/logic/threat.dart';
import 'package:consentlens/logic/learn_content.dart';
import 'package:consentlens/logic/i18n.dart';

void main() {
  group('scam engine — dangerous verdicts (must never miss these)', () {
    test('KYC / account-block SMS', () {
      final r = scanText(
          'Dear customer your SBI account will be blocked today. Update KYC immediately: http://bit.ly/sbi-kyc');
      expect(r.level, ScamLevel.dangerous);
      expect(r.matched.any((m) => m.id == 'kyc'), isTrue);
      expect(r.badLinks, isNotEmpty);
      expect(r.urgency, isTrue);
    });

    test('OTP-sharing request', () {
      final r = scanText('Please share the OTP you just received to verify');
      expect(r.level, ScamLevel.dangerous);
      expect(r.topRule?.id, 'otp');
    });

    test('digital arrest threat', () {
      final r = scanText(
          'This is CBI. An illegal parcel in your name is under investigation. Arrest warrant issued.');
      expect(r.level, ScamLevel.dangerous);
      expect(r.matched.any((m) => m.id == 'digital_arrest'), isTrue);
    });

    test('UPI refund-PIN trick', () {
      final r = scanText('To receive your refund of Rs 4999 enter your PIN in the app');
      expect(r.level, ScamLevel.dangerous);
      expect(r.matched.any((m) => m.id == 'upi'), isTrue);
    });

    test('lottery / KBC prize', () {
      final r = scanText('Congratulations! You have won 25 lakh in KBC lucky draw');
      expect(r.level, ScamLevel.dangerous);
      expect(r.matched.any((m) => m.id == 'lottery'), isTrue);
    });

    test('suspicious rule + urgency escalates to dangerous', () {
      final r = scanText('Your parcel delivery failed. Pay redelivery fee within 24 hours');
      expect(r.matched.any((m) => m.id == 'courier'), isTrue);
      expect(r.urgency, isTrue);
      expect(r.level, ScamLevel.dangerous);
    });

    test('link shortener alone is dangerous', () {
      final r = scanText('hello see this https://bit.ly/3xYz');
      expect(r.level, ScamLevel.dangerous);
      expect(r.badLinks, contains('bit.ly'));
    });
  });

  group('scam engine — suspicious verdicts', () {
    test('courier fee without urgency', () {
      final r = scanText('Your DTDC parcel redelivery is pending, pay the fee to release');
      expect(r.level, ScamLevel.suspicious);
    });

    test('"customs" escalates a parcel message to dangerous (digital-arrest entry)', () {
      final r = scanText('Your parcel is held at customs, pay customs duty to release');
      expect(r.level, ScamLevel.dangerous);
      expect(r.matched.any((m) => m.id == 'digital_arrest'), isTrue);
    });

    test('work-from-home job with joining fee', () {
      final r = scanText('Work from home, earn daily, small joining fee to start');
      expect(r.level, ScamLevel.suspicious);
      expect(r.matched.any((m) => m.id == 'job'), isTrue);
    });

    test('urgency alone (no scam topic) is suspicious, not safe', () {
      final r = scanText('Act now! This offer is expiring, verify now');
      expect(r.level, ScamLevel.suspicious);
      expect(r.matched, isEmpty);
    });
  });

  group('scam engine — safe verdicts (no false alarms on normal life)', () {
    test('ordinary family message', () {
      final r = scanText('Amma, I will reach home by 6, keep dinner ready');
      expect(r.level, ScamLevel.safe);
      expect(r.matched, isEmpty);
      expect(r.badLinks, isEmpty);
    });

    test('empty input', () {
      final r = scanText('   ');
      expect(r.level, ScamLevel.safe);
    });

    test('official link is not flagged', () {
      final r = scanText('Track your train on https://www.irctc.co.in today');
      expect(r.badLinks, isEmpty);
    });
  });

  group('scam engine — result plumbing', () {
    test('topRule is the most severe match', () {
      final r = scanText('parcel held at customs, share the otp to release');
      expect(r.topRule?.weight, ScamLevel.dangerous);
    });

    test('spoken() is non-empty in all three languages for every level', () {
      final samples = {
        ScamLevel.dangerous: scanText('share the otp'),
        ScamLevel.suspicious: scanText('part time job with a small joining fee'),
        ScamLevel.safe: scanText('see you at lunch'),
      };
      samples.forEach((lvl, r) {
        expect(r.level, lvl);
        for (final lang in ['en', 'hi', 'kn']) {
          expect(r.spoken(lang).of(lang).trim(), isNotEmpty,
              reason: 'level=$lvl lang=$lang');
        }
      });
    });
  });

  group('threat heuristics — hostOf parsing', () {
    test('strips scheme, path, query, port and userinfo', () {
      expect(hostOf('https://Example.COM/path?q=1'), 'example.com');
      expect(hostOf('http://evil.com:8080/x'), 'evil.com');
      expect(hostOf('http://google.com@phish.top/login'), 'phish.top');
      expect(hostOf('www.test.in/abc'), 'www.test.in');
    });
  });

  group('threat heuristics — shady detection', () {
    test('blocklisted domain', () {
      expect(assessDomain('update-kyc-now.top').shady, isTrue);
      expect(assessDomain('https://sub.update-kyc-now.top/x').shady, isTrue);
    });

    test('raw IP host', () {
      expect(assessDomain('http://192.168.4.7/login').shady, isTrue);
    });

    test('punycode look-alike', () {
      expect(assessDomain('xn--pple-43d.com').shady, isTrue);
    });

    test('brand spoof with lure words', () {
      expect(assessDomain('paypal-login-secure.xyz').shady, isTrue);
      expect(assessDomain('sbi-account-verify.com').shady, isTrue);
    });

    test('official brand hosts stay clean', () {
      expect(assessDomain('https://accounts.google.com').shady, isFalse);
      expect(assessDomain('https://www.icicibank.com/login').shady, isFalse);
      expect(assessDomain('https://uidai.gov.in').shady, isFalse);
    });

    test('risky TLD + lure word', () {
      expect(assessDomain('free-reward.xyz').shady, isTrue);
    });

    test('excessive hyphens', () {
      expect(assessDomain('a-b-c-d-e.com').shady, isTrue);
    });

    test('normal domains are not flagged', () {
      expect(assessDomain('wikipedia.org').shady, isFalse);
      expect(assessDomain('flipkart.com').shady, isFalse);
    });
  });

  group('safe browser allowlist — siteTrust', () {
    test('commonly used sites are trusted (with and without www/subdomains)', () {
      expect(siteTrust('https://www.google.com/search?q=x'), SiteTrust.trusted);
      expect(siteTrust('youtube.com'), SiteTrust.trusted);
      expect(siteTrust('https://m.facebook.com'), SiteTrust.trusted);
      expect(siteTrust('https://www.amazon.in/dp/B0'), SiteTrust.trusted);
      expect(siteTrust('onlinesbi.sbi'), SiteTrust.trusted);
      expect(siteTrust('https://uidai.gov.in'), SiteTrust.trusted);
      expect(siteTrust('cybercrime.gov.in'), SiteTrust.trusted);
      expect(siteTrust('paytm.com'), SiteTrust.trusted);
    });

    test('lookalike and ride-along hosts are NOT trusted', () {
      expect(isTrustedSite('fakeflipkart.com'), isFalse);
      expect(isTrustedSite('google.com.evil.in'), isFalse);
      expect(isTrustedSite('amazon.in.claim-prize.net'), isFalse);
      expect(isTrustedSite('notgov.in.example.com'), isFalse);
    });

    test('commonly-used coding / learning / work sites are trusted', () {
      for (final s in [
        'https://leetcode.com/problems/two-sum',
        'github.com',
        'https://stackoverflow.com/questions/123',
        'geeksforgeeks.org',
        'hackerrank.com',
        'https://www.w3schools.com/python',
        'https://lens.google.com',
        'https://scholar.google.com',
        'https://meet.google.com/abc',
        'notion.so',
        'figma.com',
        'https://outlook.office.com',
      ]) {
        expect(siteTrust(s), SiteTrust.trusted, reason: s);
      }
    });

    test('random unknown sites are flagged unknown', () {
      expect(siteTrust('some-random-shop.com'), SiteTrust.unknown);
      expect(siteTrust('https://my-new-blog.net'), SiteTrust.unknown);
    });

    test('plain HTTP is detected as insecure', () {
      expect(isInsecureHttp('http://example.com'), isTrue);
      expect(isInsecureHttp('http://leetcode.com'), isTrue);
      expect(isInsecureHttp('https://leetcode.com'), isFalse);
      expect(isInsecureHttp('leetcode.com'), isFalse);
      expect(isInsecureHttp('HTTPS://Secure.com'), isFalse);
    });

    test('shady heuristics still win over unknown', () {
      expect(siteTrust('update-kyc-now.top'), SiteTrust.shady);
      expect(siteTrust('paypal-login-secure.xyz'), SiteTrust.shady);
      expect(siteTrust('http://10.0.0.1/login'), SiteTrust.shady);
    });
  });

  group('learning content integrity', () {
    test('badges have unique ids and trilingual names', () {
      final ids = allBadges.map((b) => b.id).toSet();
      expect(ids.length, allBadges.length);
      for (final b in allBadges) {
        for (final lang in ['en', 'hi', 'kn']) {
          expect(b.name.of(lang).trim(), isNotEmpty);
        }
      }
    });

    test('every lesson has cards, steps and trilingual narration', () {
      expect(microLessons, isNotEmpty);
      for (final m in microLessons) {
        expect(m.cards, isNotEmpty, reason: m.id);
        expect(m.steps, isNotEmpty, reason: m.id);
        for (final lang in ['en', 'hi', 'kn']) {
          expect(m.narration().of(lang).trim(), isNotEmpty,
              reason: '${m.id} $lang');
        }
      }
    });

    test('quiz questions all have trilingual scenario + explanation', () {
      expect(practiceQuiz.length, greaterThanOrEqualTo(3));
      for (final q in practiceQuiz) {
        for (final lang in ['en', 'hi', 'kn']) {
          expect(q.scenario.of(lang).trim(), isNotEmpty);
          expect(q.explain.of(lang).trim(), isNotEmpty);
        }
      }
    });

    test('scam library entries carry real/fake/tell in all languages', () {
      expect(scamLibrary, isNotEmpty);
      for (final c in scamLibrary) {
        for (final lang in ['en', 'hi', 'kn']) {
          expect(c.realExample.of(lang).trim(), isNotEmpty);
          expect(c.fakeExample.of(lang).trim(), isNotEmpty);
          expect(c.tell.of(lang).trim(), isNotEmpty);
        }
      }
    });
  });

  group('i18n', () {
    test('L.of falls back to English for unknown language codes', () {
      const l = L('en', 'hi', 'kn');
      expect(l.of('ta'), 'en');
      expect(l.of('hi'), 'hi');
      expect(l.of('kn'), 'kn');
    });

    test('TTS locales cover all app languages', () {
      expect(ttsLocales.keys, containsAll(['en', 'hi', 'kn']));
    });
  });
}
