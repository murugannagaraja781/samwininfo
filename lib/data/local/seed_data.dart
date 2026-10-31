import '../../models/agent.dart';
import '../../models/buyer_requirement.dart';
import '../../models/chat_message.dart';
import '../../models/notification_item.dart';
import '../../models/property.dart';
import '../../models/user_profile.dart';

class SeedData {
  SeedData._();

  static final List<Agent> initialAgents = [
    const Agent(
      id: 'agent_1',
      name: 'முருகன் (Murugan N)',
      agencyName: 'தென்காசி ட்ரீம்ஸ் ரியல்டர்ஸ்',
      phone: '+91 98941 74944',
      email: 'tenkasidreams@gmail.com',
      avatarKey: 'agent_1',
      rating: 4.9,
      reviewsCount: 148,
      experienceYears: 9,
      totalListings: 28,
      isVerified: true,
      about:
          'தென்காசி மாவட்டம் மற்றும் குற்றாலம் சுற்றுவட்டாரத்தில் DTCP மனைகள், தனி வீடுகள் மற்றும் நஞ்சை/புஞ்சை விவசாய நிலங்களுக்கான நம்பகமான ஆலோசகர்.',
    ),
    const Agent(
      id: 'agent_2',
      name: 'பிரியா சுந்தரம் (Priya S)',
      agencyName: 'பாவூர்சத்திரம் பிரைம் எஸ்டேட்ஸ்',
      phone: '+91 97908 65432',
      email: 'priya.sundaram@tenkasirealty.in',
      avatarKey: 'agent_2',
      rating: 4.8,
      reviewsCount: 96,
      experienceYears: 6,
      totalListings: 19,
      isVerified: true,
      about:
          'பாவூர்சத்திரம் மற்றும் சுரண்டை பகுதிகளில் புதிய வீடுகள் மற்றும் வணிக கடைகள் வாங்குதல்/விற்பதில் சிறந்த சேவை.',
    ),
    const Agent(
      id: 'agent_3',
      name: 'கார்த்திக் ராஜா (Karthik Raja)',
      agencyName: 'குற்றாலம் நேச்சுரல் பார்ம்ஸ்',
      phone: '+91 99402 77889',
      email: 'karthik@tenkasifarmland.in',
      avatarKey: 'agent_3',
      rating: 4.9,
      reviewsCount: 220,
      experienceYears: 12,
      totalListings: 45,
      isVerified: true,
      about:
          'மேற்கு தொடர்ச்சி மலை அடிவாரத்தில் தென்னந்தோப்பு, பண்ணை வீடுகள் மற்றும் மாந்தோப்பு முதலீடுகளில் 12 வருட அனுபவம்.',
    ),
    const Agent(
      id: 'agent_4',
      name: 'அனிதா வெங்கடேஷ் (Anitha V)',
      agencyName: 'ஹெரிடேஜ் பிராபர்ட்டீஸ் தென்காசி',
      phone: '+91 94441 12233',
      email: 'anitha@tenkasidreams.com',
      avatarKey: 'agent_4',
      rating: 4.7,
      reviewsCount: 82,
      experienceYears: 5,
      totalListings: 16,
      isVerified: true,
      about:
          'தென்காசி காசி விஸ்வநாதர் கோவில் மாடவீதி மற்றும் டவுன் பகுதியில் பாரம்பரிய வீடுகள் மற்றும் வாடகை வீடுகள் வழிகாட்டி.',
    ),
  ];

  static final List<Property> initialProperties = [];

  static final List<ChatConversation> initialConversations = [];

  static final List<NotificationItem> initialNotifications = [];

  static const UserProfile initialProfile = UserProfile(
    name: 'விருந்தினர் பயனர் (Guest User)',
    phone: '',
    email: '',
    city: 'Tenkasi',
    avatarKey: 'avatar_user',
    isVerified: false,
    isLoggedIn: false,
    memberSince: '2026',
    completionPercentage: 0.0,
  );

  static const List<String> initialRecentSearches = [];

  static final List<BuyerRequirement> initialBuyerRequirements = [];
}
