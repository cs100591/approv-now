# Translation Files Analysis Report

## Executive Summary

**Analysis Date:** February 28, 2026  
**English Template:** app_en.arb (361 unique translation keys)  
**Languages Analyzed:** 8

---

## Overview by Language

| Language | File | Total Keys | Missing | Completion | Priority |
|----------|------|------------|---------|------------|----------|
| **Spanish** | app_es.arb | 360 | 1 | 99.7% | 🔵 Low |
| **Indonesian** | app_id.arb | 361 | 0 | 100% | ✅ Complete |
| **Japanese** | app_ja.arb | 361 | 0 | 100% | ✅ Complete |
| **Korean** | app_ko.arb | 361 | 0 | 100% | ✅ Complete |
| **Malay** | app_ms.arb | 329 | 32 | 91.1% | 🟡 Medium |
| **Thai** | app_th.arb | 329 | 32 | 91.1% | 🟡 Medium |
| **Vietnamese** | app_vi.arb | 330 | 31 | 91.4% | 🟡 Medium |
| **Chinese** | app_zh.arb | 361 | 0 | 100% | ✅ Complete |

---

## Detailed Missing Keys Analysis

### 1. Spanish (app_es.arb) - 1 Missing Key
**Status:** Near Complete - Quick Fix Needed

**Missing:**
- `requests` → "Requests"

---

### 2. Indonesian (app_id.arb) - 0 Missing Keys
**Status:** ✅ Complete

All 361 keys present and translated.

---

### 3. Japanese (app_ja.arb) - 0 Missing Keys
**Status:** ✅ Complete

All 361 keys present and translated.

---

### 4. Korean (app_ko.arb) - 0 Missing Keys
**Status:** ✅ Complete

All 361 keys present and translated.

---

### 5. Malay (app_ms.arb) - 32 Missing Keys
**Status:** Incomplete - Missing Notification & Profile Features

**Missing Keys (32 total):**

**Notification Settings (13 keys):**
1. `notificationSettings` → "Notification Settings"
2. `notificationSettingsInfo` → "You can view all your notifications in the Notifications tab."
3. `notificationTypes` → "Notification Types"
4. `pushNotifications` → "Push Notifications"
5. `pushNotificationsSubtitle` → "Receive push notifications on your device"
6. `emailNotifications` → "Email Notifications"
7. `emailNotificationsSubtitle` → "Receive email notifications"
8. `emailNotificationsProOnly` → "Upgrade to Pro to enable email notifications"
9. `requestUpdates` → "Request Updates"
10. `requestUpdatesSubtitle` → "New requests, approvals, and rejections"
11. `invitationUpdates` → "Workspace Invitations"
12. `invitationUpdatesSubtitle` → "When you are invited to a workspace"
13. `mentionUpdates` → "Mentions"
14. `mentionUpdatesSubtitle` → "When someone mentions you in comments"

**Profile & Account (4 keys):**
15. `editProfile` → "Edit Profile"
16. `profileUpdated` → "Profile updated successfully"
17. `biometricLoginEnabled` → "Biometric login enabled"
18. `biometricLoginDisabled` → "Biometric login disabled"

**Workspace Management (4 keys):**
19. `deleteWorkspace` → "Delete Workspace"
20. `workspaceDeleted` → "Workspace deleted successfully"
21. `failedToDeleteWorkspace` → "Failed to delete workspace"
22. `workspaceCreated` → "Workspace created successfully"
23. `joinedWorkspace` → "Joined {workspaceName} successfully!"

**Pro Features (4 keys):**
24. `pro` → "Pro"
25. `proFeature` → "Pro Feature"
26. `proFeatureMessage` → "Email notifications are available for Pro users only. Upgrade to Pro to enable this feature."
27. `upgradeToPro` → "Upgrade to Pro"

**General UI (5 keys):**
28. `logoutConfirmation` → "Are you sure you want to log out?"
29. `permissionDenied` → "Permission Denied"
30. `ok` → "OK"
31. `settingsSaved` → "Settings saved"
32. `requests` → "Requests"

---

### 6. Thai (app_th.arb) - 32 Missing Keys
**Status:** Incomplete - Missing Notification & Profile Features

**Missing Keys:** Same as Malay (32 keys)
- All Notification Settings keys (14)
- Profile & Account keys (4)
- Workspace Management keys (5)
- Pro Features keys (4)
- General UI keys (5)

---

### 7. Vietnamese (app_vi.arb) - 31 Missing Keys
**Status:** Incomplete - Missing Notification & Profile Features

**Missing Keys:** Same as Malay minus `requests` (31 keys)
- All Notification Settings keys (14)
- Profile & Account keys (4)
- Workspace Management keys (5)
- Pro Features keys (4)
- General UI keys (4) - missing `requests`

---

### 8. Chinese (app_zh.arb) - 0 Missing Keys
**Status:** ✅ Complete

All 361 keys present and translated.

---

## Key Findings

### ✅ Complete Translations (4 languages)
- **Indonesian** - 100% complete
- **Japanese** - 100% complete
- **Korean** - 100% complete
- **Chinese** - 100% complete

### 🟡 Incomplete Translations (3 languages)
- **Malay** - Missing 32 keys (8.9% missing)
- **Thai** - Missing 32 keys (8.9% missing)
- **Vietnamese** - Missing 31 keys (8.6% missing)

**Common Missing Categories:**
1. Notification Settings (14 keys) - Missing from all 3
2. Profile & Biometric features (4 keys)
3. Workspace management features (5 keys)
4. Pro subscription features (4 keys)

### 🔵 Quick Fix Needed (1 language)
- **Spanish** - Missing only 1 key: `requests`

---

## Recommendations

### Priority 1: Quick Wins (Spanish)
- Add the single missing `requests` key to Spanish
- Estimated time: 5 minutes

### Priority 2: Major Updates (Malay, Thai, Vietnamese)
- Focus on the 32/31 missing keys
- Priority order:
  1. **Notification Settings** (14 keys) - Core feature
  2. **Pro Features** (4 keys) - Revenue related
  3. **Profile & Biometric** (4 keys) - User experience
  4. **Workspace Management** (5 keys) - Admin features
  5. **General UI** (5 keys) - Polish

### Priority 3: English Template Cleanup
The English template has **33 duplicate keys** that appear multiple times:
- `notifications`
- `markAllRead`
- `failedToUpdateProfile`
- `openingRequest`
- `settingUpWorkspace`
- `cancel`
- `faceId`
- `notLoggedIn`
- `language`
- `changeRole`
- `selectWorkspaceFirst`
- `accept`
- `fingerprint`
- `switchedToWorkspace`
- `removeMember`
- `biometricLogin`
- `unableToDeclineInvitation`
- `failedToDeclineInvitation`
- `invitationDeclined`
- `invitationAccepted`
- `invitationDismissed`
- `loadingWorkspace`
- `decline`
- `unableToAcceptInvitation`
- `selectLanguage`
- `createNewWorkspace`
- `noNotifications`
- `allCaughtUp`
- `defaultWorkspaceCreated`
- `noWorkspaceSelected`
- `notificationDismissed`
- `failedToAcceptInvitation`
- `logoutConfirmation`

**Impact:** These duplicates don't break functionality but make the file unnecessarily large.

---

## Empty/Placeholder Values

**No empty strings or placeholder values detected** in any of the language files (e.g., "", "TODO", "TRANSLATE", "XXX").

All existing translations appear to be actual translated content.

---

## Action Items

1. **Immediate:** Add `requests` key to Spanish translation
2. **This Week:** Translate missing notification settings for Malay, Thai, Vietnamese
3. **Next Sprint:** Complete remaining 18 keys for Malay/Thai/Vietnamese
4. **Technical Debt:** Clean up duplicate keys in English template

---

## Files Summary

```
lib/l10n/
├── app_en.arb      361 unique keys (33 duplicates to clean)
├── app_es.arb      360 keys (1 missing: requests)
├── app_id.arb      361 keys ✅ Complete
├── app_ja.arb      361 keys ✅ Complete
├── app_ko.arb      361 keys ✅ Complete
├── app_ms.arb      329 keys (32 missing)
├── app_th.arb      329 keys (32 missing)
├── app_vi.arb      330 keys (31 missing)
└── app_zh.arb      361 keys ✅ Complete
```

---

*Report generated by ARB Translation Analyzer*