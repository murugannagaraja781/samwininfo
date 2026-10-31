<?php
header("Cache-Control: no-store, no-cache, must-revalidate, max-age=0");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");
$v = time();
?>
<!DOCTYPE html>
<html lang="ta">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title id="pageTitleDisplay">SamWin - Super Admin Portal | சூப்பர் அட்மின்</title>
  <link rel="icon" type="image/png" href="../assets/images/app_logo.png">
  
  <!-- Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+Tamil:wght@400;500;600;700;800&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  
  <!-- Styles -->
  <link rel="stylesheet" href="css/admin.css?v=<?= $v ?>">
</head>
<body>

  <!-- Toast Container -->
  <div id="toastContainer" class="toast-container"></div>

  <!-- ==================== 1. LOGIN SCREEN ==================== -->
  <div id="loginView" class="login-container">
    <div class="login-card">
      <div class="login-header">
        <div class="login-logo" id="loginLogoContainer" style="display:flex; justify-content:center; margin-bottom:12px;">
          <img src="../assets/images/app_logo.png" style="width: 72px; height: 72px; border-radius: 50%; object-fit: contain; box-shadow: 0 4px 18px rgba(245,158,11,0.4);" alt="SamWin Logo">
        </div>
        <h1 class="login-title" id="loginTitleDisplay">SamWin</h1>
        <p class="login-subtitle" id="loginSubtitleDisplay">சூப்பர் அட்மின் கட்டுப்பாட்டு தளம் (Super Admin Portal)</p>
        <span class="badge-super-admin">👑 Super Admin Access</span>
      </div>

      <form id="loginForm">
        <div class="form-group">
          <label class="form-label" for="loginUsername">பயனர்பெயர் (Username / Login ID)</label>
          <input type="text" id="loginUsername" class="form-control" value="admin3" placeholder="admin3" required autofocus>
        </div>

        <div class="form-group">
          <label class="form-label" for="loginPassword">கடவுச்சொல் (Password)</label>
          <input type="password" id="loginPassword" class="form-control" value="000003" placeholder="••••••" required>
        </div>

        <button type="submit" class="btn btn-primary btn-block" style="margin-top: 10px;">
          🚀 உள்நுழைக (Super Admin Login)
        </button>
      </form>

      <!-- APK Direct Downloads on Login Screen -->
      <div style="margin-top: 24px; padding-top: 18px; border-top: 1px solid rgba(255, 255, 255, 0.1);">
        <div style="text-align: center; margin-bottom: 12px;">
          <div style="font-size: 13.5px; font-weight: 800; color: #f8fafc; display: flex; align-items: center; justify-content: center; gap: 6px;">
            <span>📲</span>
            <span>ஆண்ட்ராய்டு செயலிகள் பதிவிறக்கம் (Download Apps)</span>
          </div>
          <p style="font-size: 11.5px; color: var(--text-muted); margin-top: 3px;">
            நேரடியாக உங்கள் போனில் நிறுவிக் கொள்ளலாம் (Live APKs)
          </p>
        </div>

        <div style="display: flex; flex-direction: column; gap: 10px;">
          <!-- User App APK Button -->
          <a href="/Ads.apk" class="btn-app-dl" download="SamWin.apk" style="display: flex; align-items: center; justify-content: space-between; padding: 10px 14px; background: linear-gradient(135deg, rgba(16, 185, 129, 0.15), rgba(5, 150, 105, 0.25)); border: 1.5px solid #10b981; border-radius: 10px; color: #fff; text-decoration: none; transition: transform 0.2s, box-shadow 0.2s; box-shadow: 0 4px 12px rgba(16, 185, 129, 0.2);">
            <div style="display: flex; align-items: center; gap: 10px;">
              <div style="width: 36px; height: 36px; border-radius: 8px; background: rgba(16, 185, 129, 0.25); display: flex; align-items: center; justify-content: center; font-size: 18px;">📱</div>
              <div style="text-align: left;">
                <div style="font-size: 13px; font-weight: 800; color: #6ee7b7;">SamWin - பயனர் செயலி (User APK)</div>
                <div style="font-size: 11px; color: #cbd5e1;">வாங்குபவர் & விற்பனையாளர் செயலி</div>
              </div>
            </div>
            <div style="display: flex; align-items: center; gap: 4px; background: #10b981; color: #042f2e; padding: 5px 10px; border-radius: 6px; font-weight: 800; font-size: 11.5px;">
              <span>⬇️ டவுன்லோட்</span>
            </div>
          </a>

          <!-- Admin App APK Button -->
          <a href="/AdsAdmin.apk" class="btn-app-dl" download="SamWinAdmin.apk" style="display: flex; align-items: center; justify-content: space-between; padding: 10px 14px; background: linear-gradient(135deg, rgba(245, 158, 11, 0.15), rgba(217, 119, 6, 0.25)); border: 1.5px solid #f59e0b; border-radius: 10px; color: #fff; text-decoration: none; transition: transform 0.2s, box-shadow 0.2s; box-shadow: 0 4px 12px rgba(245, 158, 11, 0.2);">
            <div style="display: flex; align-items: center; gap: 10px;">
              <div style="width: 36px; height: 36px; border-radius: 8px; background: rgba(245, 158, 11, 0.25); display: flex; align-items: center; justify-content: center; font-size: 18px;">🛡️</div>
              <div style="text-align: left;">
                <div style="font-size: 13px; font-weight: 800; color: #fbbf24;">SamWin Admin - அட்மின் செயலி (Admin APK)</div>
                <div style="font-size: 11px; color: #cbd5e1;">சூப்பர் அட்மின் நிர்வாக செயலி</div>
              </div>
            </div>
            <div style="display: flex; align-items: center; gap: 4px; background: #f59e0b; color: #451a03; padding: 5px 10px; border-radius: 6px; font-weight: 800; font-size: 11.5px;">
              <span>⬇️ டவுன்லோட்</span>
            </div>
          </a>
        </div>
      </div>
    </div>
  </div>

  <!-- ==================== 2. MAIN DASHBOARD VIEW ==================== -->
  <div id="dashboardView" class="app-container" style="display: none;">
    
    <!-- Sidebar -->
    <aside class="sidebar">
      <div class="brand-section">
        <div class="brand-icon" id="sidebarLogoContainer">
          <img src="../assets/images/app_logo.png" style="width: 38px; height: 38px; border-radius: 50%; object-fit: contain;" alt="SamWin Logo">
        </div>
        <div>
          <div class="brand-name" id="sidebarBrandName">SamWin</div>
          <div class="brand-tag" id="sidebarBrandTag">SUPER ADMIN PORTAL</div>
        </div>
      </div>

      <!-- Quick Add Property Sidebar Button -->
      <div style="padding: 12px 14px 4px 14px;">
        <button type="button" class="btn btn-gold btn-block" onclick="openAddPropertyModal()" style="display: flex; align-items: center; justify-content: center; gap: 8px; padding: 12px 14px; font-weight: 800; font-size: 13.5px; border-radius: 10px; width: 100%; box-shadow: 0 4px 14px rgba(245,158,11,0.4); cursor: pointer; text-shadow: 0 1px 2px rgba(0,0,0,0.2);">
          <span style="font-size: 16px;">➕</span>
          <span>புதிய விளம்பரம் சேர் (Post Ad)</span>
        </button>
      </div>

      <ul class="nav-menu">
        <li class="nav-item active">
          <a class="nav-link" data-tab="overview">
            <span class="icon">📊</span>
            <span>முகப்பு (Dashboard)</span>
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" data-tab="pending-ads">
            <span class="icon">⏳</span>
            <span>காத்திருப்பில் உள்ளவை (Pending)</span>
            <span class="badge badge-pending" id="sidebarPendingBadge" style="margin-left:auto; display:none; font-size:11px; padding:2px 7px;">0</span>
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" data-tab="properties">
            <span class="icon">🏡</span>
            <span>அனைத்து விளம்பரங்கள் (All Ads)</span>
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" data-tab="requirements">
            <span class="icon">📋</span>
            <span>மக்களின் தேவை (Buyer Board)</span>
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" data-tab="payments">
            <span class="icon">💰</span>
            <span>வருவாய் & கட்டணங்கள் (Revenue)</span>
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" data-tab="calculator">
            <span class="icon">📐</span>
            <span>நில அளவை மாற்றி (Calculator)</span>
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" data-tab="app-config">
            <span class="icon">📱</span>
            <span>ஆப் அமைப்புகள் (App Config)</span>
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" data-tab="user-activities">
            <span class="icon">👥</span>
            <span>பயனர்கள் செயல்பாடு (Activities)</span>
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" data-tab="live-users">
            <span class="icon">🟢</span>
            <span>நேரலை பயனர்கள் (Live Users)</span>
            <span class="badge badge-emerald" id="sidebarLiveCount" style="margin-left:auto; font-size:11px; padding:2px 7px;">0 Live</span>
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" data-tab="settings">
            <span class="icon">⚙️</span>
            <span>சுற்றுச்சூழல் & பிராண்டிங் (.ENV)</span>
          </a>
        </li>
        <li class="nav-item">
          <a class="nav-link" href="javascript:void(0)" onclick="openApkDownloadModal()">
            <span class="icon">📲</span>
            <span>ஆப் டவுன்லோட் (Download APK)</span>
            <span class="badge badge-emerald" style="margin-left:auto; font-size:10px; font-weight:800; padding:2px 6px;">NEW</span>
          </a>
        </li>
      </ul>

      <div class="sidebar-footer">
        <div class="admin-user-card">
          <div class="admin-avatar">SA</div>
          <div class="admin-info">
            <div class="name" id="adminNameDisplay">SamWin Admin</div>
            <div class="role" id="adminRoleDisplay">Super Admin (admin3)</div>
          </div>
        </div>
        <button class="btn btn-secondary btn-block" onclick="handleLogout()" style="padding: 8px 12px; font-size: 12px;">
          🚪 வெளியேறு (Logout)
        </button>
      </div>
    </aside>

    <!-- Main Wrapper -->
    <div class="main-wrapper">
      
      <!-- Top Navbar -->
      <header class="top-navbar">
        <div class="page-title-box">
          <h1 id="topNavTitleDisplay">தென்காசி ரியல் எஸ்டேட் நிர்வாகம்</h1>
          <p id="topNavSubtitleDisplay">SamWin Land Real Estate Management System</p>
        </div>

        <div class="nav-actions">
          <!-- Real-Time Notification Bell & Dropdown -->
          <div class="notif-bell-wrapper" id="notifBellWrapper">
            <button class="btn-notif" id="notifBellBtn" onclick="toggleNotifDropdown()" title="Notifications / புதிய விளம்பர அறிவிப்புகள்">
              🔔
              <span class="notif-badge" id="notifBadgeCount" style="display: none;">0</span>
            </button>
            <div class="notif-dropdown" id="notifDropdown">
              <div class="notif-header">
                <h4>🔔 புதிய விளம்பர அறிவிப்புகள்</h4>
                <button class="notif-clear-btn" onclick="clearAllNotifications()">நீக்கு (Clear)</button>
              </div>
              <div class="notif-list" id="notifListContainer">
                <div style="padding: 24px 16px; text-align: center; color: var(--text-muted); font-size: 13px;">
                  அறிவிப்புகள் எதுவும் இல்லை (No notifications)
                </div>
              </div>
            </div>
          </div>

          <div class="status-pill-online">
            <span class="dot"></span>
            <span>API Active (.ENV / MySQL)</span>
          </div>
          <button class="btn btn-emerald" onclick="openApkDownloadModal()" style="display: flex; align-items: center; gap: 7px; font-weight: 800; box-shadow: 0 4px 14px rgba(16, 185, 129, 0.35);">
            <span style="font-size: 16px;">📲</span>
            <span>ஆப் பதிவிறக்கம் (Download APK)</span>
          </button>
          <button class="btn btn-gold" onclick="openAddPropertyModal()">
            ➕ புதிய விளம்பரம் (Post Ad)
          </button>
        </div>
      </header>

      <!-- Content Body -->
      <main class="content-body">
        
        <!-- REAL-TIME PENDING AD CONTINUOUS ALARM & DIRECT ACTION STATION -->
        <div id="pendingAdAlarmBanner" class="pending-alarm-banner" style="display: none;">
          <div class="pending-alarm-header">
            <div class="pending-alarm-content">
              <span class="pending-alarm-icon">🚨</span>
              <div class="pending-alarm-text">
                <strong id="pendingAlarmTitle">🔔 புதிய பயனர் விளம்பரம் அப்ரூவலுக்கு வந்துள்ளது! (Pending Ad Waiting for Action)</strong>
                <span id="pendingAlarmDesc">விளம்பரத்தை அங்கீகரித்து (Accept / Approve) அல்லது நிராகரிக்கும் (Reject) வரை தொடர்ந்து அலாரம் ஒலிக்கும்.</span>
              </div>
            </div>
            <div class="pending-alarm-counter">
              <span class="badge badge-pending" id="pendingAlarmCounterBadge" style="font-size: 13px; padding: 6px 14px; font-weight: 800;">1 புதிய விளம்பரம் காத்திருப்பில்</span>
            </div>
          </div>

          <!-- PENDING ADS CARD LIST DIRECTLY INSIDE THIS ALERT BANNER -->
          <div class="pending-cards-grid" id="pendingAlarmCardsContainer" style="margin-top: 14px;">
            <!-- Dynamic Pending Property Cards Injected Here with Direct Accept / Reject buttons -->
          </div>
        </div>

        <!-- TAB 1: OVERVIEW & PROPERTIES -->
        <section id="tab-overview" class="tab-panel active">
          
          <!-- QUICK MOBILE APK DOWNLOAD BANNER -->
          <div style="background: linear-gradient(135deg, rgba(15, 23, 42, 0.95), rgba(30, 41, 59, 0.95)); border: 1.5px solid rgba(16, 185, 129, 0.4); border-radius: 12px; padding: 16px 20px; margin-bottom: 24px; display: flex; align-items: center; justify-content: space-between; gap: 16px; flex-wrap: wrap; box-shadow: 0 6px 20px rgba(0,0,0,0.3);">
            <div style="display: flex; align-items: center; gap: 14px;">
              <div style="width: 46px; height: 46px; border-radius: 12px; background: rgba(16, 185, 129, 0.2); display: flex; align-items: center; justify-content: center; font-size: 24px; border: 1px solid rgba(16, 185, 129, 0.4);">📲</div>
              <div>
                <div style="font-size: 15px; font-weight: 800; color: #fff; display: flex; align-items: center; gap: 8px;">
                  <span>Ads Android செயலிகள் பதிவிறக்கத்திற்கு தயார்!</span>
                  <span class="badge badge-emerald" style="font-size: 10px; padding: 2px 7px;">v1.0.0 Live</span>
                </div>
                <div style="font-size: 12.5px; color: var(--text-muted); margin-top: 3px;">
                  வாடிக்கையாளர் செயலி (User App) மற்றும் சூப்பர் அட்மின் செயலி (Admin App) இரண்டையும் இங்கிருந்தே நேரடியாக பதிவிறக்கலாம்.
                </div>
              </div>
            </div>
            <div style="display: flex; gap: 10px; flex-wrap: wrap;">
              <a href="/Ads.apk" download="SamWin.apk" class="btn btn-emerald" style="display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 800; text-decoration: none; padding: 9px 16px; box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);">
                <span>📱 பயனர் ஆப் (User APK)</span>
              </a>
              <a href="/AdsAdmin.apk" download="SamWinAdmin.apk" class="btn btn-gold" style="display: flex; align-items: center; gap: 6px; font-size: 12.5px; font-weight: 800; text-decoration: none; padding: 9px 16px; box-shadow: 0 4px 12px rgba(245, 158, 11, 0.3);">
                <span>🛡️ அட்மின் ஆப் (Admin APK)</span>
              </a>
              <button type="button" onclick="openApkDownloadModal()" class="btn btn-secondary" style="font-size: 12.5px; font-weight: 700; padding: 9px 14px;">
                ℹ️ விவரங்கள்
              </button>
            </div>
          </div>

          <!-- KPI Stats Grid -->
          <div class="stats-grid">
            <div class="stat-card">
              <div class="stat-info">
                <h3>மொத்த விளம்பரங்கள்</h3>
                <div class="stat-number" id="statTotalAds">0</div>
                <div class="stat-sub">Total Property Listings</div>
              </div>
              <div class="stat-icon-wrapper icon-emerald">🏡</div>
            </div>

            <div class="stat-card">
              <div class="stat-info">
                <h3>நேரலை விளம்பரங்கள்</h3>
                <div class="stat-number" id="statActiveAds">0</div>
                <div class="stat-sub">Active & Live Ads</div>
              </div>
              <div class="stat-icon-wrapper icon-gold">⚡</div>
            </div>

            <div class="stat-card">
              <div class="stat-info">
                <h3>சரிபார்ப்பில் உள்ளவை</h3>
                <div class="stat-number" id="statPendingAds">0</div>
                <div class="stat-sub">Pending Verification</div>
              </div>
              <div class="stat-icon-wrapper icon-blue">⏳</div>
            </div>

            <div class="stat-card">
              <div class="stat-info">
                <h3>மக்களின் தேவை</h3>
                <div class="stat-number" id="statRequirements">0</div>
                <div class="stat-sub">Buyer Requests Board</div>
              </div>
              <div class="stat-icon-wrapper icon-purple">📋</div>
            </div>

            <div class="stat-card">
              <div class="stat-info">
                <h3>பார்வைகள் (Total Views)</h3>
                <div class="stat-number" id="statViews">0</div>
                <div class="stat-sub">Total Ad Engagements</div>
              </div>
              <div class="stat-icon-wrapper icon-emerald">👁️</div>
            </div>

            <div class="stat-card">
              <div class="stat-info">
                <h3>மொத்த வசூல் (Revenue)</h3>
                <div class="stat-number" id="statRevenue">₹0</div>
                <div class="stat-sub">Paid Contact Unlocks</div>
              </div>
              <div class="stat-icon-wrapper icon-gold">💰</div>
            </div>

            <div class="stat-card">
              <div class="stat-info">
                <h3>கட்டண தொடர்புகள்</h3>
                <div class="stat-number" id="statPaidUnlocks">0</div>
                <div class="stat-sub">₹30 Contact Views</div>
              </div>
              <div class="stat-icon-wrapper icon-emerald">🔓</div>
            </div>

            <div class="stat-card" style="cursor: pointer; border-left: 4px solid #10b981;" onclick="switchTab('live-users')" title="நேரலை பயனர்களைப் பார்க்க கிளிக் செய்க">
              <div class="stat-info">
                <h3>நேரலை பயனர்கள்</h3>
                <div class="stat-number" id="statDashboardLiveUsers" style="color: #10b981;">0</div>
                <div class="stat-sub">Live Active Users (App / Web) →</div>
              </div>
              <div class="stat-icon-wrapper icon-emerald">👥</div>
            </div>
          </div>

          <!-- PENDING APPROVALS QUICK BANNER (Overview) -->
          <div class="pending-approvals-box" id="pendingApprovalsSection" style="display: none;">
            <div class="pending-box-header">
              <div class="pending-box-title">
                <span>🔔 சரிபார்க்க வேண்டிய புதிய பயனர் விளம்பரங்கள் (Pending Ad Approvals)</span>
                <span class="pending-badge-count" id="pendingBoxBadgeCount">0 காத்திருப்பில்</span>
              </div>
              <div style="display:flex; justify-content:space-between; align-items:center;">
                <div style="font-size: 12px; color: var(--text-muted);">
                  பயனர்கள் சமர்ப்பித்த விளம்பரங்கள் • அப்ரூவல் செய்தவுடன் உடனடியாக தளத்தில் நேரலையாக தோன்றும்
                </div>
                <button class="btn btn-gold" style="font-size:12px; padding:4px 10px;" onclick="switchTab('pending-ads')">
                  ⏳ அனைத்தையும் சரிபார்க்க →
                </button>
              </div>
            </div>
          <!-- RECENT & ALL PROPERTIES PREVIEW SECTION (Overview) -->
          <div class="section-card" style="margin-top: 24px;">
            <div class="section-header">
              <div>
                <h2 class="section-title">🏡 சமீபத்திய விளம்பரங்கள் (Recent & All Property Listings)</h2>
                <p style="font-size: 13px; color: var(--text-muted); margin-top: 4px;">
                  தென்காசி ரியல் எஸ்டேட் விளம்பரங்களின் நேரலை பட்டியல் • முழு அட்டவணை மற்றும் வடிகட்டிகளுக்கு 'அனைத்து விளம்பரங்கள்' பகுதிக்கு செல்லலாம்.
                </p>
              </div>
              <button class="btn btn-gold" onclick="switchTab('properties')">
                🏡 அனைத்து விளம்பரங்களையும் பார் (View All Ads →)
              </button>
            </div>

            <div class="custom-table-responsive">
              <table class="custom-table">
                <thead>
                  <tr>
                    <th>விளம்பரம் (Property / Location)</th>
                    <th>பிரிவு (Category)</th>
                    <th>விலை & அளவு (Price & Size)</th>
                    <th>உரிமையாளர் / ஏஜென்ட்</th>
                    <th>நிலை (Status)</th>
                    <th style="text-align: right;">செயல்கள் (Actions)</th>
                  </tr>
                </thead>
                <tbody id="overviewPropertiesTableBody">
                  <!-- Rendered via JS -->
                </tbody>
              </table>
            </div>
          </div>

        </section>

        <!-- TAB: PENDING ADS (காத்திருப்பில் உள்ளவை / வெயிட்டிங் ஃபார் அக்சப்ட்) -->
        <section id="tab-pending-ads" class="tab-panel">
          <div class="section-card">
            <div class="section-header">
              <div>
                <h2 class="section-title">⏳ சரிபார்க்க வேண்டிய பயனர் விளம்பரங்கள் (Pending Ad Approvals / Waiting for Accept)</h2>
                <p style="font-size: 13px; color: var(--text-muted); margin-top: 4px;">
                  பயனர்கள் சமர்ப்பித்த புதிய விளம்பரங்கள் • ஆய்வு செய்து அப்ரூவல் அல்லது நிராகரிக்கலாம்.
                </p>
              </div>
              <span class="badge badge-pending" id="pendingSectionBadgeCount" style="font-size: 13px; padding: 6px 14px;">0 காத்திருப்பில்</span>
            </div>
            <div class="pending-cards-grid" id="pendingCardsDedicatedContainer">
              <!-- Dedicated Pending Property Cards Injected Here -->
            </div>
          </div>
        </section>

        <!-- TAB: ALL PROPERTIES & FREE/PAID PERMISSION CONTROL -->
        <section id="tab-properties" class="tab-panel">
          <!-- Category Quick Selection Pills -->
          <div class="category-pills-row">
            <div class="cat-pill-card active" data-cat="all">
              <div class="cat-icon">🌟</div>
              <div class="cat-title">அனைத்தும்</div>
              <div class="cat-count">All Categories</div>
            </div>
            <div class="cat-pill-card" data-cat="house">
              <div class="cat-icon">🏡</div>
              <div class="cat-title">வீடு / வில்லா</div>
              <div class="cat-count"><span id="catCountHouse">0</span> Ads</div>
            </div>
            <div class="cat-pill-card" data-cat="land">
              <div class="cat-icon">📐</div>
              <div class="cat-title">மனை / நிலம்</div>
              <div class="cat-count"><span id="catCountLand">0</span> Ads</div>
            </div>
            <div class="cat-pill-card" data-cat="farmland">
              <div class="cat-icon">🌴</div>
              <div class="cat-title">தோட்டம்</div>
              <div class="cat-count"><span id="catCountFarmland">0</span> Ads</div>
            </div>
            <div class="cat-pill-card" data-cat="shop">
              <div class="cat-icon">🏪</div>
              <div class="cat-title">கடை / வணிகம்</div>
              <div class="cat-count"><span id="catCountShop">0</span> Ads</div>
            </div>
            <div class="cat-pill-card" data-cat="apartment">
              <div class="cat-icon">🏢</div>
              <div class="cat-title">அபார்ட்மெண்ட்</div>
              <div class="cat-count"><span id="catCountApartment">0</span> Ads</div>
            </div>
            <div class="cat-pill-card" data-cat="rental">
              <div class="cat-icon">🔑</div>
              <div class="cat-title">வாடகை / லீஸ்</div>
              <div class="cat-count"><span id="catCountRental">0</span> Ads</div>
            </div>
          </div>

          <!-- Properties Master Table Section -->
          <div class="section-card">
            <div class="section-header">
              <div class="section-title">
                <span>🏡 அனைத்து சொத்து விளம்பரங்கள் & இலவச/கட்டண அனுமதி (All Ads - Free/Paid Control)</span>
              </div>

              <div class="table-controls">
                <div class="search-input-box">
                  <span class="search-icon">🔍</span>
                  <input type="text" id="tableSearchInput" class="form-control" placeholder="தேடுக (Title, City, Owner, ID)...">
                </div>

                <select id="tableCategoryFilter" class="select-filter">
                  <option value="all">அனைத்து பிரிவுகள் (All Categories)</option>
                  <option value="house">வீடு (House / Villa)</option>
                  <option value="land">மனை / நிலம் (Land / Plots)</option>
                  <option value="farmland">தோட்டம் (Farmland / Orchard)</option>
                  <option value="shop">கடை / வணிகம் (Shop / Commercial)</option>
                  <option value="apartment">அபார்ட்மெண்ட் (Apartment)</option>
                  <option value="rental">வாடகைக்கு (Rental / Lease)</option>
                </select>

                <select id="tableStatusFilter" class="select-filter">
                  <option value="all">அனைத்து நிலைகள் (All Status)</option>
                  <option value="active">Active (நேரலை)</option>
                  <option value="pending">Pending (காத்திருப்பு)</option>
                  <option value="sold">Sold (விற்பனையானது)</option>
                </select>

                <select id="tableAccessFilter" class="select-filter" onchange="handleAccessFilterChange(this.value)">
                  <option value="all">அனைத்து அனுமதிகள் (All Access)</option>
                  <option value="free">🟢 இலவச விளம்பரங்கள் (Free Only)</option>
                  <option value="paid">💎 கட்டண விளம்பரங்கள் (Paid Only)</option>
                </select>

                <button class="btn btn-primary" onclick="openAddPropertyModal()">
                  ➕ விளம்பரம் சேர்
                </button>
              </div>
            </div>

            <!-- Table -->
            <div class="custom-table-responsive">
              <table class="custom-table">
                <thead>
                  <tr>
                    <th>விளம்பரம் (Property / Location)</th>
                    <th>பிரிவு (Category)</th>
                    <th>விலை & அளவு (Price & Size)</th>
                    <th>உரிமையாளர் / ஏஜென்ட்</th>
                    <th>சரிபார்ப்பு (Verification)</th>
                    <th>அணுகல் பர்மிஷன் (Free / Paid)</th>
                    <th>நிலை (Status)</th>
                    <th style="text-align: right;">செயல்கள் (Actions)</th>
                  </tr>
                </thead>
                <tbody id="propertiesTableBody">
                  <!-- Rendered via JS -->
                </tbody>
              </table>
            </div>
          </div>
        </section>

        <!-- TAB 2: BUYER REQUIREMENTS BOARD -->
        <section id="tab-requirements" class="tab-panel">
          <div class="section-card">
            <div class="section-header">
              <div>
                <h2 class="section-title">📋 மக்களின் தேவை பலகை (Buyer Requirements Board)</h2>
                <p style="font-size: 13px; color: var(--text-muted); margin-top: 4px;">
                  தென்காசி மற்றும் சுற்றுவட்டார வாடிக்கையாளர்களின் நேரடி சொத்து தேவைகள் மற்றும் தொடர்புகள்.
                </p>
              </div>
              <button class="btn btn-gold" onclick="openAddRequirementModal()">
                ➕ புதிய தேவை பதிவு (Add Requirement)
              </button>
            </div>

            <div id="requirementsGrid" class="requirements-grid">
              <!-- Rendered via JS -->
            </div>
          </div>
        </section>

        <!-- TAB 3: LAND UNIT CALCULATOR -->
        <section id="tab-calculator" class="tab-panel">
          <div class="calculator-box">
            <h2 style="font-size: 22px; font-weight: 800; color: #ffffff; text-align: center; margin-bottom: 8px;">
              📐 நில அளவை & விலை மாற்றி (Land Unit & Price Calculator)
            </h2>
            <p style="font-size: 13px; color: var(--text-secondary); text-align: center; margin-bottom: 24px;">
              சென்ட் (Cents), குழி (Kuzhi), ஏக்கர் (Acres), சதுர அடி (Sq.Ft) மற்றும் கிரவுண்ட் (Grounds) இடையிலான துல்லிய அளவீடு.
            </p>

            <div class="calc-input-row">
              <div class="form-group" style="margin-bottom:0;">
                <label class="form-label">நிலத்தின் அளவு (Land Value)</label>
                <input type="number" id="calcInputVal" class="form-control" value="10" placeholder="10">
              </div>
              <div class="form-group" style="margin-bottom:0;">
                <label class="form-label">அளவை அலகு (Unit)</label>
                <select id="calcInputUnit" class="form-control">
                  <option value="cent" selected>சென்ட் (Cents)</option>
                  <option value="kuzhi">குழி (Kuzhi - 144 Sq.Ft)</option>
                  <option value="sqft">சதுர அடி (Sq.Ft)</option>
                  <option value="acre">ஏக்கர் (Acres)</option>
                  <option value="ground">கிரவுண்ட் (Grounds - 2400 Sq.Ft)</option>
                  <option value="maa">மா (Maa - 100 Kuzhi)</option>
                </select>
              </div>
            </div>

            <!-- Rate Calculator -->
            <div class="calc-input-row">
              <div class="form-group" style="margin-bottom:0;">
                <label class="form-label">ஒரு அலகின் விலை மதிப்பு (Rate ₹)</label>
                <input type="number" id="calcRateVal" class="form-control" value="250000" placeholder="250000">
              </div>
              <div class="form-group" style="margin-bottom:0;">
                <label class="form-label">விலை அலகு (Rate Per)</label>
                <select id="calcRateUnit" class="form-control">
                  <option value="cent" selected>1 சென்ட் வீதம்</option>
                  <option value="kuzhi">1 குழி வீதம்</option>
                  <option value="sqft">1 சதுர அடி வீதம்</option>
                  <option value="acre">1 ஏக்கர் வீதம்</option>
                </select>
              </div>
            </div>

            <!-- Results Grid -->
            <div class="calc-results-grid">
              <div class="calc-result-card">
                <div class="unit-label">சென்ட் (Cents)</div>
                <div class="unit-val" id="resCent">0</div>
              </div>
              <div class="calc-result-card">
                <div class="unit-label">குழி (Kuzhi)</div>
                <div class="unit-val" id="resKuzhi">0</div>
              </div>
              <div class="calc-result-card">
                <div class="unit-label">சதுர அடி (Sq.Ft)</div>
                <div class="unit-val" id="resSqFt">0</div>
              </div>
              <div class="calc-result-card">
                <div class="unit-label">ஏக்கர் (Acres)</div>
                <div class="unit-val" id="resAcre">0</div>
              </div>
              <div class="calc-result-card">
                <div class="unit-label">கிரவுண்ட் (Grounds)</div>
                <div class="unit-val" id="resGround">0</div>
              </div>
              <div class="calc-result-card">
                <div class="unit-label">மா (Maa)</div>
                <div class="unit-val" id="resMaa">0</div>
              </div>
            </div>

            <!-- Total Estimated Price Card -->
            <div style="margin-top: 24px; padding: 20px; background: rgba(16, 185, 129, 0.1); border: 1px solid rgba(16, 185, 129, 0.3); border-radius: var(--radius-sm); text-align: center;">
              <div style="font-size: 13px; color: var(--text-secondary); margin-bottom: 4px;">மதிப்பிடப்பட்ட மொத்த சொத்து விலை (Total Estimated Value):</div>
              <div id="resTotalPrice" style="font-size: 28px; font-weight: 800; color: var(--accent-primary);">₹0</div>
            </div>
          </div>
        </section>

        <!-- TAB: REVENUE & PAYMENTS -->
        <section id="tab-payments" class="tab-panel">
          <div class="section-card">
            <div class="section-header">
              <div>
                <h2 class="section-title">💰 வருவாய் & கட்டண பரிவர்த்தனைகள் (Revenue & Payments)</h2>
                <p style="font-size: 13px; color: var(--text-muted); margin-top: 4px;">
                  வாடிக்கையாளர்கள் ₹30 செலுத்தி தொடர்பு எண்களை திறந்த நேரடி பரிவர்த்தனைகள்
                </p>
              </div>
              <button class="btn btn-secondary" onclick="loadPaymentsData()">
                🔄 புதுப்பி (Refresh)
              </button>
            </div>

            <div class="stats-grid" style="margin-bottom: 24px;">
              <div class="stat-card">
                <div class="stat-info">
                  <h3>மொத்த வசூல் (Total Revenue)</h3>
                  <div class="stat-number" id="paySummaryTotal">₹0</div>
                  <div class="stat-sub">Razorpay UPI & Cards Total</div>
                </div>
                <div class="stat-icon-wrapper icon-gold">💰</div>
              </div>

              <div class="stat-card">
                <div class="stat-info">
                  <h3>கட்டண தொடர்புகள்</h3>
                  <div class="stat-number" id="paySummaryPaidCount">0</div>
                  <div class="stat-sub">Paid Unlocks (₹30 each)</div>
                </div>
                <div class="stat-icon-wrapper icon-emerald">🔓</div>
              </div>

              <div class="stat-card">
                <div class="stat-info">
                  <h3>இலவச பார்வைகள்</h3>
                  <div class="stat-number" id="paySummaryFreeCount">0</div>
                  <div class="stat-sub">Free Contact Views (3 Quota)</div>
                </div>
                <div class="stat-icon-wrapper icon-blue">🎁</div>
              </div>

              <div class="stat-card">
                <div class="stat-info">
                  <h3>ஒரு தொடர்பு கட்டணம்</h3>
                  <div class="stat-number" id="paySummaryPrice">₹30</div>
                  <div class="stat-sub">Price per Contact Unlock</div>
                </div>
                <div class="stat-icon-wrapper icon-purple">⚡</div>
              </div>
            </div>

            <!-- PRICING & OFFER CONTROL CENTER -->
            <div style="background: linear-gradient(135deg, rgba(23, 34, 56, 0.95), rgba(15, 23, 42, 0.95)); border: 1.5px solid rgba(245, 158, 11, 0.35); border-radius: var(--radius-md); padding: 22px; margin-bottom: 24px; box-shadow: 0 10px 25px rgba(0,0,0,0.4);">
              <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px; flex-wrap: wrap; gap: 10px;">
                <div>
                  <div style="font-size: 16px; font-weight: 800; color: #fbbf24; display: flex; align-items: center; gap: 8px;">
                    ⚙️ கட்டணங்கள், இலவச வரம்பு & ஆஃபர் மேலாண்மை (Pricing & Offer Controls)
                  </div>
                  <div style="font-size: 12.5px; color: var(--text-muted); margin-top: 3px;">
                    சூப்பர் அட்மின் நினைத்தால் எந்த நேரத்திலும் இலவச வரம்பு, கட்டண தொகை (₹30 அல்லது ₹10) மற்றும் தள்ளுபடி ஆஃபர்களை மாற்றிக்கொள்ளலாம்.
                  </div>
                </div>
                <button class="btn btn-emerald" style="font-weight: 800; padding: 9px 18px;" onclick="savePricingOfferSettings()">
                  💾 அமைப்புகளை சேமி (Save Pricing & Offers)
                </button>
              </div>

              <div class="form-grid-3" style="margin-bottom: 16px;">
                <div class="form-group">
                  <label class="form-label" style="color: #6ee7b7;">🎁 ஆரம்ப இலவச தொடர்புகள் வரம்பு</label>
                  <input type="number" id="pricing_FREE_CONTACT_LIMIT" class="form-control" placeholder="3" min="0" max="50" value="3">
                  <small style="color: var(--text-muted); font-size: 11px;">புதிய பயனர் லாகின் செய்ததும் பார்க்கும் இலவச எண்கள் (Default: 3)</small>
                </div>

                <div class="form-group">
                  <label class="form-label" style="color: #fbbf24;">🏷️ வழக்கமான கட்டணம் (₹ Standard Price)</label>
                  <input type="number" id="pricing_CONTACT_UNLOCK_PRICE" class="form-control" placeholder="30" min="1" value="30">
                  <small style="color: var(--text-muted); font-size: 11px;">இலவச வரம்பு முடிந்த பின் ஒரு திறப்பிற்கான கட்டணம் (Default: ₹30)</small>
                </div>

                <div class="form-group">
                  <label class="form-label" style="color: #93c5fd;">🔢 கட்டணத்திற்கு திறக்கப்படும் எண்கள்</label>
                  <input type="number" id="pricing_UNLOCK_CONTACTS_COUNT" class="form-control" placeholder="1" min="1" value="1">
                  <small style="color: var(--text-muted); font-size: 11px;">கட்டணம் செலுத்தினால் எத்தனை தொடர்பு எண்கள் திறக்க வேண்டும்</small>
                </div>
              </div>

              <!-- Offer Controls Box -->
              <div style="background: rgba(245, 158, 11, 0.07); border: 1px dashed rgba(245, 158, 11, 0.4); border-radius: var(--radius-sm); padding: 16px; margin-bottom: 16px;">
                <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 14px; flex-wrap: wrap; gap: 8px;">
                  <label style="display: flex; align-items: center; gap: 8px; font-weight: 700; color: #fbbf24; cursor: pointer;">
                    <input type="checkbox" id="pricing_OFFER_ACTIVE" style="width: 18px; height: 18px; accent-color: #f59e0b;" onchange="updateOfferBadgeStatus(this.checked)">
                    <span>⚡ சிறப்பு தள்ளுபடி ஆஃபர் இயக்கவும் (Enable Promotional Offer)</span>
                  </label>
                  <span class="badge" id="pricingOfferStatusBadge" style="background: rgba(148, 163, 184, 0.15); color: #94a3b8;">ஆஃபர் முடக்கத்தில் உள்ளது</span>
                </div>

                <div class="form-grid-3">
                  <div class="form-group">
                    <label class="form-label">🏷️ ஆஃபர் விலை (Special Offer ₹)</label>
                    <input type="number" id="pricing_OFFER_UNLOCK_PRICE" class="form-control" placeholder="10" min="1" value="10">
                    <small style="color: var(--text-muted); font-size: 11px;">உதா: ₹10 மட்டும் (தள்ளுபடி விலை)</small>
                  </div>

                  <div class="form-group">
                    <label class="form-label">🔢 ஆஃபரில் திறக்கப்படும் தொடர்புகள்</label>
                    <input type="number" id="pricing_OFFER_CONTACTS_COUNT" class="form-control" placeholder="1" min="1" value="1">
                    <small style="color: var(--text-muted); font-size: 11px;">ஆஃபரில் எத்தனை எண்கள் திறக்கப்படும் (உதா: 1 அல்லது 3)</small>
                  </div>

                  <div class="form-group">
                    <label class="form-label">📢 ஆஃபர் பேனர் வாசகம் (Banner Text)</label>
                    <input type="text" id="pricing_OFFER_BANNER_TEXT" class="form-control" placeholder="சிறப்பு சலுகை: வெறும் ₹10 செலுத்தி உரிமையாளர் எண்ணை உடனே பெறலாம்!" value="சிறப்பு சலுகை: வெறும் ₹10 செலுத்தி உரிமையாளர் எண்ணை உடனே பெறலாம்!">
                    <small style="color: var(--text-muted); font-size: 11px;">வாடிக்கையாளர்களுக்கு காட்டப்படும் அறிவிப்பு</small>
                  </div>
                </div>
              </div>

              <!-- Quick Presets -->
              <div style="display: flex; align-items: center; gap: 8px; flex-wrap: wrap;">
                <span style="font-size: 12px; font-weight: 700; color: var(--text-muted);">⚡ விரைவு அமைப்புகள் (Presets):</span>
                <button type="button" class="btn btn-secondary" style="padding: 4px 10px; font-size: 11px;" onclick="applyPricingPreset(3, 30, 1, false, 10, 1, 'சிறப்பு சலுகை: வெறும் ₹10 செலுத்தி உரிமையாளர் எண்ணை உடனே பெறலாம்!')">
                  ⭐ இயல்பு: 3 இலவசம் + ₹30 கட்டணம்
                </button>
                <button type="button" class="btn btn-gold" style="padding: 4px 10px; font-size: 11px;" onclick="applyPricingPreset(3, 30, 1, true, 10, 1, '🎉 சிறப்பு ஆஃபர்: வெறும் ₹10 செலுத்தி உரிமையாளர் எண்ணை உடனே அறியலாம்!')">
                  🔥 சூப்பர் ஆஃபர்: 3 இலவசம் + ₹10 ஆஃபர்
                </button>
                <button type="button" class="btn btn-secondary" style="padding: 4px 10px; font-size: 11px;" onclick="applyPricingPreset(5, 20, 1, false, 10, 1, 'சிறப்பு சலுகை!')">
                  🎁 5 இலவசம் + ₹20 கட்டணம்
                </button>
                <button type="button" class="btn btn-secondary" style="padding: 4px 10px; font-size: 11px;" onclick="applyPricingPreset(0, 10, 1, true, 10, 1, 'நேரடி கட்டணம்: ₹10 மட்டும்')">
                  ⚡ 0 இலவசம் + நேரடி ₹10 கட்டணம்
                </button>
              </div>
            </div>

            <div class="table-container">
              <table class="data-table">
                <thead>
                  <tr>
                    <th>பரிவர்த்தனை ID</th>
                    <th>தேதி & நேரம்</th>
                    <th>சொத்தின் தலைப்பு</th>
                    <th>வாடிக்கையாளர்</th>
                    <th>கட்டண முறை</th>
                    <th>தொகை</th>
                    <th>நிலை</th>
                  </tr>
                </thead>
                <tbody id="paymentsTableBody">
                  <tr><td colspan="7" style="text-align:center; padding:30px; color:var(--text-muted);">ஏற்றப்படுகிறது...</td></tr>
                </tbody>
              </table>
            </div>
          </div>
        </section>

        <!-- TAB 4: ENVIRONMENT & WHITE-LABEL CONFIGURATION -->
        <section id="tab-settings" class="tab-panel">
          <div class="section-card">
            <div class="section-header">
              <div>
                <h2 class="section-title">⚙️ ஒயிட் லேபில் & சுற்றுச்சூழல் அமைப்புகள் (White-Label & .ENV Settings)</h2>
                <p style="font-size: 13px; color: var(--text-muted); margin-top: 4px;">
                  லோகோ, பிராண்ட் பெயர், தொடர்பு எண்கள், தீம் வண்ணங்கள் மற்றும் MySQL டேட்டாபேஸ் அமைப்புகளை இங்கிருந்தே மாற்றலாம்.
                </p>
              </div>
              <div style="display:flex; gap:10px;">
                <button class="btn btn-secondary" onclick="resetEnvConfig()">🔄 Reset Defaults</button>
                <button class="btn btn-primary" onclick="saveEnvForm()">💾 சேமிக்க (Save Settings)</button>
              </div>
            </div>

            <!-- Sub Navigation Tabs for Form vs Raw -->
            <div style="display:flex; gap:12px; margin-bottom: 24px;">
              <button id="btnEnvTabForm" class="btn btn-primary" style="padding:8px 16px; font-size:13px;" onclick="toggleEnvEditorView('form')">🎛️ ஒயிட் லேபில் & அமைப்புகள் படிவம்</button>
              <button id="btnEnvTabRaw" class="btn btn-secondary" style="padding:8px 16px; font-size:13px;" onclick="toggleEnvEditorView('raw')">📝 நேரடி .env எடிட்டர் (Raw .env)</button>
            </div>

            <!-- Form View Section -->
            <div id="envFormSection">
              
              <!-- Card 1: White-Label Branding & Identity -->
              <div style="background: rgba(11, 17, 30, 0.5); border: 1px solid var(--border-glass); border-radius: var(--radius-md); padding: 22px; margin-bottom: 20px;">
                <div style="font-size:16px; font-weight:700; color:var(--accent-gold); margin-bottom:16px; display:flex; align-items:center; gap:8px;">
                  🏷️ பிராண்டிங் & லோகோ மேலாண்மை (Brand Identity & Logo Customization)
                </div>

                <div class="form-grid-3">
                  <div class="form-group">
                    <label class="form-label">செயலி / இணையதள பெயர் (App & Brand Name) *</label>
                    <input type="text" id="env_APP_NAME" class="form-control" placeholder="SamWin Land" required>
                  </div>
                  <div class="form-group">
                    <label class="form-label">டேக்லைன் / முழக்கம் (Slogan / Tagline)</label>
                    <input type="text" id="env_APP_TAGLINE" class="form-control" placeholder="தென்காசி கனவுகள் - ரியல் எஸ்டேட்">
                  </div>
                  <div class="form-group">
                    <label class="form-label">லோகோ ஐகான் / Emoji (Logo Symbol)</label>
                    <input type="text" id="env_APP_LOGO_EMOJI" class="form-control" placeholder="🏛️">
                  </div>
                </div>

                <div class="form-grid-2">
                  <div class="form-group">
                    <label class="form-label">லோகோ பட முகவரி (Logo Image URL)</label>
                    <input type="text" id="env_APP_LOGO_URL" class="form-control" placeholder="https://domain.com/logo.png அல்லது பதிவேற்றவும்">
                  </div>
                  <div class="form-group">
                    <label class="form-label">புதிய லோகோ படம் Upload செய்ய (Logo Upload)</label>
                    <input type="file" id="uploadLogoFile" class="form-control" accept="image/*" onchange="handleBrandImageUpload(this, 'logo')">
                  </div>
                </div>

                <div class="form-grid-2">
                  <div class="form-group">
                    <label class="form-label">Hero Banner Image URL (முகப்பு பேனர்)</label>
                    <input type="text" id="env_HERO_BANNER_URL" class="form-control" placeholder="https://domain.com/banner.jpg">
                  </div>
                  <div class="form-group">
                    <label class="form-label">புதிய Banner படம் Upload செய்ய</label>
                    <input type="file" id="uploadBannerFile" class="form-control" accept="image/*" onchange="handleBrandImageUpload(this, 'banner')">
                  </div>
                </div>

                <div class="form-grid-3">
                  <div class="form-group">
                    <label class="form-label">முதன்மை வண்ணம் (Primary Color)</label>
                    <div style="display:flex; gap:8px;">
                      <input type="color" id="env_PRIMARY_COLOR_PICKER" value="#10b981" style="width:44px; height:42px; border:none; border-radius:6px; cursor:pointer;" onchange="document.getElementById('env_PRIMARY_COLOR').value = this.value">
                      <input type="text" id="env_PRIMARY_COLOR" class="form-control" value="#10B981" onchange="document.getElementById('env_PRIMARY_COLOR_PICKER').value = this.value">
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="form-label">துணை வண்ணம் (Accent Gold)</label>
                    <div style="display:flex; gap:8px;">
                      <input type="color" id="env_ACCENT_COLOR_PICKER" value="#f59e0b" style="width:44px; height:42px; border:none; border-radius:6px; cursor:pointer;" onchange="document.getElementById('env_ACCENT_COLOR').value = this.value">
                      <input type="text" id="env_ACCENT_COLOR" class="form-control" value="#F59E0B" onchange="document.getElementById('env_ACCENT_COLOR_PICKER').value = this.value">
                    </div>
                  </div>
                  <div class="form-group">
                    <label class="form-label">நிறுவனத்தின் பெயர் (Company Name)</label>
                    <input type="text" id="env_COMPANY_NAME" class="form-control" placeholder="SamWin Real Estate Group">
                  </div>
                </div>

                <div class="form-group">
                  <label class="form-label">அடிக்குறிப்பு காப்புரிமை வாசகம் (Footer Copyright)</label>
                  <input type="text" id="env_FOOTER_COPYRIGHT" class="form-control" placeholder="© 2026 SamWin Land. All Rights Reserved.">
                </div>
              </div>

              <!-- Card 2: Contact & Social Media Information -->
              <div style="background: rgba(11, 17, 30, 0.5); border: 1px solid var(--border-glass); border-radius: var(--radius-md); padding: 22px; margin-bottom: 20px;">
                <div style="font-size:16px; font-weight:700; color:var(--accent-primary); margin-bottom:16px; display:flex; align-items:center; gap:8px;">
                  📞 தொடர்பு & சமூக வலைதளங்கள் (Contact & Social Details)
                </div>

                <div class="form-grid-3">
                  <div class="form-group">
                    <label class="form-label">அட்மின் / உரிமையாளர் பெயர்</label>
                    <input type="text" id="env_ADMIN_NAME" class="form-control" placeholder="Murugan Nagarajan">
                  </div>
                  <div class="form-group">
                    <label class="form-label">அழைப்பு எண் (Admin Contact Phone) *</label>
                    <input type="text" id="env_ADMIN_PHONE" class="form-control" placeholder="+91 98941 74944" required>
                  </div>
                  <div class="form-group">
                    <label class="form-label">அதிகாரப்பூர்வ WhatsApp எண் *</label>
                    <input type="text" id="env_WHATSAPP_NUMBER" class="form-control" placeholder="+91 98941 74944" required>
                  </div>
                </div>

                <div class="form-grid-3">
                  <div class="form-group">
                    <label class="form-label">அதிகாரப்பூர்வ Support Email</label>
                    <input type="email" id="env_ADMIN_EMAIL" class="form-control" placeholder="tenkasidreams@gmail.com">
                  </div>
                  <div class="form-group">
                    <label class="form-label">நகரம் / மாவட்டம் (Default City)</label>
                    <input type="text" id="env_DEFAULT_CITY" class="form-control" placeholder="Tenkasi">
                  </div>
                  <div class="form-group">
                    <label class="form-label">நாணயக் குறியீடு (Currency Symbol)</label>
                    <input type="text" id="env_CURRENCY_SYMBOL" class="form-control" placeholder="₹">
                  </div>
                </div>

                <div class="form-group">
                  <label class="form-label">முழு அலுவலக முகவரி (Full Office Address)</label>
                  <input type="text" id="env_OFFICE_ADDRESS" class="form-control" placeholder="Main Road, Courtallam Junction, Tenkasi - 627811">
                </div>

                <div class="form-grid-3">
                  <div class="form-group">
                    <label class="form-label">Facebook Link</label>
                    <input type="text" id="env_SOCIAL_FACEBOOK" class="form-control" placeholder="https://facebook.com/yourpage">
                  </div>
                  <div class="form-group">
                    <label class="form-label">YouTube Link</label>
                    <input type="text" id="env_SOCIAL_YOUTUBE" class="form-control" placeholder="https://youtube.com/@yourchannel">
                  </div>
                  <div class="form-group">
                    <label class="form-label">Telegram Link</label>
                    <input type="text" id="env_SOCIAL_TELEGRAM" class="form-control" placeholder="https://t.me/yourgroup">
                  </div>
                </div>
              </div>

              <!-- Card: Monetization & Razorpay Gateway Settings -->
              <div style="background: rgba(11, 17, 30, 0.5); border: 1px solid var(--border-glass); border-radius: var(--radius-md); padding: 22px; margin-bottom: 20px;">
                <div style="font-size:16px; font-weight:700; color:var(--accent-gold); display:flex; align-items:center; gap:8px; margin-bottom:16px;">
                  💳 Razorpay Payment Gateway & தொடர்பு கட்டண அமைப்புகள்
                </div>

                <div class="form-grid-3">
                  <div class="form-group">
                    <label class="form-label">Razorpay இயங்கும் முறை (Mode) *</label>
                    <select id="env_RAZORPAY_MODE" class="form-control">
                      <option value="test">🧪 Test Mode (சோதனை முறை - rzp_test)</option>
                      <option value="live">🚀 Live Mode (நேரலை முறை - rzp_live)</option>
                    </select>
                  </div>
                  <div class="form-group">
                    <label class="form-label">Razorpay Account ID (Merchant ID)</label>
                    <input type="text" id="env_RAZORPAY_ACCOUNT_ID" class="form-control" placeholder="acc_Tdw7B4Z0zFh95x">
                  </div>
                  <div class="form-group">
                    <label class="form-label">UPI ID (கட்டண பெறுநர்)</label>
                    <input type="text" id="env_UPI_ID" class="form-control" placeholder="9894174944@upi">
                  </div>
                </div>

                <div class="form-grid-2" style="margin-top:10px;">
                  <div class="form-group">
                    <label class="form-label">Live Key ID (நேரலை சாவி - rzp_live_...)</label>
                    <input type="text" id="env_RAZORPAY_LIVE_KEY_ID" class="form-control" placeholder="rzp_live_xxxxxxxx">
                  </div>
                  <div class="form-group">
                    <label class="form-label">Live Key Secret (நேரலை இரகசிய சாவி)</label>
                    <input type="password" id="env_RAZORPAY_LIVE_KEY_SECRET" class="form-control" placeholder="••••••••••••">
                  </div>
                </div>

                <div class="form-grid-2" style="margin-top:10px;">
                  <div class="form-group">
                    <label class="form-label">Test Key ID (சோதனை சாவி - rzp_test_...)</label>
                    <input type="text" id="env_RAZORPAY_TEST_KEY_ID" class="form-control" placeholder="rzp_test_TeE2LFCxmmioPq">
                  </div>
                  <div class="form-group">
                    <label class="form-label">Test Key Secret (சோதனை இரகசிய சாவி)</label>
                    <input type="password" id="env_RAZORPAY_TEST_KEY_SECRET" class="form-control" placeholder="••••••••••••">
                  </div>
                </div>

                <div class="form-grid-2" style="margin-top:10px;">
                  <div class="form-group">
                    <label class="form-label">தொடர்பு பார்க்கும் கட்டணம் (Unlock Price in ₹) *</label>
                    <input type="number" id="env_CONTACT_UNLOCK_PRICE" class="form-control" placeholder="30" value="30">
                  </div>
                  <div class="form-group">
                    <label class="form-label">புதிய பயனருக்கு இலவச தொடர்புகள் (Free Quota) *</label>
                    <input type="number" id="env_FREE_CONTACT_LIMIT" class="form-control" placeholder="3" value="3">
                  </div>
                </div>
              </div>

              <!-- Card: SMS & WhatsApp OTP Gateway Settings -->
              <div style="background: rgba(11, 17, 30, 0.5); border: 1px solid var(--border-glass); border-radius: var(--radius-md); padding: 22px; margin-bottom: 20px;">
                <div style="font-size:16px; font-weight:700; color:#10B981; display:flex; align-items:center; gap:8px; margin-bottom:16px;">
                  📱 SMS & WhatsApp OTP Gateway (நேரடி OTP அனுப்பும் முறை)
                </div>

                <div class="form-grid-2">
                  <div class="form-group">
                    <label class="form-label">SMS Gateway Provider *</label>
                    <select id="env_SMS_GATEWAY_PROVIDER" class="form-control">
                      <option value="fast2sms">🇮🇳 Fast2SMS (India Bulk SMS - Recommended)</option>
                      <option value="twilio">🌐 Twilio (Global SMS)</option>
                      <option value="whatsapp">💬 WhatsApp Cloud API</option>
                      <option value="mock">🧪 Test / Dev Mock (இலவச டெஸ்ட் முறை)</option>
                    </select>
                  </div>
                  <div class="form-group">
                    <label class="form-label">செல்போன் OTP உள்நுழைவு (Phone OTP Login)</label>
                    <select id="env_PHONE_OTP_ENABLED" class="form-control">
                      <option value="true">செயலில் உள்ளது (Enabled)</option>
                      <option value="false">முடக்கப்பட்டது (Disabled)</option>
                    </select>
                  </div>
                </div>

                <div class="form-grid-2" style="margin-top:10px;">
                  <div class="form-group">
                    <label class="form-label">Fast2SMS API Key (Fast2SMS சாவி)</label>
                    <input type="password" id="env_FAST2SMS_API_KEY" class="form-control" placeholder="Fast2SMS Dev API Key">
                    <small style="color:var(--text-muted); font-size:11px;">fast2sms.com ➔ Dev API ➔ API Key</small>
                  </div>
                  <div class="form-group">
                    <label class="form-label">Twilio Account SID (விருப்பப்படி)</label>
                    <input type="text" id="env_TWILIO_ACCOUNT_SID" class="form-control" placeholder="ACxxxxxxxxxxxxxx">
                  </div>
                </div>

                <div class="form-grid-3" style="margin-top:10px;">
                  <div class="form-group">
                    <label class="form-label">Twilio Auth Token</label>
                    <input type="password" id="env_TWILIO_AUTH_TOKEN" class="form-control" placeholder="••••••••••••">
                  </div>
                  <div class="form-group">
                    <label class="form-label">Twilio Phone Number</label>
                    <input type="text" id="env_TWILIO_PHONE_NUMBER" class="form-control" placeholder="+1xxxxxxxxxx">
                  </div>
                  <div class="form-group">
                    <label class="form-label">WhatsApp Cloud API URL (விருப்பப்படி)</label>
                    <input type="text" id="env_WHATSAPP_API_URL" class="form-control" placeholder="https://graph.facebook.com/v19.0/...">
                  </div>
                </div>
              </div>

              <!-- Card 3: Database Settings -->
              <div style="background: rgba(11, 17, 30, 0.5); border: 1px solid var(--border-glass); border-radius: var(--radius-md); padding: 22px; margin-bottom: 20px;">
                <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:16px;">
                  <div style="font-size:16px; font-weight:700; color:var(--accent-blue); display:flex; align-items:center; gap:8px;">
                    🗄️ MySQL Database Connection (டேட்டாபேஸ் இணைப்பு)
                  </div>
                  <button type="button" class="btn btn-secondary" style="padding:6px 14px; font-size:12px;" onclick="testDatabaseConnection()">
                    🔌 Test Connection
                  </button>
                </div>

                <div id="dbConnectionStatusBox" style="display:none; padding:12px; border-radius:var(--radius-sm); margin-bottom:16px; font-size:13px;"></div>

                <div class="form-grid-3">
                  <div class="form-group">
                    <label class="form-label">DB Host (ஹோஸ்ட்)</label>
                    <input type="text" id="env_DB_HOST" class="form-control" placeholder="localhost">
                  </div>
                  <div class="form-group">
                    <label class="form-label">DB Port (போர்ட்)</label>
                    <input type="text" id="env_DB_PORT" class="form-control" placeholder="3306">
                  </div>
                  <div class="form-group">
                    <label class="form-label">DB Name (டேட்டாபேஸ் பெயர்)</label>
                    <input type="text" id="env_DB_NAME" class="form-control" placeholder="tenkasi_dreams">
                  </div>
                </div>

                <div class="form-grid-3">
                  <div class="form-group">
                    <label class="form-label">DB Username (பயனர்)</label>
                    <input type="text" id="env_DB_USER" class="form-control" placeholder="root">
                  </div>
                  <div class="form-group">
                    <label class="form-label">DB Password (கடவுச்சொல்)</label>
                    <input type="password" id="env_DB_PASS" class="form-control" placeholder="••••••">
                  </div>
                  <div class="form-group">
                    <label class="form-label">Storage Mode (சேமிப்பு முறை)</label>
                    <select id="env_STORAGE_MODE" class="form-control">
                      <option value="auto">Auto (MySQL first, JSON fallback)</option>
                      <option value="mysql">Force MySQL only</option>
                      <option value="json">JSON Flat File storage only</option>
                    </select>
                  </div>
                </div>
              </div>

              <!-- Card 4: Super Admin Authentication Settings -->
              <div style="background: rgba(11, 17, 30, 0.5); border: 1px solid var(--border-glass); border-radius: var(--radius-md); padding: 22px; margin-bottom: 20px;">
                <div style="font-size:16px; font-weight:700; color:var(--accent-gold); margin-bottom:16px; display:flex; align-items:center; gap:8px;">
                  👑 Super Admin Authentication (சூப்பர் அட்மின் கணக்கு)
                </div>

                <div class="form-grid-3">
                  <div class="form-group">
                    <label class="form-label">Super Admin Username *</label>
                    <input type="text" id="env_SUPER_ADMIN_USER" class="form-control" value="admin3" required>
                  </div>
                  <div class="form-group">
                    <label class="form-label">Super Admin Password *</label>
                    <input type="text" id="env_SUPER_ADMIN_PASS" class="form-control" value="000003" required>
                  </div>
                  <div class="form-group">
                    <label class="form-label">Session Lifetime (Hours)</label>
                    <input type="number" id="env_SESSION_LIFETIME_HOURS" class="form-control" value="24">
                  </div>
                </div>
              </div>

            </div>

            <!-- Raw Editor Section -->
            <div id="envRawSection" style="display:none;">
              <div class="form-group">
                <label class="form-label">.env கோப்பு நேரடி உள்ளடக்கம் (Direct .env Editor)</label>
                <textarea id="rawEnvTextarea" class="form-control" style="font-family: monospace; font-size: 13px; line-height: 1.6; height: 420px; background: #080c14; color: #a7f3d0; border-color: rgba(16, 185, 129, 0.3);"></textarea>
              </div>
              <button class="btn btn-primary" onclick="saveRawEnvFile()">💾 Save Raw .env File</button>
            </div>

          </div>
        </section>

        <!-- TAB 5: APP CONFIGURATION & LOGIN MODE CONTROLS -->
        <section id="tab-app-config" class="tab-panel">
          <div class="section-card">
            <div class="section-header">
              <div>
                <h2 class="section-title">📱 செயலி அமைப்புகள் & லாகின் கட்டுப்பாடு (App Configuration)</h2>
                <p style="font-size: 13px; color: var(--text-muted); margin-top: 4px;">
                  மொபைல் செயலி மற்றும் இணையதளத்தில் Google Sign-In அல்லது செல்போன் OTP என உள்நுழைவு முறையையும், தொடர்பு கட்டணங்களையும் இங்கிருந்து நிர்வகிக்கலாம்.
                </p>
              </div>
              <button class="btn btn-emerald" style="font-weight: 800; padding: 10px 20px;" onclick="saveAppConfigSettings()">
                💾 அமைப்புகளை சேமி (Save App Config)
              </button>
            </div>

            <!-- Card 1: User Login Authentication Mode Controls -->
            <div style="background: linear-gradient(135deg, rgba(15, 23, 42, 0.95), rgba(30, 41, 59, 0.95)); border: 1.5px solid rgba(16, 185, 129, 0.4); border-radius: var(--radius-md); padding: 24px; margin-bottom: 24px; box-shadow: 0 10px 25px rgba(0,0,0,0.3);">
              <div style="font-size: 17px; font-weight: 800; color: #6ee7b7; display: flex; align-items: center; gap: 10px; margin-bottom: 6px;">
                🔐 பயனர் உள்நுழைவு முறை கட்டுப்பாடு (User Login Authentication Mode)
              </div>
              <p style="font-size: 13px; color: var(--text-muted); margin-bottom: 20px;">
                வாடிக்கையாளர் ஆப்பை திறக்கும்போது எந்த முறையில் லாகின் செய்ய வேண்டும் என்பதை தேர்வு செய்யுங்கள்:
              </p>

              <!-- 3 Interactive Mode Option Cards -->
              <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 16px; margin-bottom: 20px;">
                <!-- Option 1: Google Sign-In Only (Default) -->
                <div class="app-mode-card" id="modeCardGoogle" onclick="selectLoginModePreset('google')" style="background: rgba(16, 185, 129, 0.1); border: 2px solid #10b981; border-radius: 12px; padding: 18px; cursor: pointer; transition: all 0.2s ease;">
                  <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 8px;">
                    <div style="font-size: 15px; font-weight: 800; color: #6ee7b7; display: flex; align-items: center; gap: 8px;">
                      <span>🌐</span> Google Sign-In மட்டும் (Google Only)
                    </div>
                    <span class="badge" id="badgeModeGoogle" style="background: #10b981; color: #fff; font-size: 11px; font-weight: 800;">பரிந்துரைக்கப்பட்டது</span>
                  </div>
                  <div style="font-size: 12.5px; color: #cbd5e1; line-height: 1.4;">
                    பயனர்கள் Gmail மூலம் 1-கிளிக்கில் உடனடியாக பாதுகாப்பாக உள்நுழைவர். செல்போன் OTP தேவையில்லை. எளிமையான அனுபவம்.
                  </div>
                </div>

                <!-- Option 2: Phone OTP Only -->
                <div class="app-mode-card" id="modeCardPhone" onclick="selectLoginModePreset('phone')" style="background: rgba(15, 23, 42, 0.6); border: 1.5px solid rgba(148, 163, 184, 0.3); border-radius: 12px; padding: 18px; cursor: pointer; transition: all 0.2s ease;">
                  <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 8px;">
                    <div style="font-size: 15px; font-weight: 800; color: #94a3b8; display: flex; align-items: center; gap: 8px;">
                      <span>📱</span> மொபைல் எண் OTP மட்டும் (Phone OTP)
                    </div>
                    <span class="badge" id="badgeModePhone" style="display: none; background: #3b82f6; color: #fff; font-size: 11px;">இயக்கத்தில் உள்ளது</span>
                  </div>
                  <div style="font-size: 12.5px; color: var(--text-muted); line-height: 1.4;">
                    பயனர்கள் தங்களது 10 இலக்க செல்போன் எண் மற்றும் OTP உள்ளிட்டு உள்நுழைவர்.
                  </div>
                </div>

                <!-- Option 3: Both Google & Phone OTP -->
                <div class="app-mode-card" id="modeCardBoth" onclick="selectLoginModePreset('both')" style="background: rgba(15, 23, 42, 0.6); border: 1.5px solid rgba(148, 163, 184, 0.3); border-radius: 12px; padding: 18px; cursor: pointer; transition: all 0.2s ease;">
                  <div style="display: flex; align-items: center; justify-content: space-between; margin-bottom: 8px;">
                    <div style="font-size: 15px; font-weight: 800; color: #94a3b8; display: flex; align-items: center; gap: 8px;">
                      <span>⚡</span> Google & மொபைல் இரண்டும் (Both)
                    </div>
                    <span class="badge" id="badgeModeBoth" style="display: none; background: #8b5cf6; color: #fff; font-size: 11px;">இயக்கத்தில் உள்ளது</span>
                  </div>
                  <div style="font-size: 12.5px; color: var(--text-muted); line-height: 1.4;">
                    பயனர்கள் தங்களுக்கு விருப்பமான Google அல்லது Phone OTP இரண்டில் ஏதேனும் ஒன்றை தேர்வு செய்யலாம்.
                  </div>
                </div>
              </div>

              <!-- Hidden input holding current mode -->
              <input type="hidden" id="app_LOGIN_METHOD" value="google">

              <!-- Checkbox Toggles -->
              <div style="background: rgba(11, 17, 30, 0.6); border: 1px solid rgba(255,255,255,0.08); border-radius: 10px; padding: 16px; display: flex; gap: 24px; flex-wrap: wrap;">
                <label style="display: flex; align-items: center; gap: 10px; font-size: 13.5px; font-weight: 700; color: #e2e8f0; cursor: pointer;">
                  <input type="checkbox" id="app_GOOGLE_SIGN_IN_ENABLED" checked style="width: 18px; height: 18px; accent-color: #10b981;" onchange="syncLoginCheckboxes()">
                  <span>🌐 Google Sign-In உள்நுழைவு அனுமதி (Enable Google Sign-In)</span>
                </label>
                <label style="display: flex; align-items: center; gap: 10px; font-size: 13.5px; font-weight: 700; color: #e2e8f0; cursor: pointer;">
                  <input type="checkbox" id="app_PHONE_OTP_ENABLED" style="width: 18px; height: 18px; accent-color: #10b981;" onchange="syncLoginCheckboxes()">
                  <span>📱 செல்போன் OTP உள்நுழைவு அனுமதி (Enable Phone OTP)</span>
                </label>
              </div>
            </div>

            <!-- Card 2: Contact Unlock Limits & Pricing -->
            <div style="background: rgba(11, 17, 30, 0.5); border: 1px solid var(--border-glass); border-radius: var(--radius-md); padding: 22px; margin-bottom: 20px;">
              <div style="font-size: 16px; font-weight: 700; color: var(--accent-gold); margin-bottom: 16px; display: flex; align-items: center; gap: 8px;">
                💰 தொடர்பு பார்க்கும் கட்டணம் & இலவச வரம்புகள் (Unlock Paywall Controls)
              </div>
              <div class="form-grid-3">
                <div class="form-group">
                  <label class="form-label">🎁 இலவச தொடர்புகள் வரம்பு (Free Contacts)</label>
                  <input type="number" id="app_FREE_CONTACT_LIMIT" class="form-control" value="3" min="0" max="50">
                  <small style="color: var(--text-muted); font-size: 11px;">புதிய பயனர் இலவசமாக பார்க்கும் எண்கள் (இயல்பு: 3)</small>
                </div>
                <div class="form-group">
                  <label class="form-label">🏷️ வழக்கமான கட்டணம் (Standard Price ₹)</label>
                  <input type="number" id="app_CONTACT_UNLOCK_PRICE" class="form-control" value="30" min="1">
                  <small style="color: var(--text-muted); font-size: 11px;">இலவச வரம்பு முடிந்த பின் கட்டணம் (இயல்பு: ₹30)</small>
                </div>
                <div class="form-group">
                  <label class="form-label">🏷️ ஆஃபர் விலை (Promotional Offer ₹)</label>
                  <input type="number" id="app_OFFER_UNLOCK_PRICE" class="form-control" value="10" min="1">
                  <small style="color: var(--text-muted); font-size: 11px;">சிறப்பு தள்ளுபடி விலை (உதா: ₹10)</small>
                </div>
              </div>

              <div style="margin-top: 10px;">
                <label style="display: flex; align-items: center; gap: 8px; font-weight: 700; color: #fbbf24; cursor: pointer; margin-bottom: 10px;">
                  <input type="checkbox" id="app_OFFER_ACTIVE" style="width: 17px; height: 17px; accent-color: #f59e0b;">
                  <span>⚡ சிறப்பு ஆஃபர் இயக்கத்தில் வைக்கவும் (Enable Promo Offer)</span>
                </label>
                <div class="form-group">
                  <label class="form-label">📢 ஆஃபர் பேனர் வாசகம்</label>
                  <input type="text" id="app_OFFER_BANNER_TEXT" class="form-control" value="🎉 சிறப்பு ஆஃபர்: வெறும் ₹10 செலுத்தி உரிமையாளர் எண்ணை உடனே அறியலாம்!">
                </div>
              </div>
            </div>

            <!-- Card 3: Razorpay Keys -->
            <div style="background: rgba(11, 17, 30, 0.5); border: 1px solid var(--border-glass); border-radius: var(--radius-md); padding: 22px; margin-bottom: 20px;">
              <div style="font-size: 16px; font-weight: 700; color: var(--accent-blue); margin-bottom: 16px; display: flex; align-items: center; gap: 8px;">
                💳 Razorpay Payment Gateway Keys (நேரலை கட்டண இணைப்பு)
              </div>
              <div class="form-grid-3">
                <div class="form-group">
                  <label class="form-label">Razorpay Account ID (Merchant ID)</label>
                  <input type="text" id="app_RAZORPAY_ACCOUNT_ID" class="form-control" placeholder="acc_Tdw7B4Z0zFh95x">
                </div>
                <div class="form-group">
                  <label class="form-label">Razorpay Key ID *</label>
                  <input type="text" id="app_RAZORPAY_KEY_ID" class="form-control" placeholder="acc_Tdw7B4Z0zFh95x">
                </div>
                <div class="form-group">
                  <label class="form-label">Razorpay Key Secret</label>
                  <input type="password" id="app_RAZORPAY_KEY_SECRET" class="form-control" placeholder="••••••••••••••••">
                </div>
              </div>
            </div>

            <div style="text-align: right;">
              <button class="btn btn-emerald" style="font-weight: 800; padding: 12px 28px; font-size: 14px;" onclick="saveAppConfigSettings()">
                💾 செயலி அமைப்புகளை சேமிக்க (Save All Settings)
              </button>
            </div>
          </div>
        </section>

        <!-- TAB 6: USER ACTIVITIES & LEADS TRACKER -->
        <section id="tab-user-activities" class="tab-panel">
          <div class="section-card">
            <div class="section-header">
              <div>
                <h2 class="section-title">👥 பயனர்கள் செயல்பாடு & லீட்ஸ் மேலாண்மை (User Activities & Leads)</h2>
                <p style="font-size: 13px; color: var(--text-muted); margin-top: 4px;">
                  பயனர்கள் யார் யாருடைய தொடர்பு எண்களைப் பார்த்தார்கள், எந்த சொத்துக்களைப் பார்த்தார்கள் மற்றும் விற்பனையாளர்களின் நேரடி வாடிக்கையாளர் லீட்ஸ்.
                </p>
              </div>
              <button class="btn btn-secondary" onclick="loadActivitiesData()">
                🔄 புதுப்பி (Refresh)
              </button>
            </div>

            <!-- Activity KPI Stats Grid -->
            <div class="stats-grid" style="margin-bottom: 24px;">
              <div class="stat-card">
                <div class="stat-info">
                  <h3>மொத்த செயல்பாடுகள்</h3>
                  <div class="stat-number" id="actStatTotal">0</div>
                  <div class="stat-sub">Total User Actions Logged</div>
                </div>
                <div class="stat-icon-wrapper icon-blue">📊</div>
              </div>

              <div class="stat-card">
                <div class="stat-info">
                  <h3>தொடர்பு எண்கள் திறப்பு</h3>
                  <div class="stat-number" id="actStatUnlocks">0</div>
                  <div class="stat-sub">Contacts Unlocked (Free + Paid)</div>
                </div>
                <div class="stat-icon-wrapper icon-emerald">🔓</div>
              </div>

              <div class="stat-card">
                <div class="stat-info">
                  <h3>கட்டண வசூல்</h3>
                  <div class="stat-number" id="actStatRevenue">₹0</div>
                  <div class="stat-sub">Paid Unlock Revenue</div>
                </div>
                <div class="stat-icon-wrapper icon-gold">💰</div>
              </div>

              <div class="stat-card">
                <div class="stat-info">
                  <h3>தனிப்பட்ட பயனர்கள்</h3>
                  <div class="stat-number" id="actStatUsers">0</div>
                  <div class="stat-sub">Active Buyers & Sellers</div>
                </div>
                <div class="stat-icon-wrapper icon-purple">👥</div>
              </div>
            </div>

            <!-- Sub-tabs Navigation Bar -->
            <div style="display: flex; gap: 8px; margin-bottom: 20px; border-bottom: 1px solid var(--border-glass); padding-bottom: 12px; flex-wrap: wrap;">
              <button class="btn btn-primary act-subtab-btn" id="btnSubTabActivities" onclick="switchActSubTab('activities')">
                📊 அனைத்து செயல்பாடுகள் (All Activities)
              </button>
              <button class="btn btn-secondary act-subtab-btn" id="btnSubTabPosters" onclick="switchActSubTab('posters')">
                📢 சொத்து பதிவிட்ட பயனர்கள் (Property Posters / Sellers)
              </button>
              <button class="btn btn-secondary act-subtab-btn" id="btnSubTabPropertyViews" onclick="switchActSubTab('propertyViews')">
                👁️ விளம்பரம் பார்த்தவர்கள் (Post Views & Viewers)
              </button>
              <button class="btn btn-secondary act-subtab-btn" id="btnSubTabChats" onclick="switchActSubTab('chats')">
                💬 வாங்குபவர்-விற்பனையாளர் அரட்டை (Buyer-Seller Chats)
              </button>
            </div>

            <!-- SUB-TAB 1: ALL ACTIVITIES -->
            <div id="actSectionActivities">
              <!-- Filter & Search Controls Bar -->
              <div style="background: rgba(15, 23, 42, 0.7); border: 1px solid var(--border-glass); border-radius: var(--radius-sm); padding: 16px; margin-bottom: 20px; display: flex; gap: 14px; flex-wrap: wrap; align-items: center;">
                <div style="flex: 1; min-width: 240px;">
                  <input type="text" id="actSearchInput" class="form-control" placeholder="🔍 பயனர் பெயர், எண், சொத்து தலைப்பு தேட..." oninput="filterActivitiesList()">
                </div>
                <div style="min-width: 180px;">
                  <select id="actFilterAction" class="form-control" onchange="filterActivitiesList()">
                    <option value="all">அனைத்து செயல்பாடுகள் (All)</option>
                    <option value="contact_unlock_free">🔓 இலவச தொடர்பு பார்வை</option>
                    <option value="contact_unlock_paid">💰 கட்டண தொடர்பு திறப்பு</option>
                    <option value="property_view">👁️ சொத்து பார்வை</option>
                    <option value="property_post">📝 புதிய விளம்பரம் பதிவு</option>
                    <option value="chat_message">💬 அரட்டை செய்தி</option>
                  </select>
                </div>
                <div style="min-width: 220px;">
                  <select id="actFilterSingleUser" class="form-control" onchange="filterActivitiesByUser(this.value)">
                    <option value="">👤 அனைத்து பயனர்கள் (All Users)</option>
                  </select>
                </div>
                <button class="btn btn-secondary" onclick="resetActivityFilters()">✕ ரீசெட்</button>
              </div>

              <!-- Single User Info Banner -->
              <div id="actSingleUserBanner" style="display: none; background: rgba(59, 130, 246, 0.12); border: 1.5px solid rgba(59, 130, 246, 0.4); border-radius: 10px; padding: 14px 18px; margin-bottom: 20px; align-items: center; justify-content: space-between;">
                <div style="display: flex; align-items: center; gap: 14px;">
                  <div style="width: 44px; height: 44px; background: #3b82f6; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 20px; color: #fff;">👤</div>
                  <div>
                    <div id="actBannerUserName" style="font-size: 15px; font-weight: 800; color: #93c5fd;">User Name</div>
                    <div style="font-size: 12px; color: var(--text-muted); margin-top: 2px;">
                      📞 <span id="actBannerUserPhone">-</span> | ✉️ <span id="actBannerUserEmail">-</span>
                    </div>
                  </div>
                </div>
                <div style="text-align: right;">
                  <span class="badge badge-verified" id="actBannerActivityCount">0 செயல்பாடுகள்</span>
                  <div style="margin-top: 6px;">
                    <button class="btn btn-secondary" style="padding: 4px 10px; font-size: 11px;" onclick="resetActivityFilters()">அனைத்து பயனர்களையும் காட்டு</button>
                  </div>
                </div>
              </div>

              <!-- Activities Data Table -->
              <div class="table-container">
                <table class="data-table">
                  <thead>
                    <tr>
                      <th>தேதி & நேரம்</th>
                      <th>பயனர் விபரம் (Buyer / User)</th>
                      <th>செயல்பாடு (Action)</th>
                      <th>சொத்து விபரம் (Property)</th>
                      <th>உரிமையாளர் / போஸ்ட் செய்தவர் (Seller)</th>
                      <th>தொகை</th>
                      <th>நேரடி தொடர்பு</th>
                    </tr>
                  </thead>
                  <tbody id="activitiesTableBody">
                    <tr><td colspan="7" style="text-align:center; padding:30px; color:var(--text-muted);">ஏற்றப்படுகிறது...</td></tr>
                  </tbody>
                </table>
              </div>
            </div>

            <!-- SUB-TAB 2: PROPERTY POSTERS / SELLERS -->
            <div id="actSectionPosters" style="display: none;">
              <div class="table-container">
                <table class="data-table">
                  <thead>
                    <tr>
                      <th>விற்பனையாளர் பெயர் (Seller / Poster)</th>
                      <th>தொலைபேசி எண்</th>
                      <th>பதிவிட்ட விளம்பரங்கள்</th>
                      <th>பெற்ற மொத்த பார்வைகள் (Views)</th>
                      <th>தொடர்பு எண் திறப்புகள் (Unlocks)</th>
                      <th>நடவடிக்கை</th>
                    </tr>
                  </thead>
                  <tbody id="postersTableBody">
                    <tr><td colspan="6" style="text-align:center; padding:30px; color:var(--text-muted);">விற்பனையாளர்கள் பட்டியல் ஏற்றப்படுகிறது...</td></tr>
                  </tbody>
                </table>
              </div>
            </div>

            <!-- SUB-TAB 3: PROPERTY VIEWS & VIEWERS -->
            <div id="actSectionPropertyViews" style="display: none;">
              <div class="table-container">
                <table class="data-table">
                  <thead>
                    <tr>
                      <th>சொத்து விபரம் (Property Title)</th>
                      <th>வகை (Type)</th>
                      <th>உரிமையாளர் (Seller)</th>
                      <th>பார்வையாளர்கள் எண்ணிக்கை</th>
                      <th>தொடர்பு திறப்புகள்</th>
                      <th>பார்த்தவர்கள் விவரம்</th>
                    </tr>
                  </thead>
                  <tbody id="propertyViewsTableBody">
                    <tr><td colspan="6" style="text-align:center; padding:30px; color:var(--text-muted);">பார்வை விவரங்கள் ஏற்றப்படுகிறது...</td></tr>
                  </tbody>
                </table>
              </div>
            </div>

            <!-- SUB-TAB 4: BUYER-SELLER CHATS -->
            <div id="actSectionChats" style="display: none;">
              <div class="table-container">
                <table class="data-table">
                  <thead>
                    <tr>
                      <th>சொத்து (Property)</th>
                      <th>வாங்குபவர் (Buyer)</th>
                      <th>விற்பனையாளர் (Seller)</th>
                      <th>கடைசி செய்தி (Last Message)</th>
                      <th>நேரம்</th>
                      <th>சாட் பார்க்க</th>
                    </tr>
                  </thead>
                  <tbody id="chatsTableBody">
                    <tr><td colspan="6" style="text-align:center; padding:30px; color:var(--text-muted);">சாட் உரையாடல்கள் ஏற்றப்படுகிறது...</td></tr>
                  </tbody>
                </table>
              </div>
            </div>

            <!-- MODAL: POSTER ADS & VIEWS MODAL -->
            <div class="modal" id="posterAdsModal" style="display:none; position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.7); z-index:9999; align-items:center; justify-content:center;">
              <div style="background:#1e293b; border-radius:14px; max-width:700px; width:90%; max-height:85vh; overflow-y:auto; padding:24px; border:1px solid rgba(255,255,255,0.1);">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
                  <h3 id="posterAdsModalTitle" style="color:#fff; font-size:18px; margin:0;">விற்பனையாளர் விளம்பரங்கள்</h3>
                  <button class="btn btn-secondary" onclick="closePosterAdsModal()" style="padding:4px 10px;">✕ மூடு</button>
                </div>
                <div id="posterAdsModalContent"></div>
              </div>
            </div>

            <!-- MODAL: PROPERTY VIEWERS MODAL -->
            <div class="modal" id="propertyViewersModal" style="display:none; position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.7); z-index:9999; align-items:center; justify-content:center;">
              <div style="background:#1e293b; border-radius:14px; max-width:650px; width:90%; max-height:85vh; overflow-y:auto; padding:24px; border:1px solid rgba(255,255,255,0.1);">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:16px;">
                  <h3 id="propertyViewersModalTitle" style="color:#fff; font-size:18px; margin:0;">சொத்தை பார்த்தவர்கள் விவரம்</h3>
                  <button class="btn btn-secondary" onclick="closePropertyViewersModal()" style="padding:4px 10px;">✕ மூடு</button>
                </div>
                <div id="propertyViewersModalContent"></div>
              </div>
            </div>

            <!-- MODAL: ADMIN CHAT THREAD MODAL -->
            <div class="modal" id="adminChatModal" style="display:none; position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.7); z-index:9999; align-items:center; justify-content:center;">
              <div style="background:#1e293b; border-radius:14px; max-width:600px; width:90%; max-height:85vh; display:flex; flex-direction:column; padding:24px; border:1px solid rgba(255,255,255,0.1);">
                <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:14px;">
                  <h3 id="adminChatModalTitle" style="color:#fff; font-size:16px; margin:0;">வாங்குபவர்-விற்பனையாளர் சாட்</h3>
                  <button class="btn btn-secondary" onclick="closeAdminChatModal()" style="padding:4px 10px;">✕ மூடு</button>
                </div>
                <div id="adminChatModalMessages" style="flex:1; max-height:400px; overflow-y:auto; padding:12px; background:rgba(15,23,42,0.6); border-radius:10px; margin-bottom:10px;"></div>
              </div>
            </div>
          </div>
        <!-- ==================== TAB 9: LIVE USERS ==================== -->
        <section id="tab-live-users" class="tab-panel">
          <div class="panel-header">
            <div>
              <h2 class="panel-title">🟢 நேரலை பயனர்கள் & உடனடி தொடர்பு (Live Users & Messaging)</h2>
              <p class="panel-subtitle">ரியல்-டைமில் மொபைல் ஆப் மற்றும் இணையதளத்தில் உலாவிக்கொண்டிருக்கும் பயனர்களின் விவரங்கள்</p>
            </div>
            <div style="display:flex; align-items:center; gap:10px; flex-wrap: wrap;">
              <button type="button" class="btn btn-gold" onclick="openAdminBroadcastModal()" style="display:flex; align-items:center; gap:6px; font-weight:700;">
                📢 அனைவருக்கும் அறிவிப்பு (Broadcast)
              </button>
              <span class="badge badge-emerald" style="display:flex; align-items:center; gap:6px; font-size:12px; padding:6px 12px;">
                <span style="width:8px; height:8px; border-radius:50%; background:#10b981; display:inline-block; box-shadow:0 0 8px #10b981;"></span>
                <span>நேரலை ஒத்திசைவு (Auto Sync 10s)</span>
              </span>
              <button type="button" class="btn btn-secondary" onclick="loadLiveUsers()" style="display:flex; align-items:center; gap:6px;">
                🔄 புதுப்பி (Refresh)
              </button>
            </div>
          </div>

          <!-- Live User Stats Cards -->
          <div class="stats-grid" style="grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); margin-bottom: 24px;">
            <div class="stat-card" style="border-left: 4px solid #10b981;">
              <div class="stat-icon" style="background: rgba(16,185,129,0.15); color: #10b981;">🟢</div>
              <div class="stat-info">
                <div class="stat-label">தற்போது நேரலையில் (Active Now)</div>
                <div class="stat-value" id="statLiveNow" style="color: #34d399;">0</div>
                <div class="stat-sub">கடந்த 3 நிமிடங்களில் செயலில் உள்ளோர்</div>
              </div>
            </div>
            <div class="stat-card" style="border-left: 4px solid #3b82f6;">
              <div class="stat-icon" style="background: rgba(59,130,246,0.15); color: #3b82f6;">📱</div>
              <div class="stat-info">
                <div class="stat-label">மொபைல் ஆப் பயனர்கள் (App Active)</div>
                <div class="stat-value" id="statAppActive" style="color: #60a5fa;">0</div>
                <div class="stat-sub">Flutter Android App பயனர்கள்</div>
              </div>
            </div>
            <div class="stat-card" style="border-left: 4px solid #f59e0b;">
              <div class="stat-icon" style="background: rgba(245,158,11,0.15); color: #f59e0b;">💻</div>
              <div class="stat-info">
                <div class="stat-label">இணையதள பயனர்கள் (Web Active)</div>
                <div class="stat-value" id="statWebActive" style="color: #fbbf24;">0</div>
                <div class="stat-sub">Chrome / Safari / Web உலாவிகள்</div>
              </div>
            </div>
            <div class="stat-card" style="border-left: 4px solid #8b5cf6;">
              <div class="stat-icon" style="background: rgba(139,92,246,0.15); color: #8b5cf6;">👥</div>
              <div class="stat-info">
                <div class="stat-label">மொத்த பதிவு செய்த பயனர்கள்</div>
                <div class="stat-value" id="statTotalUsers" style="color: #c084fc;">0</div>
                <div class="stat-sub">கண்காணிக்கப்பட்ட மொத்த பயனர்கள்</div>
              </div>
            </div>
          </div>

          <!-- Filter & Search Toolbar -->
          <div class="filter-bar" style="margin-bottom: 20px; display: flex; flex-wrap: wrap; gap: 12px; align-items: center; justify-content: space-between;">
            <div style="display: flex; gap: 10px; flex-wrap: wrap; flex: 1; min-width: 280px;">
              <div class="search-box" style="flex: 1; min-width: 200px;">
                <input type="text" id="liveUserSearchInput" class="form-control" placeholder="🔍 பயனர் பெயர், எண் அல்லது மின்னஞ்சல் மூலம் தேடுக..." oninput="renderLiveUsersTable()">
              </div>
              <select id="liveUserStatusFilter" class="form-control" style="width: 170px;" onchange="renderLiveUsersTable()">
                <option value="all" selected>அனைத்து நிலைகள் (All Status)</option>
                <option value="online">🟢 நேரலை (Online)</option>
                <option value="idle">🟡 செயலற்றோர் (Idle)</option>
                <option value="offline">⚪ ஆஃப்லைன் (Offline)</option>
              </select>
              <select id="liveUserPlatformFilter" class="form-control" style="width: 170px;" onchange="renderLiveUsersTable()">
                <option value="all">அனைத்து தளங்கள்</option>
                <option value="app">📱 Android App</option>
                <option value="web">💻 Web Browser</option>
              </select>
            </div>
          </div>

          <!-- Live Users Data Table -->
          <div class="card">
            <div class="table-container">
              <table class="data-table">
                <thead>
                  <tr>
                    <th>நிலை (Status)</th>
                    <th>பயனர் விபரம் (User Name & Info)</th>
                    <th>தளம் (Platform)</th>
                    <th>தற்போதைய திரை / செயல்பாடு</th>
                    <th>கடைசி இயக்கம் (Last Active)</th>
                    <th style="text-align: right;">நடவடிக்கை (Action)</th>
                  </tr>
                </thead>
                <tbody id="liveUsersTableBody">
                  <tr><td colspan="6" style="text-align:center; padding:30px; color:var(--text-muted);">நேரலை பயனர்கள் பட்டியல் ஏற்றப்படுகிறது...</td></tr>
                </tbody>
              </table>
            </div>
          </div>
        </section>

      </main>
    </div>
  </div>

  <!-- ==================== 3. ADD / EDIT PROPERTY MODAL ==================== -->
  <div id="propertyModal" class="modal-backdrop">
    <div class="modal-dialog">
      <div class="modal-header">
        <h3 class="modal-title" id="propertyModalTitle">➕ விளம்பரம் சேர்த்தல் / திருத்துதல்</h3>
        <div style="display: flex; align-items: center; gap: 10px;">
          <button type="submit" form="propertyForm" class="btn btn-gold btn-sm" style="font-size: 13px; font-weight: 800; padding: 8px 16px; border-radius: 8px; box-shadow: 0 2px 8px rgba(245,158,11,0.35);">
            💾 உடனே சேமி (Save)
          </button>
          <button type="button" class="modal-close" onclick="closeModal('propertyModal')">✕</button>
        </div>
      </div>

      <form id="propertyForm" class="modal-content" onsubmit="handlePropertySubmit(event)">
        <div class="modal-body">
          <input type="hidden" id="propIdField">

          <div class="form-group">
            <label class="form-label">விளம்பர தலைப்பு (Title) *</label>
            <input type="text" id="propTitle" class="form-control" placeholder="எ.கா: 3 BHK தனி வீடு விற்பனைக்கு" required>
          </div>

          <div class="form-grid-3">
            <div class="form-group">
              <label class="form-label">சொத்து வகை (Category) *</label>
              <select id="propType" class="form-control" required>
                <option value="House">வீடு (House / Villa)</option>
                <option value="Land">மனை / நிலம் (Land / Plots)</option>
                <option value="Farmland">தோட்டம் (Farmland / Orchard)</option>
                <option value="Shop">கடை / வணிகம் (Shop / Commercial)</option>
                <option value="Apartment">அபார்ட்மெண்ட் (Apartment / Flat)</option>
                <option value="Rental">வாடகைக்கு (Rental / Lease)</option>
              </select>
            </div>

            <div class="form-group">
              <label class="form-label">விலை (Price in ₹) *</label>
              <input type="number" id="propPrice" class="form-control" placeholder="4500000" required>
            </div>

            <div class="form-group">
              <label class="form-label">பரப்பளவு (Area in Sq.Ft) *</label>
              <input type="number" id="propAreaSqFt" class="form-control" placeholder="1500" required>
            </div>
          </div>

          <div class="form-grid-2">
            <div class="form-group">
              <label class="form-label">முகவரி / இடம் (Location) *</label>
              <input type="text" id="propLocation" class="form-control" placeholder="Tenkasi Bypass Road" required>
            </div>

            <div class="form-group">
              <label class="form-label">மாவட்டம் / நகரம் (City / District)</label>
              <input type="text" id="propCity" class="form-control" value="Tenkasi" placeholder="Tenkasi">
            </div>
          </div>

          <div class="form-grid-2">
            <div class="form-group">
              <label class="form-label">விற்பனையாளர் பெயர் (Seller / Agent Name) *</label>
              <input type="text" id="propSellerName" class="form-control" placeholder="எ.கா: சூப்பர் அட்மின் / முருகா ரியல் எஸ்டேட்" value="Super Admin" required>
            </div>

            <div class="form-group">
              <label class="form-label">பதிவிட்டவர் (Poster Type)</label>
              <select id="propPosterType" class="form-control">
                <option value="Direct Owner">நேரடி உரிமையாளர் (Direct Owner)</option>
                <option value="Agent">ரியல் எஸ்டேட் ஏஜென்ட் (Agent)</option>
                <option value="Promoter">லேண்ட் புரமோட்டர் (Promoter)</option>
              </select>
            </div>
          </div>

          <div class="form-grid-2">
            <div class="form-group">
              <label class="form-label">தொடர்பு எண் (Phone / WhatsApp) *</label>
              <input type="text" id="propContactPhone" class="form-control" value="+91 98941 74944" required>
            </div>

            <div class="form-group">
              <label class="form-label">பார்வை திசை (Facing)</label>
              <select id="propFacing" class="form-control">
                <option value="East">East (கிழக்கு)</option>
                <option value="North">North (வடக்கு)</option>
                <option value="North-East">North-East (வடகிழக்கு)</option>
                <option value="West">West (மேற்கு)</option>
                <option value="South">South (தெற்கு)</option>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">அருகிலுள்ள அடையாளம் (Landmark)</label>
            <input type="text" id="propLandmark" class="form-control" placeholder="Near Kasi Viswanathar Temple">
          </div>

          <!-- Dynamic Category Specific Form Section -->
          <div id="dynamicCategoryFields" class="category-dynamic-fields">
            <!-- Rendered automatically via handleCategoryChange -->
          </div>

          <div class="form-group" style="margin-top: 16px;">
            <label class="form-label">முழு விவரம் (Description)</label>
            <textarea id="propDescription" class="form-control" rows="3" placeholder="சொத்தின் கூடுதல் சிறப்பம்சங்கள், நீர் வளம், சாலை வசதி..."></textarea>
          </div>

          <div class="form-group" style="margin-top: 16px;">
            <label class="form-label" style="display:flex; justify-content:space-between; align-items:center;">
              <span>📸 புகைப்படங்கள் (Property Photos)</span>
              <span style="font-size:0.75rem; color:var(--text-muted);">பல புகைப்படங்களை தேர்ந்தெடுக்கலாம் (Multiple images)</span>
            </label>
            <div class="image-upload-box" onclick="document.getElementById('propImageInput').click()" style="border: 2px dashed rgba(212,175,55,0.4); border-radius: 12px; padding: 20px; text-align: center; cursor: pointer; background: rgba(255,255,255,0.02); transition: all 0.2s ease;">
              <input type="file" id="propImageInput" accept="image/*" multiple style="display:none;" onchange="handleAdminImageUpload(event)">
              <div style="font-size: 1.8rem; margin-bottom: 6px;">📷</div>
              <div style="font-size: 0.9rem; font-weight: 600; color: var(--accent-gold);">புகைப்படங்களை பதிவேற்ற இங்கே கிளிக் செய்யவும்</div>
              <div style="font-size: 0.78rem; color: var(--text-muted); margin-top: 4px;">JPG, PNG, WebP (அதிகபட்சம் 10MB)</div>
            </div>
            <div id="adminPropImagePreviewGrid" style="display: grid; grid-template-columns: repeat(auto-fill, minmax(80px, 1fr)); gap: 10px; margin-top: 12px;"></div>
          </div>

          <div class="form-grid-3" style="margin-top: 14px;">
            <div class="form-group">
              <label class="form-label">விளம்பர நிலை (Status)</label>
              <select id="propStatus" class="form-control">
                <option value="active">Active (நேரலை)</option>
                <option value="pending">Pending (காத்திருப்பு)</option>
                <option value="sold">Sold (விற்பனையானது)</option>
              </select>
            </div>

            <div style="display:flex; flex-direction:column; justify-content:center; gap:8px;">
              <div class="checkbox-group">
                <input type="checkbox" id="propIsVerified" checked>
                <label for="propIsVerified">✓ சரிபார்க்கப்பட்டது (Verified Shield)</label>
              </div>
              <div class="checkbox-group">
                <input type="checkbox" id="propIsFeatured">
                <label for="propIsFeatured">★ சிறப்பு விளம்பரம் (Featured Ad)</label>
              </div>
              <div class="checkbox-group">
                <input type="checkbox" id="propIsPremium">
                <label for="propIsPremium">👑 பிரீமியம் விளம்பரம் (Premium / Paid Unlock)</label>
              </div>
            </div>

            <div style="display:flex; flex-direction:column; justify-content:center; gap:8px;">
              <div class="checkbox-group">
                <input type="checkbox" id="propBankLoan" checked>
                <label for="propBankLoan">வங்கி கடன் வசதி (Bank Loan)</label>
              </div>
              <div class="checkbox-group">
                <input type="checkbox" id="propPriceNegotiable" checked>
                <label for="propPriceNegotiable">விலை பேசலாம் (Negotiable)</label>
              </div>
            </div>
          </div>
        </div>

        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" onclick="closeModal('propertyModal')" style="font-weight: 700; padding: 11px 20px;">
            ரத்து செய் (Cancel)
          </button>
          <button type="submit" class="btn btn-gold" id="btnSaveProperty" style="font-size: 15px; font-weight: 800; padding: 12px 30px; box-shadow: 0 4px 18px rgba(245, 158, 11, 0.5); border-radius: 10px; display: inline-flex; align-items: center; gap: 8px; cursor: pointer;">
            <span>🚀</span>
            <span>விளம்பரம் சேமி / வெளியிடு (Submit & Publish)</span>
          </button>
        </div>
      </form>
    </div>
  </div>

  <!-- ==================== 4. ADD BUYER REQUIREMENT MODAL ==================== -->
  <div id="requirementModal" class="modal-backdrop">
    <div class="modal-dialog" style="max-width: 600px;">
      <div class="modal-header">
        <h3 class="modal-title">➕ வாடிக்கையாளர் தேவை பதிவு (Add Requirement)</h3>
        <button class="modal-close" onclick="closeModal('requirementModal')">✕</button>
      </div>

      <form id="reqForm">
        <div class="modal-body">
          <div class="form-grid-2">
            <div class="form-group">
              <label class="form-label">வாடிக்கையாளர் பெயர் *</label>
              <input type="text" id="reqUserName" class="form-control" placeholder="எ.கா: முத்துராமன்" required>
            </div>
            <div class="form-group">
              <label class="form-label">தொலைபேசி எண் *</label>
              <input type="text" id="reqUserPhone" class="form-control" placeholder="+91 98421 55678" required>
            </div>
          </div>

          <div class="form-grid-2">
            <div class="form-group">
              <label class="form-label">தேவைப்படும் சொத்து வகை</label>
              <select id="reqPropertyType" class="form-control">
                <option value="Land">மனை / நிலம் (Land)</option>
                <option value="Farmland">தோட்டம் (Farmland)</option>
                <option value="House">தனி வீடு (House)</option>
                <option value="Shop">கடை / வணிகம் (Shop)</option>
                <option value="Rental">வாடகை வீடு (Rental)</option>
              </select>
            </div>
            <div class="form-group">
              <label class="form-label">தேடும் இடம் (Location) *</label>
              <input type="text" id="reqTargetLocation" class="form-control" placeholder="Tenkasi / Courtallam" required>
            </div>
          </div>

          <div class="form-grid-2">
            <div class="form-group">
              <label class="form-label">குறைந்தபட்ச பட்ஜெட் (₹)</label>
              <input type="number" id="reqBudgetMin" class="form-control" placeholder="1000000">
            </div>
            <div class="form-group">
              <label class="form-label">அதிகபட்ச பட்ஜெட் (₹)</label>
              <input type="number" id="reqBudgetMax" class="form-control" placeholder="2500000">
            </div>
          </div>

          <div class="form-grid-2">
            <div class="form-group">
              <label class="form-label">விரும்பும் அளவு (Preferred Size)</label>
              <input type="text" id="reqPreferredSize" class="form-control" placeholder="5 முதல் 8 சென்ட்">
            </div>
            <div class="form-group">
              <label class="form-label">திசை (Facing)</label>
              <select id="reqFacing" class="form-control">
                <option value="East / North">East / North</option>
                <option value="East">East</option>
                <option value="North">North</option>
                <option value="Any">Any Facing</option>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">தேவை விளக்கம் (Description)</label>
            <textarea id="reqDescription" class="form-control" rows="3" placeholder="DTCP அப்ரூவல் உள்ள மனை தேவை, உடனடி பதிவு..."></textarea>
          </div>
        </div>

        <div class="modal-footer">
          <button type="button" class="btn btn-secondary" onclick="closeModal('requirementModal')">ரத்து</button>
          <button type="submit" class="btn btn-gold">📋 பதிவு செய் (Save Requirement)</button>
        </div>
      </form>
    </div>
  </div>

  <!-- Property Detailed Review Inspector Modal -->
  <div class="modal-backdrop" id="propertyInspectModal">
    <div class="modal-dialog" style="max-width: 740px;">
      <div class="modal-content">
        <div class="modal-header">
          <h3 class="modal-title" id="inspectModalTitle">👁 விளம்பர முழு விவரங்கள் (Property Review)</h3>
          <button class="modal-close" onclick="closeModal('propertyInspectModal')">✕</button>
        </div>
        <div class="modal-body" id="inspectModalBody" style="max-height: 70vh; overflow-y: auto;">
          <!-- Injected via JS -->
        </div>
        <div class="modal-footer" id="inspectModalFooter" style="display: flex; justify-content: flex-end; gap: 10px;">
          <!-- Injected via JS -->
        </div>
      </div>
    </div>
  </div>

  <!-- Modal: Super Admin Direct Message Modal -->
  <div class="modal-backdrop" id="adminDirectMsgModal">
    <div class="modal-dialog" style="max-width: 580px;">
      <form class="modal-content" onsubmit="submitAdminDirectMsg(event)">
        <div class="modal-header">
          <h3 class="modal-title">💬 நேரடி செய்தி அனுப்பு (Direct Message to User)</h3>
          <button type="button" class="modal-close" onclick="closeModal('adminDirectMsgModal')">✕</button>
        </div>
        <div class="modal-body">
          <input type="hidden" id="adminMsgUserId">
          <input type="hidden" id="adminMsgUserPhone">

          <!-- Recipient Preview Box -->
          <div style="background: rgba(59,130,246,0.08); border: 1px solid rgba(59,130,246,0.25); border-radius: 10px; padding: 12px 16px; margin-bottom: 16px;">
            <div style="font-size: 11px; color: var(--text-muted);">பெறுநர் விபரம் (Recipient):</div>
            <div style="font-size: 15px; font-weight: 700; color: #fff;" id="adminMsgRecipientName">-</div>
            <div style="font-size: 13px; color: #60a5fa;" id="adminMsgRecipientPhone">-</div>
          </div>

          <!-- Quick Templates -->
          <div class="form-group" style="margin-bottom: 12px;">
            <label class="form-label" style="font-size: 12px;">⚡ விரைவு டெம்ப்ளேட்டுகள் (Quick Templates):</label>
            <div style="display: flex; flex-wrap: wrap; gap: 6px;">
              <button type="button" class="btn btn-secondary" style="font-size: 11px; padding: 4px 8px;" onclick="applyMsgTemplate('வணக்கம்! நீங்கள் தேடும் சொத்து விபரம் குறித்து உதவ நாங்கள் தயாராக உள்ளோம். ஏதேனும் சந்தேகங்கள் உள்ளதா?')">
                🤝 உதவி வேண்டுமா?
              </button>
              <button type="button" class="btn btn-secondary" style="font-size: 11px; padding: 4px 8px;" onclick="applyMsgTemplate('சிறப்பு சலுகை: உங்கள் சொத்தை தென்காசி கனவுகள் தளத்தில் இன்று இலவசமாக பதிவேற்றுங்கள்!')">
                🎁 இலவச விளம்பர சலுகை
              </button>
              <button type="button" class="btn btn-secondary" style="font-size: 11px; padding: 4px 8px;" onclick="applyMsgTemplate('வணக்கம்! நீங்கள் பார்த்த சொத்தின் உரிமையாளரிடம் பேச விரும்புகிறீர்களா? எங்களை +91 98941 74944 எண்ணில் தொடர்பு கொள்ளவும்.')">
                📞 அழைப்பு உதவி
              </button>
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">செய்தி (Message Content) *</label>
            <textarea id="adminMsgText" class="form-control" rows="4" placeholder="பயனருக்கு அனுப்ப வேண்டிய செய்தியை தட்டச்சு செய்யவும்..." required></textarea>
          </div>
        </div>
        <div class="modal-footer" style="display: flex; justify-content: flex-end; gap: 10px;">
          <button type="button" class="btn btn-secondary" onclick="closeModal('adminDirectMsgModal')">ரத்து</button>
          <button type="submit" class="btn btn-primary" id="btnSendAdminMsg">
            🚀 செய்தி அனுப்பு (Send Message)
          </button>
        </div>
      </form>
    </div>
  </div>

  <!-- Modal: Super Admin Bulk Push Notification / Broadcast Modal -->
  <div class="modal-backdrop" id="adminBroadcastModal">
    <div class="modal-dialog" style="max-width: 600px;">
      <form class="modal-content" onsubmit="submitAdminBroadcast(event)">
        <div class="modal-header">
          <h3 class="modal-title">📢 அனைவருக்கும் பொது அறிவிப்பு (Bulk Push Notification)</h3>
          <button type="button" class="modal-close" onclick="closeModal('adminBroadcastModal')">✕</button>
        </div>
        <div class="modal-body">
          <div style="background: rgba(16,185,129,0.1); border: 1px solid rgba(16,185,129,0.3); border-radius: 10px; padding: 12px 16px; margin-bottom: 16px;">
            <div style="font-size: 13px; font-weight: 700; color: #34d399;">🌐 அனைத்து பயனர்களுக்கும் ஒரே நேரத்தில் சென்றடையும்</div>
            <div style="font-size: 12px; color: var(--text-muted); margin-top: 2px;">
              இந்த அறிவிப்பு செயலில் உள்ள அனைத்து மொபைல் ஆப் மற்றும் இணையதள பயனர்களுக்கும் உடனடி விழிப்பூட்டலாகவும் (In-App Dialog Popup), அறிவிப்புப் பலகையிலும் (Notification Tray) தோன்றும்.
            </div>
          </div>

          <!-- Quick Templates -->
          <div class="form-group" style="margin-bottom: 12px;">
            <label class="form-label" style="font-size: 12px;">⚡ விரைவு டெம்ப்ளேட்டுகள் (Quick Templates):</label>
            <div style="display: flex; flex-wrap: wrap; gap: 6px;">
              <button type="button" class="btn btn-secondary" style="font-size: 11px; padding: 4px 8px;" onclick="applyBroadcastTemplate('🎉 புதிய சொத்துக்கள் சேர்க்கப்பட்டன!', 'தென்காசி, குற்றாலம் மற்றும் சுற்றுவட்டார பகுதிகளில் பிரத்யேக வீட்டுமனைகள் மற்றும் வீடுகள் இன்று விற்பனைக்கு வந்துள்ளன! உடனே பார்வையிடுங்கள்.')">
                🏡 புதிய சொத்துக்கள்
              </button>
              <button type="button" class="btn btn-secondary" style="font-size: 11px; padding: 4px 8px;" onclick="applyBroadcastTemplate('🎁 சிறப்பு இலவச விளம்பர சலுகை!', 'உங்கள் நிலம் அல்லது வீட்டை தென்காசி கனவுகள் தளத்தில் இன்று முற்றிலும் இலவசமாக விளம்பரம் செய்யலாம். இந்த அறிய வாய்ப்பை பயன்படுத்தி உடனே விளம்பரம் பதிவிடுங்கள்!')">
                🎁 இலவச விளம்பரம்
              </button>
              <button type="button" class="btn btn-secondary" style="font-size: 11px; padding: 4px 8px;" onclick="applyBroadcastTemplate('🔔 ஆப் புதுப்பிப்பு & வேகமான வசதிகள்!', 'தென்காசி கனவுகள் மொபைல் ஆப் புதிய மேம்பாடுகளுடன் தயார்! புதிய சொத்துக்களை எளிதாக தேடி உரிமையாளர்களை உடனே தொடர்பு கொள்ளுங்கள்.')">
                ⚡ ஆப் அப்டேட்
              </button>
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">அறிவிப்பு தலைப்பு (Notification Title) *</label>
            <input type="text" id="adminBroadcastTitle" class="form-control" placeholder="எ.கா: 🎉 புதிய வீட்டுமனைகள் விற்பனைக்கு வந்துள்ளன!" required>
          </div>

          <div class="form-group">
            <label class="form-label">அறிவிப்பு செய்தி (Notification Message Content) *</label>
            <textarea id="adminBroadcastMessage" class="form-control" rows="4" placeholder="பயனர்களுக்கு அனுப்ப வேண்டிய அறிவிப்பு செய்தியை தட்டச்சு செய்யவும்..." required></textarea>
          </div>
        </div>
        <div class="modal-footer" style="display: flex; justify-content: flex-end; gap: 10px;">
          <button type="button" class="btn btn-secondary" onclick="closeModal('adminBroadcastModal')">ரத்து</button>
          <button type="submit" class="btn btn-gold" id="btnSendAdminBroadcast">
            📢 அனைவருக்கும் அனுப்புக (Broadcast to All)
          </button>
        </div>
      </form>
    </div>
  </div>

  <!-- ==================== MODAL: APK DOWNLOAD MODAL ==================== -->
  <div class="modal" id="apkDownloadModal" style="display:none; position:fixed; top:0; left:0; right:0; bottom:0; background:rgba(0,0,0,0.75); z-index:9999; align-items:center; justify-content:center; backdrop-filter: blur(4px);">
    <div style="background:#0f172a; border-radius:16px; max-width:680px; width:92%; max-height:90vh; overflow-y:auto; padding:26px; border:1px solid rgba(255,255,255,0.15); box-shadow: 0 20px 40px rgba(0,0,0,0.6);">
      <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:18px; padding-bottom:14px; border-bottom:1px solid rgba(255,255,255,0.1);">
        <div style="display:flex; align-items:center; gap:12px;">
          <img src="../assets/images/app_logo.png" style="width:38px; height:38px; border-radius:50%; object-fit:contain;" alt="SamWin Logo">
          <div>
            <h3 style="color:#fff; font-size:18px; margin:0; font-weight:800;">📲 Ads Android செயலிகள் பதிவிறக்கம்</h3>
            <div style="color:var(--text-muted); font-size:12px; margin-top:2px;">அதிகாரப்பூர்வ நேரலை செயலிகள் (Official Release APKs)</div>
          </div>
        </div>
        <button class="btn btn-secondary" onclick="closeApkDownloadModal()" style="padding:6px 12px; font-size:13px;">✕ மூடு</button>
      </div>

      <!-- App 1: Client / User App -->
      <div style="background: rgba(16, 185, 129, 0.08); border: 1.5px solid rgba(16, 185, 129, 0.35); border-radius: 12px; padding: 18px; margin-bottom: 16px;">
        <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 12px; flex-wrap: wrap;">
          <div style="display: flex; gap: 12px;">
            <div style="width: 44px; height: 44px; border-radius: 10px; background: rgba(16, 185, 129, 0.25); display: flex; align-items: center; justify-content: center; font-size: 22px;">📱</div>
            <div>
              <div style="font-size: 16px; font-weight: 800; color: #6ee7b7; display: flex; align-items: center; gap: 8px;">
                <span>Ads - வாடிக்கையாளர் செயலி (User App)</span>
                <span class="badge badge-emerald" style="font-size: 10px;">v1.0.0</span>
              </div>
              <div style="font-size: 12.5px; color: #cbd5e1; margin-top: 3px;">
                பொதுமக்கள், வாங்குபவர்கள் மற்றும் விற்பனையாளர்கள் பயன்படுத்தும் முக்கிய ஆண்ட்ராய்டு செயலி.
              </div>
              <div style="font-size: 11px; color: var(--text-muted); margin-top: 4px; font-family: monospace;">
                ஃபைல்: Ads.apk | பேக்கேஜ்: com.antigravity.realestate.real_estate_app
              </div>
            </div>
          </div>
          <div style="display: flex; gap: 8px;">
            <a href="/Ads.apk" download="SamWin.apk" class="btn btn-emerald" style="padding: 9px 16px; font-size: 13px; font-weight: 800; text-decoration: none; display: flex; align-items: center; gap: 6px;">
              <span>⬇️ பதிவிறக்கு (Download)</span>
            </a>
            <button type="button" class="btn btn-secondary" onclick="copyApkDownloadLink('client')" style="padding: 9px 12px; font-size: 12px;" title="இணைப்பை நகலெடு">
              📋 லிங்க் காப்பி
            </button>
          </div>
        </div>
      </div>

      <!-- App 2: Super Admin App -->
      <div style="background: rgba(245, 158, 11, 0.08); border: 1.5px solid rgba(245, 158, 11, 0.35); border-radius: 12px; padding: 18px; margin-bottom: 18px;">
        <div style="display: flex; justify-content: space-between; align-items: flex-start; gap: 12px; flex-wrap: wrap;">
          <div style="display: flex; gap: 12px;">
            <div style="width: 44px; height: 44px; border-radius: 10px; background: rgba(245, 158, 11, 0.25); display: flex; align-items: center; justify-content: center; font-size: 22px;">🛡️</div>
            <div>
              <div style="font-size: 16px; font-weight: 800; color: #fbbf24; display: flex; align-items: center; gap: 8px;">
                <span>Ads Admin - சூப்பர் அட்மின் செயலி (Admin App)</span>
                <span class="badge badge-gold" style="font-size: 10px;">v1.0.0</span>
              </div>
              <div style="font-size: 12.5px; color: #cbd5e1; margin-top: 3px;">
                அட்மின்கள் மொபைல் மூலமாகவே விளம்பரங்களை அங்கீகரிக்க, எடிட் செய்ய மற்றும் நிர்வகிக்க பிரத்யேக ஆப்.
              </div>
              <div style="font-size: 11px; color: var(--text-muted); margin-top: 4px; font-family: monospace;">
                ஃபைல்: AdsAdmin.apk | பேக்கேஜ்: com.antigravity.realestate.admin
              </div>
            </div>
          </div>
          <div style="display: flex; gap: 8px;">
            <a href="/AdsAdmin.apk" download="SamWinAdmin.apk" class="btn btn-gold" style="padding: 9px 16px; font-size: 13px; font-weight: 800; text-decoration: none; display: flex; align-items: center; gap: 6px;">
              <span>⬇️ பதிவிறக்கு (Download)</span>
            </a>
            <button type="button" class="btn btn-secondary" onclick="copyApkDownloadLink('admin')" style="padding: 9px 12px; font-size: 12px;" title="இணைப்பை நகலெடு">
              📋 லிங்க் காப்பி
            </button>
          </div>
        </div>
      </div>

      <!-- Installation Guide Note -->
      <div style="background: rgba(59, 130, 246, 0.08); border: 1px dashed rgba(59, 130, 246, 0.35); border-radius: 10px; padding: 14px 16px;">
        <div style="font-size: 13px; font-weight: 700; color: #93c5fd; margin-bottom: 4px;">💡 நிறுவும் முறை (Installation Instructions):</div>
        <ol style="margin: 0; padding-left: 20px; font-size: 12px; color: #cbd5e1; line-height: 1.6;">
          <li>மேலே உள்ள பொத்தானை கிளிக் செய்து APK ஃபைலை உங்கள் போனில் பதிவிறக்குங்கள்.</li>
          <li>பதிவிறக்கம் முடிந்ததும் ஃபைலை திறக்கவும். பாதுகாப்பு எச்சரிக்கை வந்தால் <strong>"Settings -> Allow from this source"</strong> (அறியப்படாத செயலிகளை அனுமதிக்கவும்) என்பதை ஆன் செய்யவும்.</li>
          <li><strong>"Install"</strong> கொடுத்து உடனே செயலியை பயன்படுத்தத் தொடங்கலாம்!</li>
        </ol>
      </div>
    </div>
  </div>

  <!-- Floating Action Button for Adding Property (Always Visible on Screen) -->
  <button type="button" class="admin-fab-btn" onclick="openAddPropertyModal()" id="adminFabAddProperty" title="புதிய விளம்பரம் சேர்க்க (Add Property)">
    <span style="font-size: 18px;">➕</span>
    <span>புதிய விளம்பரம் சேர் (Post Ad)</span>
  </button>

  <!-- Scripts -->
  <script src="js/admin.js?v=<?= $v ?>"></script>
</body>
</html>
