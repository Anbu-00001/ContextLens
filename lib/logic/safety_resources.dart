// ── Official Indian help resources (women safety + cybercrime) ─────────────
// Verified government channels surfaced when ConsentLens flags a high risk or
// suspected stalkerware. Tapping dials the number or opens the portal.

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'i18n.dart';

class HelpResource {
  final L title;
  final L subtitle;
  final String action; // "tel:1930" or "https://cybercrime.gov.in"
  final IconData icon;

  const HelpResource({
    required this.title,
    required this.subtitle,
    required this.action,
    required this.icon,
  });

  bool get isPhone => action.startsWith('tel:');
}

const List<HelpResource> helpResources = [
  HelpResource(
    icon: Icons.support_agent_rounded,
    title: L('Women Helpline 181', 'महिला हेल्पलाइन 181', 'ಮಹಿಳಾ ಸಹಾಯವಾಣಿ 181'),
    subtitle: L('24x7 help for women in distress', 'संकट में महिलाओं के लिए 24x7 मदद',
        'ಸಂಕಷ್ಟದಲ್ಲಿರುವ ಮಹಿಳೆಯರಿಗೆ 24x7 ಸಹಾಯ'),
    action: 'tel:181',
  ),
  HelpResource(
    icon: Icons.local_police_rounded,
    title: L('Women Helpline 1091', 'महिला हेल्पलाइन 1091', 'ಮಹಿಳಾ ಸಹಾಯವಾಣಿ 1091'),
    subtitle: L('Police women safety helpline', 'पुलिस महिला सुरक्षा हेल्पलाइन',
        'ಪೊಲೀಸ್ ಮಹಿಳಾ ಸುರಕ್ಷತಾ ಸಹಾಯವಾಣಿ'),
    action: 'tel:1091',
  ),
  HelpResource(
    icon: Icons.shield_rounded,
    title: L('Cyber Crime 1930', 'साइबर क्राइम 1930', 'ಸೈಬರ್ ಅಪರಾಧ 1930'),
    subtitle: L('Report online crime & fraud', 'ऑनलाइन अपराध व धोखाधड़ी की शिकायत',
        'ಆನ್‌ಲೈನ್ ಅಪರಾಧ ಮತ್ತು ವಂಚನೆ ವರದಿ'),
    action: 'tel:1930',
  ),
  HelpResource(
    icon: Icons.report_rounded,
    title: L('cybercrime.gov.in', 'cybercrime.gov.in', 'cybercrime.gov.in'),
    subtitle: L('File a complaint online', 'ऑनलाइन शिकायत दर्ज करें',
        'ಆನ್‌ಲೈನ್ ದೂರು ದಾಖಲಿಸಿ'),
    action: 'https://cybercrime.gov.in',
  ),
  HelpResource(
    icon: Icons.sim_card_rounded,
    title: L('Sanchar Saathi', 'संचार साथी', 'ಸಂಚಾರ್ ಸಾಥಿ'),
    subtitle: L('Report fraud SIM / device', 'धोखाधड़ी वाले सिम/डिवाइस की रिपोर्ट',
        'ವಂಚನೆ ಸಿಮ್ / ಸಾಧನ ವರದಿ'),
    action: 'https://sancharsaathi.gov.in',
  ),
  HelpResource(
    icon: Icons.emergency_rounded,
    title: L('Emergency 112', 'आपातकाल 112', 'ತುರ್ತು 112'),
    subtitle: L('National emergency response', 'राष्ट्रीय आपातकालीन सेवा',
        'ರಾಷ್ಟ್ರೀಯ ತುರ್ತು ಸೇವೆ'),
    action: 'tel:112',
  ),
];

Future<void> launchHelp(String action) async {
  final uri = Uri.parse(action);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri,
        mode: action.startsWith('tel:')
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication);
  }
}
