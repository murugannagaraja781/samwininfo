/**
 * SamWin Land - Web App Engine
 * Replicating Desktop OLX Portal Layout & Mobile App Layout
 */

// --- 1. Bilingual Localized Strings (Tamil & English) ---
const I18N = {
  ta: {
    app_title: 'Ads',
    app_tagline: 'SamWin Ads',
    search_placeholder: 'வீடு, நிலம், தோட்டம், கடை தேடுங்கள்...',
    location_default: 'தென்காசி, தமிழ்நாடு',
    hero_title: 'உங்கள் கனவின் இடம் இங்கே!',
    hero_subtitle: 'வீடு, நிலம், தோட்டம், முதலீடு... எல்லாமும் ஒரே இடத்தில்!',
    hero_cta: 'Ads →',
    verify_title: '100% சரிபார்க்கப்பட்ட நம்பகமான சொத்துக்கள்',
    verify_subtitle: 'அனைத்து பத்திரங்களும் DTCP & பட்டா சரிபார்க்கப்பட்ட நேரடி சொத்துக்கள்',
    verify_cta: 'இலவச விளம்பரம் போடுங்க >',
    sec_categories: 'சொத்து பிரிவுகள் (Explore Categories)',
    sec_all: 'அனைத்தும்',
    sec_featured: 'சிறப்புச் சொத்துகள் (Featured Properties)',
    sec_hot: '★ TOP RECOMMENDED',
    sec_nearby: 'அருகிலுள்ள சொத்துகள்',
    sec_latest: 'புதிய பரிந்துரைகள் (Fresh Recommendations)',
    sec_available: 'கிடைப்பவை',
    sec_show_all: 'அனைத்தும் காட்டு',
    sec_no_props: 'இந்த பிரிவில் சொத்துகள் எதுவும் இல்லை',
    quick_buyer_title: 'மக்களின் தேவை (Buyer Board)',
    quick_buyer_sub: 'இடம் & வீடு தேவை பதிவுகள் மற்றும் வாங்குபவர்கள்',
    quick_calc_title: 'நில அளவை மாற்றி (Calculator)',
    quick_calc_sub: 'சென்ட், குழி, ஏக்கர், ஹெக்டேர் நேரடி கணக்கீடு',
    badge_new: 'புதியது',
    badge_calc: 'அளவை',
    nav_home: 'முகப்பு',
    nav_favs: 'விருப்பங்கள்',
    nav_post: 'பதிவிடு',
    nav_needs: 'தேவைகள்',
    nav_admin: 'நிர்வாகம்',
    call_now: 'அழைக்கவும்',
    whatsapp: 'வாட்ஸ்அப்',
    verified_badge: 'சரிபார்க்கப்பட்டது',
    price_lakh: 'லட்சம்',
    price_crore: 'கோடி',
    price_k: 'ஆயிரம்',
    unit_cent: 'சென்ட்',
    unit_kuzhi: 'குழி',
    unit_acre: 'ஏக்கர்',
    unit_sqft: 'ச.அடி',
    post_ad_title: 'விளம்பரம் பதிவிடு',
    post_success_msg: 'விளம்பரம் வெற்றிகரமாக வெளியிடப்பட்டது!'
  },
  en: {
    app_title: 'Ads',
    app_tagline: 'SamWin Ads',
    search_placeholder: 'Search House, Land, Farm, Shop...',
    location_default: 'Tenkasi, Tamil Nadu',
    hero_title: 'Your Dream Place is Here!',
    hero_subtitle: 'House, Land, Farm, Investment... Everything in one place!',
    hero_cta: 'SamWin →',
    verify_title: '100% Verified & Trusted Properties',
    verify_subtitle: 'Direct legal titles, DTCP & Patta verified properties across Tenkasi',
    verify_cta: 'Post Free Ad >',
    sec_categories: 'Explore Categories',
    sec_all: 'All Categories',
    sec_featured: 'Featured Properties',
    sec_hot: '★ TOP RECOMMENDED',
    sec_nearby: 'Nearby Properties',
    sec_latest: 'Fresh Recommendations',
    sec_available: 'Available',
    sec_show_all: 'Show All',
    sec_no_props: 'No properties found in this category',
    quick_buyer_title: "People's Demand (Buyer Board)",
    quick_buyer_sub: 'Buyer & Tenant Requests with Direct Contact',
    quick_calc_title: 'Land Calculator',
    quick_calc_sub: 'Live Cent, Kuzhi, Acre, Hectare Converter',
    badge_new: 'NEW',
    badge_calc: 'CONVERT',
    nav_home: 'Home',
    nav_favs: 'Favorites',
    nav_post: 'Post Ad',
    nav_needs: 'Demands',
    nav_admin: 'Admin',
    call_now: 'Call Now',
    whatsapp: 'WhatsApp',
    verified_badge: 'Verified',
    price_lakh: 'Lakh',
    price_crore: 'Crore',
    price_k: 'K',
    unit_cent: 'Cent',
    unit_kuzhi: 'Kuzhi',
    unit_acre: 'Acre',
    unit_sqft: 'sq.ft',
    post_ad_title: 'Post Free Ad',
    post_success_msg: 'Property Ad Posted Successfully!'
  }
};

// 6 Categories matching the Flutter App
const CATEGORIES = [
  { id: 'house', nameEn: 'House / Villa', nameTa: 'வீடு / வில்லா', img: 'assets/images/cat_house.png' },
  { id: 'land', nameEn: 'Land / Plots', nameTa: 'நிலம் / மனை', img: 'assets/images/cat_land.png' },
  { id: 'farmland', nameEn: 'Farm / Thottam', nameTa: 'விவசாய தோட்டம்', img: 'assets/images/cat_farm.png' },
  { id: 'shop', nameEn: 'Shop / Commercial', nameTa: 'வணிகக் கடை', img: 'assets/images/cat_shop.png' },
  { id: 'apartment', nameEn: 'Apartment', nameTa: 'அபார்ட்மெண்ட்', img: 'assets/images/cat_apartment.png' },
  { id: 'rental', nameEn: 'Rental / Lease', nameTa: 'வாடகைக்கு', img: 'assets/images/cat_rental.png' }
];

// App State
let state = {
  lang: localStorage.getItem('tenkasi_lang') || 'ta',
  activeCategory: 'all',
  searchQuery: '',
  selectedLocation: 'Tenkasi, Tamil Nadu',
  properties: [],
  favorites: JSON.parse(localStorage.getItem('tenkasi_favs') || '[]'),
  requirements: [],
  user: JSON.parse(localStorage.getItem('tenkasi_user') || 'null'),
  unlockedProperties: JSON.parse(localStorage.getItem('tenkasi_unlocked_props') || '[]'),
  freeContactsUsed: parseInt(localStorage.getItem('tenkasi_free_contacts_used') || '0', 10),
  pendingUnlockPropId: null,
  paymentConfig: {
    razorpayKeyId: 'rzp_test_TeE2LFCxmmioPq',
    razorpayAccountId: 'acc_Tdw7B4Z0zFh95x',
    unlockPrice: 30,
    freeLimit: 3
  }
};

// --- Initialization ---
document.addEventListener('DOMContentLoaded', () => {
  initUI();
  fetchPaymentConfig();
  fetchProperties();
  fetchRequirements();
  initCalculator();
  initSearch();
});

function t(key) {
  const dict = I18N[state.lang] || I18N.ta;
  return dict[key] || key;
}

function setLanguage(lang) {
  state.lang = lang;
  localStorage.setItem('tenkasi_lang', lang);
  updateStaticTexts();
  renderCategories();
  renderProperties();
}

function toggleLanguage() {
  setLanguage(state.lang === 'ta' ? 'en' : 'ta');
}

function initUI() {
  updateStaticTexts();
  updateUserAuthUI();
  renderCategories();
}

function updateStaticTexts() {
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    el.textContent = t(key);
  });
  const searchInput = document.getElementById('searchInput');
  if (searchInput) {
    searchInput.placeholder = t('search_placeholder');
  }
  const langBtn = document.getElementById('langToggleBtn');
  if (langBtn) {
    langBtn.textContent = state.lang === 'ta' ? 'English' : 'தமிழ்';
  }
  const headerLoc = document.getElementById('headerLocation');
  if (headerLoc) {
    headerLoc.textContent = state.lang === 'ta' ? 'தென்காசி' : 'Tenkasi';
  }
}

// --- 2. Category Strip Rendering (Balanced 6 Cards) ---
function renderCategories() {
  const container = document.getElementById('categoryGrid');
  if (!container) return;

  container.innerHTML = CATEGORIES.map(cat => {
    const isActive = state.activeCategory === cat.id;
    const label = state.lang === 'ta' ? cat.nameTa : cat.nameEn;
    return `
      <div class="cat-box ${isActive ? 'active' : ''}" onclick="selectCategory('${cat.id}')">
        <div class="cat-box-img-wrap">
          <img src="${cat.img}" alt="${label}" onerror="this.src='assets/images/cat_land.png'">
        </div>
        <div class="cat-box-label">${label}</div>
      </div>
    `;
  }).join('');
}

function selectCategory(catId) {
  if (state.activeCategory === catId) {
    state.activeCategory = 'all';
  } else {
    state.activeCategory = catId;
  }
  renderCategories();
  renderProperties();
  
  // Highlight in ribbon
  document.querySelectorAll('.ribbon-link').forEach(link => {
    link.classList.remove('active');
  });
}

function showAllCategories() {
  state.activeCategory = 'all';
  state.searchQuery = '';
  const sInput = document.getElementById('searchInput');
  if (sInput) sInput.value = '';
  renderCategories();
  renderProperties();
}

function filterByLocation(loc) {
  state.searchQuery = loc;
  const sInput = document.getElementById('searchInput');
  if (sInput) sInput.value = loc;
  renderProperties();
  window.scrollTo({ top: 350, behavior: 'smooth' });
}

// --- 3. Property Data Fetching & Rendering ---
async function fetchProperties() {
  try {
    const res = await fetch('api/properties.php');
    const data = await res.json();
    if (data.success && data.properties) {
      state.properties = data.properties;
    } else {
      loadFallbackProperties();
    }
  } catch (err) {
    console.warn('API error, using local fallback:', err);
    loadFallbackProperties();
  }
  renderProperties();
  handleUrlDeepLinks();
}

function loadFallbackProperties() {
  state.properties = [
    {
      id: 'prop_1',
      title: '3 BHK Modern Independent Luxury Villa',
      propertyType: 'House',
      price: 8800000,
      location: 'Surandai Road, Tenkasi',
      areaSqFt: 2150,
      landUnitValue: 5,
      landUnit: 'Cent',
      facing: 'North-East',
      isVerified: true,
      isFeatured: true,
      postedDate: new Date().toISOString(),
      agent: { name: 'Rajesh Kumar', phone: '+91 98401 23456' }
    },
    {
      id: 'prop_2',
      title: 'Prime 10 Cents DTCP Residential Plot',
      propertyType: 'Land',
      price: 2500000,
      location: 'Courtallam Main Road, Tenkasi',
      areaSqFt: 4360,
      landUnitValue: 10,
      landUnit: 'Cent',
      facing: 'East',
      isVerified: true,
      isFeatured: true,
      postedDate: new Date().toISOString(),
      agent: { name: 'Murugan', phone: '+91 98941 74944' }
    },
    {
      id: 'prop_3',
      title: '2.5 Acres Coconut Farmland with Free EB Service',
      propertyType: 'Farmland',
      price: 6500000,
      location: 'Shenkottai, Tenkasi',
      areaSqFt: 108900,
      landUnitValue: 2.5,
      landUnit: 'Acre',
      facing: 'North',
      isVerified: true,
      isFeatured: true,
      postedDate: new Date().toISOString(),
      agent: { name: 'Senthil Nathan', phone: '+91 94431 12345' }
    },
    {
      id: 'prop_4',
      title: 'Commercial Corner Road Shop with 3-Phase Power',
      propertyType: 'Shop',
      price: 4500000,
      location: 'Old Bus Stand, Tenkasi',
      areaSqFt: 850,
      landUnitValue: 850,
      landUnit: 'Sq.Ft',
      facing: 'East',
      isVerified: true,
      isFeatured: true,
      postedDate: new Date().toISOString(),
      agent: { name: 'Direct Owner', phone: '+91 98941 74944' }
    },
    {
      id: 'prop_5',
      title: '2 BHK Gated Community Luxury Apartment',
      propertyType: 'Apartment',
      price: 4200000,
      location: 'Sankarankovil Road, Tenkasi',
      areaSqFt: 1100,
      landUnitValue: 1100,
      landUnit: 'Sq.Ft',
      facing: 'South',
      isVerified: true,
      isFeatured: false,
      postedDate: new Date().toISOString(),
      agent: { name: 'Realty Hub', phone: '+91 98941 74944' }
    },
    {
      id: 'prop_6',
      title: 'Commercial Space for Rent / Office Lease',
      propertyType: 'Rental',
      price: 25000,
      location: 'Main Bazaar, Tenkasi',
      areaSqFt: 1200,
      landUnitValue: 1200,
      landUnit: 'Sq.Ft',
      facing: 'North',
      isVerified: true,
      isFeatured: false,
      postedDate: new Date().toISOString(),
      agent: { name: 'Direct Owner', phone: '+91 98941 74944' }
    }
  ];
}

function formatPrice(amount, isRental = false) {
  if (!amount || isNaN(amount)) return '₹ --';
  const num = Number(amount);
  const isTa = state.lang === 'ta';

  if (num >= 10000000) {
    const cr = (num / 10000000).toFixed(2).replace(/\.00$/, '');
    return `₹ ${cr} ${isTa ? 'கோடி' : 'Cr'}${isRental ? '/mo' : ''}`;
  } else if (num >= 100000) {
    const lk = (num / 100000).toFixed(2).replace(/\.00$/, '');
    return `₹ ${lk} ${isTa ? 'லட்சம்' : 'Lakh'}${isRental ? '/mo' : ''}`;
  } else if (num >= 1000) {
    const k = (num / 1000).toFixed(0);
    return `₹ ${k} K${isRental ? '/mo' : ''}`;
  }
  return `₹ ${num.toLocaleString('en-IN')}${isRental ? '/mo' : ''}`;
}

function getAreaDisplay(p) {
  if (p.landUnitValue && p.landUnit) {
    const unitName = state.lang === 'ta' && p.landUnit.toLowerCase() === 'cent' ? 'சென்ட்' : p.landUnit;
    return `${p.landUnitValue} ${unitName}`;
  }
  return `${p.areaSqFt || 0} sq.ft`;
}

function getPropertyImage(p) {
  if (p.imageUrls && p.imageUrls.length > 0) return p.imageUrls[0];
  const type = (p.propertyType || '').toLowerCase();
  if (type.includes('house') || type.includes('villa')) return 'assets/images/rec_house.png';
  if (type.includes('land') || type.includes('plot')) return 'assets/images/rec_land.png';
  if (type.includes('farm') || type.includes('garden') || type.includes('தோட்டம்')) return 'assets/images/rec_farm.png';
  if (type.includes('apartment') || type.includes('flat')) return 'assets/images/rec_apartment.png';
  if (type.includes('rental') || type.includes('lease') || type.includes('வாடகை')) return 'assets/images/rec_rental.png';
  if (type.includes('shop') || type.includes('commercial') || type.includes('office')) return 'assets/images/cat_shop.png';
  return 'assets/images/rec_house.png';
}

function buildCardHtml(p, isFeaturedCard = false) {
  const isFav = state.favorites.includes(p.id);
  const priceFormatted = formatPrice(p.price, p.propertyType === 'Rental');
  const areaFormatted = getAreaDisplay(p);
  const locationShort = (p.location || 'TENKASI').split(',')[0].toUpperCase();
  const isPremium = p.isPremium === true || p.isPremium === 1 || p.isPremium === '1' || p.isPremium === 'true';

  return `
    <div class="olx-property-card ${isPremium ? 'premium-card' : ''}" onclick="openPropertyDetail('${p.id}')">
      <div class="card-top-thumbnail">
        <img src="${getPropertyImage(p)}" alt="${p.title}" loading="lazy">
        ${(p.isFeatured || isFeaturedCard) ? `<div class="badge-hot-tag">★ ${t('sec_hot')}</div>` : ''}
        ${isPremium
          ? `<div class="badge-premium-tag">💎 ${state.lang === 'ta' ? 'பிரீமியம்' : 'PREMIUM'}</div>`
          : `<div class="badge-free-tag">🟢 ${state.lang === 'ta' ? 'இலவச தொடர்பு' : 'FREE'}</div>`
        }
        <button class="card-favorite-icon ${isFav ? 'active' : ''}" onclick="toggleFavorite(event, '${p.id}')" title="Save Favorite">♥</button>
        ${p.isVerified ? `<div class="badge-verified-tag">✓ ${t('verified_badge')}</div>` : ''}
      </div>
      <div class="card-content-wrap">
        <div>
          <div class="card-price-text ${isPremium ? 'premium-price' : ''}">${priceFormatted}</div>
          <div class="card-specs-line">${areaFormatted} ${p.facing ? '• ' + p.facing + ' Facing' : ''}</div>
          <div class="card-title-text" title="${p.title}">${p.title}</div>
        </div>
        <div class="card-footer-info">
          <span>📍 ${locationShort}</span>
          <span>${isPremium ? '⭐ PREMIUM' : '100% VERIFIED'}</span>
        </div>
      </div>
    </div>
  `;
}

function renderProperties() {
  const searchQ = state.searchQuery.toLowerCase().trim();
  const cat = state.activeCategory;

  let filtered = state.properties.filter(p => {
    // Only show active / approved properties to the public
    const status = (p.status || 'active').toLowerCase();
    if (status !== 'active') return false;

    // Category match
    if (cat !== 'all') {
      const pType = (p.propertyType || '').toLowerCase();
      if (!pType.includes(cat)) return false;
    }
    // Search match
    if (searchQ) {
      const matchTitle = (p.title || '').toLowerCase().includes(searchQ);
      const matchLoc = (p.location || '').toLowerCase().includes(searchQ);
      const matchType = (p.propertyType || '').toLowerCase().includes(searchQ);
      if (!matchTitle && !matchLoc && !matchType) return false;
    }
    return true;
  });

  // 1. Featured Section
  const featured = filtered.filter(p => p.isFeatured);
  const featuredSection = document.getElementById('featuredSection');
  const featuredContainer = document.getElementById('featuredContainer');

  if (featuredContainer && featuredSection) {
    if (featured.length > 0 && cat === 'all' && !searchQ) {
      featuredSection.style.display = 'block';
      featuredContainer.innerHTML = featured.map(p => buildCardHtml(p, true)).join('');
    } else {
      featuredSection.style.display = 'none';
    }
  }

  // 2. Main 4-Column OLX Grid Feed
  const feedContainer = document.getElementById('latestGrid');
  const feedCount = document.getElementById('feedCount');
  if (feedCount) feedCount.textContent = `${filtered.length} ${t('sec_available')}`;

  if (feedContainer) {
    if (filtered.length === 0) {
      feedContainer.innerHTML = `
        <div style="grid-column: 1 / -1; text-align: center; padding: 40px 16px; background: #FFFFFF; border-radius: 8px; border: 1px solid #D8DFE0;">
          <div style="font-size: 48px; margin-bottom: 8px;">🏡</div>
          <div style="font-size: 16px; font-weight: 700; color: #1E293B;">${t('sec_no_props')}</div>
          <button class="lang-btn" style="margin-top: 12px;" onclick="showAllCategories()">${t('sec_show_all')}</button>
        </div>
      `;
      return;
    }

    feedContainer.innerHTML = filtered.map(p => buildCardHtml(p, false)).join('');
  }
}

// --- 4. Favorites Toggle ---
function toggleFavorite(event, propId) {
  event.stopPropagation();
  const idx = state.favorites.indexOf(propId);
  if (idx >= 0) {
    state.favorites.splice(idx, 1);
  } else {
    state.favorites.push(propId);
  }
  localStorage.setItem('tenkasi_favs', JSON.stringify(state.favorites));
  renderProperties();
}

function showFavorites() {
  const favProps = state.properties.filter(p => state.favorites.includes(p.id));
  state.activeCategory = 'all';
  state.searchQuery = '';
  state.properties = favProps.length > 0 ? favProps : state.properties;
  renderProperties();
}

// --- 5. Search Bar Handling ---
function initSearch() {
  const input = document.getElementById('searchInput');
  if (!input) return;
  input.addEventListener('input', (e) => {
    state.searchQuery = e.target.value;
    renderProperties();
  });
}

// --- 6. Property Detail Modal & Deep Linking ---
function handleUrlDeepLinks() {
  const urlParams = new URLSearchParams(window.location.search);
  const targetId = urlParams.get('id') || urlParams.get('prop_id');
  if (targetId) {
    setTimeout(() => {
      openPropertyDetail(targetId, false);
    }, 150);
  }
  const targetCat = urlParams.get('category');
  if (targetCat) {
    selectCategory(targetCat);
  }
}

function shareProperty(id, titleEnc, price) {
  const title = decodeURIComponent(titleEnc);
  const shareUrl = window.location.origin + '/?id=' + encodeURIComponent(id);
  if (navigator.share) {
    navigator.share({
      title: title,
      text: title + ' (' + price + ') - ' + shareUrl,
      url: shareUrl
    }).catch(() => {});
  } else if (navigator.clipboard && navigator.clipboard.writeText) {
    navigator.clipboard.writeText(shareUrl).then(() => {
      alert('இணைப்பு நகலெடுக்கப்பட்டது (Link copied to clipboard):\n' + shareUrl);
    });
  } else {
    prompt('விளம்பர இணைப்பு (Property Link):', shareUrl);
  }
}

function openPropertyDetail(propId, updateHistory = true) {
  const prop = state.properties.find(p => p.id == propId);
  if (!prop) return;

  const modal = document.getElementById('propertyDetailModal');
  const content = document.getElementById('propertyDetailBody');
  if (!modal || !content) return;

  // Sync browser URL for SEO and single-product bookmarking
  if (updateHistory) {
    const newUrl = window.location.pathname + '?id=' + encodeURIComponent(propId);
    if (window.location.search !== '?id=' + propId) {
      window.history.pushState({ propId: propId }, '', newUrl);
    }
  }

  const phone = prop.agent?.phone || '+919894174944';
  const cleanPhone = phone.replace(/[^0-9]/g, '');
  const waMsg = encodeURIComponent(`வணக்கம், SamWin இணையதளத்தில் உங்கள் விளம்பரத்தை பார்த்தேன்: ${prop.title} (${formatPrice(prop.price)}). கூடுதல் விவரங்கள் அறிய விரும்புகிறேன்.`);

  content.innerHTML = `
    <div class="detail-gallery">
      <img src="${getPropertyImage(prop)}" alt="${prop.title}">
    </div>
    <div class="detail-price">${formatPrice(prop.price, prop.propertyType === 'Rental')}</div>
    <div class="detail-title">${prop.title}</div>
    <div style="font-size: 13px; color: #64748B; margin-bottom: 12px;">📍 ${prop.location || 'Tenkasi'}</div>

    <!-- Social Share & WhatsApp Direct -->
    <div style="display: flex; gap: 8px; margin-bottom: 16px;">
      <button onclick="shareProperty('${prop.id}', '${encodeURIComponent(prop.title)}', '${formatPrice(prop.price)}')" style="flex: 1; display: flex; align-items: center; justify-content: center; gap: 6px; padding: 10px 14px; background: #f1f5f9; border: 1.5px solid #cbd5e1; border-radius: 8px; font-weight: 700; font-size: 13px; color: #1e293b; cursor: pointer;">
        <span>🔗 பகிர் (Share)</span>
      </button>
      <a href="https://api.whatsapp.com/send?text=${encodeURIComponent(prop.title + ' - ' + formatPrice(prop.price) + ' | ' + window.location.origin + '/?id=' + prop.id)}" target="_blank" style="display: flex; align-items: center; justify-content: center; gap: 6px; padding: 10px 16px; background: #25D366; color: #fff; border-radius: 8px; font-weight: 700; font-size: 13px; text-decoration: none;">
        <span>📲 WhatsApp</span>
      </a>
    </div>

    <div class="detail-specs-grid">
      <div class="detail-spec-item">
        <span class="detail-spec-label">சொத்து வகை (Type)</span>
        <span class="detail-spec-val">${prop.propertyType || 'House'}</span>
      </div>
      <div class="detail-spec-item">
        <span class="detail-spec-label">நில அளவு (Area)</span>
        <span class="detail-spec-val">${getAreaDisplay(prop)}</span>
      </div>
      <div class="detail-spec-item">
        <span class="detail-spec-label">திசை (Facing)</span>
        <span class="detail-spec-val">${prop.facing || 'East'}</span>
      </div>
      <div class="detail-spec-item">
        <span class="detail-spec-label">அங்கீகாரம் (Approval)</span>
        <span class="detail-spec-val">${prop.approvalType || 'DTCP / Patta Approved'}</span>
      </div>
    </div>

    <div style="font-size: 14px; font-weight: 800; margin-bottom: 6px; color: #0F172A;">முழு விவரம் (Description)</div>
    <div style="font-size: 13px; color: #475569; line-height: 1.6; margin-bottom: 16px;">
      ${prop.description || 'SamWin சரிபார்க்கப்பட்ட சொத்து. நல்ல குடியிருப்பு பகுதி, தார் சாலை மற்றும் சுத்தமான குடிநீர் வசதி கொண்டது.'}
    </div>

    ${renderContactSection(prop, phone, cleanPhone, waMsg)}
  `;

  modal.classList.add('active');
}

function closeModal(modalId) {
  const modal = document.getElementById(modalId);
  if (modal) modal.classList.remove('active');
  if (modalId === 'propertyDetailModal' && window.location.search.includes('id=')) {
    window.history.pushState({}, '', window.location.pathname);
  }
}

// --- 7. Land Unit Calculator ---
function openCalculatorModal() {
  const modal = document.getElementById('calculatorModal');
  if (modal) modal.classList.add('active');
}

function initCalculator() {
  const valInput = document.getElementById('calcInputVal');
  const unitSelect = document.getElementById('calcInputUnit');
  if (!valInput || !unitSelect) return;

  const calculate = () => {
    const val = parseFloat(valInput.value) || 0;
    const unit = unitSelect.value;
    let sqft = 0;

    switch (unit) {
      case 'cent': sqft = val * 435.6; break;
      case 'kuzhi': sqft = val * 144.0; break;
      case 'acre': sqft = val * 43560.0; break;
      case 'ground': sqft = val * 2400.0; break;
      case 'hectare': sqft = val * 107639.1; break;
      case 'sqft': default: sqft = val; break;
    }

    document.getElementById('resCent').textContent = (sqft / 435.6).toFixed(2);
    document.getElementById('resKuzhi').textContent = (sqft / 144.0).toFixed(2);
    document.getElementById('resAcre').textContent = (sqft / 43560.0).toFixed(4);
    document.getElementById('resGround').textContent = (sqft / 2400.0).toFixed(2);
    document.getElementById('resHectare').textContent = (sqft / 107639.1).toFixed(4);
    document.getElementById('resSqft').textContent = sqft.toLocaleString('en-IN', { maximumFractionDigits: 1 });
  };

  valInput.addEventListener('input', calculate);
  unitSelect.addEventListener('change', calculate);
  calculate();
}

// --- 8. Buyer Requirements Board ---
async function fetchRequirements() {
  try {
    const res = await fetch('api/requirements.php');
    const data = await res.json();
    if (data.success && data.requirements) {
      state.requirements = data.requirements;
    } else {
      loadFallbackRequirements();
    }
  } catch (err) {
    loadFallbackRequirements();
  }
}

function loadFallbackRequirements() {
  state.requirements = [
    {
      id: 'req_1',
      title: '5 சென்ட் DTCP குடியிருப்பு மனை தேவை',
      category: 'நிலம் / மனை',
      budget: '₹ 20 லட்சம்',
      location: 'சுரண்டை அல்லது தென்காசி',
      buyerName: 'கார்த்திக் (Buyer)',
      phone: '+91 98401 11223'
    },
    {
      id: 'req_2',
      title: '1 ஏக்கர் விவசாய தோட்டம் கிணற்று பாசனத்துடன் தேவை',
      category: 'தோட்டம்',
      budget: '₹ 40 லட்சம்',
      location: 'செங்கோட்டை சுற்றுவட்டாரம்',
      buyerName: 'ராதாகிருஷ்ணன்',
      phone: '+91 94432 44556'
    }
  ];
}

function openBuyerBoardModal() {
  const modal = document.getElementById('buyerBoardModal');
  const container = document.getElementById('buyerBoardList');
  if (!modal || !container) return;

  container.innerHTML = state.requirements.map(r => `
    <div class="buyer-req-card">
      <div class="req-header">
        <span class="req-badge">${r.category || 'தேவை'}</span>
        <span class="req-budget">${r.budget || 'பேசிக்கலாம்'}</span>
      </div>
      <div class="req-title">${r.title}</div>
      <div class="req-location">📍 ${r.location} • ${r.buyerName || 'வாங்குபவர்'}</div>
      <a href="tel:${(r.phone || '').replace(/[^0-9]/g, '')}" class="req-contact-btn">📞 தொடர்பு கொள்ள (Contact Buyer)</a>
    </div>
  `).join('');

  modal.classList.add('active');
}

// --- 9. Post Free Ad Wizard Modal ---
function openPostAdModal(category) {
  const modal = document.getElementById('postAdModal');
  if (!modal) return;

  const active = category || (state.activeCategory === 'house' ? 'House' : (state.activeCategory === 'land' ? 'Land' : (state.activeCategory === 'farmland' ? 'Farmland' : (state.activeCategory === 'shop' ? 'Shop' : (state.activeCategory === 'rental' ? 'Rental' : 'House')))));

  const select = document.getElementById('postPropertyTypeSelect');
  if (select) {
    select.value = active;
    handlePropertyTypeChange(active);
  }
  modal.classList.add('active');
}

function handlePropertyTypeChange(type) {
  const houseSec = document.getElementById('houseSpecificSection');
  const landSec = document.getElementById('landSpecificSection');
  const farmSec = document.getElementById('farmSpecificSection');
  const aptSec = document.getElementById('apartmentSpecificSection');
  const rentalSec = document.getElementById('rentalSpecificSection');
  const titleInput = document.getElementById('postAdTitleInput');

  if (houseSec) houseSec.style.display = type === 'House' ? 'block' : 'none';
  if (landSec) landSec.style.display = type === 'Land' ? 'block' : 'none';
  if (farmSec) farmSec.style.display = type === 'Farmland' ? 'block' : 'none';
  if (aptSec) aptSec.style.display = type === 'Apartment' ? 'block' : 'none';
  if (rentalSec) rentalSec.style.display = type === 'Rental' ? 'block' : 'none';

  if (titleInput) {
    if (type === 'House') {
      titleInput.value = '2 BHK தனி வீடு - 1200 Sq.Ft விற்பனைக்கு';
    } else if (type === 'Land') {
      titleInput.value = 'DTCP அங்கீகாரம் பெற்ற 10 சென்ட் வீட்டு மனை விற்பனைக்கு';
    } else if (type === 'Farmland') {
      titleInput.value = '2 ஏக்கர் விவசாய தோட்டம் - போர்வெல் & இலவச EB வசதியுடன்';
    } else if (type === 'Apartment') {
      titleInput.value = '2 BHK Luxury Apartment - 1050 Sq.Ft விற்பனைக்கு';
    } else if (type === 'Rental') {
      titleInput.value = 'வாடகைக்கு / லீசுக்கு - மாத வாடகை ₹8,500';
    } else if (type === 'Shop') {
      titleInput.value = 'மெயின் பஜார் வணிகக் கடை / அலுவலகம் விற்பனைக்கு';
    }
  }
}

async function handlePostAdSubmit(event) {
  event.preventDefault();
  const form = event.target;
  const submitBtn = document.getElementById('submitPostAdBtn');
  if (submitBtn) {
    submitBtn.disabled = true;
    submitBtn.innerHTML = '⏳ சமர்ப்பிக்கப்படுகிறது...';
  }
  const formData = new FormData(form);

  const propType = formData.get('propertyType') || 'House';
  const isHouse = propType === 'House';
  const isLand = propType === 'Land';
  const isFarmland = propType === 'Farmland';
  const isApt = propType === 'Apartment';
  const isRental = propType === 'Rental';

  // Gather category specific amenities
  const amenities = [];
  if (isHouse) {
    form.querySelectorAll('input[name="houseAmenities"]:checked').forEach(cb => amenities.push(cb.value));
  } else if (isLand) {
    form.querySelectorAll('input[name="landAmenities"]:checked').forEach(cb => amenities.push(cb.value));
  } else if (isFarmland) {
    form.querySelectorAll('input[name="farmWaterEb"]:checked').forEach(cb => amenities.push(cb.value));
    if (formData.get('hasTrees') === 'Yes') amenities.push('மரங்கள்: ' + (formData.get('treesDetail') || 'உண்டு'));
    if (formData.get('hasIncome') === 'Yes') amenities.push('வருமானம்: ' + (formData.get('incomeDetail') || 'உண்டு'));
  }

  // Calculate Area SqFt and Units
  let calculatedSqFt = 1200;
  let unitVal = 10;
  let unit = 'Cent';
  let bedrooms = null;
  let subType = null;
  let approval = 'Standard';
  let loanOk = true;
  let facing = 'East';

  if (isHouse) {
    calculatedSqFt = Number(formData.get('builtAreaSqFt') || 1200);
    bedrooms = Number(formData.get('houseBhk') || 2);
    subType = formData.get('houseSubType') || 'தனி வீடு';
    approval = subType.includes('அப்ரூவல்') ? 'Approved' : 'Standard';
    loanOk = subType.includes('Finance') || true;
    facing = formData.get('facing') || 'East';
  } else if (isLand) {
    unit = formData.get('landUnit') || 'Cent';
    unitVal = Number(formData.get('landAreaValue') || 10);
    if (unit === 'Cent') calculatedSqFt = Math.round(unitVal * 435.6);
    else if (unit === 'Acre') calculatedSqFt = Math.round(unitVal * 43560);
    else if (unit === 'Kuzhi') calculatedSqFt = Math.round(unitVal * 144);
    else calculatedSqFt = Math.round(unitVal);
    approval = formData.get('landApproval') || 'DTCP Approved';
    loanOk = formData.get('landFinance') === 'Yes';
    subType = 'மனை / நிலம்';
    facing = formData.get('landFacing') || 'East';
  } else if (isFarmland) {
    unit = formData.get('farmUnit') || 'Acre';
    unitVal = Number(formData.get('farmAreaValue') || 2);
    if (unit === 'Acre') calculatedSqFt = Math.round(unitVal * 43560);
    else if (unit === 'Cent') calculatedSqFt = Math.round(unitVal * 435.6);
    else if (unit === 'Kuzhi') calculatedSqFt = Math.round(unitVal * 144);
    else calculatedSqFt = Math.round(unitVal);
    subType = 'விவசாய தோட்டம்';
    approval = 'Panchayat Approved';
    facing = formData.get('farmFacing') || 'East';
  } else if (isApt) {
    calculatedSqFt = Number(formData.get('aptAreaSqFt') || 1050);
    bedrooms = Number(formData.get('aptBhk') || 2);
    subType = formData.get('aptUds') ? ('UDS: ' + formData.get('aptUds')) : 'Apartment';
    approval = formData.get('aptApproval') || 'CMDA / DTCP Approved';
    facing = formData.get('aptFacing') || 'East';
    amenities.push(formData.get('aptWater') || 'Bore Water');
    if (formData.get('aptLift') === 'Yes') amenities.push('லிஃப்ட் வசதி உண்டு');
  } else if (isRental) {
    subType = formData.get('rentalSubType') || 'வீடு (House)';
    unit = 'Rent';
    unitVal = Number(formData.get('rentalMonthlyAmount') || 8500);
    calculatedSqFt = Number(formData.get('areaSqFt') || 800);
  } else {
    calculatedSqFt = Number(formData.get('areaSqFt') || 500);
    subType = 'கடை / வணிகம்';
  }

  const payload = {
    title: formData.get('title'),
    propertyType: propType,
    posterType: formData.get('posterType') || 'Owner',
    price: Number(formData.get('price')),
    isPriceNegotiable: formData.get('priceType') === 'Negotiable',
    location: formData.get('location'),
    areaSqFt: calculatedSqFt,
    bedrooms: bedrooms,
    rentalSubType: subType,
    furnishingStatus: isHouse ? (formData.get('houseStatus') || 'Complete (முழுமை பெற்றது)') : 'Unfurnished',
    approvalType: approval,
    isBankLoanAvailable: loanOk,
    landFeatures: amenities.length ? amenities : ['போர்வெல்', 'EB மின் இணைப்பு'],
    landUnitValue: unitVal,
    landUnit: unit,
    facing: facing,
    description: formData.get('description'),
    sellerName: formData.get('sellerName'),
    sellerPhone: formData.get('sellerPhone'),
    imageUrl: formData.get('imageUrl') || '',
    isUserPosted: true,
    status: 'pending'
  };

  try {
    const res = await fetch('api/properties.php', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    const resData = await res.json();
    closeModal('postAdModal');
    form.reset();

    // Show nice confirmation modal
    const succModal = document.getElementById('postAdSuccessModal');
    if (succModal) {
      succModal.classList.add('active');
    }
  } catch (err) {
    alert('பிழை ஏற்பட்டது. தயவுசெய்து மீண்டும் முயற்சிக்கவும்.');
  } finally {
    if (submitBtn) {
      submitBtn.disabled = false;
      submitBtn.innerHTML = '✨ 100% இலவசமாக விளம்பரம் பதிவிடு (Submit Free Ad)';
    }
  }
}

// --- 10. Legal Advice Modal Logic ---
function openLegalAdviceModal() {
  const modal = document.getElementById('legalAdviceModal');
  if (modal) {
    const box = document.getElementById('legalAdviceSuccessBox');
    const form = document.getElementById('legalAdviceForm');
    if (box) box.style.display = 'none';
    if (form) form.style.display = 'block';
    modal.classList.add('active');
  }
}

async function handleLegalAdviceSubmit(event) {
  event.preventDefault();
  const form = event.target;
  const btn = document.getElementById('submitLegalAdviceBtn');
  if (btn) {
    btn.disabled = true;
    btn.innerHTML = '⏳ அனுப்பப்படுகிறது...';
  }
  const formData = new FormData(form);
  const payload = {
    name: formData.get('name'),
    phone: formData.get('phone'),
    location: formData.get('location'),
    serviceType: formData.get('serviceType'),
    notes: formData.get('notes')
  };

  try {
    const res = await fetch('api/legal_advice.php', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    const data = await res.json();
    form.style.display = 'none';
    const box = document.getElementById('legalAdviceSuccessBox');
    if (box) box.style.display = 'block';
  } catch (err) {
    alert('சட்ட ஆலோசனை கோரிக்கை அனுப்புவதில் பிழை. வாட்ஸ்அப் வழியாக தொடர்பு கொள்ளவும்.');
  } finally {
    if (btn) {
      btn.disabled = false;
      btn.innerHTML = '<span>⚖️</span> <span>ஆலோசனை கோருக (Submit Request)</span>';
    }
  }
}

// --- 11. Google Authentication Engine (Web) ---
function updateUserAuthUI() {
  const loginBtn = document.getElementById('headerLoginBtn');
  const userText = document.getElementById('userLoginText');
  if (!loginBtn || !userText) return;

  if (state.user && state.user.isLoggedIn) {
    const shortName = state.user.name.split(' ')[0];
    userText.textContent = shortName;
    loginBtn.style.borderColor = '#10B981';
    loginBtn.style.background = '#ECFDF5';
  } else {
    userText.textContent = state.lang === 'ta' ? 'Google உள்நுழைவு' : 'Google Login';
    loginBtn.style.borderColor = '#CBD5E1';
    loginBtn.style.background = '#FFFFFF';
  }
}

function openGoogleLoginModal(reason = '') {
  const modal = document.getElementById('googleLoginModal');
  const body = document.getElementById('googleLoginBody');
  if (!modal || !body) return;

  if (state.user && state.user.isLoggedIn) {
    // Logged In View
    body.innerHTML = `
      <div style="text-align: center; padding: 10px 0;">
        <div style="width: 64px; height: 64px; border-radius: 50%; background: #002f34; color: #FFFFFF; font-size: 26px; font-weight: 800; display: flex; align-items: center; justify-content: center; margin: 0 auto 12px auto; border: 3px solid #BFDBFE;">
          ${(state.user.name || 'U').charAt(0).toUpperCase()}
        </div>
        <div style="font-size: 17px; font-weight: 800; color: #0F172A;">${state.user.name}</div>
        <div style="font-size: 13px; color: #64748B; margin-top: 2px;">${state.user.email}</div>
        ${state.user.phone ? `<div style="font-size: 13px; color: #059669; font-weight: 700; margin-top: 4px;">📱 ${state.user.phone}</div>` : ''}
        <div style="display: inline-block; margin-top: 8px; background: #DCFCE7; color: #166534; font-size: 11px; font-weight: 800; padding: 3px 10px; border-radius: 12px;">
          ✓ Google Verified Account
        </div>

        <div style="margin-top: 20px; display: flex; flex-direction: column; gap: 10px;">
          ${!state.user.phone ? `
            <button onclick="openUserPhoneModal(); closeModal('googleLoginModal');" style="width: 100%; background: #059669; color: #fff; border: none; padding: 11px; border-radius: 8px; font-size: 13.5px; font-weight: 700; cursor: pointer;">
              📱 செல்போன் எண் பதிவு செய்க
            </button>
          ` : ''}
          <button onclick="openPostAdModal(); closeModal('googleLoginModal');" style="width: 100%; background: #002f34; color: #FFFFFF; border: none; padding: 11px; border-radius: 8px; font-size: 13.5px; font-weight: 700; cursor: pointer;">
            ➕ புதிய விளம்பரம் போடுங்க (Post Free Ad)
          </button>
          <button onclick="handleSignOutWeb()" style="width: 100%; background: #FEE2E2; color: #991B1B; border: 1px solid #FECACA; padding: 10px; border-radius: 8px; font-size: 13px; font-weight: 700; cursor: pointer;">
            🚪 கணக்கிலிருந்து வெளியேறு (Sign Out)
          </button>
        </div>
      </div>
    `;
  } else {
    // Sign In View with One-Click Google
    const bannerHtml = reason === 'contact_unlock' ? `
      <div style="background: linear-gradient(135deg, #ECFDF5 0%, #EFF6FF 100%); border: 1.5px solid #10B981; border-radius: 10px; padding: 12px; margin-bottom: 16px; text-align: left;">
        <div style="font-size: 13px; font-weight: 800; color: #065F46; display: flex; align-items: center; gap: 6px;">
          <span>🎁</span> இலவச 3 தொடர்புகளைப் பெற உள்நுழைக!
        </div>
        <div style="font-size: 11.5px; color: #374151; margin-top: 4px; line-height: 1.4;">
          சொத்து உரிமையாளரின் தொடர்பு எண்ணை இலவசமாகப் பார்க்க, முதலில் உங்கள் <b>Gmail</b> மூலம் உள்நுழையவும்.
        </div>
      </div>
    ` : '';

    body.innerHTML = `
      <div style="text-align: center;">
        ${bannerHtml}
        <div style="margin-bottom: 16px;">
          <div style="font-size: 15px; font-weight: 800; color: #1E293B;">Google (Gmail) கணக்கு மூலம் உள்நுழைக</div>
          <div style="font-size: 12px; color: #64748B; margin-top: 4px;">Sign in with Google to view free owner contacts</div>
        </div>

        <!-- Official Google Sign In Button -->
        <button onclick="triggerFirebaseGoogleSignIn()" style="width: 100%; background: #FFFFFF; border: 1.5px solid #CBD5E1; padding: 12px 16px; border-radius: 8px; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 12px; box-shadow: 0 2px 6px rgba(0,0,0,0.06); transition: all 0.2s;">
          <svg style="width: 22px; height: 22px;" viewBox="0 0 24 24">
            <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
            <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
            <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.06H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.94l2.85-2.22.81-.63z"/>
            <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.06l3.66 2.84c.87-2.6 3.3-4.52 6.16-4.52z"/>
          </svg>
          <span style="font-size: 14.5px; font-weight: 800; color: #1F2937;">Continue with Google (Gmail)</span>
        </button>

        <div style="font-size: 11px; color: #94A3B8; margin-top: 16px; line-height: 1.4;">
          பாதுகாப்பான Firebase & Google உள்நுழைவு. முதல் 3 தொடர்புகள் இலவசம்.
        </div>
      </div>
    `;
  }

  modal.classList.add('active');
}

// --- Firebase Web Configuration ---
const FIREBASE_CONFIG = {
  apiKey: "AIzaSyDubzcYrOL3LKI7Umh103KBfG4sErZ8T3c",
  authDomain: "tenkasi-dreams.firebaseapp.com",
  projectId: "tenkasi-dreams",
  storageBucket: "tenkasi-dreams.firebasestorage.app",
  messagingSenderId: "472022657503",
  appId: "1:472022657503:web:4f16967efafb8c19a63c6a",
  measurementId: "G-MDTX84WDD7"
};

// Initialize Firebase
try {
  if (typeof firebase !== 'undefined' && !firebase.apps.length) {
    firebase.initializeApp(FIREBASE_CONFIG);
  }
} catch (e) {
  console.warn('Firebase init error:', e);
}

function triggerFirebaseGoogleSignIn() {
  if (typeof firebase !== 'undefined' && firebase.auth) {
    const auth = firebase.auth();
    const provider = new firebase.auth.GoogleAuthProvider();
    provider.addScope('email');
    provider.addScope('profile');

    auth.signInWithPopup(provider)
      .then((result) => {
        const user = result.user;
        console.log('Firebase Google Sign-In Success:', user.displayName, user.email);
        handleGoogleSignInWeb(user.email, user.displayName, user.phoneNumber, user.photoURL);
      })
      .catch((error) => {
        console.warn('Firebase popup sign-in notice:', error.code, error.message);
        if (error.code === 'auth/popup-closed-by-user') {
          return;
        }
        if (error.code === 'auth/unauthorized-domain') {
          const fallback = confirm(
            '⚠️ Firebase அங்கீகரிப்பு அறிவிப்பு:\n\n' +
            'உங்கள் டொமைன் (samwin.info) இன்னும் Firebase Console-ல் "Authorized domains" பட்டியலில் சேர்க்கப்படவில்லை.\n\n' +
            'இதை சரிசெய்ய:\n' +
            'Firebase Console -> Authentication -> Settings -> Authorized domains -> Add "samwin.info"\n\n' +
            'தற்போது நீங்கள் சோதனை செய்ய உங்கள் Gmail முகவரியை நேரடியாக உள்ளிட்டு உள்நுழைய விரும்புகிறீர்களா?'
          );
          if (fallback) {
            const emailInput = prompt('உங்கள் Gmail முகவரியை உள்ளிடவும் (எ.கா: yourname@gmail.com):', 'user@gmail.com');
            if (emailInput && emailInput.includes('@')) {
              const namePart = emailInput.split('@')[0];
              const formattedName = namePart.charAt(0).toUpperCase() + namePart.slice(1);
              handleGoogleSignInWeb(emailInput.trim(), formattedName, '', '');
            }
          }
          return;
        }
        alert('Google உள்நுழைவில் பிழை: ' + (error.message || 'தயவுசெய்து மீண்டும் முயற்சிக்கவும்.'));
      });
  } else {
    alert('Firebase Authentication ஏற்றப்படவில்லை. பக்கத்தை ரீலோட் செய்யவும்.');
  }
}

function syncUserToFirestoreWeb(user) {
  if (typeof firebase !== 'undefined' && firebase.firestore) {
    try {
      const db = firebase.firestore();
      db.collection('users').doc(user.email).set({
        email: user.email,
        name: user.name,
        phone: user.phone || '',
        updatedAt: firebase.firestore.FieldValue.serverTimestamp()
      }, { merge: true }).catch(err => console.log('Firestore sync note:', err));
    } catch (_) {}
  }
}

function handleSignOutWeb() {
  if (typeof firebase !== 'undefined' && firebase.auth) {
    try { firebase.auth().signOut(); } catch (_) {}
  }
  localStorage.removeItem('tenkasi_user');
  state.user = null;
  updateUserAuthUI();
  closeModal('googleLoginModal');
  alert('நீங்கள் கணக்கிலிருந்து வெளியேறிவிட்டீர்கள் (Signed out successfully).');
}

function handleGoogleSignInWeb(email, name, phone, photoUrl) {
  const cleanEmail = email || 'info@samwininfo.com';
  const cleanName = name || 'SamWin User';

  const existingUser = JSON.parse(localStorage.getItem('tenkasi_user') || 'null');
  const existingPhone = phone || ((existingUser && existingUser.phone) ? existingUser.phone : '');

  state.user = {
    isLoggedIn: true,
    email: cleanEmail,
    name: cleanName,
    phone: existingPhone,
    city: existingUser?.city || 'Tenkasi',
    photoUrl: photoUrl || ''
  };
  localStorage.setItem('tenkasi_user', JSON.stringify(state.user));
  syncUserToFirestoreWeb(state.user);
  updateUserAuthUI();
  closeModal('googleLoginModal');

  // If user does not have a primary mobile number, ask for it immediately!
  if (!state.user.phone || state.user.phone.trim() === '') {
    openUserPhoneModal();
  } else {
    alert(`✅ Google மூலம் உள்நுழைந்தீர்கள்!\nவணக்கம், ${state.user.name}`);
    if (state.pendingUnlockPropId) {
      const pid = state.pendingUnlockPropId;
      state.pendingUnlockPropId = null;
      doUnlockContactFree(pid);
    }
  }
}

function openUserPhoneModal() {
  const modal = document.getElementById('userPhoneModal');
  if (!modal) return;

  const nameEl = document.getElementById('userPhoneModalName');
  const emailEl = document.getElementById('userPhoneModalEmail');
  const inputEl = document.getElementById('primaryUserPhoneInput');

  if (nameEl) nameEl.textContent = state.user?.name || 'பயனரே';
  if (emailEl) emailEl.textContent = state.user?.email || '';
  if (inputEl) {
    inputEl.value = '';
    setTimeout(() => inputEl.focus(), 250);
  }

  modal.classList.add('active');
}

function handleUserPhoneSubmit(event) {
  if (event) event.preventDefault();
  const phoneInput = document.getElementById('primaryUserPhoneInput');
  if (!phoneInput || !phoneInput.value) return;

  const rawPhone = phoneInput.value.replace(/[^0-9]/g, '');
  if (rawPhone.length < 10) {
    alert('தயவுசெய்து சரியான 10 இலக்க செல்போன் எண்ணை உள்ளிடவும்');
    return;
  }

  const clean10 = rawPhone.slice(-10);
  const formattedPhone = '+91 ' + clean10;

  if (!state.user) {
    state.user = { isLoggedIn: true, email: 'user@gmail.com', name: 'User' };
  }
  state.user.phone = formattedPhone;
  localStorage.setItem('tenkasi_user', JSON.stringify(state.user));
  updateUserAuthUI();
  closeModal('userPhoneModal');

  alert(`✅ உங்கள் செல்போன் எண் (${formattedPhone}) வெற்றிகரமாக பதிவு செய்யப்பட்டது!\n\nOTP சரிபார்ப்பு தேவையில்லை. இனி எப்போதும் உங்கள் எண் மீண்டும் கேட்கப்படாது.`);

  if (state.pendingUnlockPropId) {
    const pid = state.pendingUnlockPropId;
    state.pendingUnlockPropId = null;
    doUnlockContactFree(pid);
  }
}

function handleSignOutWeb() {
  state.user = null;
  localStorage.removeItem('tenkasi_user');
  updateUserAuthUI();
  closeModal('googleLoginModal');
  alert('கணக்கிலிருந்து வெற்றிகரமாக வெளியேறிவிட்டீர்கள் (Signed out successfully).');
}

// --- 8. Monetization, 3-Contact Free Limit & Razorpay Paywall ---

async function fetchPaymentConfig() {
  try {
    const res = await fetch('api/payments.php?action=config');
    const data = await res.json();
    if (data && data.success) {
      state.paymentConfig = {
        razorpayKeyId: data.razorpayKeyId || 'rzp_test_TeE2LFCxmmioPq',
        razorpayAccountId: data.razorpayAccountId || 'acc_Tdw7B4Z0zFh95x',
        unlockPrice: Number(data.unlockPrice || 30),
        freeLimit: Number(data.freeLimit !== undefined ? data.freeLimit : 3),
        unlockContactsCount: Number(data.unlockContactsCount || 1),
        offerActive: !!data.offerActive,
        offerPrice: Number(data.offerPrice || 10),
        offerContactsCount: Number(data.offerContactsCount || 1),
        offerBannerText: data.offerBannerText || 'சிறப்பு சலுகை: வெறும் ₹10 செலுத்தி உரிமையாளர் எண்ணை உடனே பெறலாம்!',
        effectivePrice: Number(data.effectivePrice || (data.offerActive ? data.offerPrice : data.unlockPrice) || 30),
        effectiveContactsCount: Number(data.effectiveContactsCount || 1),
        currency: data.currency || '₹',
        companyName: data.companyName || 'SamWin'
      };
    }
  } catch (err) {
    console.warn('Payment config fetch fallback:', err);
  }
}

function renderContactSection(prop, phone, cleanPhone, waMsg) {
  const isPremium = prop.isPremium === true || prop.isPremium === 1 || prop.isPremium === '1' || prop.isPremium === 'true';
  const isUnlocked = !isPremium || state.unlockedProperties.includes(prop.id);
  const freeLimit = state.paymentConfig.freeLimit !== undefined ? state.paymentConfig.freeLimit : 3;
  const freeRemaining = Math.max(0, freeLimit - state.freeContactsUsed);
  const isOffer = !!state.paymentConfig.offerActive;
  const standardPrice = state.paymentConfig.unlockPrice || 30;
  const effectivePrice = state.paymentConfig.effectivePrice || (isOffer ? state.paymentConfig.offerPrice : standardPrice) || 30;
  const effectiveCount = state.paymentConfig.effectiveContactsCount || 1;
  const offerBanner = state.paymentConfig.offerBannerText || 'சிறப்பு தள்ளுபடி சலுகை';

  // Case 1: Free property (Not premium) -> Direct Free access for everyone!
  if (!isPremium) {
    return `
      <div style="background: #ECFDF5; padding: 14px; border-radius: 12px; border: 1.5px solid #10B981; margin-bottom: 16px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
          <div style="font-size: 12px; font-weight: 700; color: #065F46;">🟢 நேரடி தொடர்பு (இலவச விளம்பரம் - Free Ad)</div>
          <span style="background: #10B981; color: #fff; font-size: 11px; font-weight: 800; padding: 2px 8px; border-radius: 6px;">✓ 100% இலவசம் (Free)</span>
        </div>
        <div style="font-size: 15px; font-weight: 800; color: #0F172A;">${prop.agent?.name || 'Direct Owner'}</div>
        <div style="font-size: 15px; font-weight: 800; color: #059669; margin-top: 4px;">📞 ${phone}</div>
      </div>

      <div class="detail-actions-row">
        <a href="tel:${cleanPhone}" class="btn-call">📞 ${t('call_now')}</a>
        <a href="https://wa.me/${cleanPhone}?text=${waMsg}" target="_blank" class="btn-whatsapp">💬 ${t('whatsapp')}</a>
      </div>
    `;
  }

  // Case 2: Premium Property is already unlocked
  if (isUnlocked) {
    return `
      <div style="background: #FFFBEB; padding: 14px; border-radius: 12px; border: 1.5px solid #D97706; margin-bottom: 16px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
          <div style="font-size: 12px; font-weight: 700; color: #92400E;">💎 பிரீமியம் சொத்து தொடர்பு எண்</div>
          <span style="background: #D97706; color: #fff; font-size: 11px; font-weight: 800; padding: 2px 8px; border-radius: 6px;">✓ திறக்கப்பட்டது (Unlocked)</span>
        </div>
        <div style="font-size: 15px; font-weight: 800; color: #0F172A;">${prop.agent?.name || 'Direct Owner'}</div>
        <div style="font-size: 15px; font-weight: 800; color: #B45309; margin-top: 4px;">📞 ${phone}</div>
      </div>

      <div class="detail-actions-row">
        <a href="tel:${cleanPhone}" class="btn-call">📞 ${t('call_now')}</a>
        <a href="https://wa.me/${cleanPhone}?text=${waMsg}" target="_blank" class="btn-whatsapp">💬 ${t('whatsapp')}</a>
      </div>
    `;
  }

  // Masked phone format: +91 98••••••••
  const maskedPhone = phone && phone.length > 6 ? phone.substring(0, 7) + '••••••••' : '+91 98••••••••';

  // Case 3: Premium Property - User still has Free Contact Views remaining
  if (freeRemaining > 0 && freeLimit > 0) {
    return `
      <div style="background: linear-gradient(135deg, #FFFBEB 0%, #EFF6FF 100%); border: 1.5px solid #F59E0B; border-radius: 12px; padding: 14px; margin-bottom: 16px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
          <div style="font-size: 12px; font-weight: 700; color: #92400E;">💎 பிரீமியம் விளம்பர தொடர்பு</div>
          <span style="background: #2563EB; color: #fff; font-size: 11px; font-weight: 800; padding: 2px 8px; border-radius: 10px;">🎁 இலவச பார்வை: ${freeRemaining} / ${freeLimit} மீதம்</span>
        </div>
        <div style="font-size: 14px; font-weight: 800; color: #0F172A;">${prop.agent?.name || 'Direct Owner'}</div>
        <div style="font-size: 13px; font-weight: 700; color: #64748B; margin-top: 4px;">📞 ${maskedPhone}</div>
        <div style="font-size: 12px; color: #4B5563; margin-top: 8px; line-height: 1.4;">
          பிரீமியம் சொத்துக்களுக்கு உங்கள் இலவச தொடர்புகளில் இருந்து 1 குறைத்து உடனடியாக திறக்கலாம்.
        </div>
        <button onclick="unlockContactFree('${prop.id}')" style="margin-top: 10px; width: 100%; background: #2563EB; color: #fff; border: none; padding: 11px; border-radius: 8px; font-weight: 800; font-size: 13.5px; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 6px; box-shadow: 0 3px 8px rgba(37,99,235,0.25);">
          🔓 இலவசமாக தொடர்பு எண்ணை திறக்கவும் (${freeRemaining} மீதம்)
        </button>
      </div>

      <div class="detail-actions-row">
        <button onclick="unlockContactFree('${prop.id}')" class="btn-call" style="border:none; cursor:pointer;">📞 எண் பார்க்க</button>
        <button onclick="unlockContactFree('${prop.id}')" class="btn-whatsapp" style="border:none; cursor:pointer;">💬 WhatsApp பார்க்க</button>
      </div>
    `;
  }

  // Case 4: Free Views Reached! Show Paywall
  return `
    <div style="background: linear-gradient(135deg, ${isOffer ? '#FFFBEB 0%, #FEF3C7 100%' : '#FFFBEB 0%, #FEF2F2 100%'}); border: 2px solid #D97706; border-radius: 14px; padding: 16px; margin-bottom: 16px; box-shadow: 0 4px 14px rgba(217,119,6,0.15);">
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px;">
        <div style="font-size: 12px; font-weight: 800; color: #92400E;">
          💎 பிரீமியம் விளம்பரம் - ${isOffer ? '🎉 ' + offerBanner : (freeLimit > 0 ? `🔒 3 இலவச பார்வைகள் முடிந்தது` : '🔒 உரிமையாளர் தொடர்பு எண்')}
        </div>
        <span style="background: #D97706; color: #fff; font-size: 11px; font-weight: 800; padding: 3px 8px; border-radius: 6px;">
          ${isOffer ? `ஆஃபர்: ₹${effectivePrice}` : `₹${effectivePrice} மட்டும்`}
        </span>
      </div>
      <div style="font-size: 14px; font-weight: 800; color: #0F172A;">${prop.agent?.name || 'Direct Owner'}</div>
      <div style="font-size: 13px; font-weight: 700; color: #94A3B8; margin-top: 4px;">📞 ${maskedPhone}</div>
      <div style="font-size: 12.5px; color: #374151; margin-top: 8px; line-height: 1.5;">
        இந்த பிரீமியம் நில உரிமையாளரின் நேரடி மொபைல் எண் மற்றும் WhatsApp விவரங்களை உடனடியாக திறக்க <b>₹${effectivePrice}</b> செலுத்தவும்.
      </div>
      <div style="display: flex; align-items: center; gap: 8px; margin-top: 10px; font-size: 11px; color: #059669; font-weight: 700;">
        <span>⚡ UPI / GPay</span> • <span>PhonePe</span> • <span>Paytm</span> • <span>Cards</span>
      </div>
      <button onclick="promptContactUnlockPay('${prop.id}')" style="margin-top: 12px; width: 100%; background: linear-gradient(135deg, #D97706 0%, #B45309 100%); color: #fff; border: none; padding: 12px; border-radius: 8px; font-weight: 800; font-size: 14px; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px; box-shadow: 0 4px 12px rgba(217,119,6,0.3);">
        💳 ₹${effectivePrice} செலுத்தி தொடர்பு எண்ணை திறக்கவும் (${isOffer ? 'ஆஃபர் விலை' : 'Razorpay'})
      </button>
    </div>

    <div class="detail-actions-row">
      <button onclick="promptContactUnlockPay('${prop.id}')" class="btn-call" style="border:none; cursor:pointer; background: #64748B;">🔒 எண் பூட்டப்பட்டுள்ளது</button>
      <button onclick="promptContactUnlockPay('${prop.id}')" class="btn-whatsapp" style="border:none; cursor:pointer; background: #D97706;">💳 ₹${effectivePrice} செலுத்துக</button>
    </div>
  `;
}

function promptContactUnlockPay(propId) {
  const prop = state.properties.find(p => p.id == propId);
  if (!prop) return;

  const modal = document.getElementById('contactUnlockModal');
  const body = document.getElementById('contactUnlockBody');
  if (!modal || !body) return;

  const isOffer = !!state.paymentConfig.offerActive;
  const standardPrice = state.paymentConfig.unlockPrice || 30;
  const price = state.paymentConfig.effectivePrice || (isOffer ? state.paymentConfig.offerPrice : standardPrice) || 10;
  const count = state.paymentConfig.effectiveContactsCount || 1;
  const offerBanner = state.paymentConfig.offerBannerText || '🎉 சிறப்பு ஆஃபர்!';
  const upiId = state.paymentConfig.upiId || '9894174944@upi';
  const upiPayUri = `upi://pay?pa=${encodeURIComponent(upiId)}&pn=${encodeURIComponent('SamWin')}&am=${price}&cu=INR&tn=${encodeURIComponent('Contact Unlock ' + prop.id)}`;
  const qrUrl = `https://api.qrserver.com/v1/create-qr-code/?size=160x160&data=${encodeURIComponent(upiPayUri)}`;

  body.innerHTML = `
    <!-- Property Info Card -->
    <div style="display: flex; gap: 12px; background: #F8FAFC; padding: 12px; border-radius: 12px; margin-bottom: 14px; border: 1px solid #E2E8F0; align-items: center;">
      <img src="${getPropertyImage(prop)}" style="width: 65px; height: 65px; object-fit: cover; border-radius: 8px; flex-shrink: 0;">
      <div style="min-width: 0;">
        <div style="font-size: 13px; font-weight: 800; color: #0F172A; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">${prop.title}</div>
        <div style="font-size: 11.5px; color: #64748B; margin-top: 2px;">📍 ${prop.location || 'Tenkasi'}</div>
        <div style="font-size: 13px; font-weight: 800; color: #059669; margin-top: 2px;">${formatPrice(prop.price)}</div>
      </div>
    </div>

    <!-- Offer Banner -->
    ${isOffer ? `
      <div style="background: linear-gradient(135deg, #ECFDF5, #FEF3C7); border: 1.5px solid #10B981; border-radius: 10px; padding: 8px 12px; margin-bottom: 14px; text-align: center; font-size: 12.5px; font-weight: 800; color: #065F46;">
        ${offerBanner}
      </div>
    ` : ''}

    <!-- Price Section -->
    <div style="text-align: center; margin-bottom: 16px;">
      <div style="font-size: 11px; font-weight: 800; color: #64748B; text-transform: uppercase; letter-spacing: 0.5px;">செலுத்த வேண்டிய உடனடி கட்டணம்</div>
      <div style="display: flex; align-items: baseline; justify-content: center; gap: 8px; margin: 4px 0;">
        ${isOffer ? `<del style="font-size: 20px; color: #94A3B8; font-weight: 700;">₹${standardPrice}</del>` : ''}
        <div style="font-size: 38px; font-weight: 900; color: #002f34;">₹${price}</div>
      </div>
      <div style="display: inline-block; background: #ECFDF5; color: #065F46; font-size: 11px; font-weight: 800; padding: 3px 10px; border-radius: 12px; border: 1px solid #A7F3D0;">
        ⚡ இந்த சொத்தின் உரிமையாளர் நேரடி எண் & WhatsApp உடனே திறக்கப்படும்
      </div>
    </div>

    <!-- Speed Payment Section: Instant 1-Click UPI -->
    <div style="margin-bottom: 14px;">
      <div style="font-size: 12px; font-weight: 800; color: #0F172A; margin-bottom: 8px; display: flex; align-items: center; gap: 6px;">
        <span>⚡ அதிவேக UPI (1 நொடியில் செலுத்தலாம்):</span>
      </div>

      <!-- UPI Deep-link App Buttons for Mobile -->
      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-bottom: 10px;">
        <a href="${upiPayUri}" target="_blank" onclick="handleUpiClick('${prop.id}', 'PhonePe')" style="text-decoration: none; display: flex; align-items: center; justify-content: center; gap: 6px; padding: 11px; background: #5f259f; color: #fff; border-radius: 8px; font-size: 13px; font-weight: 800; box-shadow: 0 2px 8px rgba(95,37,159,0.3);">
          <span>🟣 PhonePe</span>
        </a>
        <a href="${upiPayUri}" target="_blank" onclick="handleUpiClick('${prop.id}', 'GPay')" style="text-decoration: none; display: flex; align-items: center; justify-content: center; gap: 6px; padding: 11px; background: #1a73e8; color: #fff; border-radius: 8px; font-size: 13px; font-weight: 800; box-shadow: 0 2px 8px rgba(26,115,232,0.3);">
          <span>🔵 Google Pay</span>
        </a>
      </div>

      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px; margin-bottom: 12px;">
        <a href="${upiPayUri}" target="_blank" onclick="handleUpiClick('${prop.id}', 'Paytm')" style="text-decoration: none; display: flex; align-items: center; justify-content: center; gap: 6px; padding: 10px; background: #00b9f5; color: #fff; border-radius: 8px; font-size: 12.5px; font-weight: 800; box-shadow: 0 2px 8px rgba(0,185,245,0.3);">
          <span>🔷 Paytm</span>
        </a>
        <a href="${upiPayUri}" target="_blank" onclick="handleUpiClick('${prop.id}', 'Any UPI')" style="text-decoration: none; display: flex; align-items: center; justify-content: center; gap: 6px; padding: 10px; background: #059669; color: #fff; border-radius: 8px; font-size: 12.5px; font-weight: 800; box-shadow: 0 2px 8px rgba(5,150,105,0.3);">
          <span>⚡ மற்ற UPI செயலிகள்</span>
        </a>
      </div>
    </div>

    <!-- QR Code Scan & Pay Accordion -->
    <div style="background: #F8FAFC; border: 1px solid #E2E8F0; border-radius: 10px; padding: 12px; margin-bottom: 14px; text-align: center;">
      <div style="font-size: 12px; font-weight: 800; color: #334155; margin-bottom: 8px;">
        📱 அல்லது QR Code ஸ்கேன் செய்து ₹${price} செலுத்தவும்:
      </div>
      <div style="display: inline-block; background: #fff; padding: 8px; border-radius: 8px; border: 1px solid #CBD5E1; box-shadow: 0 2px 8px rgba(0,0,0,0.06);">
        <img src="${qrUrl}" alt="UPI QR Code" style="width: 140px; height: 140px; display: block;">
      </div>
      <div style="font-size: 11px; color: #64748B; margin-top: 6px; font-weight: 700;">
        UPI ID: <span style="color: #0F172A; user-select: all;">${upiId}</span>
      </div>
    </div>

    <!-- Razorpay Checkout Button -->
    <button id="rzpCheckoutBtn" onclick="triggerRazorpayCheckout('${prop.id}')" style="width: 100%; background: linear-gradient(135deg, #0284C7 0%, #0369A1 100%); color: #fff; border: none; padding: 13px; border-radius: 10px; font-size: 14.5px; font-weight: 800; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px; box-shadow: 0 4px 14px rgba(2,132,199,0.35); margin-bottom: 10px;">
      <span style="font-size: 18px;">💳</span> Razorpay மூலம் ₹${price} செலுத்தவும் (Cards / Netbanking)
    </button>

    <!-- Instant Confirm & Unlock Button -->
    <button onclick="executeUnlockPayment('${prop.id}', 'pay_upi_' + Date.now(), 'Instant UPI')" style="width: 100%; background: #10B981; color: #fff; border: none; padding: 13px; border-radius: 10px; font-size: 14px; font-weight: 800; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 6px; box-shadow: 0 3px 10px rgba(16,185,129,0.35);">
      <span>✅</span> பணம் செலுத்திவிட்டேன் - தொடர்பை உடனே திற (Unlock Now)
    </button>
  `;

  modal.classList.add('active');
}

function handleUpiClick(propId, appName) {
  setTimeout(() => {
    const confirmBox = confirm(`✅ ${appName} மூலம் பணம் செலுத்திவிட்டீர்களா?\n\nஉரிமையாளர் தொடர்பு எண்ணை உடனடியாக திறக்க 'OK' கிளிக் செய்யவும்.`);
    if (confirmBox) {
      executeUnlockPayment(propId, 'pay_' + appName.toLowerCase() + '_' + Date.now(), `${appName} UPI`);
    }
  }, 2500);
}

async function triggerRazorpayCheckout(propId) {
  const prop = state.properties.find(p => p.id == propId);
  if (!prop) return;

  const isOffer = !!state.paymentConfig.offerActive;
  const price = state.paymentConfig.effectivePrice || (isOffer ? state.paymentConfig.offerPrice : 30) || 10;
  const amountPaise = price * 100;

  const btn = document.getElementById('rzpCheckoutBtn');
  const originalBtnHtml = btn ? btn.innerHTML : '';
  if (btn) {
    btn.innerHTML = '<span>⏳ ஆர்டர் உருவாக்கப்படுகிறது... (Creating Order...)</span>';
    btn.disabled = true;
  }

  // Check if Razorpay SDK is loaded
  if (typeof Razorpay === 'undefined') {
    alert('❌ Razorpay SDK ஏற்றப்படவில்லை. பக்கத்தை ரீலோட் செய்யவும்.');
    if (btn) {
      btn.innerHTML = originalBtnHtml;
      btn.disabled = false;
    }
    return;
  }

  try {
    // STEP 1: Call Backend to Create Order
    let orderRes;
    const orderPayload = {
      amount: amountPaise,
      currency: 'INR',
      receipt: 'rcpt_' + prop.id + '_' + Date.now(),
      notes: {
        propId: String(prop.id),
        propTitle: prop.title.substring(0, 40)
      }
    };

    try {
      orderRes = await fetch('api/create-order.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(orderPayload)
      });
      if (!orderRes.ok) throw new Error('Status ' + orderRes.status);
    } catch (e1) {
      // Direct fallback to payments.php?action=create_order
      orderRes = await fetch('api/payments.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(Object.assign({ action: 'create_order' }, orderPayload))
      });
    }

    const orderData = await orderRes.json();
    if (!orderRes.ok || !orderData.success || !orderData.order_id) {
      throw new Error(orderData.error || 'Razorpay order creation failed.');
    }

    if (btn) {
      btn.innerHTML = '<span>💳 பணம் செலுத்துதல் திறக்கிறது...</span>';
    }

    // STEP 2: Configure Razorpay Checkout Modal
    const keyId = orderData.key_id || state.paymentConfig.razorpayKeyId || 'rzp_test_TeE2LFCxmmioPq';
    const options = {
      key: keyId,
      amount: orderData.amount,
      currency: orderData.currency || 'INR',
      name: 'தென்காசி கனவுகள்',
      description: `உரிமையாளர் தொடர்பு எண் - ${prop.title.substring(0, 30)}`,
      order_id: orderData.order_id,
      prefill: {
        name: state.user?.name || 'Customer',
        email: state.user?.email || 'customer@samwin.info',
        contact: state.user?.phone || '9894174944'
      },
      notes: {
        propId: String(prop.id),
        propTitle: prop.title
      },
      theme: {
        color: '#002f34'
      },
      handler: async function (response) {
        // STEP 3: Verify Payment Signature on Backend
        if (btn) {
          btn.innerHTML = '<span>⏳ சரிபார்க்கப்படுகிறது... (Verifying...)</span>';
        }
        await handlePaymentVerification(prop, response, price);
      },
      modal: {
        ondismiss: function () {
          if (btn) {
            btn.innerHTML = originalBtnHtml;
            btn.disabled = false;
          }
        }
      }
    };

    const rzp = new Razorpay(options);
    rzp.on('payment.failed', function (response) {
      const errMsg = response.error?.description || response.error?.reason || 'பணம் செலுத்துதல் தோல்வியடைந்தது';
      alert('❌ பேமெண்ட் தோல்வியடைந்தது: ' + errMsg);
      if (btn) {
        btn.innerHTML = originalBtnHtml;
        btn.disabled = false;
      }
    });
    rzp.open();
  } catch (err) {
    console.error('Razorpay checkout error:', err);
    alert('❌ பேமெண்ட் தொடங்குவதில் பிழை: ' + (err.message || 'தயவுசெய்து மீண்டும் முயற்சிக்கவும்.'));
    if (btn) {
      btn.innerHTML = originalBtnHtml;
      btn.disabled = false;
    }
  }
}

async function handlePaymentVerification(prop, rzpResponse, price) {
  const btn = document.getElementById('rzpCheckoutBtn');
  try {
    const payload = {
      razorpay_order_id: rzpResponse.razorpay_order_id,
      razorpay_payment_id: rzpResponse.razorpay_payment_id,
      razorpay_signature: rzpResponse.razorpay_signature,
      propId: prop.id,
      propTitle: prop.title,
      amount: price,
      buyerName: state.user?.name || 'Customer (Guest)',
      buyerPhone: state.user?.phone || '',
      buyerEmail: state.user?.email || '',
      sellerName: prop.agent?.name || 'Direct Owner',
      sellerPhone: prop.agent?.phone || prop.contactPhone || ''
    };

    let verifyRes;
    try {
      verifyRes = await fetch('api/verify-payment.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });
      if (!verifyRes.ok) throw new Error('Status ' + verifyRes.status);
    } catch (e1) {
      // Direct fallback to payments.php?action=verify_payment
      verifyRes = await fetch('api/payments.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(Object.assign({ action: 'verify_payment' }, payload))
      });
    }

    const verifyData = await verifyRes.json();
    if (!verifyRes.ok || !verifyData.success) {
      throw new Error(verifyData.error || 'Payment signature verification failed.');
    }

    // Success! Unlock property in client state
    if (!state.unlockedProperties.includes(prop.id)) {
      state.unlockedProperties.push(prop.id);
      localStorage.setItem('tenkasi_unlocked_props', JSON.stringify(state.unlockedProperties));
    }

    closeModal('contactUnlockModal');
    openPropertyDetail(prop.id);
    alert(`🎉 ₹${price} வெற்றிகரமாக பெறப்பட்டது!\n\n"${prop.title}" சொத்து உரிமையாளரின் மொபைல் எண் மற்றும் WhatsApp தொடர்பு வெற்றிகரமாக திறக்கப்பட்டுள்ளது.`);
  } catch (err) {
    console.error('Payment verification error:', err);
    alert('❌ பேமெண்ட் சரிபார்ப்பு தோல்வியடைந்தது: ' + (err.message || 'Signature mismatch'));
    if (btn) {
      btn.innerHTML = '<span style="font-size: 18px;">💳</span> Razorpay மூலம் ₹' + price + ' செலுத்தவும்';
      btn.disabled = false;
    }
  }
}

async function executeUnlockPayment(propId, paymentId, method) {
  const prop = state.properties.find(p => p.id == propId);
  if (!prop) return;

  const isOffer = !!state.paymentConfig.offerActive;
  const price = state.paymentConfig.effectivePrice || (isOffer ? state.paymentConfig.offerPrice : 30) || 10;

  if (!state.unlockedProperties.includes(propId)) {
    state.unlockedProperties.push(propId);
    localStorage.setItem('tenkasi_unlocked_props', JSON.stringify(state.unlockedProperties));
  }

  closeModal('contactUnlockModal');

  try {
    await fetch('api/payments.php', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        action: 'record_payment',
        paymentId: paymentId,
        propId: prop.id,
        propTitle: prop.title,
        amount: price,
        buyerName: state.user?.name || 'Customer (Guest)',
        buyerPhone: state.user?.phone || '',
        buyerEmail: state.user?.email || '',
        sellerName: prop.agent?.name || 'Direct Owner',
        sellerPhone: prop.agent?.phone || prop.contactPhone || '',
        method: method || 'Razorpay UPI'
      })
    });
  } catch (e) {
    console.warn('Payment logging failed', e);
  }

  // Refresh property detail view
  openPropertyDetail(propId);

  alert(`🎉 ₹${price} வெற்றிகரமாக பெறப்பட்டது!\n\n"${prop.title}" சொத்து உரிமையாளரின் மொபைல் எண் மற்றும் WhatsApp தொடர்பு வெற்றிகரமாக திறக்கப்பட்டுள்ளது.`);
}

async function unlockContactFree(propId) {
  const prop = state.properties.find(p => p.id == propId);
  if (!prop) return;

  // Step 1: User MUST be logged in via Gmail (Google Sign-In)
  if (!state.user || !state.user.isLoggedIn) {
    state.pendingUnlockPropId = propId;
    alert('🔒 இலவச 3 தொடர்புகளைப் பார்க்க, முதலில் உங்கள் Gmail மூலம் உள்நுழையவும்.');
    openGoogleLoginModal('contact_unlock');
    return;
  }

  // Step 2: User MUST provide primary mobile number (No OTP Needed)
  if (!state.user.phone || state.user.phone.trim() === '') {
    state.pendingUnlockPropId = propId;
    openUserPhoneModal();
    return;
  }

  // Step 3: Check Free Limit (3 Contacts)
  const freeLimit = state.paymentConfig.freeLimit || 3;
  if (state.freeContactsUsed >= freeLimit) {
    promptContactUnlockPay(propId);
    return;
  }

  // Step 4: Perform the Free Contact Unlock
  doUnlockContactFree(propId);
}

async function doUnlockContactFree(propId) {
  const prop = state.properties.find(p => p.id == propId);
  if (!prop) return;

  const freeLimit = state.paymentConfig.freeLimit || 3;

  if (!state.unlockedProperties.includes(propId)) {
    state.freeContactsUsed++;
    localStorage.setItem('tenkasi_free_contacts_used', state.freeContactsUsed.toString());

    state.unlockedProperties.push(propId);
    localStorage.setItem('tenkasi_unlocked_props', JSON.stringify(state.unlockedProperties));

    try {
      await fetch('api/payments.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'record_free_view',
          propId: prop.id,
          propTitle: prop.title,
          buyerName: state.user?.name || 'Customer',
          buyerEmail: state.user?.email || '',
          buyerPhone: state.user?.phone || '',
          sellerName: prop.agent?.name || 'Direct Owner',
          sellerPhone: prop.agent?.phone || prop.contactPhone || ''
        })
      });
    } catch (e) {}
  }

  openPropertyDetail(propId);

  const left = Math.max(0, freeLimit - state.freeContactsUsed);
  alert(`✅ இலவச தொடர்பு பார்வை திறக்கப்பட்டது!\n\nவணக்கம் ${state.user.name},\n"${prop.title}" சொத்து உரிமையாளரின் தொடர்பு எண் இப்போது திறக்கப்பட்டுள்ளது.\n\nஉங்களுக்கு இன்னும் ${left} இலவச தொடர்புகள் மீதம் உள்ளன.`);
}

// ==========================================================
// Live Web User Heartbeat & Super Admin Direct Messaging
// ==========================================================
function initWebHeartbeat() {
  let guestId = localStorage.getItem('tenkasi_web_guest_id');
  if (!guestId) {
    guestId = 'web_' + Math.random().toString(36).substring(2, 10) + Date.now();
    localStorage.setItem('tenkasi_web_guest_id', guestId);
  }

  async function sendHeartbeat() {
    try {
      const user = state.user || {};
      const res = await fetch('api/users.php', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'heartbeat',
          user_id: user.id || guestId,
          user_name: user.name || 'Web Visitor',
          user_phone: user.phone || '',
          user_email: user.email || '',
          platform: 'Web Browser (' + (navigator.userAgent.includes('Mobile') ? 'Mobile Web' : 'Desktop Web') + ')',
          current_screen: document.title || 'Home',
          role: user.role || 'buyer'
        })
      });
      const data = await res.json();
      if (data && data.success && Array.isArray(data.unread_admin_messages) && data.unread_admin_messages.length > 0) {
        for (const msg of data.unread_admin_messages) {
          showAdminMessageToast(msg);
          // Mark as read
          fetch('api/users.php', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ action: 'mark_read', message_id: msg.id })
          }).catch(() => {});
        }
      }
    } catch (e) {}
  }

  // Send initial heartbeat and then every 30s
  sendHeartbeat();
  setInterval(sendHeartbeat, 30000);
}

function showAdminMessageToast(msg) {
  const existing = document.getElementById('adminWebMsgToast');
  if (existing) existing.remove();

  const toast = document.createElement('div');
  toast.id = 'adminWebMsgToast';
  toast.style.cssText = `
    position: fixed;
    bottom: 24px;
    right: 24px;
    max-width: 360px;
    background: #0f172a;
    border: 2px solid #3b82f6;
    box-shadow: 0 10px 25px rgba(0,0,0,0.5);
    border-radius: 14px;
    padding: 16px;
    z-index: 99999;
    color: #fff;
    font-family: inherit;
    animation: slideUp 0.3s ease;
  `;
  toast.innerHTML = `
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
      <span style="font-weight:700; color:#60a5fa; font-size:13px; display:flex; align-items:center; gap:6px;">
        💬 ${escapeHtml(msg.admin_name || 'Super Admin')}
      </span>
      <button onclick="this.parentElement.parentElement.remove()" style="background:none; border:none; color:#94a3b8; font-size:16px; cursor:pointer;">✕</button>
    </div>
    <div style="font-size:13.5px; line-height:1.5; color:#e2e8f0; margin-bottom:12px;">
      ${escapeHtml(msg.message || '')}
    </div>
    <div style="text-align:right;">
      <button onclick="this.parentElement.parentElement.remove()" class="btn-primary" style="padding:4px 12px; font-size:12px; border-radius:6px; cursor:pointer;">
        சரி (OK)
      </button>
    </div>
  `;
  document.body.appendChild(toast);
}

// Start heartbeat
initWebHeartbeat();



