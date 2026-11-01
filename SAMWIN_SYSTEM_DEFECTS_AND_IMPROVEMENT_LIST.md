# SamWin Info - குறைபாடுகள் மற்றும் மேம்பாடுகளின் முழுமையான பட்டியல்
# Comprehensive Audit Report: Website & Mobile App (APK) Deficiencies

**ஆய்வு தேதி (Audit Date):** 01 நவம்பர் 2026  
**நிறுவனம் / தளம்:** SamWin Info (`https://samwin.info`)  
**தயாரிப்பு:** Website, Super Admin Panel, Backend APIs & Flutter Android App

---

## 📌 சுருக்கம் (Executive Summary)

தற்போது இணையதளம் மற்றும் அட்மின் பேனல் கோப்புகள் சர்வரில் பதிவேற்றப்பட்டுள்ளன. இருப்பினும், தளம் மற்றும் மொபைல் ஆப் (APK) பொதுமக்களுக்கு வெளியிடுவதற்கு முன்பும், Play Store-ல் பதிவேற்றுவதற்கு முன்பும் கீழ்க்காணும் **4 முக்கிய பிரிவுகளில்** உள்ள குறைபாடுகளை சரிசெய்ய வேண்டும்:

1. **சர்வர் & DNS குறைபாடுகள் (Server & DNS Issues)**
2. **இணையதளக் குறைபாடுகள் (Website & Policy Issues)**
3. **Backend API & கட்டணச் சேவை குறைபாடுகள் (Payment, OTP & Database)**
4. **Flutter மொபைல் ஆப் (APK) குறைபாடுகள் (App Identity, FCM, Keystore)**

---

## 1. சர்வர் & DNS குறைபாடுகள் (Hosting & Infrastructure)

| # | குறைபாடு (Issue) | தாக்கம் (Impact) | செய்ய வேண்டிய தீர்வு (Action Required) |
|---|---|---|---|
| **1.1** | **DNS A Record தவறான IP-ல் உள்ளது** | தளம் திறக்காமல் BigRock Parking Loader சுற்றிக்கொண்டே இருக்கும். | BigRock DNS-ல் `samwin.info` மற்றும் `www`-ன் A Record-ஐ **`66.116.229.226`** என மாற்ற வேண்டும். |
| **1.2** | **Document Root Folder குழப்பம்** | `samwin.info` Addon Domain-ஆக இருந்தால் `public_html`-ல் உள்ள கோப்புகளை சர்வர் காட்டாது. | File Manager-ல் உள்ள கோப்புகளை `/home1/sa1795ec/samwin.info` என்ற போல்டரிலும் Copy/Extract செய்து வைக்க வேண்டும். |
| **1.3** | **SSL சான்றிதழ் (HTTPS)** | பயனர்கள் தளத்தை திறக்கும்போது "Not Secure / SSL Warning" வரலாம். | DNS A Record (.226) மாறியவுடன், cPanel-ல் **AutoSSL** இயக்கி `samwin.info`-க்கு இலவச SSL சான்றிதழ் வழங்க வேண்டும். |
| **1.4** | **FTP User Root Isolation** | `ftb1@samwin.info` மூலமாக அப்லோட் செய்யும் கோப்புகள் சர்வரின் உண்மையான `public_html`-க்கு நேரடியாக செல்லாமல் subfolder-ல் விழுகிறது. | cPanel FTP Accounts-ல் Directory-ஐ வெறும் **`public_html`** என்று மாற்றி Unlimited Quota வழங்க வேண்டும். |

---

## 2. இணையதளக் குறைபாடுகள் (Website & Admin Panel)

| # | குறைபாடு (Issue) | விவரம் (Details) | செய்ய வேண்டிய தீர்வு (Action Required) |
|---|---|---|---|
| **2.1** | **பழைய மின்னஞ்சல் முகவரிகள்** | `terms.html`, `privacy.html`, `refund.html`, `index.html`, `delete-account.html` ஆகியவற்றில் இன்னும் **`tenkasidreams@gmail.com`** என்று உள்ளது. | அனைத்திலும் அதிகாரப்பூர்வ மின்னஞ்சலான **`info@samwininfo.com`** என்று மாற்ற வேண்டும். |
| **2.2** | **Google Sign-In அங்கீகரிக்கப்படாத டொமைன்** | `js/app.js`-ல் உள்ள Firebase Google Login பொத்தானை அழுத்தினால் `auth/unauthorized-domain` பிழை வரும். | Firebase Console -> Authentication -> Settings -> **Authorized Domains**-ல் சென்று `samwin.info` சேர்க்கப்பட வேண்டும். |
| **2.3** | **அலுவலக முகவரி & லொகேஷன்** | Footer மற்றும் Policy பக்கங்களில் Tenkasi Courtallam முகவரி உள்ளது. | SamWin Info-வின் உண்மையான தலைமை அலுவலக முகவரியை `.env` மற்றும் HTML கோப்புகளில் புதுப்பிக்க வேண்டும். |
| **2.4** | **Admin Logo & Title Branding** | சில பக்கங்களில் மற்றும் Tab தலைப்புகளில் பழைய தலைப்புகள் வர வாய்ப்புள்ளது. | `index.html` மற்றும் `admin/index.html`-ன் Title மற்றும் Favicon முழுமையாக `SamWin Info`-க்கு மாற்றப்பட வேண்டும். |

---

## 3. Backend API & கட்டணச் சேவை குறைபாடுகள் (Monetization & Security)

| # | குறைபாடு (Issue) | விவரம் (Details) | செய்ய வேண்டிய தீர்வு (Action Required) |
|---|---|---|---|
| **3.1** | **Razorpay Payment Gateway Test Mode-ல் உள்ளது** | `.env`-ல் உள்ள Razorpay Key (`rzp_test_...`) சோதனைக்கானது. பயனர்கள் உண்மையான பணம் செலுத்த முடியாது. | உங்கள் நேரடி வணிகக் கணக்கின் (Active Business) **`rzp_live_...`** Key ID மற்றும் Secret Key-ஐ `.env`-ல் உள்ளிட வேண்டும். |
| **3.2** | **SMS OTP Gateway - Mock Mode-ல் உள்ளது** | `api/otp.php`-ல் SMS அனுப்பும் முறை `mock` என்று உள்ளது. பயனர்களின் செல்போனுக்கு உண்மையான SMS OTP போகாது. | Fast2SMS (இந்தியா) அல்லது Twilio API Key-ஐ வாங்கி `.env`-ல் `SMS_GATEWAY_PROVIDER=fast2sms` என இயக்க வேண்டும். |
| **3.3** | **Database Seeding & Default Properties** | MySQL Database-ல் இயல்புநிலை மாதிரி விளம்பரங்கள் (Dummy Properties) இருக்கலாம். | `api/init_db.php` இயக்கிய பிறகு தேவையற்ற மாதிரி விளம்பரங்களை நீக்கிவிட்டு உண்மையான விளம்பரங்களை பதிவேற்ற வேண்டும். |
| **3.4** | **Admin Auth Fallback Credentials** | `api/config.php`-ல் பழைய `admin3` / `000003` இருந்தது. தற்போது `admin` / `samwin123` எனப் புதுப்பிக்கப்பட்டுள்ளது. | சர்வரில் இந்த புதிய `api/auth.php` மற்றும் `api/config.php` அப்லோட் செய்யப்பட்டிருப்பதை உறுதிப்படுத்த வேண்டும். |

---

## 4. Flutter மொபைல் ஆப் (APK) குறைபாடுகள்

| # | குறைபாடு (Issue) | விவரம் (Details) | செய்ய வேண்டிய தீர்வு (Action Required) |
|---|---|---|---|
| **4.1** | **App Name (Launcher Title)** | `android/app/build.gradle.kts`-ல் ஆப் பெயர் **`SamWin`** என வெற்றிகரமாக மாற்றப்பட்டது! | ✅ முடிந்தது (Completed) |
| **4.2** | **Package Name (Application ID)** | Package Name அதிகாரப்பூர்வமாக **`com.samwininfo.app`** (மற்றும் Admin-க்கு `com.samwininfo.admin`) என மாற்றப்பட்டது! | ✅ முடிந்தது (Completed) |
| **4.3** | **Firebase Push Notifications (google-services.json)** | `android/app/google-services.json` கோப்பு இன்னும் பழைய `tenkasi-dreams` திட்டத்துடன் இணைக்கப்பட்டுள்ளது. | SamWin Info-க்கு புதிய Firebase Project உருவாக்கி புதிய `google-services.json` வைக்க வேண்டும்; இல்லையேல் Admin Notifications வராது. |
| **4.4** | **Release Keystore Password** | `build.gradle.kts`-ல் signing config பாஸ்வேர்டு பழைய `TenkasiDreams@2026` என உள்ளது. | SamWin-க்கு பிரத்யேகமாக புதிய Production Keystore உருவாக்கப்பட வேண்டும். |
| **4.5** | **Account Deletion Link** | `legal_policy_screen.dart`-ல் கணக்கு நீக்கத்திற்கு `tenkasidreams@gmail.com`-க்கு அனுப்பச் சொல்கிறது. Google Play கொள்கைப்படி இது தவறாகக் கருதப்படலாம். | `info@samwininfo.com` அல்லது இணையதளத்தின் `https://samwin.info/delete-account.html` பக்கத்திற்கு இணைக்க வேண்டும். |
| **4.6** | **Google Play Store Assets** | `playstore_feature_graphic_1024x500.png` மற்றும் `playstore_icon_512.png` ஆகியவற்றில் SamWin முத்திரை உள்ளதா என உறுதி செய்ய வேண்டும். | SamWin லோகோ மற்றும் வண்ணங்களுடன் கூடிய புதிய 512x512 Icon மற்றும் 1024x500 Feature Graphic தயாரிக்க வேண்டும். |

---

## 🛠️ முன்னுரிமைப் பணிகள் (Action Priority Matrix)

### 🔴 அவசரம் (உடனடியாக செய்ய வேண்டியவை - Priority 1):
1. BigRock DNS A Record-ஐ `66.116.229.226`-க்கு மாற்றுதல்.
2. File Manager-ல் உள்ள கோப்புகளை `/samwin.info` போல்டரிலும் நகலெடுத்தல்.
3. `api/init_db.php` இயக்கி Live Database Tables உருவாக்குதல்.

### 🟡 நடுத்தரம் (ஆப் வெளியீட்டிற்கு முன் செய்ய வேண்டியவை - Priority 2):
4. HTML மற்றும் Flutter App-ல் உள்ள பழைய `tenkasidreams@gmail.com` மின்னஞ்சல்களை `info@samwininfo.com` என மாற்றுதல்.
5. Android App Name-ஐ "Ads"-லிருந்து "SamWin Info" என மாற்றுதல்.
6. Razorpay Live API Keys-ஐ `.env`-ல் உள்ளிடுதல்.

### 🟢 மேம்பாடுகள் (Long Term / Play Store Release - Priority 3):
7. Fast2SMS அல்லது Twilio SMS OTP Gateway நேரடி இணைப்பு.
8. SamWin Info-வுக்கான புதிய Firebase Project & `google-services.json`.
9. பிரத்யேக Release Keystore தயாரித்து Play Store Bundle (`.aab`) உருவாக்குதல்.

---
*அறிக்கை தயாரிப்பு: Antigravity AI Pair Programmer*
