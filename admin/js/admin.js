/**
 * SamWin Land - Super Admin Web Application Controller
 * Global Credentials: User: admin3 | Pass: 000003
 * Full White-Label & .ENV Branding Suite
 */

const API_BASE = '../api';

const AppState = {
  token: localStorage.getItem('tk_admin_token') || null,
  user: JSON.parse(localStorage.getItem('tk_admin_user') || 'null'),
  properties: [],
  pendingProperties: [],
  notifications: [],
  lastNotifCount: 0,
  requirements: [],
  stats: null,
  envConfig: null,
  activeCategory: 'all',
  activeStatus: 'all',
  searchQuery: '',
  editingPropertyId: null,
  liveUsers: []
};

// Initialize app when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
  initAuthCheck();
  setupEventListeners();
  setupLandCalculator();

  if (AppState.token) {
    initRealtimeAdminStream();
  }

  // Background Fast Auto-Polling for Real-Time User Posts & Live Users (every 2 seconds fallback for instant arrival)
  setInterval(async () => {
    if (AppState.token) {
      await fetchNotifications();
      await fetchProperties(true);
      await loadLiveUsers(true);
    }
  }, 2000);
});

/* ==================== AUTHENTICATION ==================== */
function initAuthCheck() {
  if (AppState.token) {
    showDashboardView();
    loadDashboardData();
  } else {
    showLoginView();
    fetchEnvConfig(); // Pre-load branding on login screen
  }
}

function showLoginView() {
  document.getElementById('loginView').style.display = 'flex';
  document.getElementById('dashboardView').style.display = 'none';
  const uInput = document.getElementById('loginUsername');
  const pInput = document.getElementById('loginPassword');
  if (uInput && !uInput.value) uInput.value = 'admin3';
  if (pInput && !pInput.value) pInput.value = '000003';
}

function showDashboardView() {
  document.getElementById('loginView').style.display = 'none';
  document.getElementById('dashboardView').style.display = 'flex';
  if (AppState.user) {
    document.getElementById('adminNameDisplay').innerText = AppState.user.name || 'Super Admin';
    document.getElementById('adminRoleDisplay').innerText = AppState.user.role || 'Super Admin';
  }
}

async function handleLogin(e) {
  if (e) e.preventDefault();
  const user = document.getElementById('loginUsername').value.trim();
  const pass = document.getElementById('loginPassword').value.trim();

  if (!user || !pass) {
    showToast('தயவுசெய்து பயனர் பெயர் மற்றும் கடவுச்சொல்லை உள்ளிடவும்', 'error');
    return;
  }

  try {
    const res = await fetch(`${API_BASE}/auth.php`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ username: user, password: pass })
    });
    const data = await res.json();

    if (data.success) {
      AppState.token = data.token;
      AppState.user = data.user;
      localStorage.setItem('tk_admin_token', data.token);
      localStorage.setItem('tk_admin_user', JSON.stringify(data.user));
      showToast(data.message || 'Super Admin உள்நுழைவு வெற்றிகரமாக முடிந்தது!', 'success');
      showDashboardView();
      initRealtimeAdminStream();
      loadDashboardData();
    } else {
      showToast(data.message || 'தவறான உள்நுழைவு விபரம்!', 'error');
    }
  } catch (err) {
    showToast('API இணைப்பு தோல்வி அல்லது தவறான கடவுச்சொல்', 'error');
  }
}

function handleLogout() {
  stopContinuousRing();
  if (adminEventSource) {
    try { adminEventSource.close(); } catch(e) {}
    adminEventSource = null;
  }
  AppState.token = null;
  AppState.user = null;
  localStorage.removeItem('tk_admin_token');
  localStorage.removeItem('tk_admin_user');
  showToast('வெற்றிகரமாக வெளியேறினீர்கள் (Logged out)', 'info');
  showLoginView();
}

/* ==================== DATA LOADING ==================== */
async function loadDashboardData() {
  initRealtimeAdminStream();
  await Promise.all([
    fetchStats(),
    fetchProperties(),
    fetchNotifications(),
    fetchRequirements(),
    fetchEnvConfig(),
    loadPaymentsData(),
    fetchAppConfig(),
    loadActivitiesData(),
    loadLiveUsers(true)
  ]);
}

async function fetchStats() {
  try {
    const res = await fetch(`${API_BASE}/stats.php`);
    const data = await res.json();
    if (data.success) {
      AppState.stats = data.stats;
      renderStats(data.stats);
    }
  } catch (err) {
    console.warn('Stats fetch fallback to local calculation:', err);
    calculateLocalStats();
  }
}

function renderStats(stats) {
  const setTxt = (id, val) => {
    const el = document.getElementById(id);
    if (el) el.innerText = (val !== undefined && val !== null) ? val : 0;
  };

  setTxt('statTotalAds', stats.totalProperties);
  setTxt('statActiveAds', stats.activeProperties);
  setTxt('statPendingAds', stats.pendingProperties);
  setTxt('statRequirements', stats.buyerRequirementsTotal);
  setTxt('statViews', stats.totalViews);

  // Category counts
  if (stats.categories) {
    setTxt('catCountHouse', stats.categories.House);
    setTxt('catCountLand', stats.categories.Land);
    setTxt('catCountFarmland', stats.categories.Farmland);
    setTxt('catCountShop', stats.categories.Shop);
    setTxt('catCountApartment', stats.categories.Apartment);
    setTxt('catCountRental', stats.categories.Rental);
  }
}

function calculateLocalStats() {
  const total = AppState.properties.length;
  let active = 0, pending = 0, sold = 0, views = 0;
  const cats = { House: 0, Land: 0, Farmland: 0, Shop: 0, Apartment: 0, Rental: 0 };

  AppState.properties.forEach(p => {
    if (p.status === 'active') active++;
    else if (p.status === 'pending') pending++;
    else if (p.status === 'sold') sold++;
    views += (p.views || 0);

    const type = (p.propertyType || '').toLowerCase();
    if (type.includes('house') || type.includes('villa')) cats.House++;
    else if (type.includes('land') || type.includes('plot')) cats.Land++;
    else if (type.includes('farm') || type.includes('thottam')) cats.Farmland++;
    else if (type.includes('shop') || type.includes('commercial')) cats.Shop++;
    else if (type.includes('apartment') || type.includes('flat')) cats.Apartment++;
    else if (p.isRental || type.includes('rental') || type.includes('lease')) cats.Rental++;
    else cats.House++;
  });

  renderStats({
    totalProperties: total,
    activeProperties: active,
    pendingProperties: pending,
    soldProperties: sold,
    totalViews: views,
    buyerRequirementsTotal: AppState.requirements ? AppState.requirements.length : 0,
    categories: cats
  });
}

/* ==================== PROPERTY MANAGEMENT ==================== */
async function fetchProperties(isSilent = false) {
  try {
    const res = await fetch(`${API_BASE}/properties.php?all=true`);
    const data = await res.json();
    if (data.success) {
      AppState.properties = data.properties || [];
      AppState.pendingProperties = AppState.properties.filter(p => (p.status || '').toLowerCase() === 'pending');
      renderPropertiesTable();
      renderPendingApprovalsSection();
      updateSidebarPendingBadge();
    }
  } catch (err) {
    if (!isSilent) console.error('Failed to load properties:', err);
  }
}

function renderPropertiesTable() {
  const tbody = document.getElementById('propertiesTableBody');
  const overviewTbody = document.getElementById('overviewPropertiesTableBody');
  if (!tbody && !overviewTbody) return;

  let filtered = AppState.properties;

  if (AppState.activeCategory !== 'all') {
    const cat = AppState.activeCategory.toLowerCase();
    filtered = filtered.filter(p => {
      const type = (p.propertyType || '').toLowerCase();
      if (cat === 'house') return type.includes('house') || type.includes('villa');
      if (cat === 'land') return type.includes('land') || type.includes('plot');
      if (cat === 'farmland') return type.includes('farm') || type.includes('thottam');
      if (cat === 'shop') return type.includes('shop') || type.includes('commercial') || type.includes('office');
      if (cat === 'apartment') return type.includes('apartment') || type.includes('flat');
      if (cat === 'rental') return p.isRental || type.includes('rental') || type.includes('lease');
      return type.includes(cat);
    });
  }

  if (AppState.activeStatus !== 'all') {
    filtered = filtered.filter(p => (p.status || '').toLowerCase() === AppState.activeStatus.toLowerCase());
  }

  if (AppState.activeAccess && AppState.activeAccess !== 'all') {
    filtered = filtered.filter(p => AppState.activeAccess === 'paid' ? !!p.isPremium : !p.isPremium);
  }

  if (AppState.searchQuery && AppState.searchQuery.trim()) {
    const q = AppState.searchQuery.trim().toLowerCase();
    filtered = filtered.filter(p => 
      (p.title || '').toLowerCase().includes(q) ||
      (p.location || '').toLowerCase().includes(q) ||
      (p.city || '').toLowerCase().includes(q) ||
      (p.id || '').toLowerCase().includes(q) ||
      (p.agent && (p.agent.name || '').toLowerCase().includes(q)) ||
      (p.sellerName && p.sellerName.toLowerCase().includes(q)) ||
      (p.sellerPhone && p.sellerPhone.includes(q))
    );
  }

  if (tbody) {
    if (filtered.length === 0) {
      tbody.innerHTML = `
        <tr>
          <td colspan="8" style="text-align:center; padding: 40px; color: var(--text-muted);">
            விளம்பரங்கள் எதுவும் கிடைக்கவில்லை (No properties found).
          </td>
        </tr>
      `;
    } else {
      tbody.innerHTML = filtered.map(p => {
        const formattedPrice = formatTamilPrice(p.price, p.propertyType);
        const catBadgeIcon = getCategoryIcon(p.propertyType);
        const isPending = (p.status || '').toLowerCase() === 'pending';

        const thumbImg = (p.imageUrls && p.imageUrls.length > 0)
          ? p.imageUrls[0]
          : (p.imageUrl || (p.customImageBase64 ? `data:image/jpeg;base64,${p.customImageBase64}` : ''));

        return `
          <tr class="${isPending ? 'row-pending' : ''}">
            <td>
              <div class="prop-cell">
                ${thumbImg 
                  ? `<img src="${thumbImg}" class="prop-thumb" style="object-fit:cover; border-radius:8px; width:44px; height:44px; border:1px solid rgba(255,255,255,0.15);" alt="Thumb" onerror="this.outerHTML='<div class=\\'prop-thumb\\'>${catBadgeIcon}</div>'">`
                  : `<div class="prop-thumb">${catBadgeIcon}</div>`
                }
                <div>
                  <div class="prop-meta-title" title="${escapeHtml(p.title)}">${escapeHtml(p.title)}</div>
                  <div class="prop-meta-location">📍 ${escapeHtml(p.location || p.city || (AppState.envConfig ? AppState.envConfig.DEFAULT_CITY : 'Tenkasi'))}</div>
                  <div style="font-size:11px; color:var(--text-muted); margin-top:2px;">
                    ID: ${p.id} ${p.isUserPosted ? '<span style="color:#f59e0b; font-weight:700;">• பயனர் விளம்பரம்</span>' : ''}
                  </div>
                </div>
              </div>
            </td>
            <td>
              <span class="badge badge-category">${catBadgeIcon} ${escapeHtml(p.propertyType || 'House')}</span>
              ${p.posterType ? `<div style="font-size:11px; color:var(--text-muted); margin-top:4px;">${escapeHtml(p.posterType)}</div>` : ''}
            </td>
            <td>
              <div class="price-text">${formattedPrice}</div>
              <div style="font-size:11px; color:var(--text-muted);">${p.areaSqFt ? p.areaSqFt.toLocaleString() + ' Sq.Ft' : ''}</div>
            </td>
            <td>
              <div>${escapeHtml(p.sellerName || (p.agent ? p.agent.name : 'Direct Owner'))}</div>
              <div style="font-size:11px; color:var(--accent-primary);">${escapeHtml(p.sellerPhone || p.contactPhone || (p.agent ? p.agent.phone : ''))}</div>
            </td>
            <td>
              <button class="badge ${p.isVerified ? 'badge-active' : 'badge-pending'}" style="cursor:pointer; border:none;" onclick="togglePropertyVerification('${p.id}')">
                ${p.isVerified ? '✓ சரிபார்க்கப்பட்டது' : '⌛ சரிபார்க்கவும்'}
              </button>
            </td>
            <td>
              <button class="badge ${p.isPremium ? 'badge-gold' : 'badge-emerald'}" 
                      style="cursor:pointer; border:none; padding:4px 9px; font-weight:700; font-size:11.5px; border-radius:6px; display:inline-flex; align-items:center; gap:4px;" 
                      onclick="togglePropertyPremium('${p.id}')"
                      title="க்ளிக் செய்து இலவசம் அல்லது கட்டணமாக மாற்றலாம்">
                ${p.isPremium ? '💎 கட்டணம் (Paid)' : '🟢 இலவசம் (Free)'}
              </button>
              <div style="font-size:10px; color:var(--text-muted); margin-top:2px;">
                ${p.isPremium ? '₹10 பேவால்' : 'நேரடி தொடர்பு'}
              </div>
            </td>
            <td>
              <div style="display:flex; flex-direction:column; gap:4px;">
                <select class="select-filter" style="padding:4px 8px; font-size:12px;" onchange="updatePropertyStatus('${p.id}', this.value)">
                  <option value="active" ${p.status === 'active' ? 'selected' : ''}>Active (நேரலை)</option>
                  <option value="pending" ${p.status === 'pending' ? 'selected' : ''}>Pending (காத்திருப்பு)</option>
                  <option value="sold" ${p.status === 'sold' ? 'selected' : ''}>Sold (விற்பனையானது)</option>
                </select>
                ${isPending ? `<button class="btn btn-emerald" style="padding:3px 8px; font-size:11px; font-weight:700; border-radius:4px;" onclick="approveProperty('${p.id}')">✓ அப்ரூவ் செய்</button>` : ''}
              </div>
            </td>
            <td>
              <div class="action-btn-group">
                <button class="btn-icon" style="background:rgba(59,130,246,0.15); color:#60a5fa;" title="முழு விவரங்களை பார் (Inspect)" onclick="openPropertyInspectModal('${p.id}')">👁️</button>
                <button class="btn-icon btn-icon-gold" title="Edit Property" onclick="openEditPropertyModal('${p.id}')">✏️</button>
                <button class="btn-icon btn-icon-emerald" title="Toggle Featured" onclick="togglePropertyFeatured('${p.id}')">${p.isFeatured ? '★' : '☆'}</button>
                <button class="btn-icon btn-icon-danger" title="Delete Property" onclick="confirmDeleteProperty('${p.id}')">🗑️</button>
              </div>
            </td>
          </tr>
        `;
      }).join('');
    }
  }

  if (overviewTbody) {
    if (AppState.properties.length === 0) {
      overviewTbody.innerHTML = `
        <tr>
          <td colspan="6" style="text-align:center; padding: 30px; color: var(--text-muted);">
            விளம்பரங்கள் எதுவும் கிடைக்கவில்லை (No properties found).
          </td>
        </tr>
      `;
    } else {
      overviewTbody.innerHTML = AppState.properties.slice(0, 10).map(p => {
        const formattedPrice = formatTamilPrice(p.price, p.propertyType);
        const catBadgeIcon = getCategoryIcon(p.propertyType);
        const isPending = (p.status || '').toLowerCase() === 'pending';
        const thumbImg = (p.imageUrls && p.imageUrls.length > 0)
          ? p.imageUrls[0]
          : (p.imageUrl || (p.customImageBase64 ? `data:image/jpeg;base64,${p.customImageBase64}` : ''));

        return `
          <tr class="${isPending ? 'row-pending' : ''}">
            <td>
              <div class="prop-cell">
                ${thumbImg 
                  ? `<img src="${thumbImg}" class="prop-thumb" style="object-fit:cover; border-radius:8px; width:44px; height:44px; border:1px solid rgba(255,255,255,0.15);" alt="Thumb" onerror="this.outerHTML='<div class=\\'prop-thumb\\'>${catBadgeIcon}</div>'">`
                  : `<div class="prop-thumb">${catBadgeIcon}</div>`
                }
                <div>
                  <div class="prop-meta-title" title="${escapeHtml(p.title)}">${escapeHtml(p.title)}</div>
                  <div class="prop-meta-location">📍 ${escapeHtml(p.location || p.city || 'Tenkasi')}</div>
                  <div style="font-size:11px; color:var(--text-muted); margin-top:2px;">
                    ID: ${p.id} ${p.isUserPosted ? '<span style="color:#f59e0b; font-weight:700;">• பயனர் விளம்பரம்</span>' : ''}
                  </div>
                </div>
              </div>
            </td>
            <td>
              <span class="badge badge-category">${catBadgeIcon} ${escapeHtml(p.propertyType || 'House')}</span>
            </td>
            <td>
              <div class="price-text">${formattedPrice}</div>
              <div style="font-size:11px; color:var(--text-muted);">${p.areaSqFt ? p.areaSqFt.toLocaleString() + ' Sq.Ft' : ''}</div>
            </td>
            <td>
              <div>${escapeHtml(p.sellerName || 'Direct Owner')}</div>
              <div style="font-size:11px; color:var(--accent-primary);">${escapeHtml(p.sellerPhone || p.contactPhone || '')}</div>
            </td>
            <td>
              <span class="badge ${p.status === 'active' ? 'badge-active' : (p.status === 'pending' ? 'badge-pending' : 'badge-gold')}">
                ${p.status === 'active' ? '✓ நேரலை' : (p.status === 'pending' ? '⏳ காத்திருப்பு' : 'விற்பனையானது')}
              </span>
            </td>
            <td style="text-align: right;">
              <div class="action-btn-group" style="justify-content: flex-end;">
                <button class="btn-icon" style="background:rgba(59,130,246,0.15); color:#60a5fa;" title="Inspect" onclick="openPropertyInspectModal('${p.id}')">👁️</button>
                <button class="btn-icon btn-icon-gold" title="Edit" onclick="openEditPropertyModal('${p.id}')">✏️</button>
                <button class="btn-icon btn-icon-danger" title="Delete" onclick="confirmDeleteProperty('${p.id}')">🗑️</button>
              </div>
            </td>
          </tr>
        `;
      }).join('');
    }
  }
}

/* ==================== ADD / EDIT PROPERTY MODAL ==================== */
let adminUploadedImages = [];

function handleAdminImageUpload(event) {
  const files = event.target.files;
  if (!files || files.length === 0) return;

  const promises = [];
  for (let i = 0; i < files.length; i++) {
    const file = files[i];
    if (!file.type.startsWith('image/')) continue;
    promises.push(readFileAsBase64(file));
  }

  Promise.all(promises).then(base64s => {
    adminUploadedImages = [...adminUploadedImages, ...base64s];
    renderAdminImagePreviews();
    event.target.value = '';
  }).catch(err => {
    console.error('Error reading images:', err);
    showToast('படங்களை ஏற்றுவதில் பிழை ஏற்பட்டது!', 'error');
  });
}

function readFileAsBase64(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result);
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
}

function renderAdminImagePreviews() {
  const grid = document.getElementById('adminPropImagePreviewGrid');
  if (!grid) return;
  grid.innerHTML = '';

  adminUploadedImages.forEach((src, idx) => {
    const div = document.createElement('div');
    div.style.position = 'relative';
    div.style.width = '100%';
    div.style.height = '80px';
    div.style.borderRadius = '8px';
    div.style.overflow = 'hidden';
    div.style.border = '1px solid rgba(212,175,55,0.4)';
    div.style.background = '#0a0a0c';

    const img = document.createElement('img');
    img.src = src;
    img.style.width = '100%';
    img.style.height = '100%';
    img.style.objectFit = 'cover';

    const rmBtn = document.createElement('button');
    rmBtn.type = 'button';
    rmBtn.innerHTML = '✕';
    rmBtn.style.position = 'absolute';
    rmBtn.style.top = '2px';
    rmBtn.style.right = '2px';
    rmBtn.style.background = 'rgba(239, 68, 68, 0.9)';
    rmBtn.style.color = '#fff';
    rmBtn.style.border = 'none';
    rmBtn.style.borderRadius = '50%';
    rmBtn.style.width = '20px';
    rmBtn.style.height = '20px';
    rmBtn.style.cursor = 'pointer';
    rmBtn.style.fontSize = '11px';
    rmBtn.style.display = 'flex';
    rmBtn.style.alignItems = 'center';
    rmBtn.style.justifyContent = 'center';
    rmBtn.onclick = (e) => {
      e.stopPropagation();
      adminUploadedImages.splice(idx, 1);
      renderAdminImagePreviews();
    };

    div.appendChild(img);
    div.appendChild(rmBtn);
    grid.appendChild(div);
  });
}

function openAddPropertyModal() {
  AppState.editingPropertyId = null;
  document.getElementById('propertyModalTitle').innerText = '➕ புதிய விளம்பரம் சேர்க்க (Add New Property)';
  document.getElementById('propertyForm').reset();
  document.getElementById('propIdField').value = '';
  if (document.getElementById('propSellerName')) {
    document.getElementById('propSellerName').value = 'Super Admin';
  }
  adminUploadedImages = [];
  renderAdminImagePreviews();
  handleCategoryChange('House');
  document.getElementById('propertyModal').classList.add('show');
  const mb = document.querySelector('#propertyModal .modal-body');
  if (mb) mb.scrollTop = 0;
}

function openEditPropertyModal(id) {
  const p = AppState.properties.find(item => item.id == id);
  if (!p) return;

  AppState.editingPropertyId = id;
  document.getElementById('propertyModalTitle').innerText = '✏️ விளம்பரம் திருத்துதல் (Edit Property #' + id + ')';
  
  document.getElementById('propIdField').value = p.id;
  document.getElementById('propTitle').value = p.title || '';
  if (document.getElementById('propSellerName')) {
    document.getElementById('propSellerName').value = p.sellerName || (p.agent ? p.agent.name : 'Super Admin');
  }
  document.getElementById('propType').value = p.propertyType || 'House';
  document.getElementById('propPrice').value = p.price || '';
  document.getElementById('propAreaSqFt').value = p.areaSqFt || '';
  document.getElementById('propLocation').value = p.location || '';
  document.getElementById('propCity').value = p.city || (AppState.envConfig ? AppState.envConfig.DEFAULT_CITY : 'Tenkasi');
  document.getElementById('propPosterType').value = p.posterType || 'Direct Owner';
  document.getElementById('propContactPhone').value = p.contactPhone || (p.agent ? p.agent.phone : '+91 98941 74944');
  document.getElementById('propLandmark').value = p.landmark || '';
  document.getElementById('propFacing').value = p.facing || 'East';
  document.getElementById('propDescription').value = p.description || '';
  document.getElementById('propStatus').value = p.status || 'active';
  document.getElementById('propIsVerified').checked = !!p.isVerified;
  document.getElementById('propIsFeatured').checked = !!p.isFeatured;
  if (document.getElementById('propIsPremium')) {
    document.getElementById('propIsPremium').checked = !!p.isPremium;
  }
  document.getElementById('propBankLoan').checked = !!p.isBankLoanAvailable;
  document.getElementById('propPriceNegotiable').checked = p.isPriceNegotiable !== false;

  adminUploadedImages = Array.isArray(p.imageUrls) && p.imageUrls.length > 0
    ? [...p.imageUrls]
    : (p.imageUrl ? [p.imageUrl] : (p.customImageBase64 ? [p.customImageBase64] : []));
  renderAdminImagePreviews();

  handleCategoryChange(p.propertyType || 'House');

  if (document.getElementById('propBedrooms')) document.getElementById('propBedrooms').value = p.bedrooms || '';
  if (document.getElementById('propBathrooms')) document.getElementById('propBathrooms').value = p.bathrooms || '';
  if (document.getElementById('propFurnishing')) document.getElementById('propFurnishing').value = p.furnishingStatus || 'Unfurnished';
  if (document.getElementById('propLandUnit')) document.getElementById('propLandUnit').value = p.landUnit || 'Cents';
  if (document.getElementById('propLandUnitValue')) document.getElementById('propLandUnitValue').value = p.landUnitValue || '';
  if (document.getElementById('propApprovalType')) document.getElementById('propApprovalType').value = p.approvalType || 'DTCP Approved';
  if (document.getElementById('propTreesDetails')) document.getElementById('propTreesDetails').value = p.treesDetails || '';
  if (document.getElementById('propIncomeDetails')) document.getElementById('propIncomeDetails').value = p.incomeDetails || '';
  if (document.getElementById('propAdvanceAmount')) document.getElementById('propAdvanceAmount').value = p.advanceAmount || '';
  if (document.getElementById('propPowerPhase')) document.getElementById('propPowerPhase').value = p.powerPhase || 'Single Phase';
  if (document.getElementById('propHasTable')) document.getElementById('propHasTable').checked = !!p.hasTable;
  if (document.getElementById('propHasFan')) document.getElementById('propHasFan').checked = !!p.hasFan;
  if (document.getElementById('propHasWaterSupply')) document.getElementById('propHasWaterSupply').checked = !!p.hasWaterSupply;
  if (document.getElementById('propHasShutter')) document.getElementById('propHasShutter').checked = !!p.hasShutter;

  document.getElementById('propertyModal').classList.add('show');
}

function handleCategoryChange(category) {
  const container = document.getElementById('dynamicCategoryFields');
  if (!container) return;

  const cat = (category || '').toLowerCase();

  if (cat.includes('shop') || cat.includes('commercial') || cat.includes('office')) {
    container.innerHTML = `
      <div style="font-weight:700; color:var(--accent-gold); margin-bottom:12px;">🏪 வணிகம் / கடை சிறப்பம்சங்கள் (Shop Attributes)</div>
      <div class="form-grid-3">
        <div class="form-group">
          <label class="form-label">EB மின் இணைப்பு</label>
          <select id="propPowerPhase" class="form-control">
            <option value="Single Phase">Single Phase EB</option>
            <option value="3 Phase EB">3 Phase EB (மூன்று பேஸ்)</option>
            <option value="Commercial Tariff">Commercial Tariff EB</option>
          </select>
        </div>
        <div class="form-group">
          <label class="form-label">அட்வான்ஸ் தொகை (Advance ₹)</label>
          <input type="number" id="propAdvanceAmount" class="form-control" placeholder="100000">
        </div>
        <div class="form-group">
          <label class="form-label">வணிக பகுதி வகை</label>
          <select id="propCommercialAreaType" class="form-control">
            <option value="Main Bazaar">பிரதான பஜார் (Main Bazaar)</option>
            <option value="Bus Stand / Junction">பேருந்து நிலையம் / Junction</option>
            <option value="Highway">மெயின் ரோடு / ஹைவே</option>
            <option value="Residential Street">குடியிருப்பு தெரு</option>
          </select>
        </div>
      </div>
      <div class="form-grid-2" style="margin-top:10px;">
        <div class="checkbox-group">
          <input type="checkbox" id="propHasShutter" checked>
          <label for="propHasShutter">ரோலிங் ஷட்டர் / கிளாஸ் டோர் (Shutter Available)</label>
        </div>
        <div class="checkbox-group">
          <input type="checkbox" id="propHasFan" checked>
          <label for="propHasFan">ஃபேன் வசதி (Fan)</label>
        </div>
        <div class="checkbox-group">
          <input type="checkbox" id="propHasWaterSupply" checked>
          <label for="propHasWaterSupply">தண்ணீர் வசதி (Water Supply)</label>
        </div>
        <div class="checkbox-group">
          <input type="checkbox" id="propHasTable">
          <label for="propHasTable">மேஜை / அலமாரி (Table / Rack)</label>
        </div>
      </div>
    `;
  } else if (cat.includes('farm') || cat.includes('thottam')) {
    container.innerHTML = `
      <div style="font-weight:700; color:var(--accent-primary); margin-bottom:12px;">🌴 தோட்டம் & விவசாய நில விபரங்கள் (Farmland Details)</div>
      <div class="form-grid-2">
        <div class="form-group">
          <label class="form-label">மரங்கள் விபரம் (Trees)</label>
          <input type="text" id="propTreesDetails" class="form-control" placeholder="எ.கா: 300 தென்னை மரங்கள், மாந்தோப்பு">
        </div>
        <div class="form-group">
          <label class="form-label">மகசூல் வருமானம் (Yield Income)</label>
          <input type="text" id="propIncomeDetails" class="form-control" placeholder="எ.கா: மாதாந்திர தேங்காய் வருமானம் ₹50,000">
        </div>
      </div>
      <div class="form-grid-3">
        <div class="form-group">
          <label class="form-label">நில அளவை அலகு</label>
          <select id="propLandUnit" class="form-control">
            <option value="Acres">ஏக்கர் (Acres)</option>
            <option value="Cents">சென்ட் (Cents)</option>
            <option value="குழி (Kuzhi)">குழி (Kuzhi)</option>
          </select>
        </div>
        <div class="form-group">
          <label class="form-label">அளவு மதிப்பு</label>
          <input type="number" step="0.01" id="propLandUnitValue" class="form-control" placeholder="5.2">
        </div>
        <div class="form-group">
          <label class="form-label">EB மின்சாரம்</label>
          <select id="propPowerPhase" class="form-control">
            <option value="Free Agri EB">இலவச விவசாய மின்சாரம் (Free Agri EB)</option>
            <option value="Commercial EB">Commercial EB</option>
          </select>
        </div>
      </div>
    `;
  } else if (cat.includes('land') || cat.includes('plot')) {
    container.innerHTML = `
      <div style="font-weight:700; color:var(--accent-blue); margin-bottom:12px;">📐 மனை / நில அளவை & அங்கீகாரம் (Land & Approvals)</div>
      <div class="form-grid-3">
        <div class="form-group">
          <label class="form-label">அளவை அலகு (Land Unit)</label>
          <select id="propLandUnit" class="form-control">
            <option value="Cents">சென்ட் (Cents)</option>
            <option value="குழி (Kuzhi)">குழி (Kuzhi - 144 Sq.Ft)</option>
            <option value="Acres">ஏக்கர் (Acres)</option>
            <option value="Sq.Ft">சதுர அடி (Sq.Ft)</option>
          </select>
        </div>
        <div class="form-group">
          <label class="form-label">அளவு மதிப்பு (Unit Value)</label>
          <input type="number" step="0.01" id="propLandUnitValue" class="form-control" placeholder="5.5">
        </div>
        <div class="form-group">
          <label class="form-label">அங்கீகாரம் (Approval)</label>
          <select id="propApprovalType" class="form-control">
            <option value="DTCP Approved">DTCP Approved</option>
            <option value="CMDA Approved">CMDA Approved</option>
            <option value="RERA Approved">RERA Approved</option>
            <option value="Panchayat Approved">பஞ்சாயத்து அப்ரூவல்</option>
            <option value="Unapproved">Unapproved</option>
          </select>
        </div>
      </div>
    `;
  } else if (cat.includes('rental') || cat.includes('lease')) {
    container.innerHTML = `
      <div style="font-weight:700; color:var(--accent-gold); margin-bottom:12px;">🔑 வாடகை & லீஸ் விபரங்கள் (Rental Details)</div>
      <div class="form-grid-3">
        <div class="form-group">
          <label class="form-label">முன்பணம் / Advance (₹)</label>
          <input type="number" id="propAdvanceAmount" class="form-control" placeholder="50000">
        </div>
        <div class="form-group">
          <label class="form-label">படுக்கையறைகள் (BHK)</label>
          <input type="number" id="propBedrooms" class="form-control" placeholder="2">
        </div>
        <div class="form-group">
          <label class="form-label">ஃபர்னிஷிங் நிலை</label>
          <select id="propFurnishing" class="form-control">
            <option value="Semi-Furnished">Semi-Furnished</option>
            <option value="Fully Furnished">Fully Furnished</option>
            <option value="Unfurnished">Unfurnished</option>
          </select>
        </div>
      </div>
    `;
  } else {
    container.innerHTML = `
      <div style="font-weight:700; color:var(--accent-primary); margin-bottom:12px;">🏡 குடியிருப்பு விபரங்கள் (Residential Specs)</div>
      <div class="form-grid-3">
        <div class="form-group">
          <label class="form-label">படுக்கையறைகள் (Bedrooms / BHK)</label>
          <input type="number" id="propBedrooms" class="form-control" placeholder="3">
        </div>
        <div class="form-group">
          <label class="form-label">குளியலறைகள் (Bathrooms)</label>
          <input type="number" id="propBathrooms" class="form-control" placeholder="3">
        </div>
        <div class="form-group">
          <label class="form-label">ஃபர்னிஷிங்</label>
          <select id="propFurnishing" class="form-control">
            <option value="Semi-Furnished">Semi-Furnished</option>
            <option value="Fully Furnished">Fully Furnished</option>
            <option value="Unfurnished">Unfurnished</option>
          </select>
        </div>
      </div>
    `;
  }
}

async function handlePropertySubmit(e) {
  e.preventDefault();

  const id = document.getElementById('propIdField').value;
  const isEditing = !!id;

  const payload = {
    id: id || undefined,
    fromAdmin: true,
    title: document.getElementById('propTitle').value.trim(),
    propertyType: document.getElementById('propType').value,
    price: parseFloat(document.getElementById('propPrice').value) || 0,
    areaSqFt: parseInt(document.getElementById('propAreaSqFt').value) || 0,
    location: document.getElementById('propLocation').value.trim(),
    city: document.getElementById('propCity').value.trim(),
    sellerName: document.getElementById('propSellerName') ? document.getElementById('propSellerName').value.trim() : 'Super Admin',
    posterType: document.getElementById('propPosterType').value,
    contactPhone: document.getElementById('propContactPhone').value.trim(),
    sellerPhone: document.getElementById('propContactPhone').value.trim(),
    landmark: document.getElementById('propLandmark').value.trim(),
    facing: document.getElementById('propFacing').value,
    description: document.getElementById('propDescription').value.trim(),
    status: document.getElementById('propStatus').value || 'active',
    isVerified: document.getElementById('propIsVerified') ? document.getElementById('propIsVerified').checked : true,
    isFeatured: document.getElementById('propIsFeatured') ? document.getElementById('propIsFeatured').checked : false,
    isPremium: document.getElementById('propIsPremium') ? document.getElementById('propIsPremium').checked : false,
    isBankLoanAvailable: document.getElementById('propBankLoan') ? document.getElementById('propBankLoan').checked : false,
    isPriceNegotiable: document.getElementById('propPriceNegotiable') ? document.getElementById('propPriceNegotiable').checked : true,
    imageUrls: adminUploadedImages,
    customImageBase64: adminUploadedImages.length > 0 ? adminUploadedImages[0] : null,
  };

  if (document.getElementById('propBedrooms')) payload.bedrooms = parseInt(document.getElementById('propBedrooms').value) || null;
  if (document.getElementById('propBathrooms')) payload.bathrooms = parseInt(document.getElementById('propBathrooms').value) || null;
  if (document.getElementById('propFurnishing')) payload.furnishingStatus = document.getElementById('propFurnishing').value;
  if (document.getElementById('propLandUnit')) payload.landUnit = document.getElementById('propLandUnit').value;
  if (document.getElementById('propLandUnitValue')) payload.landUnitValue = parseFloat(document.getElementById('propLandUnitValue').value) || null;
  if (document.getElementById('propApprovalType')) payload.approvalType = document.getElementById('propApprovalType').value;
  if (document.getElementById('propTreesDetails')) payload.treesDetails = document.getElementById('propTreesDetails').value.trim();
  if (document.getElementById('propIncomeDetails')) payload.incomeDetails = document.getElementById('propIncomeDetails').value.trim();
  if (document.getElementById('propAdvanceAmount')) payload.advanceAmount = parseFloat(document.getElementById('propAdvanceAmount').value) || null;
  if (document.getElementById('propPowerPhase')) payload.powerPhase = document.getElementById('propPowerPhase').value;
  if (document.getElementById('propHasTable')) payload.hasTable = document.getElementById('propHasTable').checked;
  if (document.getElementById('propHasFan')) payload.hasFan = document.getElementById('propHasFan').checked;
  if (document.getElementById('propHasWaterSupply')) payload.hasWaterSupply = document.getElementById('propHasWaterSupply').checked;
  if (document.getElementById('propHasShutter')) payload.hasShutter = document.getElementById('propHasShutter').checked;

  try {
    const res = await fetch(`${API_BASE}/properties.php`, {
      method: isEditing ? 'PUT' : 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    const result = await res.json();

    if (result.success) {
      showToast(result.message || 'வெற்றிகரமாக சேமிக்கப்பட்டது!', 'success');
      closeModal('propertyModal');
      await fetchProperties();
      await fetchStats();
    } else {
      showToast(result.message || 'சேமிப்பதில் பிழை ஏற்பட்டது!', 'error');
    }
  } catch (err) {
    showToast('API இணைப்பு தோல்வி! சர்வரில் சேமிக்க முடியவில்லை.', 'error');
  }
}

async function togglePropertyVerification(id) {
  const p = AppState.properties.find(item => item.id == id);
  if (!p) return;
  const newVerified = !p.isVerified;

  try {
    await fetch(`${API_BASE}/properties.php`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id: id, isVerified: newVerified })
    });
    p.isVerified = newVerified;
    showToast(newVerified ? 'விளம்பரம் சரிபார்க்கப்பட்டது! (Verified)' : 'சரிபார்ப்பு நீக்கப்பட்டது', 'info');
    renderPropertiesTable();
    fetchStats();
  } catch (err) {
    p.isVerified = newVerified;
    renderPropertiesTable();
  }
}

async function togglePropertyFeatured(id) {
  const p = AppState.properties.find(item => item.id == id);
  if (!p) return;
  const newFeatured = !p.isFeatured;

  try {
    await fetch(`${API_BASE}/properties.php`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id: id, isFeatured: newFeatured })
    });
    p.isFeatured = newFeatured;
    showToast(newFeatured ? 'சிறப்புப் பட்டியலில் சேர்க்கப்பட்டது (Featured)' : 'சிறப்புப் பட்டியலிருந்து நீக்கப்பட்டது', 'info');
    renderPropertiesTable();
  } catch (err) {
    p.isFeatured = newFeatured;
    renderPropertiesTable();
  }
}

async function togglePropertyPremium(id) {
  const p = AppState.properties.find(item => item.id == id);
  if (!p) return;
  const newPremium = !p.isPremium;

  try {
    const res = await fetch(`${API_BASE}/properties.php?action=toggle_premium`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id: id, isPremium: newPremium })
    });
    const data = await res.json();
    if (data && data.success) {
      p.isPremium = newPremium;
      showToast(newPremium ? '💎 பிரீமியம் / கட்டண விளம்பரமாக மாற்றப்பட்டது!' : '🟢 இலவச விளம்பரமாக மாற்றப்பட்டது!', 'success');
      renderPropertiesTable();
      fetchStats();
    } else {
      showToast(data.message || 'மாற்ற முடியவில்லை', 'error');
    }
  } catch (err) {
    showToast('API பிழை: ' + err.message, 'error');
  }
}

async function updatePropertyStatus(id, newStatus) {
  try {
    await fetch(`${API_BASE}/properties.php`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id: id, status: newStatus })
    });
    const p = AppState.properties.find(item => item.id == id);
    if (p) p.status = newStatus;
    showToast('நிலை மாற்றப்பட்டது: ' + newStatus, 'success');
    fetchProperties(true);
    fetchStats();
  } catch (err) {
    console.error('Failed to update status', err);
  }
}

/* ==================== SUPER ADMIN AD APPROVAL & CONTINUOUS RING ENGINE ==================== */
let adminAudioCtx = null;
let ringIntervalId = null;
let isRinging = false;
let soundMutedByUser = false;
let adminEventSource = null;

function getAdminAudioContext() {
  if (!adminAudioCtx) {
    const AudioContextClass = window.AudioContext || window.webkitAudioContext;
    if (AudioContextClass) {
      adminAudioCtx = new AudioContextClass();
    }
  }
  if (adminAudioCtx && adminAudioCtx.state === 'suspended') {
    adminAudioCtx.resume().catch(() => {});
  }
  return adminAudioCtx;
}

// Unlock audio context on any user interaction (resolves browser autoplay policy)
['click', 'touchstart', 'keydown'].forEach(evt => {
  document.addEventListener(evt, () => {
    getAdminAudioContext();
  }, { once: true });
});

function playRingToneBurst() {
  try {
    const ctx = getAdminAudioContext();
    if (!ctx) return;
    if (ctx.state === 'suspended') {
      ctx.resume().catch(() => {});
    }

    // High-attention dual-frequency telephone ring burst (750Hz + 950Hz)
    const playBurst = (startTime, duration) => {
      [750, 950].forEach(freq => {
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(freq, startTime);
        
        gain.gain.setValueAtTime(0.0001, startTime);
        gain.gain.linearRampToValueAtTime(0.28, startTime + 0.04);
        gain.gain.setValueAtTime(0.28, startTime + duration - 0.05);
        gain.gain.linearRampToValueAtTime(0.0001, startTime + duration);

        osc.connect(gain);
        gain.connect(ctx.destination);

        osc.start(startTime);
        osc.stop(startTime + duration);
      });
    };

    const now = ctx.currentTime;
    // Ring 1 (0.38s), pause 0.16s, Ring 2 (0.38s)
    playBurst(now, 0.38);
    playBurst(now + 0.54, 0.38);
  } catch (e) {
    console.warn('Audio ring burst error:', e);
  }
}

function playNotificationChime() {
  try {
    const ctx = getAdminAudioContext();
    if (!ctx) return;
    const now = ctx.currentTime;
    const playTone = (freq, startTime, duration) => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, startTime);
      gain.gain.setValueAtTime(0.001, startTime);
      gain.gain.exponentialRampToValueAtTime(0.3, startTime + 0.05);
      gain.gain.exponentialRampToValueAtTime(0.001, startTime + duration);
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start(startTime);
      osc.stop(startTime + duration);
    };
    playTone(587.33, now, 0.25); // D5
    playTone(880.00, now + 0.18, 0.45); // A5
  } catch (e) {}
}

function startContinuousRing(desc) {
  const banner = document.getElementById('pendingAdAlarmBanner');
  if (banner) {
    banner.style.display = 'block';
    if (desc) {
      const descEl = document.getElementById('pendingAlarmDesc');
      if (descEl) descEl.innerText = desc;
    }
  }

  if (isRinging) return;

  isRinging = true;
  playRingToneBurst();

  if (ringIntervalId) clearInterval(ringIntervalId);
  // Repeat every 2.4 seconds continuously until Super Admin approves or rejects ALL pending ads!
  ringIntervalId = setInterval(() => {
    if (!isRinging) {
      clearInterval(ringIntervalId);
      ringIntervalId = null;
      return;
    }
    playRingToneBurst();
  }, 2400);
}

function stopContinuousRing() {
  isRinging = false;
  if (ringIntervalId) {
    clearInterval(ringIntervalId);
    ringIntervalId = null;
  }
  const banner = document.getElementById('pendingAdAlarmBanner');
  if (banner) banner.style.display = 'none';
}

function initRealtimeAdminStream() {
  if (adminEventSource) {
    try { adminEventSource.close(); } catch(e) {}
    adminEventSource = null;
  }

  if (!window.EventSource) return;

  try {
    adminEventSource = new EventSource(`${API_BASE}/events.php?user_phone=admin`);

    adminEventSource.addEventListener('connected', (e) => {
      console.log('Real-time Admin SSE Stream Connected');
    });

    adminEventSource.addEventListener('new_pending_ad', (e) => {
      try {
        const data = JSON.parse(e.data);
        console.log('Real-time New Pending Ad Received:', data);

        const p = (data.payload && data.payload.property) ? data.payload.property : (data.property || {});

        // Immediately add to AppState.pendingProperties if not already present
        if (p && p.id) {
          const exists = AppState.pendingProperties.some(item => item.id == p.id);
          if (!exists) {
            AppState.pendingProperties.unshift(p);
          }
          const propExists = AppState.properties.some(item => item.id == p.id);
          if (!propExists) {
            AppState.properties.unshift(p);
          }
        }

        // Immediately re-render pending approvals and start continuous ringing!
        renderPendingApprovalsSection();
        renderPropertiesTable();
        updateSidebarPendingBadge();

        const title = p.title || 'புதிய விளம்பரம்';
        const price = p.price ? (' - ₹' + Number(p.price).toLocaleString('en-IN')) : '';
        const seller = p.sellerName ? ` (${p.sellerName})` : '';

        startContinuousRing(`🔔 புதிய விளம்பரம்: "${title}"${price}${seller} • அப்ரூவல் (Accept) அல்லது நிராகரிப்பு (Reject) செய்யும் வரை தொடர்ந்து ஒலிக்கும்!`);
        showToast('🚨 புதிய விளம்பரம் வந்துள்ளது! அப்ரூவல் தேவை', 'info');

        // Also fetch from server to guarantee sync
        fetchProperties(true);
        fetchNotifications();

        if ('Notification' in window && Notification.permission === 'granted') {
          new Notification('🚨 தென்காசி கனவுகள் - புதிய விளம்பரம்!', {
            body: `"${title}"${price} சரிபார்த்து அப்ரூவல் வழங்கவும்`,
            icon: '../assets/images/logo.png'
          });
        }
      } catch (err) {
        console.warn('Error handling new_pending_ad SSE:', err);
      }
    });

    adminEventSource.addEventListener('pending_ad_action_taken', (e) => {
      try {
        fetchProperties(true);
        fetchNotifications();
      } catch (err) {}
    });

    adminEventSource.onerror = () => {
      // EventSource automatically reconnects
    };
  } catch (err) {
    console.warn('Failed to initialize Admin SSE:', err);
  }
}

async function fetchNotifications() {
  try {
    const res = await fetch(`${API_BASE}/notifications.php`);
    const data = await res.json();
    if (data.success) {
      AppState.notifications = data.notifications || [];
      const pendingCount = data.pendingCount || 0;
      const unreadCount = data.unreadCount || 0;

      // Update Top Nav Bell Badge
      const badge = document.getElementById('notifBadgeCount');
      if (badge) {
        const displayCount = unreadCount > 0 ? unreadCount : pendingCount;
        if (displayCount > 0) {
          badge.innerText = displayCount;
          badge.style.display = 'flex';
        } else {
          badge.style.display = 'none';
        }
      }

      // If pendingCount > 0, start continuous ringing until Super Admin accepts/rejects
      if (pendingCount > 0) {
        startContinuousRing(`${pendingCount} விளம்பரங்கள் அப்ரூவலுக்காக காத்திருக்கின்றன • உடனே அப்ரூவல் (Accept) அல்லது நிராகரிப்பு (Reject) செய்யவும்.`);
      } else {
        // No pending ads remaining! Automatically stop continuous ring!
        stopContinuousRing();
      }
      AppState.lastNotifCount = pendingCount;

      renderNotifDropdownList();
    }
  } catch (err) {
    console.warn('Notifications fetch error:', err);
  }
}

function renderNotifDropdownList() {
  const container = document.getElementById('notifListContainer');
  if (!container) return;

  if (AppState.notifications.length === 0) {
    container.innerHTML = `
      <div style="padding: 28px 16px; text-align: center; color: var(--text-muted); font-size: 13px;">
        அறிவிப்புகள் எதுவும் இல்லை (No notifications)
      </div>
    `;
    return;
  }

  container.innerHTML = AppState.notifications.map(n => {
    const isUnread = !n.isRead;
    const isPending = n.status === 'pending';
    const timeFormatted = formatDateTime(n.timestamp);

    return `
      <div class="notif-item ${isUnread ? 'unread' : ''}" onclick="handleNotifClick('${n.id}', '${n.propertyId}')">
        <div class="notif-item-title">${escapeHtml(n.title)}</div>
        <div class="notif-item-msg">${escapeHtml(n.message)}</div>
        <div class="notif-item-meta">
          <span>🕒 ${timeFormatted}</span>
          ${isPending ? '<span style="color:#f59e0b; font-weight:700;">⏳ அப்ரூவல் தேவை</span>' : '<span style="color:#10b981;">✓ முடிவுற்றது</span>'}
        </div>
        ${isPending ? `
          <div class="notif-quick-actions" onclick="event.stopPropagation()">
            <button class="btn btn-emerald" style="padding:4px 8px; font-size:11px; font-weight:700; border-radius:4px;" onclick="approveProperty('${n.propertyId}')">✓ அப்ரூவ்</button>
            <button class="btn btn-danger" style="padding:4px 8px; font-size:11px; font-weight:700; border-radius:4px;" onclick="rejectProperty('${n.propertyId}')">✕ நிராகரி</button>
            <button class="btn btn-secondary" style="padding:4px 8px; font-size:11px; font-weight:700; border-radius:4px;" onclick="openPropertyInspectModal('${n.propertyId}')">👁️ பார்</button>
          </div>
        ` : ''}
      </div>
    `;
  }).join('');
}

function toggleNotifDropdown() {
  const dd = document.getElementById('notifDropdown');
  if (!dd) return;
  const isShown = dd.classList.contains('show');
  if (!isShown) {
    dd.classList.add('show');
    if ('Notification' in window && Notification.permission === 'default') {
      Notification.requestPermission();
    }
    markNotificationsRead('all');
  } else {
    dd.classList.remove('show');
  }
}

async function markNotificationsRead(id = 'all') {
  try {
    await fetch(`${API_BASE}/notifications.php?action=mark_read`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id })
    });
    AppState.notifications.forEach(n => {
      if (id === 'all' || n.id === id) n.isRead = true;
    });
    const badge = document.getElementById('notifBadgeCount');
    if (badge && id === 'all') badge.style.display = 'none';
    renderNotifDropdownList();
  } catch (err) {
    console.error('Failed to mark notifications read:', err);
  }
}

async function clearAllNotifications() {
  try {
    await fetch(`${API_BASE}/notifications.php?action=clear`, { method: 'POST' });
    AppState.notifications = [];
    AppState.lastNotifCount = 0;
    const badge = document.getElementById('notifBadgeCount');
    if (badge) badge.style.display = 'none';
    renderNotifDropdownList();
    showToast('அறிவிப்புகள் அழிக்கப்பட்டன', 'info');
  } catch (err) {
    console.error('Failed to clear notifications:', err);
  }
}

function handleNotifClick(notifId, propId) {
  markNotificationsRead(notifId);
  const dd = document.getElementById('notifDropdown');
  if (dd) dd.classList.remove('show');
  if (propId) {
    openPropertyInspectModal(propId);
  }
}

function updateSidebarPendingBadge() {
  const badge = document.getElementById('sidebarPendingBadge');
  if (!badge) return;
  const count = AppState.pendingProperties ? AppState.pendingProperties.length : 0;
  if (count > 0) {
    badge.innerText = count;
    badge.style.display = 'inline-block';
  } else {
    badge.style.display = 'none';
  }
}

function renderPendingApprovalsSection() {
  const section = document.getElementById('pendingApprovalsSection');
  const container = document.getElementById('pendingCardsContainer');
  const dedicatedContainer = document.getElementById('pendingCardsDedicatedContainer');
  const alarmContainer = document.getElementById('pendingAlarmCardsContainer');
  const countBadge = document.getElementById('pendingBoxBadgeCount');
  const sectionBadge = document.getElementById('pendingSectionBadgeCount');
  const sidebarBadge = document.getElementById('sidebarPendingBadge');
  const alarmCounterBadge = document.getElementById('pendingAlarmCounterBadge');

  const pending = AppState.pendingProperties || [];

  if (sidebarBadge) {
    if (pending.length > 0) {
      sidebarBadge.innerText = pending.length;
      sidebarBadge.style.display = 'inline-block';
    } else {
      sidebarBadge.style.display = 'none';
    }
  }

  if (sectionBadge) {
    sectionBadge.innerText = `${pending.length} காத்திருப்பில்`;
  }

  if (alarmCounterBadge) {
    alarmCounterBadge.innerText = `${pending.length} புதிய விளம்பரம் காத்திருப்பில்`;
  }

  if (pending.length === 0) {
    stopContinuousRing();
    if (section) section.style.display = 'none';
    if (alarmContainer) alarmContainer.innerHTML = '';
    if (dedicatedContainer) {
      dedicatedContainer.innerHTML = `
        <div style="grid-column: 1 / -1; text-align: center; padding: 60px 20px; background: rgba(255,255,255,0.02); border-radius: 12px; border: 1px dashed rgba(255,255,255,0.1);">
          <div style="font-size: 48px; margin-bottom: 12px;">🎉</div>
          <div style="font-size: 16px; font-weight: 700; color: #fff;">தற்போது காத்திருப்பில் புதிய விளம்பரங்கள் எதுவும் இல்லை!</div>
          <div style="font-size: 13px; color: var(--text-muted); margin-top: 6px;">அனைத்து பயனர் விளம்பரங்களும் சரிபார்க்கப்பட்டு நேரலையில் உள்ளன.</div>
        </div>
      `;
    }
    return;
  }

  if (section) section.style.display = 'block';
  if (countBadge) {
    countBadge.innerText = `${pending.length} புதிய விளம்பரம் காத்திருப்பில்`;
  }

  const cardsHtml = pending.map(p => {
    const formattedPrice = formatTamilPrice(p.price, p.propertyType);
    const catIcon = getCategoryIcon(p.propertyType);
    const areaDisplay = p.landUnitValue ? `${p.landUnitValue} ${p.landUnit || 'Cent'}` : (p.areaSqFt ? `${p.areaSqFt} Sq.Ft` : '');
    const sellerName = p.sellerName || (p.agent ? p.agent.name : 'Direct Owner');
    const sellerPhone = p.sellerPhone || p.contactPhone || (p.agent ? p.agent.phone : '');
    const cleanPhone = (sellerPhone || '').replace(/[^0-9]/g, '');

    const thumbImg = (p.imageUrls && p.imageUrls.length > 0)
      ? p.imageUrls[0]
      : (p.imageUrl || (p.customImageBase64 ? `data:image/jpeg;base64,${p.customImageBase64}` : ''));

    return `
      <div class="pending-card" style="border: 1px solid ${p.isPremium ? '#f59e0b' : 'rgba(255,255,255,0.08)'}; background: rgba(15, 23, 42, 0.95);">
        <div>
          ${thumbImg ? `
            <div style="width:100%; height:130px; border-radius:8px; overflow:hidden; margin-bottom:10px; background:#000; border:1px solid rgba(255,255,255,0.1);">
              <img src="${thumbImg}" alt="Property" style="width:100%; height:100%; object-fit:cover;">
            </div>
          ` : ''}
          <div class="pending-card-top">
            <span class="pending-card-type">${catIcon} ${escapeHtml(p.propertyType || 'Land')}</span>
            <div class="pending-card-price">${formattedPrice}</div>
          </div>
          <div class="pending-card-title">${escapeHtml(p.title)}</div>
          <div class="pending-card-location">📍 ${escapeHtml(p.location || 'Tenkasi')} ${areaDisplay ? '• ' + areaDisplay : ''}</div>
          
          <div class="seller-info-box">
            <div class="seller-info-name">
              <span>👤 ${escapeHtml(sellerName)}</span>
              <span style="font-size:11px; color:#f59e0b; font-weight:600;">விற்பனையாளர்</span>
            </div>
            <div style="font-size:12px; color:var(--text-muted); margin-top:3px;">📞 ${escapeHtml(sellerPhone || 'எண் இல்லை')}</div>
            <div class="seller-contact-actions">
              ${cleanPhone ? `
                <a href="tel:${cleanPhone}" class="btn-contact-quick btn-quick-call">📞 அழைக்க</a>
                <a href="https://wa.me/91${cleanPhone}?text=${encodeURIComponent('வணக்கம், தென்காசி கனவுகள் மூலம் நீங்கள் பதிவிட்ட ' + p.title + ' விளம்பரம் தொடர்பாக அழைக்கிறோம்.')}" target="_blank" class="btn-contact-quick btn-quick-wa">💬 WhatsApp</a>
              ` : ''}
            </div>
          </div>

          <!-- Free / Paid Permission Toggle on Pending Card -->
          <div style="margin-top:10px; display:flex; justify-content:space-between; align-items:center; background:rgba(255,255,255,0.03); border:1px solid rgba(255,255,255,0.06); padding:8px 12px; border-radius:8px;">
            <span style="font-size:11.5px; color:var(--text-muted);">அனுமதி வகை:</span>
            <button class="badge ${p.isPremium ? 'badge-gold' : 'badge-emerald'}" style="cursor:pointer; border:none; padding:3px 9px; font-weight:700; font-size:11px;" onclick="togglePropertyPremium('${p.id}')">
              ${p.isPremium ? '💎 கட்டண விளம்பரம் (Paid)' : '🟢 இலவச விளம்பரம் (Free)'}
            </button>
          </div>
        </div>

        <div class="pending-actions-bar">
          <button class="btn-approve-action" onclick="approveProperty('${p.id}')">
            ✓ அங்கீகரித்து நேரலையில் வெளியிடு (Accept)
          </button>
          <button class="btn-reject-action" onclick="rejectProperty('${p.id}')" title="நிராகரி (Reject)">
            ✕
          </button>
          <button class="btn-inspect-action" onclick="openPropertyInspectModal('${p.id}')" title="முழு விவரங்கள்">
            👁️
          </button>
        </div>
      </div>
    `;
  }).join('');

  if (container) container.innerHTML = cardsHtml;
  if (dedicatedContainer) dedicatedContainer.innerHTML = cardsHtml;
  if (alarmContainer) alarmContainer.innerHTML = cardsHtml;

  // Since pending.length > 0, start continuous ringing!
  startContinuousRing(`${pending.length} புதிய விளம்பரங்கள் காத்திருக்கின்றன • அப்ரூவல் (Accept) அல்லது நிராகரிப்பு (Reject) செய்யும் வரை தொடர்ந்து ஒலிக்கும்.`);
}

async function togglePropertyPremium(id) {
  const p = AppState.properties.find(item => item.id == id);
  if (!p) return;
  const newStatus = !p.isPremium;

  try {
    const res = await fetch(`${API_BASE}/properties.php?action=toggle_premium`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id, isPremium: newStatus })
    });
    const data = await res.json();
    if (data.success) {
      p.isPremium = newStatus;
      showToast(newStatus ? '💎 விளம்பரம் கட்டணம் (Paid / Premium) என மாற்றப்பட்டது!' : '🟢 விளம்பரம் இலவசம் (Free) என மாற்றப்பட்டது!', 'success');
      renderPropertiesTable();
      renderPendingApprovalsSection();
    } else {
      showToast(data.message || 'மாற்றம் தோல்வியடைந்தது', 'error');
    }
  } catch (err) {
    p.isPremium = newStatus;
    showToast('உள்ளூர் நினைவகத்தில் மாற்றப்பட்டது', 'info');
    renderPropertiesTable();
    renderPendingApprovalsSection();
  }
}

function handleAccessFilterChange(val) {
  AppState.activeAccess = val;
  renderPropertiesTable();
}

async function approveProperty(id) {
  try {
    const res = await fetch(`${API_BASE}/properties.php?action=approve`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id })
    });
    const data = await res.json();
    if (data.success) {
      showToast('✅ விளம்பரம் வெற்றிகரமாக ஒப்புதல் அளிக்கப்பட்டு நேரலை செய்யப்பட்டது!', 'success');
      // Immediately remove from pending properties
      AppState.pendingProperties = AppState.pendingProperties.filter(p => p.id != id);
      const prop = AppState.properties.find(p => p.id == id);
      if (prop) {
        prop.status = 'active';
        prop.isVerified = true;
      }
      renderPendingApprovalsSection();
      renderPropertiesTable();
      updateSidebarPendingBadge();

      // If no more pending properties, stop sound immediately!
      if (AppState.pendingProperties.length === 0) {
        stopContinuousRing();
      }

      await Promise.all([
        fetchProperties(true),
        fetchNotifications(),
        fetchStats()
      ]);
      closeModal('propertyInspectModal');
    } else {
      showToast(data.message || 'அப்ரூவல் தோல்வியடைந்தது', 'error');
    }
  } catch (err) {
    console.error('Approve failed:', err);
    showToast('இணைப்பு தோல்வி', 'error');
  }
}

async function rejectProperty(id) {
  if (!confirm('இந்த விளம்பரத்தை நிராகரிக்க விரும்புகிறீர்களா? (Reject this property ad?)')) return;

  try {
    const res = await fetch(`${API_BASE}/properties.php?action=reject`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id })
    });
    const data = await res.json();
    if (data.success) {
      showToast('விளம்பரம் நிராகரிக்கப்பட்டது (Rejected)', 'info');
      // Immediately remove from pending properties
      AppState.pendingProperties = AppState.pendingProperties.filter(p => p.id != id);
      const prop = AppState.properties.find(p => p.id == id);
      if (prop) {
        prop.status = 'rejected';
      }
      renderPendingApprovalsSection();
      renderPropertiesTable();
      updateSidebarPendingBadge();

      // If no more pending properties, stop sound immediately!
      if (AppState.pendingProperties.length === 0) {
        stopContinuousRing();
      }

      await Promise.all([
        fetchProperties(true),
        fetchNotifications(),
        fetchStats()
      ]);
      closeModal('propertyInspectModal');
    } else {
      showToast(data.message || 'நிராகரிப்பு தோல்வி', 'error');
    }
  } catch (err) {
    console.error('Reject failed:', err);
    showToast('இணைப்பு தோல்வி', 'error');
  }
}

function switchInspectMainImage(url, el) {
  const mainImg = document.getElementById('inspectMainImage');
  if (mainImg) mainImg.src = url;
  document.querySelectorAll('.inspect-thumb').forEach(t => {
    t.style.borderColor = 'rgba(255,255,255,0.15)';
    t.style.transform = 'scale(1)';
  });
  if (el) {
    el.style.borderColor = '#fbbf24';
    el.style.transform = 'scale(1.05)';
  }
}

function openPropertyInspectModal(id) {
  const p = AppState.properties.find(item => item.id == id);
  if (!p) return;

  const modal = document.getElementById('propertyInspectModal');
  const titleEl = document.getElementById('inspectModalTitle');
  const bodyEl = document.getElementById('inspectModalBody');
  const footerEl = document.getElementById('inspectModalFooter');
  if (!modal || !bodyEl) return;

  const isPending = (p.status || '').toLowerCase() === 'pending';
  const formattedPrice = formatTamilPrice(p.price, p.propertyType);
  const catIcon = getCategoryIcon(p.propertyType);
  const typeLower = (p.propertyType || '').toLowerCase();
  const sellerName = p.sellerName || (p.agent ? p.agent.name : 'Direct Owner');
  const sellerPhone = p.sellerPhone || p.contactPhone || (p.agent ? p.agent.phone : '+91 98941 74944');
  const posterType = p.posterType || (p.agent && p.agent.agencyName ? p.agent.agencyName : 'நேரடி உரிமையாளர் (Direct Owner)');
  const cleanPhone = (sellerPhone || '').replace(/[^0-9]/g, '');

  const images = (p.imageUrls && p.imageUrls.length > 0) 
    ? p.imageUrls 
    : (p.imageUrl ? [p.imageUrl] : (p.customImageBase64 ? [`data:image/jpeg;base64,${p.customImageBase64}`] : []));
  const amenities = [...(p.amenities || []), ...(p.landFeatures || [])];

  if (titleEl) {
    titleEl.innerHTML = `👁️ ${escapeHtml(p.title)} <span style="font-size:12px; color:var(--text-muted); font-weight:normal;">(ID: ${p.id})</span>`;
  }

  // Dynamic Category Specific Rows
  let categorySpecificHtml = '';

  if (typeLower.includes('farm') || typeLower.includes('thottam') || typeLower.includes('தோட்டம்')) {
    categorySpecificHtml = `
      <div style="background:rgba(16,185,129,0.06); border:1px solid rgba(16,185,129,0.25); border-radius:10px; padding:14px; margin-bottom:16px;">
        <div style="font-size:12.5px; font-weight:700; color:#34d399; margin-bottom:10px;">🌾 விவசாய நிலம் / தோட்டம் கூடுதல் விவரங்கள்:</div>
        <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(200px, 1fr)); gap:10px;">
          <div><span style="color:var(--text-muted); font-size:11px;">💧 நீர் ஆதாரம்:</span> <b style="color:#fff; font-size:12.5px;">${escapeHtml(p.waterSource || 'கிணறு / போர்வெல்')}</b></div>
          <div><span style="color:var(--text-muted); font-size:11px;">⚡ மின் இணைப்பு (EB):</span> <b style="color:#fff; font-size:12.5px;">${escapeHtml(p.powerPhase || 'இலவச விவசாய மின்சாரம்')}</b></div>
          <div><span style="color:var(--text-muted); font-size:11px;">🌴 மரங்கள் விவரம்:</span> <b style="color:#fff; font-size:12.5px;">${p.hasTrees ? escapeHtml(p.treesDetails || 'மரங்கள் உள்ளன') : 'இல்லை'}</b></div>
          <div><span style="color:var(--text-muted); font-size:11px;">💵 ஆண்டு வருமானம்:</span> <b style="color:#fff; font-size:12.5px;">${p.hasIncome ? escapeHtml(p.incomeDetails || 'வருமானம் உண்டு') : 'குறிப்பிடப்படவில்லை'}</b></div>
        </div>
      </div>
    `;
  } else if (typeLower.includes('house') || typeLower.includes('villa') || typeLower.includes('apartment') || typeLower.includes('வீடு')) {
    categorySpecificHtml = `
      <div style="background:rgba(59,130,246,0.06); border:1px solid rgba(59,130,246,0.25); border-radius:10px; padding:14px; margin-bottom:16px;">
        <div style="font-size:12.5px; font-weight:700; color:#60a5fa; margin-bottom:10px;">🏠 வீடு / அடுக்குமாடி கூடுதல் விவரங்கள்:</div>
        <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(180px, 1fr)); gap:10px;">
          <div><span style="color:var(--text-muted); font-size:11px;">🛏️ படுக்கையறைகள் (BHK):</span> <b style="color:#fff; font-size:12.5px;">${p.bedrooms ? p.bedrooms + ' BHK' : '-'}</b></div>
          <div><span style="color:var(--text-muted); font-size:11px;">🚿 கழிப்பறைகள்:</span> <b style="color:#fff; font-size:12.5px;">${p.bathrooms || '-'}</b></div>
          <div><span style="color:var(--text-muted); font-size:11px;">🏢 தளம் (Floor):</span> <b style="color:#fff; font-size:12.5px;">${escapeHtml(p.floor || 'Ground Floor')}</b></div>
          <div><span style="color:var(--text-muted); font-size:11px;">🛋️ பர்னிஷிங் நிலை:</span> <b style="color:#fff; font-size:12.5px;">${escapeHtml(p.furnishingStatus || 'Unfurnished')}</b></div>
          <div><span style="color:var(--text-muted); font-size:11px;">🛗 லிப்ட் வசதி:</span> <b style="color:#fff; font-size:12.5px;">${p.hasLift ? '✓ உள்ளது' : '✕ இல்லை'}</b></div>
          <div><span style="color:var(--text-muted); font-size:11px;">🧹 மாதாந்திர பராமரிப்பு:</span> <b style="color:#fff; font-size:12.5px;">${p.maintenanceMonthly ? '₹' + p.maintenanceMonthly : 'இல்லை'}</b></div>
        </div>
      </div>
    `;
  } else if (typeLower.includes('shop') || typeLower.includes('commercial') || typeLower.includes('office') || typeLower.includes('வணிக')) {
    categorySpecificHtml = `
      <div style="background:rgba(234,179,8,0.06); border:1px solid rgba(234,179,8,0.25); border-radius:10px; padding:14px; margin-bottom:16px;">
        <div style="font-size:12.5px; font-weight:700; color:#fbbf24; margin-bottom:10px;">🏢 வணிக வளாகம் / கடை விவரங்கள்:</div>
        <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(180px, 1fr)); gap:10px;">
          <div><span style="color:var(--text-muted); font-size:11px;">🚪 ஷட்டர் வசதி:</span> <b style="color:#fff; font-size:12.5px;">${p.hasShutter ? '✓ உண்டு' : '✕ இல்லை'}</b></div>
          <div><span style="color:var(--text-muted); font-size:11px;">⚡ மின் இணைப்பு (Power):</span> <b style="color:#fff; font-size:12.5px;">${escapeHtml(p.powerPhase || '3 Phase')}</b></div>
          <div><span style="color:var(--text-muted); font-size:11px;">🏢 வணிக வகை:</span> <b style="color:#fff; font-size:12.5px;">${escapeHtml(p.commercialAreaType || 'Commercial Space')}</b></div>
          <div><span style="color:var(--text-muted); font-size:11px;">🪑 உள்புற வசதிகள்:</span> <b style="color:#fff; font-size:12.5px;">${[p.hasTable ? 'மேஜை' : '', p.hasFan ? 'மின்விசிறி' : '', p.hasWaterSupply ? 'தண்ணீர்' : ''].filter(Boolean).join(', ') || 'குறிப்பிடப்படவில்லை'}</b></div>
        </div>
      </div>
    `;
  }

  // Rental Specific
  let rentalHtml = '';
  if (p.isRental || typeLower.includes('rental') || typeLower.includes('lease') || typeLower.includes('வாடகை')) {
    rentalHtml = `
      <div style="background:rgba(168,85,247,0.06); border:1px solid rgba(168,85,247,0.25); border-radius:10px; padding:14px; margin-bottom:16px;">
        <div style="font-size:12.5px; font-weight:700; color:#c084fc; margin-bottom:10px;">🔑 வாடகை / குத்தகை விவரங்கள்:</div>
        <div style="display:grid; grid-template-columns:repeat(auto-fit, minmax(180px, 1fr)); gap:10px;">
          <div><span style="color:var(--text-muted); font-size:11px;">💵 முன்பணம் (Advance):</span> <b style="color:#38bdf8; font-size:13px;">${p.advanceAmount ? '₹' + Number(p.advanceAmount).toLocaleString('en-IN') : 'பேசித் தீர்மானிக்கலாம்'}</b></div>
          <div><span style="color:var(--text-muted); font-size:11px;">📑 ஒப்பந்த வகை:</span> <b style="color:#fff; font-size:12.5px;">${p.isLease ? 'குத்தகை (Lease)' : 'மாத வாடகை (Monthly Rent)'}</b></div>
          <div><span style="color:var(--text-muted); font-size:11px;">🏷️ வாடகை உள்வகை:</span> <b style="color:#fff; font-size:12.5px;">${escapeHtml(p.rentalSubType || 'குடும்பம் / வணிகம்')}</b></div>
        </div>
      </div>
    `;
  }

  bodyEl.innerHTML = `
    <!-- Top Bar: Category, Status, Price -->
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px; flex-wrap:wrap; gap:8px; border-bottom:1px solid rgba(255,255,255,0.07); padding-bottom:12px;">
      <div>
        <span class="badge badge-category" style="font-size:13px; padding:4px 10px;">${catIcon} ${escapeHtml(p.propertyType || 'Land')}</span>
        <span class="badge ${p.status === 'active' ? 'badge-active' : (isPending ? 'badge-pending' : 'badge-sold')}" style="margin-left:6px;">
          ${p.status === 'active' ? '✓ நேரலை (Active)' : (isPending ? '⏳ காத்திருப்பு (Pending Approval)' : p.status)}
        </span>
        <button class="badge ${p.isPremium ? 'badge-gold' : 'badge-emerald'}" style="cursor:pointer; border:none; margin-left:6px; font-size:12px; padding:4px 10px; font-weight:700;" onclick="togglePropertyPremium('${p.id}'); openPropertyInspectModal('${p.id}');" title="க்ளிக் செய்து இலவசம் / கட்டணம் மாற்றலாம்">
          ${p.isPremium ? '💎 கட்டண விளம்பரம் (Paid)' : '🟢 இலவச விளம்பரம் (Free)'}
        </button>
        ${p.isFeatured ? '<span class="badge" style="background:#f59e0b; color:#000; font-weight:700; margin-left:6px;">⭐ Featured</span>' : ''}
      </div>
      <div style="text-align:right;">
        <div style="font-size:22px; font-weight:800; color:var(--accent-gold);">${formattedPrice}</div>
        <div style="font-size:11px; color:var(--text-muted);">${p.isPriceNegotiable ? '✓ விலை பேசித் தீர்மானிக்கலாம்' : 'நிலையான விலை (Fixed)'}</div>
      </div>
    </div>

    <!-- Activity & Views Quick Bar -->
    <div style="background:rgba(255,255,255,0.03); border:1px solid rgba(255,255,255,0.08); border-radius:8px; padding:10px 14px; margin-bottom:16px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px;">
      <div style="display:flex; gap:16px; align-items:center; font-size:12.5px;">
        <span style="color:#38bdf8; font-weight:600;">👁️ பார்வைகள்: <b>${p.views || 0}</b> முறை</span>
        <span style="color:#34d399; font-weight:600;">📞 தொடர்புகள்: <b>${p.enquiries || 0}</b></span>
        <span style="color:var(--text-muted); font-size:11px;">📅 ${p.postedDate ? new Date(p.postedDate).toLocaleDateString('ta-IN') : '-'}</span>
      </div>
      <div>
        <button type="button" class="btn btn-secondary" style="font-size:11.5px; padding:4px 10px; font-weight:600;" onclick="closeModal('propertyInspectModal'); openPropertyViewersModal('${p.id}');">
          👥 யார் யார் பார்த்தார்கள்? (Viewers)
        </button>
      </div>
    </div>

    <!-- Photo Gallery -->
    ${images.length > 0 ? `
      <div style="margin-bottom:16px;">
        <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:8px;">
          <span style="font-size:12px; font-weight:700; color:var(--text-secondary);">🖼️ சொத்து புகைப்படங்கள் (${images.length}):</span>
          <span style="font-size:11px; color:var(--text-muted);">படத்தை பெரிதாக்க க்ளிக் செய்யவும்</span>
        </div>
        <div style="position:relative; width:100%; height:260px; border-radius:10px; overflow:hidden; border:1px solid rgba(255,255,255,0.12); background:#000;">
          <img id="inspectMainImage" src="${images[0]}" alt="Property Image" style="width:100%; height:100%; object-fit:cover; transition:0.3s ease;">
          <a href="${images[0]}" target="_blank" style="position:absolute; top:10px; right:10px; background:rgba(0,0,0,0.6); color:#fff; padding:4px 8px; border-radius:6px; font-size:11px; text-decoration:none;">🔍 முழு படம்</a>
        </div>
        ${images.length > 1 ? `
          <div style="display:flex; gap:8px; overflow-x:auto; padding:8px 0; margin-top:6px;">
            ${images.map((url, idx) => `
              <img src="${url}" onclick="switchInspectMainImage('${url}', this)" class="inspect-thumb" style="width:68px; height:52px; object-fit:cover; border-radius:6px; cursor:pointer; border:2px solid ${idx === 0 ? '#fbbf24' : 'rgba(255,255,255,0.15)'}; transition:0.2s;" title="படம் ${idx + 1}">
            `).join('')}
          </div>
        ` : ''}
      </div>
    ` : `
      <div style="padding:16px; text-align:center; background:rgba(255,255,255,0.02); border-radius:8px; border:1px dashed rgba(255,255,255,0.1); color:var(--text-muted); margin-bottom:16px; font-size:12px;">
        📷 சொத்து புகைப்படம் எதுவும் பதிவேற்றப்படவில்லை (No photos uploaded)
      </div>
    `}

    <!-- Seller Verification Box -->
    <div style="background:rgba(245,158,11,0.08); border:1px solid rgba(245,158,11,0.25); border-radius:10px; padding:14px 16px; margin-bottom:18px;">
      <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:6px;">
        <span style="font-weight:700; color:#fbbf24; font-size:13px;">👤 விற்பனையாளர் / பதிவிட்டவர் தொடர்பு விபரம்:</span>
        <span class="badge" style="background:rgba(245,158,11,0.2); color:#fbbf24; font-size:11px;">${escapeHtml(posterType)}</span>
      </div>
      <div style="font-size:15px; font-weight:700; color:#fff; margin-bottom:4px;">${escapeHtml(sellerName)}</div>
      <div style="font-size:14px; color:var(--text-primary); margin-bottom:10px;">📞 ${escapeHtml(sellerPhone)}</div>
      <div style="display:flex; gap:10px;">
        ${cleanPhone ? `
          <a href="tel:${cleanPhone}" class="btn btn-emerald" style="padding:6px 14px; font-size:12px; text-decoration:none;">📞 உடனே அழைக்க</a>
          <a href="https://wa.me/91${cleanPhone}?text=${encodeURIComponent('வணக்கம் ' + sellerName + ', தென்காசி கனவுகள் தளம் மூலம் நீங்கள் பதிவிட்ட ' + p.title + ' விளம்பரம் தொடர்பாக தொடர்பு கொள்கிறோம்.')}" target="_blank" class="btn" style="background:#25d366; color:#fff; padding:6px 14px; font-size:12px; text-decoration:none;">💬 WhatsApp</a>
        ` : ''}
      </div>
    </div>

    <!-- General Specifications Grid -->
    <div style="display:grid; grid-template-columns:1fr 1fr; gap:12px; margin-bottom:16px; background:rgba(255,255,255,0.02); padding:14px; border-radius:8px; border:1px solid rgba(255,255,255,0.06);">
      <div>
        <div style="font-size:11px; color:var(--text-muted);">இடம் / ஊர் (Location)</div>
        <div style="font-size:13px; font-weight:600; color:#fff;">📍 ${escapeHtml(p.location || 'Tenkasi')}${p.landmark ? ' (' + escapeHtml(p.landmark) + ')' : ''}</div>
      </div>
      <div>
        <div style="font-size:11px; color:var(--text-muted);">நில அளவு / பரப்பு (Area)</div>
        <div style="font-size:13px; font-weight:600; color:#fff;">📐 ${p.landUnitValue ? p.landUnitValue + ' ' + (p.landUnit || 'Cent') : (p.areaSqFt ? p.areaSqFt + ' Sq.Ft' : '-')}</div>
      </div>
      <div>
        <div style="font-size:11px; color:var(--text-muted);">அங்கீகாரம் (Approval)</div>
        <div style="font-size:13px; font-weight:600; color:#10b981;">✓ ${escapeHtml(p.approvalType || 'DTCP / பஞ்சாயத்து அப்ரூவல்')}</div>
      </div>
      <div>
        <div style="font-size:11px; color:var(--text-muted);">திசை (Facing)</div>
        <div style="font-size:13px; font-weight:600; color:#fff;">🧭 ${escapeHtml(p.facing || 'East')}</div>
      </div>
      <div>
        <div style="font-size:11px; color:var(--text-muted);">வங்கி கடன் வசதி (Bank Loan)</div>
        <div style="font-size:13px; font-weight:600; color:#fff;">${p.isBankLoanAvailable ? '✓ வங்கி கடன் கிடைக்கும்' : '✕ வங்கி கடன் இல்லை'}</div>
      </div>
      <div>
        <div style="font-size:11px; color:var(--text-muted);">விலை பேசித் தீர்மானிக்கலாமா?</div>
        <div style="font-size:13px; font-weight:600; color:#fff;">${p.isPriceNegotiable ? '✓ ஆம் (Negotiable)' : '✕ நிலையானது (Fixed)'}</div>
      </div>
    </div>

    <!-- Category Specific Specifications (Farmland / House / Commercial / Rental) -->
    ${categorySpecificHtml}
    ${rentalHtml}

    <!-- Amenities & Features Badges -->
    ${amenities.length > 0 ? `
      <div style="margin-bottom:16px;">
        <div style="font-size:12px; font-weight:700; color:var(--text-secondary); margin-bottom:8px;">✨ வசதிகள் & சிறப்பு அம்சங்கள் (Amenities):</div>
        <div style="display:flex; flex-wrap:wrap; gap:6px;">
          ${amenities.map(a => `<span class="badge" style="background:rgba(59,130,246,0.12); color:#93c5fd; border:1px solid rgba(59,130,246,0.25); font-size:11.5px; padding:3px 8px;">✓ ${escapeHtml(a)}</span>`).join('')}
        </div>
      </div>
    ` : ''}

    <!-- Description -->
    <div style="margin-bottom:16px;">
      <div style="font-size:12px; font-weight:700; color:var(--text-secondary); margin-bottom:6px;">📝 விளம்பர விளக்கம் (Description):</div>
      <div style="background:rgba(0,0,0,0.25); border:1px solid rgba(255,255,255,0.05); padding:12px; border-radius:8px; font-size:13px; line-height:1.6; color:#cbd5e1; white-space:pre-line;">
        ${escapeHtml(p.description || 'விளக்கம் எதுவும் உள்ளிடப்படவில்லை.')}
      </div>
    </div>
  `;

  if (footerEl) {
    if (isPending) {
      footerEl.innerHTML = `
        <button type="button" class="btn btn-secondary" onclick="closeModal('propertyInspectModal')">மூடு</button>
        <button type="button" class="btn btn-danger" onclick="rejectProperty('${p.id}')">✕ நிராகரி (Reject)</button>
        <button type="button" class="btn btn-gold" onclick="closeModal('propertyInspectModal'); openEditPropertyModal('${p.id}')">✏️ திருத்து</button>
        <button type="button" class="btn btn-emerald" style="font-weight:800;" onclick="approveProperty('${p.id}')">✓ அப்ரூவ் செய்து உடனே வெளியிடு</button>
      `;
    } else {
      footerEl.innerHTML = `
        <button type="button" class="btn btn-secondary" onclick="closeModal('propertyInspectModal')">மூடு</button>
        <button type="button" class="btn btn-danger" style="background:rgba(239,68,68,0.2); border:1px solid rgba(239,68,68,0.4); color:#fca5a5;" onclick="confirmDeleteProperty('${p.id}'); closeModal('propertyInspectModal');">🗑️ நீக்கு</button>
        <button type="button" class="btn btn-gold" onclick="closeModal('propertyInspectModal'); openEditPropertyModal('${p.id}')">✏️ திருத்து</button>
      `;
    }
  }

  modal.classList.add('show');
}

async function confirmDeleteProperty(id) {
  if (!confirm('இந்த விளம்பரத்தை நிச்சயமாக நீக்க விரும்புகிறீர்களா?')) return;

  try {
    const res = await fetch(`${API_BASE}/properties.php?id=${id}`, { method: 'DELETE' });
    const result = await res.json();
    if (result.success) {
      showToast('விளம்பரம் நீக்கப்பட்டது!', 'success');
      AppState.properties = AppState.properties.filter(p => p.id != id);
      renderPropertiesTable();
      fetchStats();
    }
  } catch (err) {
    AppState.properties = AppState.properties.filter(p => p.id != id);
    renderPropertiesTable();
    showToast('விளம்பரம் உள்ளூர் நினைவகத்திலிருந்து நீக்கப்பட்டது', 'info');
  }
}

/* ==================== BUYER REQUIREMENTS BOARD ==================== */
async function fetchRequirements() {
  try {
    const res = await fetch(`${API_BASE}/requirements.php`);
    const data = await res.json();
    if (data.success) {
      AppState.requirements = data.requirements || [];
      renderRequirementsBoard();
    }
  } catch (err) {
    console.error('Failed to load requirements:', err);
  }
}

function renderRequirementsBoard() {
  const container = document.getElementById('requirementsGrid');
  if (!container) return;

  if (AppState.requirements.length === 0) {
    container.innerHTML = `<div style="grid-column: 1/-1; text-align:center; padding:40px; color:var(--text-muted);">மக்களின் தேவைகள் எதுவும் பதிவு செய்யப்படவில்லை.</div>`;
    return;
  }

  container.innerHTML = AppState.requirements.map(r => {
    const cleanPhone = (r.userPhone || '').replace(/[^0-9]/g, '');
    const waPhone = cleanPhone.startsWith('91') ? cleanPhone : '91' + cleanPhone;
    const brandTitle = AppState.envConfig ? AppState.envConfig.APP_NAME : 'தென்காசி ட்ரீம்ஸ் லேண்ட்';
    const waText = encodeURIComponent(`வணக்கம் ${r.userName}, ${brandTitle} மூலம் நீங்கள் பதிவு செய்த ${r.propertyType} விளம்பரம் தொடர்பாக அழைக்கிறோம்.`);
    const budgetStr = formatRequirementBudget(r.budgetMin, r.budgetMax);

    return `
      <div class="req-card">
        <div>
          <div class="req-header">
            <div>
              <div class="req-user-name">${escapeHtml(r.userName)}</div>
              <div style="font-size:12px; color:var(--accent-primary); margin-top:2px;">📞 ${escapeHtml(r.userPhone)}</div>
            </div>
            <span class="req-badge">${getCategoryIcon(r.propertyType)} ${escapeHtml(r.propertyType || 'Land')}</span>
          </div>

          <div class="req-details-list">
            <div class="req-detail-item">📍 <strong>இடம்:</strong> ${escapeHtml(r.targetLocation || (AppState.envConfig ? AppState.envConfig.DEFAULT_CITY : 'Tenkasi'))}</div>
            <div class="req-detail-item">💰 <strong>பட்ஜெட்:</strong> ${budgetStr}</div>
            ${r.preferredSize ? `<div class="req-detail-item">📐 <strong>அளவு:</strong> ${escapeHtml(r.preferredSize)}</div>` : ''}
            ${r.facingPreference ? `<div class="req-detail-item">🧭 <strong>திசை:</strong> ${escapeHtml(r.facingPreference)}</div>` : ''}
          </div>

          <div class="req-desc">
            "${escapeHtml(r.description || 'விபரம் எதுவும் குறிப்பிடப்படவில்லை')}"
          </div>
        </div>

        <div class="req-actions-bar">
          <a href="tel:${r.userPhone}" class="btn-contact-call">📞 Call Now</a>
          <a href="https://wa.me/${waPhone}?text=${waText}" target="_blank" class="btn-contact-whatsapp">💬 WhatsApp</a>
          <button class="btn-icon btn-icon-danger" title="Delete Requirement" onclick="deleteRequirement('${r.id}')">🗑️</button>
        </div>
      </div>
    `;
  }).join('');
}

function openAddRequirementModal() {
  document.getElementById('reqForm').reset();
  document.getElementById('requirementModal').classList.add('show');
}

async function handleRequirementSubmit(e) {
  e.preventDefault();
  const payload = {
    userName: document.getElementById('reqUserName').value.trim(),
    userPhone: document.getElementById('reqUserPhone').value.trim(),
    propertyType: document.getElementById('reqPropertyType').value,
    targetLocation: document.getElementById('reqTargetLocation').value.trim(),
    budgetMin: parseFloat(document.getElementById('reqBudgetMin').value) || 0,
    budgetMax: parseFloat(document.getElementById('reqBudgetMax').value) || 0,
    preferredSize: document.getElementById('reqPreferredSize').value.trim(),
    facingPreference: document.getElementById('reqFacing').value,
    description: document.getElementById('reqDescription').value.trim()
  };

  try {
    const res = await fetch(`${API_BASE}/requirements.php`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    const data = await res.json();
    if (data.success) {
      showToast('தேவை வெற்றிகரமாக பதிவு செய்யப்பட்டது!', 'success');
      closeModal('requirementModal');
      await fetchRequirements();
      await fetchStats();
    }
  } catch (err) {
    showToast('API இணைப்பு தோல்வி! தேவையை சர்வரில் பதிவு செய்ய முடியவில்லை.', 'error');
  }
}

async function deleteRequirement(id) {
  if (!confirm('இந்த தேவை பதிவை நீக்க விரும்புகிறீர்களா?')) return;
  try {
    await fetch(`${API_BASE}/requirements.php?id=${id}`, { method: 'DELETE' });
    AppState.requirements = AppState.requirements.filter(r => r.id != id);
    renderRequirementsBoard();
    showToast('தேவை பதிவு நீக்கப்பட்டது', 'success');
    fetchStats();
  } catch (err) {
    AppState.requirements = AppState.requirements.filter(r => r.id != id);
    renderRequirementsBoard();
  }
}

/* ==================== ENVIRONMENT & WHITE-LABEL CONFIGURATION ==================== */
async function fetchEnvConfig() {
  try {
    const res = await fetch(`${API_BASE}/env.php`);
    const data = await res.json();
    if (data.success) {
      AppState.envConfig = data.config;
      populateEnvForm(data.config);
      applyWhiteLabelBranding(data.config);
      if (document.getElementById('rawEnvTextarea')) {
        document.getElementById('rawEnvTextarea').value = data.raw || '';
      }
    }
  } catch (err) {
    console.warn('Failed to load .env config:', err);
  }
}

function applyWhiteLabelBranding(cfg) {
  if (!cfg) return;

  const appName = cfg.APP_NAME || 'SamWin Land';
  const appTagline = cfg.APP_TAGLINE || 'தென்காசி கனவுகள் - ரியல் எஸ்டேட் நிர்வாகம்';
  const emoji = cfg.APP_LOGO_EMOJI || '🏛️';
  const logoUrl = cfg.APP_LOGO_URL;

  // 1. Page & Tab Titles
  document.title = `${appName} - Super Admin Portal | சூப்பர் அட்மின்`;
  const pageTitleDisplay = document.getElementById('pageTitleDisplay');
  if (pageTitleDisplay) pageTitleDisplay.innerText = `${appName} - Super Admin Portal`;

  // 2. Login Page Logo & Branding
  const loginTitle = document.getElementById('loginTitleDisplay');
  if (loginTitle) loginTitle.innerText = appName;
  const loginSubtitle = document.getElementById('loginSubtitleDisplay');
  if (loginSubtitle) loginSubtitle.innerText = appTagline;
  const loginLogo = document.getElementById('loginLogoContainer');
  if (loginLogo) {
    if (logoUrl) {
      loginLogo.innerHTML = `<img src="${logoUrl}" alt="${escapeHtml(appName)}" style="width:100%; height:100%; object-fit:contain; border-radius:16px;">`;
    } else {
      loginLogo.innerText = emoji;
    }
  }

  // 3. Sidebar Logo & Brand Name
  const sidebarBrand = document.getElementById('sidebarBrandName');
  if (sidebarBrand) sidebarBrand.innerText = appName;
  const sidebarLogo = document.getElementById('sidebarLogoContainer');
  if (sidebarLogo) {
    if (logoUrl) {
      sidebarLogo.innerHTML = `<img src="${logoUrl}" alt="${escapeHtml(appName)}" style="width:100%; height:100%; object-fit:contain; border-radius:10px;">`;
    } else {
      sidebarLogo.innerText = emoji;
    }
  }

  // 4. Top Navbar Title & Subtitle
  const navTitle = document.getElementById('topNavTitleDisplay');
  if (navTitle) navTitle.innerText = appName;
  const navSubtitle = document.getElementById('topNavSubtitleDisplay');
  if (navSubtitle) navSubtitle.innerText = appTagline;

  // 5. Theme Colors
  if (cfg.PRIMARY_COLOR) {
    document.documentElement.style.setProperty('--accent-primary', cfg.PRIMARY_COLOR);
  }
  if (cfg.ACCENT_COLOR) {
    document.documentElement.style.setProperty('--accent-gold', cfg.ACCENT_COLOR);
  }
}

function populateEnvForm(cfg) {
  if (!cfg) return;
  const setVal = (id, val) => {
    const el = document.getElementById(id);
    if (el) el.value = val !== undefined ? val : '';
  };

  // Database
  setVal('env_DB_HOST', cfg.DB_HOST);
  setVal('env_DB_PORT', cfg.DB_PORT);
  setVal('env_DB_NAME', cfg.DB_NAME);
  setVal('env_DB_USER', cfg.DB_USER);
  setVal('env_DB_PASS', cfg.DB_PASS);
  setVal('env_STORAGE_MODE', cfg.STORAGE_MODE || 'auto');

  // Auth
  setVal('env_SUPER_ADMIN_USER', cfg.SUPER_ADMIN_USER);
  setVal('env_SUPER_ADMIN_PASS', cfg.SUPER_ADMIN_PASS);
  setVal('env_SESSION_LIFETIME_HOURS', cfg.SESSION_LIFETIME_HOURS || '24');

  // White-Label Branding
  setVal('env_APP_NAME', cfg.APP_NAME);
  setVal('env_APP_TAGLINE', cfg.APP_TAGLINE);
  setVal('env_APP_LOGO_EMOJI', cfg.APP_LOGO_EMOJI || '🏛️');
  setVal('env_APP_LOGO_URL', cfg.APP_LOGO_URL);
  setVal('env_HERO_BANNER_URL', cfg.HERO_BANNER_URL);
  setVal('env_PRIMARY_COLOR', cfg.PRIMARY_COLOR || '#10B981');
  setVal('env_PRIMARY_COLOR_PICKER', cfg.PRIMARY_COLOR || '#10B981');
  setVal('env_ACCENT_COLOR', cfg.ACCENT_COLOR || '#F59E0B');
  setVal('env_ACCENT_COLOR_PICKER', cfg.ACCENT_COLOR || '#F59E0B');
  setVal('env_COMPANY_NAME', cfg.COMPANY_NAME);
  setVal('env_FOOTER_COPYRIGHT', cfg.FOOTER_COPYRIGHT);

  // Contacts
  setVal('env_ADMIN_NAME', cfg.ADMIN_NAME);
  setVal('env_ADMIN_PHONE', cfg.ADMIN_PHONE);
  setVal('env_WHATSAPP_NUMBER', cfg.WHATSAPP_NUMBER);
  setVal('env_ADMIN_EMAIL', cfg.ADMIN_EMAIL);
  setVal('env_OFFICE_ADDRESS', cfg.OFFICE_ADDRESS);
  setVal('env_DEFAULT_CITY', cfg.DEFAULT_CITY || 'Tenkasi');
  setVal('env_CURRENCY_SYMBOL', cfg.CURRENCY_SYMBOL || '₹');

  // Social
  setVal('env_SOCIAL_FACEBOOK', cfg.SOCIAL_FACEBOOK);
  setVal('env_SOCIAL_YOUTUBE', cfg.SOCIAL_YOUTUBE);
  setVal('env_SOCIAL_TELEGRAM', cfg.SOCIAL_TELEGRAM);

  // Monetization & Razorpay
  setVal('env_RAZORPAY_MODE', cfg.RAZORPAY_MODE || 'test');
  setVal('env_RAZORPAY_ACCOUNT_ID', cfg.RAZORPAY_ACCOUNT_ID);
  setVal('env_UPI_ID', cfg.UPI_ID || '9894174944@upi');
  setVal('env_RAZORPAY_LIVE_KEY_ID', cfg.RAZORPAY_LIVE_KEY_ID);
  setVal('env_RAZORPAY_LIVE_KEY_SECRET', cfg.RAZORPAY_LIVE_KEY_SECRET);
  setVal('env_RAZORPAY_TEST_KEY_ID', cfg.RAZORPAY_TEST_KEY_ID || cfg.RAZORPAY_KEY_ID || 'rzp_test_TeE2LFCxmmioPq');
  setVal('env_RAZORPAY_TEST_KEY_SECRET', cfg.RAZORPAY_TEST_KEY_SECRET || cfg.RAZORPAY_KEY_SECRET || 'bxk4gdsx48aBSjVSJd61IjLe');
  setVal('env_CONTACT_UNLOCK_PRICE', cfg.CONTACT_UNLOCK_PRICE !== undefined ? cfg.CONTACT_UNLOCK_PRICE : 30);
  setVal('env_FREE_CONTACT_LIMIT', cfg.FREE_CONTACT_LIMIT !== undefined ? cfg.FREE_CONTACT_LIMIT : 3);

  // SMS & WhatsApp Gateway
  setVal('env_SMS_GATEWAY_PROVIDER', cfg.SMS_GATEWAY_PROVIDER || 'fast2sms');
  setVal('env_PHONE_OTP_ENABLED', cfg.PHONE_OTP_ENABLED !== undefined ? String(cfg.PHONE_OTP_ENABLED) : 'true');
  setVal('env_FAST2SMS_API_KEY', cfg.FAST2SMS_API_KEY || '');
  setVal('env_TWILIO_ACCOUNT_SID', cfg.TWILIO_ACCOUNT_SID || '');
  setVal('env_TWILIO_AUTH_TOKEN', cfg.TWILIO_AUTH_TOKEN || '');
  setVal('env_TWILIO_PHONE_NUMBER', cfg.TWILIO_PHONE_NUMBER || '');
  setVal('env_WHATSAPP_API_URL', cfg.WHATSAPP_API_URL || '');
}

function toggleEnvEditorView(mode) {
  const formSec = document.getElementById('envFormSection');
  const rawSec = document.getElementById('envRawSection');
  const btnForm = document.getElementById('btnEnvTabForm');
  const btnRaw = document.getElementById('btnEnvTabRaw');

  if (mode === 'raw') {
    formSec.style.display = 'none';
    rawSec.style.display = 'block';
    btnForm.className = 'btn btn-secondary';
    btnRaw.className = 'btn btn-primary';
    fetchEnvConfig();
  } else {
    formSec.style.display = 'block';
    rawSec.style.display = 'none';
    btnForm.className = 'btn btn-primary';
    btnRaw.className = 'btn btn-secondary';
  }
}

async function handleBrandImageUpload(fileInput, type) {
  if (!fileInput.files || !fileInput.files[0]) return;
  const file = fileInput.files[0];
  const reader = new FileReader();

  reader.onload = async function(e) {
    const base64 = e.target.result;
    showToast('படம் பதிவேற்றப்படுகிறது... (Uploading image)', 'info');

    try {
      const res = await fetch(`${API_BASE}/env.php?action=upload_image`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ type: type, image_base64: base64 })
      });
      const data = await res.json();

      if (data.success) {
        showToast(data.message || 'படம் வெற்றிகரமாக சேமிக்கப்பட்டது!', 'success');
        if (type === 'logo') {
          document.getElementById('env_APP_LOGO_URL').value = data.url;
        } else if (type === 'banner') {
          document.getElementById('env_HERO_BANNER_URL').value = data.url;
        }
        await fetchEnvConfig();
      } else {
        showToast(data.message || 'பதிவேற்றம் தோல்வி', 'error');
      }
    } catch (err) {
      showToast('Upload error', 'error');
    }
  };

  reader.readAsDataURL(file);
}

async function saveEnvForm() {
  const payload = {
    // Database
    DB_HOST: document.getElementById('env_DB_HOST').value.trim(),
    DB_PORT: document.getElementById('env_DB_PORT').value.trim(),
    DB_NAME: document.getElementById('env_DB_NAME').value.trim(),
    DB_USER: document.getElementById('env_DB_USER').value.trim(),
    DB_PASS: document.getElementById('env_DB_PASS').value,
    STORAGE_MODE: document.getElementById('env_STORAGE_MODE').value,

    // Auth
    SUPER_ADMIN_USER: document.getElementById('env_SUPER_ADMIN_USER').value.trim(),
    SUPER_ADMIN_PASS: document.getElementById('env_SUPER_ADMIN_PASS').value.trim(),
    SESSION_LIFETIME_HOURS: document.getElementById('env_SESSION_LIFETIME_HOURS').value.trim(),

    // White-Label Branding
    APP_NAME: document.getElementById('env_APP_NAME').value.trim(),
    APP_TAGLINE: document.getElementById('env_APP_TAGLINE').value.trim(),
    APP_LOGO_EMOJI: document.getElementById('env_APP_LOGO_EMOJI').value.trim(),
    APP_LOGO_URL: document.getElementById('env_APP_LOGO_URL').value.trim(),
    HERO_BANNER_URL: document.getElementById('env_HERO_BANNER_URL').value.trim(),
    PRIMARY_COLOR: document.getElementById('env_PRIMARY_COLOR').value.trim(),
    ACCENT_COLOR: document.getElementById('env_ACCENT_COLOR').value.trim(),
    COMPANY_NAME: document.getElementById('env_COMPANY_NAME').value.trim(),
    FOOTER_COPYRIGHT: document.getElementById('env_FOOTER_COPYRIGHT').value.trim(),

    // Contacts
    ADMIN_NAME: document.getElementById('env_ADMIN_NAME').value.trim(),
    ADMIN_PHONE: document.getElementById('env_ADMIN_PHONE').value.trim(),
    WHATSAPP_NUMBER: document.getElementById('env_WHATSAPP_NUMBER').value.trim(),
    ADMIN_EMAIL: document.getElementById('env_ADMIN_EMAIL').value.trim(),
    OFFICE_ADDRESS: document.getElementById('env_OFFICE_ADDRESS').value.trim(),
    DEFAULT_CITY: document.getElementById('env_DEFAULT_CITY').value.trim(),
    CURRENCY_SYMBOL: document.getElementById('env_CURRENCY_SYMBOL').value.trim(),

    // Social
    SOCIAL_FACEBOOK: document.getElementById('env_SOCIAL_FACEBOOK').value.trim(),
    SOCIAL_YOUTUBE: document.getElementById('env_SOCIAL_YOUTUBE').value.trim(),
    SOCIAL_TELEGRAM: document.getElementById('env_SOCIAL_TELEGRAM').value.trim(),

    // Monetization & Razorpay Gateway
    RAZORPAY_MODE: (document.getElementById('env_RAZORPAY_MODE')?.value || 'test'),
    RAZORPAY_ACCOUNT_ID: (document.getElementById('env_RAZORPAY_ACCOUNT_ID')?.value || '').trim(),
    UPI_ID: (document.getElementById('env_UPI_ID')?.value || '').trim(),
    RAZORPAY_LIVE_KEY_ID: (document.getElementById('env_RAZORPAY_LIVE_KEY_ID')?.value || '').trim(),
    RAZORPAY_LIVE_KEY_SECRET: (document.getElementById('env_RAZORPAY_LIVE_KEY_SECRET')?.value || '').trim(),
    RAZORPAY_TEST_KEY_ID: (document.getElementById('env_RAZORPAY_TEST_KEY_ID')?.value || '').trim(),
    RAZORPAY_TEST_KEY_SECRET: (document.getElementById('env_RAZORPAY_TEST_KEY_SECRET')?.value || '').trim(),
    RAZORPAY_KEY_ID: (document.getElementById('env_RAZORPAY_MODE')?.value === 'live' 
      ? (document.getElementById('env_RAZORPAY_LIVE_KEY_ID')?.value || '').trim() 
      : (document.getElementById('env_RAZORPAY_TEST_KEY_ID')?.value || '').trim()),
    RAZORPAY_KEY_SECRET: (document.getElementById('env_RAZORPAY_MODE')?.value === 'live' 
      ? (document.getElementById('env_RAZORPAY_LIVE_KEY_SECRET')?.value || '').trim() 
      : (document.getElementById('env_RAZORPAY_TEST_KEY_SECRET')?.value || '').trim()),
    CONTACT_UNLOCK_PRICE: parseInt(document.getElementById('env_CONTACT_UNLOCK_PRICE')?.value || '30', 10),
    FREE_CONTACT_LIMIT: parseInt(document.getElementById('env_FREE_CONTACT_LIMIT')?.value || '3', 10),

    // SMS & WhatsApp Gateway
    SMS_GATEWAY_PROVIDER: (document.getElementById('env_SMS_GATEWAY_PROVIDER')?.value || 'fast2sms'),
    PHONE_OTP_ENABLED: (document.getElementById('env_PHONE_OTP_ENABLED')?.value === 'true'),
    FAST2SMS_API_KEY: (document.getElementById('env_FAST2SMS_API_KEY')?.value || '').trim(),
    TWILIO_ACCOUNT_SID: (document.getElementById('env_TWILIO_ACCOUNT_SID')?.value || '').trim(),
    TWILIO_AUTH_TOKEN: (document.getElementById('env_TWILIO_AUTH_TOKEN')?.value || '').trim(),
    TWILIO_PHONE_NUMBER: (document.getElementById('env_TWILIO_PHONE_NUMBER')?.value || '').trim(),
    WHATSAPP_API_URL: (document.getElementById('env_WHATSAPP_API_URL')?.value || '').trim()
  };

  try {
    const res = await fetch(`${API_BASE}/env.php`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    const data = await res.json();
    if (data.success) {
      showToast(data.message || 'அமைப்புகள் வெற்றிகரமாக சேமிக்கப்பட்டன!', 'success');
      await fetchEnvConfig();
    } else {
      showToast(data.message || 'சேமிப்பதில் பிழை!', 'error');
    }
  } catch (err) {
    showToast('API இணைப்பு தோல்வி', 'error');
  }
}

async function saveRawEnvFile() {
  const rawText = document.getElementById('rawEnvTextarea').value;
  if (!rawText.trim()) {
    showToast('.env கோப்பு காலியாக இருக்கக்கூடாது', 'error');
    return;
  }

  try {
    const res = await fetch(`${API_BASE}/env.php?action=save_raw`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ raw: rawText })
    });
    const data = await res.json();
    if (data.success) {
      showToast(data.message || '.env சேமிக்கப்பட்டது!', 'success');
      await fetchEnvConfig();
    } else {
      showToast(data.message || 'சேமிப்பதில் பிழை!', 'error');
    }
  } catch (err) {
    showToast('API இணைப்பு தோல்வி', 'error');
  }
}

async function testDatabaseConnection() {
  const statusBox = document.getElementById('dbConnectionStatusBox');
  if (!statusBox) return;

  statusBox.style.display = 'block';
  statusBox.style.background = 'rgba(59, 130, 246, 0.15)';
  statusBox.style.border = '1px solid rgba(59, 130, 246, 0.3)';
  statusBox.style.color = '#93c5fd';
  statusBox.innerHTML = `⏳ MySQL டேட்டாபேஸ் இணைப்பு சோதிக்கப்படுகிறது... (Testing connection)`;

  const payload = {
    DB_HOST: document.getElementById('env_DB_HOST').value.trim(),
    DB_PORT: document.getElementById('env_DB_PORT').value.trim(),
    DB_NAME: document.getElementById('env_DB_NAME').value.trim(),
    DB_USER: document.getElementById('env_DB_USER').value.trim(),
    DB_PASS: document.getElementById('env_DB_PASS').value
  };

  try {
    const res = await fetch(`${API_BASE}/env.php?action=test_db`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    const data = await res.json();

    if (data.connected) {
      statusBox.style.background = 'rgba(16, 185, 129, 0.15)';
      statusBox.style.border = '1px solid rgba(16, 185, 129, 0.35)';
      statusBox.style.color = '#6ee7b7';
      statusBox.innerHTML = `✅ <strong>வெற்றி!</strong> ${escapeHtml(data.message)}<br><small style="color:#a7f3d0;">${escapeHtml(data.server_info || '')}</small>`;
      showToast('MySQL டேட்டாபேஸ் வெற்றிகரமாக இணைக்கப்பட்டது!', 'success');
    } else {
      statusBox.style.background = 'rgba(239, 68, 68, 0.15)';
      statusBox.style.border = '1px solid rgba(239, 68, 68, 0.35)';
      statusBox.style.color = '#fca5a5';
      statusBox.innerHTML = `❌ <strong>இணைப்பு தோல்வி:</strong> ${escapeHtml(data.message)}<br><small>குறிப்பு: XAMPP MySQL ஆன் செய்யப்பட்டுள்ளதா அல்லது JSON Storage Mode பயன்படுத்தவும்.</small>`;
      showToast('டேட்டாபேஸ் இணைப்பு தோல்வி', 'error');
    }
  } catch (err) {
    statusBox.style.background = 'rgba(245, 158, 11, 0.15)';
    statusBox.style.border = '1px solid rgba(245, 158, 11, 0.35)';
    statusBox.style.color = '#fde68a';
    statusBox.innerHTML = `ℹ️ API இணைப்பு இல்லை, ஆனால் JSON தானியங்கி சேமிப்பு (JSON Auto Fallback Mode) இயக்கத்தில் உள்ளது.`;
  }
}

async function resetEnvConfig() {
  if (!confirm('அனைத்து பிராண்டிங் & சுற்றுச்சூழல் அமைப்புகளையும் ஆரம்ப நிலைக்கு மாற்ற விரும்புகிறீர்களா? (Reset all white-label & .env settings?)')) {
    return;
  }

  try {
    const res = await fetch(`${API_BASE}/env.php?action=reset`, { method: 'POST' });
    const data = await res.json();
    if (data.success) {
      showToast(data.message || 'அமைப்புகள் ஆரம்ப நிலைக்கு மாற்றப்பட்டன', 'info');
      await fetchEnvConfig();
    }
  } catch (err) {
    showToast('Reset failed', 'error');
  }
}

/* ==================== REAL-TIME LAND UNIT CALCULATOR ==================== */
function setupLandCalculator() {
  const valInput = document.getElementById('calcInputVal');
  const unitSelect = document.getElementById('calcInputUnit');
  const rateInput = document.getElementById('calcRateVal');
  const rateUnitSelect = document.getElementById('calcRateUnit');

  if (!valInput || !unitSelect) return;

  const recalculate = () => {
    const val = parseFloat(valInput.value) || 0;
    const unit = unitSelect.value;
    
    let sqFt = 0;
    if (unit === 'sqft') sqFt = val;
    else if (unit === 'cent') sqFt = val * 435.6;
    else if (unit === 'kuzhi') sqFt = val * 144.0;
    else if (unit === 'acre') sqFt = val * 43560.0;
    else if (unit === 'ground') sqFt = val * 2400.0;
    else if (unit === 'maa') sqFt = val * 14400.0;

    const cents = sqFt / 435.6;
    const kuzhi = sqFt / 144.0;
    const acres = sqFt / 43560.0;
    const grounds = sqFt / 2400.0;
    const maa = sqFt / 14400.0;

    document.getElementById('resSqFt').innerText = sqFt.toLocaleString(undefined, { maximumFractionDigits: 2 });
    document.getElementById('resCent').innerText = cents.toLocaleString(undefined, { maximumFractionDigits: 2 });
    document.getElementById('resKuzhi').innerText = kuzhi.toLocaleString(undefined, { maximumFractionDigits: 2 });
    document.getElementById('resAcre').innerText = acres.toLocaleString(undefined, { maximumFractionDigits: 4 });
    document.getElementById('resGround').innerText = grounds.toLocaleString(undefined, { maximumFractionDigits: 2 });
    document.getElementById('resMaa').innerText = maa.toLocaleString(undefined, { maximumFractionDigits: 2 });

    if (rateInput) {
      const rate = parseFloat(rateInput.value) || 0;
      const rateUnit = rateUnitSelect ? rateUnitSelect.value : 'cent';
      let totalPrice = 0;

      if (rateUnit === 'cent') totalPrice = cents * rate;
      else if (rateUnit === 'kuzhi') totalPrice = kuzhi * rate;
      else if (rateUnit === 'sqft') totalPrice = sqFt * rate;
      else if (rateUnit === 'acre') totalPrice = acres * rate;

      const priceBox = document.getElementById('resTotalPrice');
      if (priceBox) {
        priceBox.innerText = formatIndianCurrency(totalPrice);
      }
    }
  };

  valInput.addEventListener('input', recalculate);
  unitSelect.addEventListener('change', recalculate);
  if (rateInput) rateInput.addEventListener('input', recalculate);
  if (rateUnitSelect) rateUnitSelect.addEventListener('change', recalculate);

  recalculate();
}

/* ==================== EVENT LISTENERS & NAVIGATION ==================== */
function setupEventListeners() {
  const loginForm = document.getElementById('loginForm');
  if (loginForm) loginForm.addEventListener('submit', handleLogin);

  const propForm = document.getElementById('propertyForm');
  if (propForm) propForm.addEventListener('submit', handlePropertySubmit);

  const reqForm = document.getElementById('reqForm');
  if (reqForm) reqForm.addEventListener('submit', handleRequirementSubmit);

  const propTypeSelect = document.getElementById('propType');
  if (propTypeSelect) {
    propTypeSelect.addEventListener('change', (e) => {
      handleCategoryChange(e.target.value);
    });
  }

  document.querySelectorAll('.nav-link[data-tab]').forEach(link => {
    link.addEventListener('click', (e) => {
      e.preventDefault();
      const tab = link.getAttribute('data-tab');
      switchTab(tab);
    });
  });

  document.querySelectorAll('.cat-pill-card[data-cat]').forEach(card => {
    card.addEventListener('click', () => {
      document.querySelectorAll('.cat-pill-card').forEach(c => c.classList.remove('active'));
      card.classList.add('active');
      const cat = card.getAttribute('data-cat');
      AppState.activeCategory = cat;
      const categorySelect = document.getElementById('tableCategoryFilter');
      if (categorySelect) categorySelect.value = cat;
      renderPropertiesTable();
    });
  });

  const tableSearch = document.getElementById('tableSearchInput');
  if (tableSearch) {
    tableSearch.addEventListener('input', (e) => {
      AppState.searchQuery = e.target.value;
      renderPropertiesTable();
    });
  }

  const catFilter = document.getElementById('tableCategoryFilter');
  if (catFilter) {
    catFilter.addEventListener('change', (e) => {
      AppState.activeCategory = e.target.value;
      renderPropertiesTable();
    });
  }

  const statusFilter = document.getElementById('tableStatusFilter');
  if (statusFilter) {
    statusFilter.addEventListener('change', (e) => {
      AppState.activeStatus = e.target.value;
      renderPropertiesTable();
    });
  }

  // Close notification dropdown when clicked outside
  document.addEventListener('click', (e) => {
    const notifWrapper = document.getElementById('notifBellWrapper');
    const notifDropdown = document.getElementById('notifDropdown');
    if (notifDropdown && notifDropdown.classList.contains('show')) {
      if (notifWrapper && !notifWrapper.contains(e.target)) {
        notifDropdown.classList.remove('show');
      }
    }
  });
}

function switchTab(tabId) {
  document.querySelectorAll('.nav-item').forEach(item => item.classList.remove('active'));
  const activeNavItem = document.querySelector(`.nav-link[data-tab="${tabId}"]`);
  if (activeNavItem && activeNavItem.parentElement) {
    activeNavItem.parentElement.classList.add('active');
  }

  document.querySelectorAll('.tab-panel').forEach(panel => panel.classList.remove('active'));
  const targetPanel = document.getElementById(`tab-${tabId}`);
  if (targetPanel) {
    targetPanel.classList.add('active');
  }

  if (tabId === 'properties' || tabId === 'overview') {
    renderPropertiesTable();
    fetchProperties(true);
  }
  if (tabId === 'pending-ads') {
    renderPendingApprovalsSection();
  }
  if (tabId === 'settings') {
    fetchEnvConfig();
  }
  if (tabId === 'payments') {
    loadPaymentsData();
  }
  if (tabId === 'app-config') {
    fetchAppConfig();
  }
  if (tabId === 'user-activities') {
    loadActivitiesData();
  }
  if (tabId === 'live-users') {
    loadLiveUsers();
  }

  window.scrollTo({ top: 0, behavior: 'smooth' });
}

/* ==================== PAYMENTS & REVENUE ==================== */
async function loadPaymentsData() {
  try {
    const res = await fetch(`${API_BASE}/payments.php`);
    const data = await res.json();
    if (data && data.success) {
      const stats = data.stats || { totalRevenue: 0, paidUnlocksCount: 0, freeViewsCount: 0 };
      const config = data.config || { unlockPrice: 30 };

      // Update Overview stats if elements exist
      const statRev = document.getElementById('statRevenue');
      if (statRev) statRev.innerText = '₹' + (stats.totalRevenue || 0);
      const statPaid = document.getElementById('statPaidUnlocks');
      if (statPaid) statPaid.innerText = stats.paidUnlocksCount || 0;

      // Update Pricing Tab Summary
      const sumTotal = document.getElementById('paySummaryTotal');
      if (sumTotal) sumTotal.innerText = '₹' + (stats.totalRevenue || 0);
      const sumPaid = document.getElementById('paySummaryPaidCount');
      if (sumPaid) sumPaid.innerText = stats.paidUnlocksCount || 0;
      const sumFree = document.getElementById('paySummaryFreeCount');
      if (sumFree) sumFree.innerText = stats.freeViewsCount || 0;
      const sumPrice = document.getElementById('paySummaryPrice');
      if (sumPrice) {
        const effPrice = config.effectivePrice !== undefined ? config.effectivePrice : (config.unlockPrice || 30);
        sumPrice.innerText = '₹' + effPrice + (config.offerActive ? ' (ஆஃபர்)' : '');
      }

      // Populate Pricing and Offer form fields
      if (config) {
        const setVal = (id, val) => {
          const el = document.getElementById(id);
          if (el && val !== undefined && val !== null) el.value = val;
        };
        setVal('pricing_FREE_CONTACT_LIMIT', config.freeLimit !== undefined ? config.freeLimit : 3);
        setVal('pricing_CONTACT_UNLOCK_PRICE', config.unlockPrice || 30);
        setVal('pricing_UNLOCK_CONTACTS_COUNT', config.unlockContactsCount || 1);
        setVal('pricing_OFFER_UNLOCK_PRICE', config.offerPrice || 10);
        setVal('pricing_OFFER_CONTACTS_COUNT', config.offerContactsCount || 1);
        setVal('pricing_OFFER_BANNER_TEXT', config.offerBannerText || 'சிறப்பு சலுகை: வெறும் ₹10 செலுத்தி உரிமையாளர் எண்ணை உடனே பெறலாம்!');

        const offerActiveEl = document.getElementById('pricing_OFFER_ACTIVE');
        if (offerActiveEl) {
          offerActiveEl.checked = !!config.offerActive;
          updateOfferBadgeStatus(offerActiveEl.checked);
        }
      }

      renderPaymentsTable(data.payments || []);
    }
  } catch (err) {
    console.warn('Payments load fallback:', err);
  }
}

function updateOfferBadgeStatus(isActive) {
  const badge = document.getElementById('pricingOfferStatusBadge');
  if (!badge) return;
  if (isActive) {
    badge.style.background = 'rgba(16, 185, 129, 0.2)';
    badge.style.color = '#34d399';
    badge.innerHTML = '🔥 ஆஃபர் நேரலையில் உள்ளது (Offer Active)';
  } else {
    badge.style.background = 'rgba(148, 163, 184, 0.15)';
    badge.style.color = '#94a3b8';
    badge.innerHTML = 'ஆஃபர் முடக்கத்தில் உள்ளது (Offer Inactive)';
  }
}

function applyPricingPreset(freeLimit, regularPrice, unlockCount, offerActive, offerPrice, offerCount, bannerText) {
  const setVal = (id, val) => {
    const el = document.getElementById(id);
    if (el && val !== undefined && val !== null) el.value = val;
  };
  setVal('pricing_FREE_CONTACT_LIMIT', freeLimit);
  setVal('pricing_CONTACT_UNLOCK_PRICE', regularPrice);
  setVal('pricing_UNLOCK_CONTACTS_COUNT', unlockCount);
  setVal('pricing_OFFER_UNLOCK_PRICE', offerPrice);
  setVal('pricing_OFFER_CONTACTS_COUNT', offerCount);
  setVal('pricing_OFFER_BANNER_TEXT', bannerText);

  const offerCheck = document.getElementById('pricing_OFFER_ACTIVE');
  if (offerCheck) {
    offerCheck.checked = !!offerActive;
    updateOfferBadgeStatus(offerCheck.checked);
  }
  showToast('பரிந்துரைக்கப்பட்ட அமைப்பு நிரப்பப்பட்டது! "அமைப்புகளை சேமி" பொத்தானை கிளிக் செய்யவும்.', 'info');
}

async function savePricingOfferSettings() {
  const freeLimit = parseInt(document.getElementById('pricing_FREE_CONTACT_LIMIT')?.value || '3', 10);
  const unlockPrice = parseInt(document.getElementById('pricing_CONTACT_UNLOCK_PRICE')?.value || '30', 10);
  const unlockCount = parseInt(document.getElementById('pricing_UNLOCK_CONTACTS_COUNT')?.value || '1', 10);
  const offerActive = document.getElementById('pricing_OFFER_ACTIVE')?.checked || false;
  const offerPrice = parseInt(document.getElementById('pricing_OFFER_UNLOCK_PRICE')?.value || '10', 10);
  const offerCount = parseInt(document.getElementById('pricing_OFFER_CONTACTS_COUNT')?.value || '1', 10);
  const offerBanner = document.getElementById('pricing_OFFER_BANNER_TEXT')?.value || '';

  const payload = {
    action: 'save_pricing',
    FREE_CONTACT_LIMIT: freeLimit,
    CONTACT_UNLOCK_PRICE: unlockPrice,
    UNLOCK_CONTACTS_COUNT: unlockCount,
    OFFER_ACTIVE: offerActive,
    OFFER_UNLOCK_PRICE: offerPrice,
    OFFER_CONTACTS_COUNT: offerCount,
    OFFER_BANNER_TEXT: offerBanner
  };

  try {
    const res = await fetch(`${API_BASE}/payments.php`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    const result = await res.json();
    if (result && result.success) {
      showToast('🎉 கட்டணங்கள் & ஆஃபர் அமைப்புகள் வெற்றிகரமாக சேமிக்கப்பட்டன! (Pricing & Offers Updated)', 'success');
      loadPaymentsData();
    } else {
      showToast(result.message || 'அமைப்புகளை சேமிக்க முடியவில்லை.', 'error');
    }
  } catch (err) {
    console.error('savePricingOfferSettings error:', err);
    showToast('சேமிப்பில் பிழை ஏற்பட்டது: ' + err.message, 'error');
  }
}

function renderPaymentsTable(payments) {
  const tbody = document.getElementById('paymentsTableBody');
  if (!tbody) return;

  if (!payments || payments.length === 0) {
    tbody.innerHTML = '<tr><td colspan="7" style="text-align:center; padding:30px; color:var(--text-muted);">பரிவர்த்தனைகள் எதுவும் இல்லை (No transactions recorded yet)</td></tr>';
    return;
  }

  tbody.innerHTML = payments.map(p => `
    <tr>
      <td><span style="font-family:monospace; font-size:12px; color:var(--accent-gold); font-weight:700;">${p.paymentId || p.id}</span></td>
      <td style="font-size:12px; color:var(--text-muted);">${formatDateTime(p.date)}</td>
      <td>
        <div style="font-weight:700; color:#fff; font-size:13px;">${p.propTitle || 'Property Contact'}</div>
        <div style="font-size:11px; color:var(--text-muted);">ID: ${p.propId || '-'}</div>
      </td>
      <td>
        <div style="font-weight:600; color:var(--text-main);">${p.buyerName || 'Customer'}</div>
        <div style="font-size:11.5px; color:var(--accent-blue);">${p.buyerPhone || '-'}</div>
      </td>
      <td><span class="badge" style="background:rgba(2,132,199,0.2); color:#38BDF8; font-weight:700;">${p.method || 'Razorpay UPI'}</span></td>
      <td><span style="font-size:15px; font-weight:800; color:#10B981;">₹${p.amount}</span></td>
      <td><span class="badge badge-success">✓ வெற்றி (Success)</span></td>
    </tr>
  `).join('');
}

function closeModal(modalId) {
  const modal = document.getElementById(modalId);
  if (modal) modal.classList.remove('show');
}

/* ==================== HELPERS & FORMATTING ==================== */
function showToast(message, type = 'info') {
  const container = document.getElementById('toastContainer');
  if (!container) return;

  const toast = document.createElement('div');
  toast.className = `toast toast-${type}`;
  toast.innerHTML = `
    <span>${type === 'success' ? '✓' : (type === 'error' ? '✕' : 'ℹ')}</span>
    <div>${escapeHtml(message)}</div>
  `;
  container.appendChild(toast);

  setTimeout(() => {
    toast.style.opacity = '0';
    toast.style.transform = 'translateX(50px)';
    setTimeout(() => toast.remove(), 300);
  }, 3500);
}

function formatDateTime(dateStr) {
  if (!dateStr) return '-';
  try {
    const d = new Date(dateStr);
    if (isNaN(d.getTime())) return dateStr;
    return d.toLocaleDateString('ta-IN', {
      day: '2-digit',
      month: 'short',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  } catch (e) {
    return dateStr;
  }
}

function formatTamilPrice(price, type) {
  if (!price || price === 0) return 'விலை விவரம் கேட்கவும்';
  const isMonthly = (type || '').toLowerCase().includes('rental');
  const symbol = AppState.envConfig && AppState.envConfig.CURRENCY_SYMBOL ? AppState.envConfig.CURRENCY_SYMBOL : '₹';
  
  if (price >= 10000000) {
    return symbol + (price / 10000000).toFixed(2) + ' கோடி' + (isMonthly ? '/மாதம்' : '');
  } else if (price >= 100000) {
    return symbol + (price / 100000).toFixed(2) + ' லட்சம்' + (isMonthly ? '/மாதம்' : '');
  } else {
    return symbol + price.toLocaleString('en-IN') + (isMonthly ? '/மாதம்' : '');
  }
}

function formatRequirementBudget(min, max) {
  if (!min && !max) return 'பேசலாம்';
  const symbol = AppState.envConfig && AppState.envConfig.CURRENCY_SYMBOL ? AppState.envConfig.CURRENCY_SYMBOL : '₹';
  const formatVal = (v) => {
    if (v >= 10000000) return (v / 10000000).toFixed(2) + ' கோடி';
    if (v >= 100000) return (v / 100000).toFixed(1) + ' லட்சம்';
    return v.toLocaleString('en-IN');
  };
  return `${symbol}${formatVal(min)} - ${symbol}${formatVal(max)}`;
}

function formatIndianCurrency(amount) {
  if (isNaN(amount) || amount === 0) return '₹0';
  const symbol = AppState.envConfig && AppState.envConfig.CURRENCY_SYMBOL ? AppState.envConfig.CURRENCY_SYMBOL : '₹';
  if (amount >= 10000000) return symbol + (amount / 10000000).toFixed(2) + ' கோடி (Crore)';
  if (amount >= 100000) return symbol + (amount / 100000).toFixed(2) + ' லட்சம் (Lakhs)';
  return symbol + Math.round(amount).toLocaleString('en-IN');
}

function getCategoryIcon(type) {
  const t = (type || '').toLowerCase();
  if (t.includes('house') || t.includes('villa')) return '🏡';
  if (t.includes('land') || t.includes('plot')) return '📐';
  if (t.includes('farm') || t.includes('thottam')) return '🌴';
  if (t.includes('shop') || t.includes('commercial') || t.includes('office')) return '🏪';
  if (t.includes('apartment') || t.includes('flat')) return '🏢';
  if (t.includes('rental') || t.includes('lease')) return '🔑';
  return '🏠';
}

function escapeHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

/* ==================== APP CONFIGURATION & LOGIN MODE ==================== */
async function fetchAppConfig() {
  try {
    const res = await fetch(`${API_BASE}/app_config.php`);
    const data = await res.json();
    if (data && data.success && data.config) {
      AppState.appConfig = data.config;
      populateAppConfigUI(data.config);
    }
  } catch (err) {
    console.warn('Failed to load app config:', err);
  }
}

function populateAppConfigUI(cfg) {
  if (!cfg) return;
  const setVal = (id, val) => {
    const el = document.getElementById(id);
    if (el && val !== undefined && val !== null) el.value = val;
  };

  const loginMethod = cfg.login_method || 'google';
  setVal('app_LOGIN_METHOD', loginMethod);
  selectLoginModePreset(loginMethod, false);

  const chkGoogle = document.getElementById('app_GOOGLE_SIGN_IN_ENABLED');
  if (chkGoogle) chkGoogle.checked = !!cfg.google_sign_in_enabled;

  const chkPhone = document.getElementById('app_PHONE_OTP_ENABLED');
  if (chkPhone) chkPhone.checked = !!cfg.phone_otp_enabled;

  setVal('app_FREE_CONTACT_LIMIT', cfg.free_contact_limit !== undefined ? cfg.free_contact_limit : 3);
  setVal('app_CONTACT_UNLOCK_PRICE', cfg.contact_unlock_price || 30);
  setVal('app_OFFER_UNLOCK_PRICE', cfg.offer_unlock_price || 10);
  setVal('app_OFFER_BANNER_TEXT', cfg.offer_banner_text || 'சிறப்பு சலுகை: வெறும் ₹10 செலுத்தி உரிமையாளர் எண்ணை உடனே அறியலாம்!');
  setVal('app_RAZORPAY_ACCOUNT_ID', cfg.razorpay_account_id || '');
  setVal('app_RAZORPAY_KEY_ID', cfg.razorpay_key_id || '');

  const offerChk = document.getElementById('app_OFFER_ACTIVE');
  if (offerChk) offerChk.checked = !!cfg.offer_active;
}

function selectLoginModePreset(mode, updateCheckboxes = true) {
  const hiddenInput = document.getElementById('app_LOGIN_METHOD');
  if (hiddenInput) hiddenInput.value = mode;

  const cardGoogle = document.getElementById('modeCardGoogle');
  const cardPhone = document.getElementById('modeCardPhone');
  const cardBoth = document.getElementById('modeCardBoth');

  const badgeGoogle = document.getElementById('badgeModeGoogle');
  const badgePhone = document.getElementById('badgeModePhone');
  const badgeBoth = document.getElementById('badgeModeBoth');

  // Reset styles
  [cardGoogle, cardPhone, cardBoth].forEach(c => {
    if (c) {
      c.style.background = 'rgba(15, 23, 42, 0.6)';
      c.style.border = '1.5px solid rgba(148, 163, 184, 0.3)';
    }
  });
  if (badgeGoogle) badgeGoogle.style.display = 'none';
  if (badgePhone) badgePhone.style.display = 'none';
  if (badgeBoth) badgeBoth.style.display = 'none';

  if (mode === 'google') {
    if (cardGoogle) {
      cardGoogle.style.background = 'rgba(16, 185, 129, 0.12)';
      cardGoogle.style.border = '2px solid #10b981';
    }
    if (badgeGoogle) badgeGoogle.style.display = 'inline-block';
    if (updateCheckboxes) {
      const g = document.getElementById('app_GOOGLE_SIGN_IN_ENABLED');
      const p = document.getElementById('app_PHONE_OTP_ENABLED');
      if (g) g.checked = true;
      if (p) p.checked = false;
    }
  } else if (mode === 'phone') {
    if (cardPhone) {
      cardPhone.style.background = 'rgba(59, 130, 246, 0.12)';
      cardPhone.style.border = '2px solid #3b82f6';
    }
    if (badgePhone) badgePhone.style.display = 'inline-block';
    if (updateCheckboxes) {
      const g = document.getElementById('app_GOOGLE_SIGN_IN_ENABLED');
      const p = document.getElementById('app_PHONE_OTP_ENABLED');
      if (g) g.checked = false;
      if (p) p.checked = true;
    }
  } else if (mode === 'both') {
    if (cardBoth) {
      cardBoth.style.background = 'rgba(139, 92, 246, 0.12)';
      cardBoth.style.border = '2px solid #8b5cf6';
    }
    if (badgeBoth) badgeBoth.style.display = 'inline-block';
    if (updateCheckboxes) {
      const g = document.getElementById('app_GOOGLE_SIGN_IN_ENABLED');
      const p = document.getElementById('app_PHONE_OTP_ENABLED');
      if (g) g.checked = true;
      if (p) p.checked = true;
    }
  }
}

function syncLoginCheckboxes() {
  const g = document.getElementById('app_GOOGLE_SIGN_IN_ENABLED')?.checked;
  const p = document.getElementById('app_PHONE_OTP_ENABLED')?.checked;

  let mode = 'google';
  if (g && p) mode = 'both';
  else if (p && !g) mode = 'phone';
  else mode = 'google';

  selectLoginModePreset(mode, false);
}

async function saveAppConfigSettings() {
  const loginMethod = document.getElementById('app_LOGIN_METHOD')?.value || 'google';
  const googleEnabled = !!document.getElementById('app_GOOGLE_SIGN_IN_ENABLED')?.checked;
  const phoneEnabled = !!document.getElementById('app_PHONE_OTP_ENABLED')?.checked;
  const freeLimit = parseInt(document.getElementById('app_FREE_CONTACT_LIMIT')?.value) || 3;
  const unlockPrice = parseInt(document.getElementById('app_CONTACT_UNLOCK_PRICE')?.value) || 30;
  const offerActive = !!document.getElementById('app_OFFER_ACTIVE')?.checked;
  const offerPrice = parseInt(document.getElementById('app_OFFER_UNLOCK_PRICE')?.value) || 10;
  const offerBanner = document.getElementById('app_OFFER_BANNER_TEXT')?.value.trim() || '';
  const rzpAccount = document.getElementById('app_RAZORPAY_ACCOUNT_ID')?.value.trim() || '';
  const rzpKey = document.getElementById('app_RAZORPAY_KEY_ID')?.value.trim() || '';
  const rzpSecret = document.getElementById('app_RAZORPAY_KEY_SECRET')?.value.trim() || '';

  const payload = {
    login_method: loginMethod,
    google_sign_in_enabled: googleEnabled,
    phone_otp_enabled: phoneEnabled,
    free_contact_limit: freeLimit,
    contact_unlock_price: unlockPrice,
    offer_active: offerActive,
    offer_unlock_price: offerPrice,
    offer_banner_text: offerBanner,
    razorpay_account_id: rzpAccount,
    razorpay_key_id: rzpKey
  };
  if (rzpSecret) payload.razorpay_key_secret = rzpSecret;

  try {
    const res = await fetch(`${API_BASE}/app_config.php`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    const data = await res.json();
    if (data && data.success) {
      showToast(data.message || 'செயலி அமைப்புகள் வெற்றிகரமாக சேமிக்கப்பட்டன!', 'success');
      AppState.appConfig = data.config;
    } else {
      showToast('சேமிப்பதில் பிழை ஏற்பட்டது', 'error');
    }
  } catch (err) {
    showToast('சேமிக்க முடியவில்லை: ' + err.message, 'error');
  }
}

/* ==================== USER ACTIVITIES & LEADS TRACKER ==================== */
async function loadActivitiesData() {
  try {
    const res = await fetch(`${API_BASE}/activities.php`);
    const data = await res.json();
    if (data && data.success) {
      AppState.activities = data.activities || [];
      AppState.activityStats = data.stats || {};
      AppState.activityUsers = data.users || [];
      AppState.activityPosters = data.posters || [];
      AppState.propertyViews = data.property_views || [];

      renderActivityStats(data.stats);
      populateActivityUserDropdown(data.users || []);
      filterActivitiesList();
      renderPostersTable(AppState.activityPosters);
      renderPropertyViewsTable(AppState.propertyViews);
    }
  } catch (err) {
    console.warn('Failed to load user activities:', err);
  }
}

function switchActSubTab(tabName) {
  const tabs = ['activities', 'posters', 'propertyViews', 'chats'];
  tabs.forEach(t => {
    const btn = document.getElementById('btnSubTab' + t.charAt(0).toUpperCase() + t.slice(1));
    const sec = document.getElementById('actSection' + t.charAt(0).toUpperCase() + t.slice(1));
    if (btn) {
      btn.className = (t === tabName) ? 'btn btn-primary act-subtab-btn' : 'btn btn-secondary act-subtab-btn';
    }
    if (sec) {
      sec.style.display = (t === tabName) ? 'block' : 'none';
    }
  });

  if (tabName === 'chats') {
    loadAdminChats();
  }
}

function renderPostersTable(posters) {
  const tbody = document.getElementById('postersTableBody');
  if (!tbody) return;

  if (!posters || posters.length === 0) {
    tbody.innerHTML = `
      <tr>
        <td colspan="6" style="text-align:center; padding: 40px; color: var(--text-muted);">
          விளம்பரம் பதிவிட்ட விற்பனையாளர்கள் விவரம் கிடைக்கவில்லை.
        </td>
      </tr>
    `;
    return;
  }

  tbody.innerHTML = posters.map(p => {
    const cleanPhone = (p.seller_phone || '').replace(/[^0-9]/g, '');
    return `
      <tr>
        <td>
          <div style="font-weight:700; color:#fff; font-size:14px;">🏷️ ${escapeHtml(p.seller_name || 'Direct Owner')}</div>
          <div style="font-size:11.5px; color:var(--text-muted); margin-top:2px;">பதிவாளர் (Property Poster)</div>
        </td>
        <td>
          <div style="font-weight:700; color:#38bdf8; font-size:13.5px;">📞 ${escapeHtml(p.seller_phone || '-')}</div>
          <div style="display:flex; gap:6px; margin-top:4px;">
            ${cleanPhone ? `
              <a href="tel:${cleanPhone}" class="btn btn-secondary" style="padding:2px 8px; font-size:11px;" title="Call">📞 Call</a>
              <a href="https://wa.me/91${cleanPhone}" target="_blank" class="btn btn-emerald" style="padding:2px 8px; font-size:11px;" title="WhatsApp">💬 WhatsApp</a>
            ` : ''}
          </div>
        </td>
        <td>
          <span class="badge badge-verified" style="font-size:13px; font-weight:800; padding:4px 10px;">
            🏠 ${p.total_properties || 0} விளம்பரங்கள்
          </span>
        </td>
        <td>
          <span style="font-size:14px; font-weight:800; color:#38bdf8;">
            👁️ ${p.total_views_received || 0} பார்வைகள்
          </span>
        </td>
        <td>
          <span style="font-size:13px; font-weight:800; color:#10b981;">
            🔓 ${p.total_unlocks_received || 0} திறப்புகள்
          </span>
        </td>
        <td>
          <button class="btn btn-primary" style="padding:6px 12px; font-size:11.5px;" onclick="openPosterAdsModal('${escapeHtml(p.seller_phone)}')">
            📋 விளம்பரங்கள் & பார்வைகள்
          </button>
        </td>
      </tr>
    `;
  }).join('');
}

function openPosterAdsModal(sellerPhone) {
  const seller = (AppState.activityPosters || []).find(p => p.seller_phone === sellerPhone);
  if (!seller) return;

  const modal = document.getElementById('posterAdsModal');
  const title = document.getElementById('posterAdsModalTitle');
  const content = document.getElementById('posterAdsModalContent');

  if (title) title.innerText = `📢 ${seller.seller_name} (${seller.seller_phone}) - விளம்பரங்கள்`;
  
  const props = seller.properties || [];
  if (props.length === 0) {
    content.innerHTML = `<p style="color:var(--text-muted); text-align:center; padding:20px;">விளம்பரங்கள் எதுவும் இல்லை.</p>`;
  } else {
    content.innerHTML = `
      <div style="margin-bottom:16px; display:flex; gap:12px;">
        <div style="background:rgba(59,130,246,0.15); padding:10px 14px; border-radius:8px; border:1px solid rgba(59,130,246,0.3);">
          <div style="font-size:11px; color:#93c5fd;">மொத்த விளம்பரங்கள்</div>
          <div style="font-size:16px; font-weight:800; color:#fff;">${props.length}</div>
        </div>
        <div style="background:rgba(16,185,129,0.15); padding:10px 14px; border-radius:8px; border:1px solid rgba(16,185,129,0.3);">
          <div style="font-size:11px; color:#6ee7b7;">பெற்ற மொத்த பார்வைகள்</div>
          <div style="font-size:16px; font-weight:800; color:#fff;">${seller.total_views_received || 0}</div>
        </div>
      </div>
      <div style="display:flex; flex-direction:column; gap:12px;">
        ${props.map(p => `
          <div style="background:rgba(15,23,42,0.6); border:1px solid var(--border-glass); border-radius:10px; padding:14px;">
            <div style="display:flex; justify-content:space-between; align-items:flex-start;">
              <div>
                <div style="font-weight:700; color:#fff; font-size:14px;">${getCategoryIcon(p.propertyType)} ${escapeHtml(p.title)}</div>
                <div style="font-size:12px; color:var(--text-muted); margin-top:2px;">விலை: ₹${p.price.toLocaleString('en-IN')} | வகை: ${p.propertyType}</div>
              </div>
              <div style="text-align:right;">
                <span class="badge badge-verified" style="font-size:12px; font-weight:800;">👁️ ${p.views_count || 0} பார்வைகள்</span>
                <div style="font-size:11px; color:#10b981; font-weight:700; margin-top:4px;">🔓 ${p.unlocks_count || 0} திறப்புகள்</div>
              </div>
            </div>
            ${p.viewers && p.viewers.length > 0 ? `
              <div style="margin-top:10px; padding-top:10px; border-top:1px solid rgba(255,255,255,0.06);">
                <div style="font-size:11px; font-weight:700; color:#94a3b8; margin-bottom:6px;">பார்த்த வாடிக்கையாளர்கள் (Recent Viewers):</div>
                <div style="display:flex; flex-direction:column; gap:4px;">
                  ${p.viewers.slice(0, 5).map(v => `
                    <div style="display:flex; justify-content:space-between; font-size:12px; color:#cbd5e1; background:rgba(255,255,255,0.03); padding:4px 8px; border-radius:6px;">
                      <span>👤 ${escapeHtml(v.user_name)} (${escapeHtml(v.user_phone || 'எண் இல்லை')})</span>
                      <span style="color:#64748b; font-size:11px;">${v.viewed_at ? v.viewed_at.substring(0, 16) : ''}</span>
                    </div>
                  `).join('')}
                </div>
              </div>
            ` : ''}
          </div>
        `).join('')}
      </div>
    `;
  }

  modal.style.display = 'flex';
}

function closePosterAdsModal() {
  const modal = document.getElementById('posterAdsModal');
  if (modal) modal.style.display = 'none';
}

function renderPropertyViewsTable(propViews) {
  const tbody = document.getElementById('propertyViewsTableBody');
  if (!tbody) return;

  if (!propViews || propViews.length === 0) {
    tbody.innerHTML = `
      <tr>
        <td colspan="6" style="text-align:center; padding: 40px; color: var(--text-muted);">
          பார்வையாளர்கள் விவரம் எதுவும் கிடைக்கவில்லை.
        </td>
      </tr>
    `;
    return;
  }

  tbody.innerHTML = propViews.map(pv => {
    return `
      <tr>
        <td>
          <div style="font-weight:700; color:#fff; font-size:13.5px;">🏡 ${escapeHtml(pv.property_title || 'சொத்து')}</div>
          <div style="font-size:11px; color:var(--text-muted); margin-top:2px;">ID: ${escapeHtml(pv.property_id)}</div>
        </td>
        <td>
          <span class="badge badge-pending" style="font-size:11.5px;">${escapeHtml(pv.property_type || 'Land')}</span>
        </td>
        <td>
          <div style="font-weight:700; color:#fde68a; font-size:13px;">🏷️ ${escapeHtml(pv.seller_name || 'Direct Owner')}</div>
          <div style="font-size:11.5px; color:var(--text-muted); margin-top:2px;">📞 ${escapeHtml(pv.seller_phone || '-')}</div>
        </td>
        <td>
          <span style="font-size:15px; font-weight:800; color:#38bdf8;">
            👁️ ${pv.views_count || 0} பார்வைகள்
          </span>
        </td>
        <td>
          <span style="font-size:13px; font-weight:800; color:#10b981;">
            🔓 ${(pv.viewers ? pv.viewers.length : 0)} பயனர்கள்
          </span>
        </td>
        <td>
          <button class="btn btn-primary" style="padding:6px 12px; font-size:11.5px;" onclick="openPropertyViewersModal('${escapeHtml(pv.property_id)}')">
            👥 பார்த்தவர்கள் பட்டியல் (${pv.views_count || 0})
          </button>
        </td>
      </tr>
    `;
  }).join('');
}

function openPropertyViewersModal(propId) {
  const prop = (AppState.propertyViews || []).find(p => p.property_id === propId);
  if (!prop) return;

  const modal = document.getElementById('propertyViewersModal');
  const title = document.getElementById('propertyViewersModalTitle');
  const content = document.getElementById('propertyViewersModalContent');

  if (title) title.innerText = `👁️ "${prop.property_title}" - பார்த்தவர்கள் பட்டியல் (${prop.views_count || 0})`;

  const viewers = prop.viewers || [];
  if (viewers.length === 0) {
    content.innerHTML = `<p style="color:var(--text-muted); text-align:center; padding:20px;">பார்த்தவர்கள் விவரம் எதுவும் பதிவு செய்யப்படவில்லை.</p>`;
  } else {
    content.innerHTML = `
      <div style="margin-bottom:14px; font-size:12px; color:var(--text-muted);">
        இந்த சொத்தை பார்வையிட்ட வாடிக்கையாளர்களின் பட்டியல் மற்றும் தொடர்பு எண்கள்:
      </div>
      <div style="display:flex; flex-direction:column; gap:8px;">
        ${viewers.map((v, i) => {
          const cleanP = (v.user_phone || '').replace(/[^0-9]/g, '');
          return `
            <div style="background:rgba(15,23,42,0.7); border:1px solid var(--border-glass); border-radius:8px; padding:12px; display:flex; justify-content:space-between; align-items:center;">
              <div>
                <div style="font-weight:700; color:#fff; font-size:13.5px;">${i + 1}. 👤 ${escapeHtml(v.user_name || 'Customer')}</div>
                <div style="font-size:12px; color:#38bdf8; font-weight:600; margin-top:2px;">📞 ${escapeHtml(v.user_phone || 'எண் இல்லை')}</div>
                ${v.user_email ? `<div style="font-size:11px; color:var(--text-muted);">✉️ ${escapeHtml(v.user_email)}</div>` : ''}
              </div>
              <div style="text-align:right;">
                <div style="font-size:11px; color:#94a3b8;">📅 ${v.viewed_at ? escapeHtml(v.viewed_at) : '-'}</div>
                <div style="display:flex; gap:6px; justify-content:flex-end; margin-top:6px;">
                  ${cleanP ? `
                    <a href="tel:${cleanP}" class="btn btn-secondary" style="padding:2px 8px; font-size:11px;">📞</a>
                    <a href="https://wa.me/91${cleanP}" target="_blank" class="btn btn-emerald" style="padding:2px 8px; font-size:11px;">💬</a>
                  ` : ''}
                </div>
              </div>
            </div>
          `;
        }).join('')}
      </div>
    `;
  }

  modal.style.display = 'flex';
}

function closePropertyViewersModal() {
  const modal = document.getElementById('propertyViewersModal');
  if (modal) modal.style.display = 'none';
}

async function loadAdminChats() {
  const tbody = document.getElementById('chatsTableBody');
  if (tbody) {
    tbody.innerHTML = `<tr><td colspan="6" style="text-align:center; padding:30px; color:var(--text-muted);">சாட் உரையாடல்கள் ஏற்றப்படுகிறது...</td></tr>`;
  }
  try {
    const res = await fetch(`${API_BASE}/chat.php?action=admin_all`);
    const data = await res.json();
    if (data && data.success) {
      renderAdminChatsTable(data.conversations || []);
    }
  } catch (err) {
    if (tbody) {
      tbody.innerHTML = `<tr><td colspan="6" style="text-align:center; padding:30px; color:var(--text-muted);">சாட் தரவு ஏற்றுவதில் பிழை.</td></tr>`;
    }
  }
}

function renderAdminChatsTable(convs) {
  const tbody = document.getElementById('chatsTableBody');
  if (!tbody) return;

  if (!convs || convs.length === 0) {
    tbody.innerHTML = `
      <tr>
        <td colspan="6" style="text-align:center; padding: 40px; color: var(--text-muted);">
          வாங்குபவர்-விற்பனையாளர் அரட்டை உரையாடல்கள் எதுவும் இல்லை.
        </td>
      </tr>
    `;
    return;
  }

  tbody.innerHTML = convs.map(c => {
    return `
      <tr>
        <td>
          <div style="font-weight:700; color:#fff; font-size:13.5px;">🏡 ${escapeHtml(c.property_title || 'சொத்து')}</div>
          <div style="font-size:11px; color:var(--text-muted); margin-top:2px;">ID: ${escapeHtml(c.property_id)}</div>
        </td>
        <td>
          <div style="font-weight:700; color:#38bdf8; font-size:13px;">👤 ${escapeHtml(c.buyer_name || 'Buyer')}</div>
          <div style="font-size:11.5px; color:var(--text-muted); margin-top:2px;">📞 ${escapeHtml(c.buyer_phone || '-')}</div>
        </td>
        <td>
          <div style="font-weight:700; color:#fde68a; font-size:13px;">🏷️ ${escapeHtml(c.seller_name || 'Seller')}</div>
          <div style="font-size:11.5px; color:var(--text-muted); margin-top:2px;">📞 ${escapeHtml(c.seller_phone || '-')}</div>
        </td>
        <td style="max-width:240px;">
          <div style="font-size:13px; color:#e2e8f0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
            ${escapeHtml(c.last_message || '-')}
          </div>
        </td>
        <td style="font-size:11.5px; color:var(--text-muted); white-space:nowrap;">
          ${escapeHtml((c.last_message_time || c.created_at || '-').substring(0, 16))}
        </td>
        <td>
          <button class="btn btn-primary" style="padding:6px 12px; font-size:11.5px;" onclick="openAdminChatModal('${escapeHtml(c.id)}')">
            💬 சாட் பார்க்க
          </button>
        </td>
      </tr>
    `;
  }).join('');
}

async function openAdminChatModal(convId) {
  const modal = document.getElementById('adminChatModal');
  const container = document.getElementById('adminChatModalMessages');
  if (container) {
    container.innerHTML = `<div style="text-align:center; padding:20px; color:var(--text-muted);">செய்திகள் ஏற்றப்படுகிறது...</div>`;
  }
  if (modal) modal.style.display = 'flex';

  try {
    const res = await fetch(`${API_BASE}/chat.php?action=messages&conversation_id=${encodeURIComponent(convId)}`);
    const data = await res.json();
    if (data && data.success && container) {
      const msgs = data.messages || [];
      if (msgs.length === 0) {
        container.innerHTML = `<div style="text-align:center; padding:20px; color:var(--text-muted);">செய்திகள் எதுவும் இல்லை.</div>`;
      } else {
        container.innerHTML = msgs.map(m => {
          const isBuyer = (m.sender_role === 'buyer');
          return `
            <div style="display:flex; flex-direction:column; align-items:${isBuyer ? 'flex-start' : 'flex-end'}; margin-bottom:10px;">
              <div style="font-size:11px; color:#94a3b8; margin-bottom:2px;">
                ${isBuyer ? '👤 வாங்குபவர்' : '🏷️ விற்பனையாளர்'} (${escapeHtml(m.sender_name || m.sender_phone)})
              </div>
              <div style="background:${isBuyer ? '#1e3a8a' : '#065f46'}; color:#fff; padding:8px 12px; border-radius:10px; max-width:80%; font-size:13.5px;">
                ${escapeHtml(m.message || '')}
              </div>
              <div style="font-size:10px; color:#64748b; margin-top:2px;">
                ${escapeHtml((m.created_at || '').substring(11, 16))}
              </div>
            </div>
          `;
        }).join('');
        container.scrollTop = container.scrollHeight;
      }
    }
  } catch (err) {
    if (container) {
      container.innerHTML = `<div style="text-align:center; padding:20px; color:var(--text-muted);">பிழை: செய்திகளை ஏற்ற முடியவில்லை.</div>`;
    }
  }
}

function closeAdminChatModal() {
  const modal = document.getElementById('adminChatModal');
  if (modal) modal.style.display = 'none';
}

function renderActivityStats(stats) {
  if (!stats) return;
  const total = document.getElementById('actStatTotal');
  if (total) total.innerText = stats.totalActivities || 0;

  const unlocks = document.getElementById('actStatUnlocks');
  if (unlocks) unlocks.innerText = stats.totalContactUnlocks || 0;

  const rev = document.getElementById('actStatRevenue');
  if (rev) rev.innerText = '₹' + (stats.totalRevenue || 0);

  const users = document.getElementById('actStatUsers');
  if (users) users.innerText = stats.uniqueUsersCount || 0;
}

function populateActivityUserDropdown(users) {
  const select = document.getElementById('actFilterSingleUser');
  if (!select) return;

  const currentVal = select.value;
  let html = '<option value="">👤 அனைத்து பயனர்கள் (All Users)</option>';
  users.forEach(u => {
    const phoneDisplay = u.phone ? ` (${u.phone})` : '';
    html += `<option value="${escapeHtml(u.key)}">${escapeHtml(u.name)}${phoneDisplay} - ${u.totalActivities} செயல்கள்</option>`;
  });
  select.innerHTML = html;
  select.value = currentVal;
}

function filterActivitiesList() {
  const search = (document.getElementById('actSearchInput')?.value || '').toLowerCase().trim();
  const actionType = document.getElementById('actFilterAction')?.value || 'all';
  const singleUser = document.getElementById('actFilterSingleUser')?.value || '';

  let filtered = AppState.activities || [];

  if (actionType !== 'all') {
    filtered = filtered.filter(a => (a.action_type || a.actionType) === actionType);
  }

  if (singleUser) {
    const cleanUser = singleUser.replace(/[^0-9]/g, '');
    filtered = filtered.filter(a => {
      const uPhone = (a.user_phone || a.userPhone || '').replace(/[^0-9]/g, '');
      const uEmail = a.user_email || a.userEmail || '';
      const uName = a.user_name || a.userName || '';
      return (cleanUser && uPhone.includes(cleanUser)) || uEmail === singleUser || uName === singleUser;
    });
  }

  if (search) {
    filtered = filtered.filter(a => {
      const blob = JSON.stringify(a).toLowerCase();
      return blob.includes(search);
    });
  }

  renderActivitiesTable(filtered);
}

function filterActivitiesByUser(userKey) {
  const banner = document.getElementById('actSingleUserBanner');
  if (!userKey) {
    if (banner) banner.style.display = 'none';
    filterActivitiesList();
    return;
  }

  const userObj = (AppState.activityUsers || []).find(u => u.key === userKey);
  if (userObj && banner) {
    banner.style.display = 'flex';
    document.getElementById('actBannerUserName').innerText = userObj.name || 'User';
    document.getElementById('actBannerUserPhone').innerText = userObj.phone || 'எண் இல்லை';
    document.getElementById('actBannerUserEmail').innerText = userObj.email || '-';
    document.getElementById('actBannerActivityCount').innerText = `${userObj.totalActivities || 0} செயல்பாடுகள் (${userObj.unlocksCount || 0} எண்கள் திறப்பு)`;
  }
  filterActivitiesList();
}

function resetActivityFilters() {
  const search = document.getElementById('actSearchInput');
  if (search) search.value = '';
  const action = document.getElementById('actFilterAction');
  if (action) action.value = 'all';
  const user = document.getElementById('actFilterSingleUser');
  if (user) user.value = '';

  const banner = document.getElementById('actSingleUserBanner');
  if (banner) banner.style.display = 'none';

  filterActivitiesList();
}

function renderActivitiesTable(list) {
  const tbody = document.getElementById('activitiesTableBody');
  if (!tbody) return;

  if (!list || list.length === 0) {
    tbody.innerHTML = `
      <tr>
        <td colspan="7" style="text-align:center; padding: 40px; color: var(--text-muted);">
          செயல்பாடுகள் எதுவும் கிடைக்கவில்லை (No activities found).
        </td>
      </tr>
    `;
    return;
  }

  tbody.innerHTML = list.map(item => {
    const actType = item.action_type || item.actionType || 'property_view';
    const dateStr = item.created_at || item.createdAt || '-';
    const uName = item.user_name || item.userName || 'Customer';
    const uPhone = item.user_phone || item.userPhone || '-';
    const uEmail = item.user_email || item.userEmail || '';
    const cleanUserPhone = uPhone.replace(/[^0-9]/g, '');

    const propTitle = item.property_title || item.propertyTitle || 'சொத்து விவரம்';
    const propType = item.property_type || item.propertyType || 'Land';
    const propLoc = item.property_location || item.propertyLocation || 'Tenkasi';
    const catIcon = getCategoryIcon(propType);

    const sName = item.seller_name || item.sellerName || 'Direct Owner';
    const sPhone = item.seller_phone || item.sellerPhone || '';
    const cleanSellerPhone = sPhone.replace(/[^0-9]/g, '');

    const amt = parseFloat(item.amount || 0);

    let badgeClass = 'badge-pending';
    let badgeText = '👁️ சொத்து பார்வை';
    if (actType === 'contact_unlock_free' || actType === 'contact_view_free') {
      badgeClass = 'badge-verified';
      badgeText = '🔓 இலவச தொடர்பு திறப்பு';
    } else if (actType === 'contact_unlock_paid') {
      badgeClass = 'badge-super-admin';
      badgeText = '💰 கட்டண தொடர்பு (₹30)';
    } else if (actType === 'property_post') {
      badgeClass = 'badge-sold';
      badgeText = '📝 புதிய விளம்பரம் பதிவு';
    } else if (actType === 'chat_message') {
      badgeClass = 'badge-pending';
      badgeText = '💬 அரட்டை செய்தி';
    }

    return `
      <tr>
        <td style="font-size:12px; color:var(--text-muted); white-space:nowrap;">
          <div>📅 ${escapeHtml(dateStr.substring(0, 10))}</div>
          <div style="font-size:11px; color:#94a3b8;">⏰ ${escapeHtml(dateStr.substring(11, 19))}</div>
        </td>
        <td>
          <div style="font-weight:700; color:#ffffff; font-size:13.5px;">👤 ${escapeHtml(uName)}</div>
          <div style="font-size:12px; color:#38bdf8; font-weight:600; margin-top:2px;">📞 ${escapeHtml(uPhone)}</div>
          ${uEmail ? `<div style="font-size:11px; color:var(--text-muted);">✉️ ${escapeHtml(uEmail)}</div>` : ''}
        </td>
        <td>
          <span class="badge ${badgeClass}" style="padding:4px 8px; font-size:11.5px; white-space:nowrap;">${badgeText}</span>
        </td>
        <td>
          <div style="font-weight:700; color:#e2e8f0; font-size:13px;">${catIcon} ${escapeHtml(propTitle)}</div>
          <div style="font-size:11.5px; color:var(--text-muted); margin-top:2px;">📍 ${escapeHtml(propLoc)}</div>
        </td>
        <td>
          <div style="font-weight:700; color:#fde68a; font-size:13px;">🏷️ ${escapeHtml(sName)}</div>
          <div style="font-size:11.5px; color:var(--text-muted); margin-top:2px;">📞 ${escapeHtml(sPhone || 'எண் இல்லை')}</div>
        </td>
        <td>
          <span style="font-weight:800; color:${amt > 0 ? '#10b981' : '#94a3b8'}; font-size:13.5px;">
            ${amt > 0 ? '₹' + amt : 'இலவசம் (₹0)'}
          </span>
        </td>
        <td>
          <div style="display:flex; gap:6px; flex-wrap:nowrap;">
            ${cleanUserPhone ? `
              <a href="tel:${cleanUserPhone}" class="btn btn-secondary" style="padding:4px 8px; font-size:11px;" title="Call Buyer">📞</a>
              <a href="https://wa.me/91${cleanUserPhone}?text=${encodeURIComponent('வணக்கம் ' + uName + ', தென்காசி கனவுகள் மூலம் நீங்கள் பார்த்த ' + propTitle + ' தொடர்பாக அழைக்கிறோம்.')}" target="_blank" class="btn btn-emerald" style="padding:4px 8px; font-size:11px;" title="WhatsApp Buyer">💬</a>
            ` : '-'}
          </div>
        </td>
      </tr>
    `;
  }).join('');
}

/* ==================== 12. LIVE ACTIVE USERS & DIRECT MESSAGING ==================== */

async function loadLiveUsers(isBackground = false) {
  try {
    const res = await fetch(`${API_BASE}/users.php?action=list_live`);
    const data = await res.json();
    if (data && data.success) {
      AppState.liveUsers = data.users || [];
      const stats = data.stats || { active_now: 0, app_active: 0, web_active: 0, total_users: 0 };

      // Update KPI Cards
      const elLiveNow = document.getElementById('statLiveNow');
      if (elLiveNow) elLiveNow.innerText = stats.active_now || 0;
      const elApp = document.getElementById('statAppActive');
      if (elApp) elApp.innerText = stats.app_active || 0;
      const elWeb = document.getElementById('statWebActive');
      if (elWeb) elWeb.innerText = stats.web_active || 0;
      const elTotal = document.getElementById('statTotalUsers');
      if (elTotal) elTotal.innerText = stats.total_users || 0;

      // Update Overview Dashboard Live Card
      const elDashLive = document.getElementById('statDashboardLiveUsers');
      if (elDashLive) elDashLive.innerText = stats.active_now || 0;

      // Update Sidebar Live Badge
      const badge = document.getElementById('sidebarLiveCount');
      if (badge) {
        badge.innerText = `${stats.active_now || 0} Live`;
      }

      renderLiveUsersTable();
    }
  } catch (err) {
    if (!isBackground) {
      console.error('Error loading live users:', err);
    }
  }
}

function renderLiveUsersTable() {
  const tbody = document.getElementById('liveUsersTableBody');
  if (!tbody) return;

  const searchInput = document.getElementById('liveUserSearchInput');
  const statusFilter = document.getElementById('liveUserStatusFilter');
  const platformFilter = document.getElementById('liveUserPlatformFilter');

  const query = (searchInput ? searchInput.value : '').trim().toLowerCase();
  const status = statusFilter ? statusFilter.value : 'all';
  const platform = platformFilter ? platformFilter.value : 'all';

  let list = AppState.liveUsers || [];

  // Filter by status
  if (status !== 'all') {
    list = list.filter(u => u.status === status);
  }

  // Filter by platform
  if (platform === 'app') {
    list = list.filter(u => (u.platform || '').toLowerCase().includes('app') || !(u.platform || '').toLowerCase().includes('web'));
  } else if (platform === 'web') {
    list = list.filter(u => (u.platform || '').toLowerCase().includes('web'));
  }

  // Filter by search query
  if (query) {
    list = list.filter(u => 
      (u.user_name || '').toLowerCase().includes(query) ||
      (u.user_phone || '').toLowerCase().includes(query) ||
      (u.user_email || '').toLowerCase().includes(query) ||
      (u.current_screen || '').toLowerCase().includes(query)
    );
  }

  if (list.length === 0) {
    tbody.innerHTML = `
      <tr>
        <td colspan="6" style="text-align:center; padding:40px; color:var(--text-muted);">
          🔍 தற்போதைய வடிகட்டலுக்கு எந்த பயனரும் கிடைக்கவில்லை.
        </td>
      </tr>
    `;
    return;
  }

  tbody.innerHTML = list.map(u => {
    const isOnline = u.status === 'online';
    const isIdle = u.status === 'idle';

    let statusBadge = '';
    if (isOnline) {
      statusBadge = `
        <span class="badge badge-emerald" style="display:inline-flex; align-items:center; gap:6px; font-weight:700; padding:4px 10px;">
          <span style="width:8px; height:8px; border-radius:50%; background:#10b981; display:inline-block; box-shadow:0 0 6px #10b981;"></span>
          🟢 நேரலையில் (Online)
        </span>
      `;
    } else if (isIdle) {
      statusBadge = `
        <span class="badge" style="background:rgba(234,179,8,0.15); color:#fbbf24; border:1px solid rgba(234,179,8,0.3); display:inline-flex; align-items:center; gap:6px; font-weight:600; padding:4px 10px;">
          <span style="width:8px; height:8px; border-radius:50%; background:#fbbf24; display:inline-block;"></span>
          🟡 சற்று முன் (Idle)
        </span>
      `;
    } else {
      statusBadge = `
        <span class="badge" style="background:rgba(148,163,184,0.12); color:#94a3b8; border:1px solid rgba(148,163,184,0.25); font-size:11px; padding:3px 8px;">
          ⚪ ஆஃப்லைன்
        </span>
      `;
    }

    const platformIcon = (u.platform || '').toLowerCase().includes('web') ? '💻 Web' : '📱 App';
    const cleanPhone = (u.user_phone || '').replace(/[^0-9]/g, '');

    // Time elapsed string in Tamil
    const diffSec = u.last_active_diff || 0;
    let timeText = 'இப்போது';
    if (diffSec > 60) {
      const mins = Math.floor(diffSec / 60);
      timeText = mins < 60 ? `${mins} நிமிடம் முன்` : `${Math.floor(mins / 60)} மணி நேரம் முன்`;
    }

    return `
      <tr>
        <td>
          ${statusBadge}
          <div style="font-size:11px; color:var(--text-muted); margin-top:4px;">${timeText}</div>
        </td>
        <td>
          <div style="font-weight:700; color:#fff; font-size:13.5px;">👤 ${escapeHtml(u.user_name || 'Customer')}</div>
          ${u.user_phone ? `<div style="font-size:12px; color:#38bdf8; font-weight:600; margin-top:2px;">📞 ${escapeHtml(u.user_phone)}</div>` : '<div style="font-size:11.5px; color:var(--text-muted);">📱 Guest User</div>'}
          ${u.user_email ? `<div style="font-size:11px; color:var(--text-muted);">✉️ ${escapeHtml(u.user_email)}</div>` : ''}
          <span class="badge" style="background:rgba(255,255,255,0.06); font-size:10px; margin-top:3px;">${escapeHtml(u.role || 'buyer')}</span>
        </td>
        <td>
          <span class="badge" style="background:${(u.platform || '').toLowerCase().includes('web') ? 'rgba(245,158,11,0.15)' : 'rgba(59,130,246,0.15)'}; color:${(u.platform || '').toLowerCase().includes('web') ? '#fbbf24' : '#60a5fa'}; font-weight:700; padding:4px 8px;">
            ${platformIcon} ${escapeHtml(u.platform || 'Android')}
          </span>
        </td>
        <td>
          <div style="font-weight:600; color:#e2e8f0; font-size:12.5px;">📍 ${escapeHtml(u.current_screen || 'Home')}</div>
        </td>
        <td style="font-size:12px; color:var(--text-muted);">
          <div>📅 ${escapeHtml((u.last_active || '').substring(0, 10))}</div>
          <div style="font-size:11px; color:#94a3b8;">⏰ ${escapeHtml((u.last_active || '').substring(11, 19))}</div>
        </td>
        <td style="text-align: right;">
          <div style="display:inline-flex; gap:6px; justify-content:flex-end;">
            <button type="button" class="btn btn-primary" style="padding:5px 10px; font-size:11.5px; font-weight:700;" onclick="openAdminDirectMsgModal('${escapeHtml(u.user_id || '')}', '${escapeHtml(u.user_name || 'Customer')}', '${escapeHtml(u.user_phone || '')}')" title="பயனருக்கு நேரடி செய்தி அனுப்புக">
              💬 செய்தி
            </button>
            ${cleanPhone ? `
              <a href="tel:${cleanPhone}" class="btn btn-secondary" style="padding:5px 8px; font-size:11.5px;" title="நேரடி அழைப்பு">📞</a>
              <a href="https://wa.me/91${cleanPhone}?text=${encodeURIComponent('வணக்கம் ' + (u.user_name || '') + ', தென்காசி கனவுகள் தளத்திலிருந்து தொடர்பு கொள்கிறோம்.')}" target="_blank" class="btn btn-emerald" style="padding:5px 8px; font-size:11.5px;" title="WhatsApp செய்தி">💬</a>
            ` : ''}
          </div>
        </td>
      </tr>
    `;
  }).join('');
}

function openAdminDirectMsgModal(userId, userName, userPhone) {
  const modal = document.getElementById('adminDirectMsgModal');
  if (!modal) return;

  document.getElementById('adminMsgUserId').value = userId || '';
  document.getElementById('adminMsgUserPhone').value = userPhone || '';
  document.getElementById('adminMsgRecipientName').innerText = userName || 'Customer';
  document.getElementById('adminMsgRecipientPhone').innerText = userPhone ? `📞 ${userPhone}` : '📱 Guest (In-App Message)';
  document.getElementById('adminMsgText').value = '';

  modal.classList.add('show');
}

function applyMsgTemplate(text) {
  const textarea = document.getElementById('adminMsgText');
  if (textarea) {
    textarea.value = text;
    textarea.focus();
  }
}

async function submitAdminDirectMsg(e) {
  if (e) e.preventDefault();
  const userId = document.getElementById('adminMsgUserId').value.trim();
  const userPhone = document.getElementById('adminMsgUserPhone').value.trim();
  const userName = document.getElementById('adminMsgRecipientName').innerText.trim();
  const text = document.getElementById('adminMsgText').value.trim();
  const btn = document.getElementById('btnSendAdminMsg');

  if (!text) {
    showToast('தயவுசெய்து செய்தியை உள்ளிடவும்', 'error');
    return;
  }

  if (btn) {
    btn.disabled = true;
    btn.innerText = 'அனுப்பப்படுகிறது...';
  }

  try {
    const res = await fetch(`${API_BASE}/users.php`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        action: 'send_admin_message',
        user_id: userId,
        user_phone: userPhone,
        user_name: userName,
        message: text,
        admin_name: (AppState.user && AppState.user.name) ? AppState.user.name : 'Super Admin'
      })
    });
    const data = await res.json();
    if (data && data.success) {
      showToast('🎉 செய்தி வெற்றிகரமாக அனுப்பப்பட்டது!', 'success');
      closeModal('adminDirectMsgModal');
    } else {
      showToast(data.message || 'செய்தி அனுப்புவதில் பிழை', 'error');
    }
  } catch (err) {
    showToast('API இணைப்பு தோல்வி', 'error');
  } finally {
    if (btn) {
      btn.disabled = false;
      btn.innerText = '🚀 செய்தி அனுப்பு (Send Message)';
    }
  }
}

/* ==================== 13. BULK PUSH NOTIFICATIONS / BROADCAST ==================== */

function openAdminBroadcastModal() {
  const modal = document.getElementById('adminBroadcastModal');
  if (!modal) return;
  document.getElementById('adminBroadcastTitle').value = '';
  document.getElementById('adminBroadcastMessage').value = '';
  modal.classList.add('show');
}

function applyBroadcastTemplate(title, msg) {
  const titleEl = document.getElementById('adminBroadcastTitle');
  const msgEl = document.getElementById('adminBroadcastMessage');
  if (titleEl) titleEl.value = title;
  if (msgEl) {
    msgEl.value = msg;
    msgEl.focus();
  }
}

async function submitAdminBroadcast(e) {
  if (e) e.preventDefault();
  const title = document.getElementById('adminBroadcastTitle').value.trim();
  const message = document.getElementById('adminBroadcastMessage').value.trim();
  const btn = document.getElementById('btnSendAdminBroadcast');

  if (!title || !message) {
    showToast('தலைப்பு மற்றும் செய்தியை உள்ளிடவும்', 'error');
    return;
  }

  if (btn) {
    btn.disabled = true;
    btn.innerText = 'அனுப்பப்படுகிறது...';
  }

  try {
    const res = await fetch(`${API_BASE}/users.php`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        action: 'broadcast_message',
        title: title,
        message: message,
        admin_name: (AppState.user && AppState.user.name) ? AppState.user.name : 'Super Admin'
      })
    });
    const data = await res.json();
    if (data && data.success) {
      showToast('📢 அறிவிப்பு அனைத்து பயனர்களுக்கும் வெற்றிகரமாக அனுப்பப்பட்டது!', 'success');
      closeModal('adminBroadcastModal');
    } else {
      showToast(data.message || data.error || 'அறிவிப்பு அனுப்புவதில் பிழை', 'error');
    }
  } catch (err) {
    showToast('API இணைப்பு தோல்வி', 'error');
  } finally {
    if (btn) {
      btn.disabled = false;
      btn.innerText = '📢 அனைவருக்கும் அனுப்புக (Broadcast to All)';
    }
  }
}

/* ==================== APK DOWNLOAD MODAL & HELPERS ==================== */
function openApkDownloadModal() {
  const modal = document.getElementById('apkDownloadModal');
  if (modal) modal.classList.add('show');
}

function closeApkDownloadModal() {
  const modal = document.getElementById('apkDownloadModal');
  if (modal) modal.classList.remove('show');
}

function copyApkDownloadLink(type) {
  const url = window.location.origin + (type === 'admin' ? '/AdsAdmin.apk' : '/Ads.apk');
  if (navigator.clipboard && navigator.clipboard.writeText) {
    navigator.clipboard.writeText(url).then(() => {
      showToast('APK நேரடி பதிவிறக்க இணைப்பு நகலெடுக்கப்பட்டது! (Link copied)', 'success');
    }).catch(() => {
      prompt('APK பதிவிறக்க இணைப்பு (Copy link):', url);
    });
  } else {
    prompt('APK பதிவிறக்க இணைப்பு (Copy link):', url);
  }
}

