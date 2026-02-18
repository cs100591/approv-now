# Approve Now - Agent Development Guide

**Project:** Approve Now  
**Type:** Mobile-first deterministic approval engine with multi-workspace architecture  
**Platform:** Flutter (iOS/Android) with future web compatibility  

---

## Quick Start

1. Read `feature_list.json` for incomplete features
2. Check `claude-progress.txt` for recent work and context
3. Select the highest priority incomplete feature
4. Implement following the modular architecture below
5. Write tests for the module/feature
6. Update progress log and commit
7. Mark feature as complete in `feature_list.json`

---

## System Architecture Principle

**MODULARITY IS MANDATORY**

Every core feature MUST exist as an independent module.

### Module Requirements
Each module MUST:
- Contain its own models
- Contain its own repository
- Contain its own service layer
- Contain its own state management
- Expose only controlled public interfaces
- **NOT** directly depend on other feature modules

### Cross-Module Communication
Cross-feature communication MUST occur via:
- Core interfaces
- Repository abstraction
- Events

**NO direct feature-to-feature imports allowed.**

---

## Folder Structure (STRICT)

```
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── routing/
│   ├── guards/
│   └── shared_interfaces/
└── modules/
    ├── auth/
    │   ├── auth_models.dart
    │   ├── auth_repository.dart
    │   ├── auth_service.dart
    │   ├── auth_provider.dart
    │   └── auth_ui/
    ├── workspace/
    │   ├── workspace_models.dart
    │   ├── workspace_repository.dart
    │   ├── workspace_service.dart
    │   ├── workspace_provider.dart
    │   └── workspace_ui/
    ├── template/
    │   ├── template_models.dart
    │   ├── template_repository.dart
    │   ├── template_service.dart
    │   ├── template_provider.dart
    │   └── template_ui/
    ├── request/
    │   ├── request_models.dart
    │   ├── request_repository.dart
    │   ├── request_service.dart
    │   ├── request_provider.dart
    │   └── request_ui/
    ├── approval_engine/
    │   ├── approval_engine_service.dart
    │   └── approval_engine_provider.dart
    ├── revision/
    │   ├── revision_service.dart
    │   └── revision_provider.dart
    ├── export/
    │   ├── pdf_service.dart
    │   └── export_provider.dart
    ├── verification/
    │   ├── hash_service.dart
    │   └── verification_provider.dart
    ├── subscription/
    │   ├── subscription_service.dart
    │   ├── subscription_repository.dart
    │   └── subscription_provider.dart
    ├── notification/
    │   ├── notification_service.dart
    │   ├── push_service.dart
    │   └── notification_provider.dart
    ├── analytics/
    │   └── analytics_service.dart
    └── plan_enforcement/
        └── plan_guard_service.dart
```

**NO shared monolithic service file allowed.**

---

## Mandatory Modules (14 Total)

### 1️⃣ Auth Module
**Responsible ONLY for:**
- Login
- Logout
- Current user state

**Must NOT:**
- Contain workspace logic
- Contain subscription logic

### 2️⃣ Workspace Module
**Responsible ONLY for:**
- Create workspace
- Update header info
- Manage workspace metadata
- Switch active workspace

**Must NOT:**
- Handle templates
- Handle approvals

### 3️⃣ Template Module
**Responsible ONLY for:**
- Create template
- Add fields
- Reorder fields
- Assign approval steps
- Validate template rules

**Must NOT:**
- Execute approval
- Handle revision logic

### 4️⃣ Request Module
**Responsible ONLY for:**
- Submit request
- Store field snapshots
- Fetch request data

**Must NOT:**
- Execute approval sequence
- Handle reset logic

### 5️⃣ Approval Engine Module
**Responsible ONLY for:**
- Sequential approval
- Move to next level
- Finalize approval
- Trigger notifications

**No UI logic allowed inside.**

### 6️⃣ Revision Module
**Responsible ONLY for:**
- Increment revision
- Reset currentLevel
- Preserve old approvals
- Mark obsolete approvals
- Trigger restart notifications

### 7️⃣ Export Module (PDF)
**Responsible ONLY for:**
- Generate PDF
- Inject workspace header
- Insert verification hash
- Apply watermark rules

**No Firestore logic inside.**

### 8️⃣ Verification Module (Hash)
**Responsible ONLY for:**
- Generate SHA-256 hash
- Validate hash
- Return verification result

**Hash Generation Formula:**
```
workspaceId
requestId
revisionNumber
submittedBy
approvalActions
field values
```

### 9️⃣ Subscription Module
**Responsible ONLY for:**
- Fetch plan
- Validate entitlement
- Enforce limits
- Connect with RevenueCat

**Plan enforcement must not be inside UI.**

### 🔟 Notification Module
**Responsible ONLY for:**
- Push via FCM
- Trigger on:
  - New request
  - Approval
  - Rejection
  - Revision restart

### 11️⃣ Analytics Module
**Responsible ONLY for logging:**
- `workspace_created`
- `template_created`
- `request_submitted`
- `request_approved`
- `request_restarted`

**Must not contain business logic.**

### 12️⃣ Plan Enforcement Module
**Responsible ONLY for:**
- Template limit
- Approval level limit
- Workspace limit
- Header availability
- Watermark rule

**Must run BEFORE action execution.**

### 13️⃣ Workspace Switch Module
**Responsible ONLY for:**
- Track active workspace
- Provide red dot count
- Count only pending approvals for current user
- Optimize: Not re-query per workspace

### 14️⃣ Permission Guard Module
**Responsible ONLY for:**
- Validate user permissions
- Gate access to features based on roles
- Enforce workspace-level permissions

---

## Cross-Module Communication Pattern

**Example Flow:**
When request is edited:

```
Request Module
    ↓ calls
Revision Module
    ↓ calls
Approval Engine Module
    ↓ calls
Notification Module
    ↓ calls
Analytics Module
```

Each module must remain independent. No circular dependencies.

---

## PDF System Rules

### Plan-Based Features

**Free Plan:**
- Watermark on all exports

**Starter Plan:**
- No watermark

**Pro Plan:**
- Custom header
  - Logo
  - Company name
  - Address
  - Footer text

**Constraint:** No layout editing allowed.

---

## Verification Rules

- Every revision must generate a new hash
- Old hash must remain valid
- Verification must return:
  - `valid`
  - `superseded`
  - `invalid`

---

## Security Rules

- All Firestore reads must filter by `workspaceId`
- No cross-workspace data leak
- Approval execution must validate approver identity
- Plan enforcement must run before template creation

---

## Future Web Compatibility

- All business logic must be platform-agnostic
- No UI-dependent logic
- All execution rules must live in service layer

---

## Design Philosophy

Approve Now must feel:
- Neutral
- Professional
- Minimal
- Reliable
- Not over-engineered

---

## Development Checklist

Before implementing any feature:

- [ ] Identify which module owns this feature
- [ ] Verify no direct imports from other feature modules
- [ ] Check plan enforcement requirements
- [ ] Ensure proper error handling
- [ ] Add analytics logging if applicable
- [ ] Write unit tests
- [ ] Write widget tests
- [ ] Update feature_list.json
- [ ] Update claude-progress.txt
- [ ] Commit with descriptive message

---

## Testing Requirements

Every module must have:
- Unit tests for service layer
- Unit tests for repository layer
- Widget tests for UI components
- Integration tests for critical flows

---

## Code Review Guidelines

### Red Flags (Must Fix)
- Direct imports between feature modules
- Business logic in UI layer
- Missing workspaceId filters on Firestore queries
- Plan enforcement in UI code
- Circular dependencies

### Yellow Flags (Should Address)
- Code duplication across modules
- Missing error handling
- No tests for new features
- Inconsistent naming conventions

---

## Session Workflow

1. **Start Session:**
   ```bash
   pwd
   git log --oneline -20
   cat claude-progress.txt
   cat feature_list.json
   ```

2. **Select Feature:**
   - Choose highest priority incomplete feature
   - Read module requirements above
   - Plan implementation approach

3. **Implement:**
   - Follow modular architecture
   - Write tests as you go
   - No direct module-to-module imports

4. **Verify:**
   - Run `flutter test`
   - Test on device/emulator
   - Verify no compilation errors

5. **Commit:**
   ```bash
   git add .
   git commit -m "feat(module-name): descriptive change
   
   - Implemented X
   - Added Y functionality
   - Tests passing"
   ```

6. **Update Progress:**
   - Update `claude-progress.txt`
   - Mark feature complete in `feature_list.json`

---

## Dependencies

Essential packages (add to `pubspec.yaml`):

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_bloc: ^8.1.3
  provider: ^6.1.1
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_messaging: ^14.7.10
  firebase_analytics: ^10.8.0
  
  # Local Storage
  shared_preferences: ^2.2.2
  
  # PDF Generation
  pdf: ^3.10.7
  printing: ^5.11.1
  
  # Subscriptions
  purchases_flutter: ^6.1.0
  
  # Crypto (Hashing)
  crypto: ^3.0.3
  
  # HTTP
  dio: ^5.4.0
  http: ^1.1.0
  
  # UI
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  fluttertoast: ^8.2.4
  shimmer: ^3.0.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.8
```

---

## Getting Help

- Check `feature_list.json` for feature requirements
- Review `claude-progress.txt` for recent context
- Follow module boundaries strictly
- When in doubt, ask for clarification on module boundaries

---

**Last Updated:** 2026-02-19  
**Version:** 1.0
