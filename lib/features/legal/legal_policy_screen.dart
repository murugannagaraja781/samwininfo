import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/api_config.dart';
import '../../core/theme/app_colors.dart';

class LegalPolicyScreen extends StatefulWidget {
  final int initialTabIndex; // 0 = Terms, 1 = Privacy, 2 = Refund

  const LegalPolicyScreen({super.key, this.initialTabIndex = 0});

  @override
  State<LegalPolicyScreen> createState() => _LegalPolicyScreenState();
}

class _LegalPolicyScreenState extends State<LegalPolicyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 2),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openWebPolicy(String path) async {
    final baseUrl = ApiConfig.instance.serverUrl.replaceAll('/api', '');
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    final uri = Uri.parse('$baseUrl/$cleanPath');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'கொள்கைகள் (Legal & Policies)',
          style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'வலைத்தளத்தில் பார்க்க (Open in Web)',
            icon: const Icon(Icons.open_in_browser_rounded),
            onPressed: () {
              final currentPath = _tabController.index == 1
                  ? 'privacy.html'
                  : _tabController.index == 2
                      ? 'refund.html'
                      : 'terms.html';
              _openWebPolicy(currentPath);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.accentGold,
          indicatorWeight: 3.5,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(text: 'விதிமுறைகள்\n(Terms)', icon: Icon(Icons.description_outlined, size: 20)),
            Tab(text: 'தனியுரிமை\n(Privacy)', icon: Icon(Icons.privacy_tip_outlined, size: 20)),
            Tab(text: 'ரீஃபண்ட்\n(Refund)', icon: Icon(Icons.currency_rupee_rounded, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTermsTab(),
          _buildPrivacyTab(),
          _buildRefundTab(),
        ],
      ),
    );
  }

  // --- 1. TERMS & CONDITIONS TAB ---
  Widget _buildTermsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoBanner(
          icon: Icons.verified_user_rounded,
          title: 'Google Play Store இணக்கமான பயன்பாட்டு விதிமுறைகள்',
          subtitle: 'கடைசியாக புதுப்பிக்கப்பட்டது: செப்டம்பர் 2026',
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          title: '1. விதிமுறைகள் ஏற்பு (Acceptance of Terms)',
          content:
              'SamWin Real Estate ("SamWin") வழங்கும் Android செயலி மற்றும் samwininfo.com வலைத்தளத்தைப் பயன்படுத்துவதன் மூலம், நீங்கள் எங்கள் அனைத்து விதிமுறைகளையும் முழுமையாக ஏற்கிறீர்கள். இதில் உடன்பாடு இல்லை எனில் செயலியைப் பயன்படுத்துவதைத் தவிர்க்கவும்.',
        ),
        _buildSectionCard(
          title: '2. சேவை விளக்கம் (Description of Service)',
          content:
              'SamWin என்பது தென்காசி, குற்றாலம், பாவூர்சத்திரம், சுரண்டை, செங்கோட்டை மற்றும் திருநெல்வேலி சுற்றுவட்டாரப் பகுதிகளில் நிலம், மனை, வீடு, தோட்டம், பண்ணை வீடு மற்றும் கடைகளை வாங்க, விற்க உதவும் டிஜிட்டல் ரியல் எஸ்டேட் தளமாகும் (Online Classifieds & Intermediary Platform).',
        ),
        _buildSectionCard(
          title: '3. விளம்பரம் பதிவிடுவதற்கான நிபந்தனைகள் (Listing Rules)',
          content:
              '• சொத்துக்கள் உண்மையானதாகவும் சரியான விலையுடனும் இருக்க வேண்டும்.\n'
              '• விளம்பரம் பதிவிடுபவர் அச்சொத்தின் உரிமையாளராகவோ அல்லது நேரடி அங்கீகாரம் பெற்றவராகவோ இருக்க வேண்டும்.\n'
              '• போலி பதிவுகள், ஆபாச படங்கள் அல்லது தவறான தகவல்கள் முற்றிலும் தடை செய்யப்பட்டுள்ளது.\n'
              '• அனைத்து விளம்பரங்களும் சூப்பர் அட்மின் ஒப்புதல் (Admin Approval) பெற்ற பின்னரே நேரலையாகக் காட்டப்படும்.',
        ),
        _buildSectionCard(
          title: '4. தொடர்பு எண் திறப்பு & கட்டணம் (Contact Unlock)',
          content:
              'போலி அழைப்புகளைத் தடுக்கவும், உண்மையான வாங்குபவர்களை மட்டும் உரிமையாளருடன் இணைக்கவும் இலவச வரம்பிற்குப் பின் (3 தொடர்புகள்) சிறிய கட்டணம் (₹10 / ₹30) Razorpay பேமெண்ட் கேட்வே மூலம் வசூலிக்கப்படுகிறது. பணம் செலுத்தியவுடன் உரிமையாளரின் மொபைல் எண் மற்றும் WhatsApp உடனே திறக்கப்படும்.',
        ),
        _buildSectionCard(
          title: '5. ஆவண சரிபார்ப்பு & பொறுப்பு துறப்பு (Due Diligence Disclaimer)',
          isWarning: true,
          content:
              'எந்தவொரு சொத்தை வாங்குவதற்கு முன்பும், அதன் மூலப்பத்திரம், பட்டா, சிட்டா, வில்லங்கச் சான்றிதழ் (EC), DTCP / RERA அப்ரூவல் ஆகியவற்றை பதிவுத்துறை அலுவலகத்தில் அல்லது உங்கள் வழக்கறிஞரிடம் சரிபார்த்துக் கொள்ள வேண்டியது வாங்குபவரின் முழுமையான பொறுப்பாகும். இருதரப்பு பணப் பரிவர்த்தனைகளுக்கு நிர்வாகம் சட்டரீதியான பொறுப்பேற்காது.',
        ),
        _buildSectionCard(
          title: '6. ஆளுகை சட்டம் (Governing Law)',
          content:
              'இந்த விதிமுறைகள் இந்திய குடியரசின் சட்டங்களுக்கு உட்பட்டவை. ஏதேனும் கருத்து வேறுபாடுகள் ஏற்பட்டால், அவை தென்காசி நீதிமன்ற அதிகார வரம்பிற்குள் (Tenkasi Jurisdiction) மட்டுமே தீர்க்கப்படும்.',
        ),
        _buildContactCard(),
      ],
    );
  }

  // --- 2. PRIVACY POLICY TAB ---
  Widget _buildPrivacyTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoBanner(
          icon: Icons.shield_rounded,
          title: 'கூகுள் ப்ளே ஸ்டோர் தனியுரிமைக் கொள்கை (Privacy Policy)',
          subtitle: 'Google Play Developer Data Safety Compliant',
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          title: '1. நாங்கள் சேகரிக்கும் தகவல்கள் (Data Collected)',
          content:
              '• தனிப்பட்ட தகவல்: பெயர், மின்னஞ்சல் முகவரி (Google Sign-In) மற்றும் செல்போன் எண்.\n'
              '• சொத்து விவரங்கள்: விற்பனைக்கு பதிவேற்றப்படும் சொத்தின் புகைப்படங்கள், தலைப்பு, விலை, பரப்பளவு, சர்வே எண் மற்றும் முகவரி.\n'
              '• பரிவர்த்தனை ஐடி: தொடர்பு எண் திறப்பிற்கு Razorpay மூலம் பெறப்படும் Order ID, Payment ID (கார்டு அல்லது UPI ரகசிய எண்கள் ஒருபோதும் சேமிக்கப்படுவதில்லை).\n'
              '• சாதனத் தகவல்: Android OS பதிப்பு, ஆப் கிராஷ் பதிவுகள் (Crash reports).',
        ),
        _buildSectionCard(
          title: '2. தகவல்கள் எவ்வாறு பயன்படுத்தப்படுகின்றன?',
          content:
              '• வாங்குபவர்களையும் நில உரிமையாளர்களையும் நேரடியாக இணைக்க.\n'
              '• உரிமையாளரின் போன் மற்றும் WhatsApp எண்ணை பாதுகாப்பாக அன்லாக் செய்ய.\n'
              '• போலி விளம்பரங்களை நீக்கி பயனர்களுக்கு பாதுகாப்பான சூழலை வழங்க.\n'
              '• சட்ட ஆலோசனை மற்றும் ஆவண சரிபார்ப்பு வழிகாட்டுதலை வழங்க.',
        ),
        _buildSectionCard(
          title: '3. மூன்றாம் தரப்பு சேவைகள் (Third-Party SDKs)',
          content:
              '• Google Play Services / Google Sign-In: பாதுகாப்பான உள்நுழைவிற்கு.\n'
              '• Razorpay Payment Gateway (PCI-DSS): பாதுகாப்பான UPI & கார்டு கட்டண பரிவர்த்தனைகளுக்கு.\n'
              '• உங்கள் தனிப்பட்ட தகவல்கள் எந்தவொரு விளம்பர நிறுவனத்திற்கும் விற்கப்படுவதோ, பகிரப்படுவதோ இல்லை.',
        ),
        _buildSectionCard(
          title: '4. தரவு நீக்க உரிமை (Data Deletion - Play Store Required)',
          isWarning: true,
          content:
              'கூகுள் ப்ளே ஸ்டோர் விதிகளின்படி, உங்கள் கணக்கு, மொபைல் எண் மற்றும் பதிவேற்றிய விளம்பரங்களை முழுமையாக நீக்க உங்களுக்கு உரிமை உண்டு.\n\n'
              'நீக்கக் கோரிக்கைக்கு tenkasidreams@gmail.com என்ற மின்னஞ்சலுக்கு "Account & Data Deletion Request" என்று குறிப்பிட்டு உங்கள் பதிவு செய்யப்பட்ட மொபைல் எண்ணை அனுப்பவும். 48 மணி நேரத்திற்குள் அனைத்து விவரங்களும் சர்வரிலிருந்து நிரந்தரமாக அழிக்கப்படும்.',
        ),
        _buildSectionCard(
          title: '5. சிறுவர் தனியுரிமை (Children\'s Privacy)',
          content:
              'எங்கள் செயலி 18 வயதுக்கு மேற்பட்டோருக்கானது. 18 வயதுக்குட்பட்டோரின் தகவல்களை நாங்கள் தெரிந்தே சேகரிப்பதில்லை.',
        ),
        _buildContactCard(),
      ],
    );
  }

  // --- 3. REFUND POLICY TAB ---
  Widget _buildRefundTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoBanner(
          icon: Icons.account_balance_wallet_rounded,
          title: 'பணத்தைத் திரும்பப்பெறும் கொள்கை (Refund & Cancellation)',
          subtitle: 'Razorpay Payment Gateway & Play Store Compliant',
        ),
        const SizedBox(height: 14),
        _buildSectionCard(
          title: '1. உடனடி டிஜிட்டல் சேவை (Instant Digital Service)',
          content:
              'SamWin தளத்தில் வசூலிக்கப்படும் கட்டணம் என்பது நில உரிமையாளரின் தொடர்பு எண்ணை உடனடியாக திரையில் காண்பிப்பதற்கான டிஜிட்டல் தகவல் சேவையாகும் (Instant Contact Reveal Service).',
        ),
        _buildSectionCard(
          title: '2. ரீஃபண்ட் தகுதி (Refund Eligibility)',
          content:
              '• ரீஃபண்ட் உண்டு: வங்கி கணக்கிலிருந்து பணம் பிடிக்கப்பட்டு, நெட்வொர்க் கோளாறால் தொடர்பு எண் திறக்கப்படாமல் போனால் அல்லது தவறுதலாக இருமுறை பணம் பிடிக்கப்பட்டால் (Double Charge).\n\n'
              '• ரீஃபண்ட் இல்லை: கட்டணம் செலுத்தப்பட்டு உரிமையாளர் எண் வெற்றிகரமாக திரையில் காட்டப்பட்டுவிட்டால் (Contact Revealed), அத்தொகை திரும்ப வழங்கப்படாது.',
        ),
        _buildSectionCard(
          title: '3. தோல்வியடைந்த பரிவர்த்தனைகள் (Failed Payments)',
          content:
              'சர்வர் அல்லது நெட்வொர்க் கோளாறால் ஒரு பரிவர்த்தனை தோல்வியடைந்து, உங்கள் கணக்கிலிருந்து பணம் பிடித்தம் செய்யப்பட்டிருந்தால், அத்தொகை Razorpay மூலம் உங்கள் மூல வங்கிக் கணக்கிற்கே 5 முதல் 7 வேலை நாட்களுக்குள் (5-7 Business Days) தானாகவே திரும்ப வந்துவிடும் (Auto Refund).',
        ),
        _buildSectionCard(
          title: '4. ரத்து செய்யும் நடைமுறை (Cancellation)',
          content:
              'உடனடி தகவல் திறப்பு சேவை என்பதால், ஒருமுறை தொடர்பு எண் திறக்கப்பட்ட பின் ஆர்டரை ரத்து செய்ய இயலாது. ஏதேனும் உதவி தேவைப்பட்டால் வாடிக்கையாளர் ஆதரவை உடனே அணுகவும்.',
        ),
        _buildContactCard(),
      ],
    );
  }

  // --- WIDGET HELPERS ---
  Widget _buildInfoBanner({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF065F46),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF047857), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({required String title, required String content, bool isWarning = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWarning ? const Color(0xFFFFFBEB) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWarning ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0),
          width: isWarning ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w800,
              color: isWarning ? const Color(0xFF92400E) : AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: isWarning ? const Color(0xFF78350F) : const Color(0xFF334155),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.headset_mic_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'வாடிக்கையாளர் உதவி (Contact & Support)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'SamWin Info Group\n'
            'நிர்வாகி: Murugan Nagarajan\n'
            'முகவரி: Main Road, Courtallam Junction, Tenkasi - 627811\n'
            'மின்னஞ்சல்: tenkasidreams@gmail.com\n'
            'தொலைபேசி / WhatsApp: +91 98941 74944',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF475569), height: 1.6),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openWebPolicy('terms.html'),
                  icon: const Icon(Icons.language_rounded, size: 16),
                  label: const Text('Website View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
