// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get language => '언어';

  @override
  String get selectLanguage => '언어 선택';

  @override
  String get dashboard => '대시보드';

  @override
  String get workspaces => '워크스페이스';

  @override
  String get profile => '프로필';

  @override
  String get account => '계정';

  @override
  String get cancel => '취소';

  @override
  String get save => '저장';

  @override
  String get delete => '삭제';

  @override
  String get create => '생성';

  @override
  String get submit => '제출';

  @override
  String get edit => '편집';

  @override
  String get add => '추가';

  @override
  String get remove => '제거';

  @override
  String get confirm => '확인';

  @override
  String get back => '뒤로';

  @override
  String get next => '다음';

  @override
  String get done => '완료';

  @override
  String get close => '닫기';

  @override
  String get retry => '재시도';

  @override
  String get loading => '로딩 중...';

  @override
  String get error => '오류';

  @override
  String get success => '성공';

  @override
  String get warning => '경고';

  @override
  String get info => '정보';

  @override
  String get yes => '예';

  @override
  String get no => '아니요';

  @override
  String get or => '또는';

  @override
  String get and => '및';

  @override
  String get email => '이메일';

  @override
  String get password => '비밀번호';

  @override
  String get name => '이름';

  @override
  String get description => '설명';

  @override
  String get settings => '설정';

  @override
  String get notifications => '알림';

  @override
  String get logout => '로그아웃';

  @override
  String get login => '로그인';

  @override
  String get register => '회원가입';

  @override
  String get signIn => '로그인';

  @override
  String get signOut => '로그아웃';

  @override
  String get createAccount => '계정 생성';

  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get resetPassword => '비밀번호 재설정';

  @override
  String get changePassword => '비밀번호 변경';

  @override
  String get currentPassword => '현재 비밀번호';

  @override
  String get newPassword => '새 비밀번호';

  @override
  String get confirmPassword => '비밀번호 확인';

  @override
  String get fullName => '전체 이름';

  @override
  String get displayName => '표시 이름';

  @override
  String get notLoggedIn => '로그인되지 않음';

  @override
  String get noName => '이름 없음';

  @override
  String get signInToYourAccount => '계정에 로그인하세요';

  @override
  String get signUpToGetStarted => 'Approve Now를 시작하려면 가입하세요';

  @override
  String get enterYourEmail => '이메일을 입력하세요';

  @override
  String get enterYourPassword => '비밀번호를 입력하세요';

  @override
  String get enterYourFullName => '전체 이름을 입력하세요';

  @override
  String get yourName => '귀하의 이름';

  @override
  String get emailIsRequired => '이메일은 필수입니다';

  @override
  String get pleaseEnterValidEmail => '유효한 이메일을 입력하세요';

  @override
  String get passwordIsRequired => '비밀번호는 필수입니다';

  @override
  String get passwordMinLength => '비밀번호는 최소 6자 이상이어야 합니다';

  @override
  String get nameIsRequired => '이름은 필수입니다';

  @override
  String get pleaseConfirmYourPassword => '비밀번호를 확인해주세요';

  @override
  String get passwordsDoNotMatch => '비밀번호가 일치하지 않습니다';

  @override
  String get accountCreatedSuccessfully => '계정이 성공적으로 생성되었습니다!';

  @override
  String get registrationTimedOut => '등록 시간이 초과되었습니다. 다시 시도해주세요.';

  @override
  String get enableBiometricLogin => '생체 인식 로그인을 활성화하시겠습니까?';

  @override
  String get biometricLoginDescription =>
      '빠른 로그인을 위해 지문 또는 Face ID를 활성화하시겠습니까?';

  @override
  String get notNow => '나중에';

  @override
  String get enable => '활성화';

  @override
  String get biometricLogin => '생체 인식 로그인';

  @override
  String get useBiometric => '생체 인식 사용';

  @override
  String get faceId => 'Face ID';

  @override
  String get fingerprint => '지문';

  @override
  String get biometricEnabled => '생체 인식 로그인이 활성화되었습니다';

  @override
  String get biometricDisabled => '생체 인식 로그인이 비활성화되었습니다';

  @override
  String get dontHaveAccount => '계정이 없으신가요?';

  @override
  String get alreadyHaveAccount => '이미 계정이 있으신가요?';

  @override
  String get logOutConfirmation => '로그아웃하시겠습니까?';

  @override
  String get logOut => '로그아웃';

  @override
  String get profileUpdatedSuccessfully => '프로필이 성공적으로 업데이트되었습니다';

  @override
  String failedToUpdateProfile(Object error) {
    return '프로필 업데이트 실패: $error';
  }

  @override
  String get settingsComingSoon => '설정 기능이 곧 제공됩니다';

  @override
  String get comingSoon => '곧 제공';

  @override
  String version(Object version) {
    return 'Approve Now v$version';
  }

  @override
  String copyright(Object year) {
    return '© $year Approve Now. All rights reserved.';
  }

  @override
  String get workspace => '워크스페이스';

  @override
  String get manageWorkspaces => '워크스페이스 관리';

  @override
  String get joinWorkspace => '워크스페이스 참여';

  @override
  String get createWorkspace => '워크스페이스 생성';

  @override
  String get switchWorkspace => '워크스페이스 전환';

  @override
  String get workspaceName => '워크스페이스 이름';

  @override
  String get workspaceDescription => '설명 (선택사항)';

  @override
  String get myCompany => '내 회사';

  @override
  String get briefDescription => '간단한 설명';

  @override
  String get noWorkspaces => '워크스페이스 없음';

  @override
  String get createFirstWorkspace => '시작하려면 첫 번째 워크스페이스를 생성하세요';

  @override
  String get settingUpWorkspace => '워크스페이스 설정 중...';

  @override
  String get loadingWorkspace => '워크스페이스 로딩 중...';

  @override
  String get workspaceLimitReached => '워크스페이스 한도 도달';

  @override
  String get workspaceLimitMessage => '더 많은 워크스페이스를 생성하려면 요금제를 업그레이드하세요.';

  @override
  String get workspaceLimitReachedMessage =>
      '귀하의 요금제에서 허용하는 최대 워크스페이스 수에 도달했습니다.';

  @override
  String get defaultWorkspaceCreated => '환영합니다! 기본 워크스페이스가 성공적으로 생성되었습니다.';

  @override
  String get failedToCreateWorkspace => '워크스페이스 생성에 실패했습니다. 다시 시도해주세요.';

  @override
  String get noWorkspaceFound => '워크스페이스를 찾을 수 없음';

  @override
  String get noWorkspaceFoundMessage => '현재 워크스페이스를 생성할 수 없습니다.';

  @override
  String get createFirstWorkspaceButton => '워크스페이스 생성';

  @override
  String get workspaceCreatedSuccessfully => '워크스페이스가 성공적으로 생성되었습니다';

  @override
  String switchedToWorkspace(Object workspaceName) {
    return '$workspaceName(으)로 전환되었습니다';
  }

  @override
  String get active => '활성';

  @override
  String get createNewWorkspace => '새 워크스페이스 생성';

  @override
  String get teamMembers => '팀원';

  @override
  String get inviteNewMember => '새 멤버 초대';

  @override
  String get noWorkspaceSelected => '선택된 워크스페이스 없음';

  @override
  String get selectWorkspaceFirst => '먼저 워크스페이스를 선택하세요';

  @override
  String get pendingInvitation => '대기 중인 초대';

  @override
  String get changeRole => '역할 변경';

  @override
  String get removeMember => '멤버 제거';

  @override
  String removeMemberConfirmation(Object memberEmail) {
    return '$memberEmail을(를) 제거하시겠습니까?';
  }

  @override
  String get cannotRemovePending => '여기서는 대기 중인 초대를 제거할 수 없습니다';

  @override
  String memberRemoved(Object memberEmail) {
    return '$memberEmail이(가) 제거되었습니다';
  }

  @override
  String changeRoleForMember(Object memberEmail) {
    return '$memberEmail의 역할 변경';
  }

  @override
  String get generateInviteCode => '초대 코드 생성';

  @override
  String get generateInviteCodeDescription => '팀원이 참여할 수 있는 6자리 초대 코드를 생성합니다.';

  @override
  String get codeDetails => '코드 세부정보';

  @override
  String get codeDetailsDescription =>
      '• 24시간 유효\n• 여러 사람이 사용 가능\n• 새 멤버는 뷰어 역할로 참여';

  @override
  String get generateCode => '코드 생성';

  @override
  String get inviteCodeGenerated => '초대 코드가 생성되었습니다';

  @override
  String expires(Object date) {
    return '만료일: $date';
  }

  @override
  String get shareCodeDescription => '팀원과 이 초대 코드를 공유하여 워크스페이스에 초대하세요.';

  @override
  String get copyCode => '코드 복사';

  @override
  String get codeCopiedToClipboard => '코드가 클립보드에 복사되었습니다';

  @override
  String get teamMemberLimitReached => '팀원 한도 도달';

  @override
  String get teamMemberLimitMessage => '귀하의 요금제에서 허용하는 최대 팀원 수에 도달했습니다.';

  @override
  String get emailNotificationsDisabled =>
      '이메일 알림이 현재 비활성화되어 있습니다. 팀원은 앱에서 초대를 확인해야 합니다.';

  @override
  String get templates => '템플릿';

  @override
  String get template => '템플릿';

  @override
  String get newTemplate => '새 템플릿';

  @override
  String get createTemplate => '템플릿 생성';

  @override
  String get noTemplates => '템플릿 없음';

  @override
  String get createFirstTemplate => '시작하려면 첫 번째 템플릿을 생성하세요';

  @override
  String get contactAdminToCreateTemplate => '템플릿을 생성하려면 워크스페이스 관리자에게 문의하세요';

  @override
  String get templateFields => '양식 필드';

  @override
  String get templateApprovalSteps => '승인 단계';

  @override
  String get templateInformation => '템플릿 정보';

  @override
  String get basicDetails => '이 템플릿의 기본 세부정보';

  @override
  String get templateName => '템플릿 이름';

  @override
  String get templateDescription => '설명';

  @override
  String get defineFormFields => '사용자가 작성할 필드를 정의';

  @override
  String get noFieldsYet => '아직 필드가 없습니다';

  @override
  String get addFirstField => '+를 탭하여 첫 번째 필드를 추가하거나 AI로 생성하세요';

  @override
  String get whoNeedsToApprove => '이 요청을 승인해야 하는 사람은?';

  @override
  String get noApprovalSteps => '승인 단계 없음';

  @override
  String get addAtLeastOneApprover => '최소 한 명의 승인자를 추가하세요';

  @override
  String get text => '텍스트';

  @override
  String get multiline => '여러 줄';

  @override
  String get number => '숫자';

  @override
  String get currency => '통화';

  @override
  String get date => '날짜';

  @override
  String get dropdown => '드롭다운';

  @override
  String get checkbox => '체크박스';

  @override
  String get file => '파일';

  @override
  String get required => '필수';

  @override
  String get moveUp => '위로 이동';

  @override
  String get moveDown => '아래로 이동';

  @override
  String get onlyOwnerCanCreateTemplate =>
      '템플릿을 생성할 수 있는 것은 워크스페이스 소유자 또는 관리자뿐입니다';

  @override
  String get generationFailed => '생성 실패';

  @override
  String aiConfigApplied(Object scenario) {
    return 'AI 구성 적용됨: $scenario';
  }

  @override
  String get addField => '필드 추가';

  @override
  String get editField => '필드 편집';

  @override
  String get fieldLabel => '필드 레이블';

  @override
  String get fieldType => '필드 유형';

  @override
  String get placeholder => '플레이스홀더 (선택사항)';

  @override
  String get hintText => '이 필드의 힌트 텍스트';

  @override
  String get dropdownOptions => '드롭다운 옵션';

  @override
  String get addOption => '옵션 추가';

  @override
  String get checkedByDefault => '기본적으로 선택됨';

  @override
  String get requiredField => '필수 필드';

  @override
  String get usersMustFill => '사용자는 이 필드를 작성해야 합니다';

  @override
  String get saveChanges => '변경사항 저장';

  @override
  String get pleaseEnterTemplateName => '템플릿 이름을 입력하세요';

  @override
  String get pleaseEnterFieldLabel => '필드 레이블을 입력하세요';

  @override
  String get pleaseAddDropdownOption => '최소 하나의 드롭다운 옵션을 추가하세요';

  @override
  String get pleaseAddOneField => '최소 하나의 필드를 추가하세요';

  @override
  String get templateCreatedSuccessfully => '템플릿이 성공적으로 생성되었습니다';

  @override
  String get failedToCreateTemplate => '템플릿 생성에 실패했습니다. 다시 시도해주세요.';

  @override
  String approvalStep(Object level) {
    return '승인 단계 $level';
  }

  @override
  String get addApproversForStep => '이 단계의 승인자 추가';

  @override
  String get stepName => '단계 이름';

  @override
  String get noWorkspaceMembers => '사용 가능한 워크스페이스 멤버가 없습니다. 먼저 멤버를 추가하세요.';

  @override
  String get selectApprover => '승인자 선택';

  @override
  String get chooseFromMembers => '워크스페이스 멤버 중에서 선택';

  @override
  String get owner => '소유자';

  @override
  String get requireAllApprovers => '모든 승인자 필요';

  @override
  String get everyoneMustApprove => '계속하려면 모두가 승인해야 합니다';

  @override
  String get pleaseEnterStepName => '단계 이름을 입력하세요';

  @override
  String get pleaseAddOneApprover => '최소 한 명의 승인자를 추가하세요';

  @override
  String get deleteTemplate => '템플릿 삭제';

  @override
  String deleteTemplateConfirmation(Object templateName) {
    return '「$templateName」을(를) 삭제하시겠습니까?';
  }

  @override
  String get useTemplate => '템플릿 사용';

  @override
  String fieldCount(Object count) {
    return '$count개 필드';
  }

  @override
  String stepCount(Object count) {
    return '$count개 단계';
  }

  @override
  String get templateStatusActive => '활성';

  @override
  String get templateStatusInactive => '비활성';

  @override
  String get briefDescriptionOfTemplate => '템플릿의 간단한 설명';

  @override
  String get eG => '예: ';

  @override
  String get eGdepartment => '예: 부서, 금액';

  @override
  String get eGmarketing => '예: 마케팅';

  @override
  String get eGmanager => '예: 매니저 검토';

  @override
  String get eGbudget => '예: 예산 승인';

  @override
  String get newRequest => '새 요청';

  @override
  String get requestDetails => '요청 세부정보';

  @override
  String get submitRequest => '요청 제출';

  @override
  String get templateNotFound => '템플릿을 찾을 수 없습니다. 목록에서 템플릿을 선택하세요.';

  @override
  String get noTemplatesAvailable => '사용 가능한 템플릿이 없습니다';

  @override
  String get createTemplateFirst => '요청을 제출하기 전에 템플릿을 생성하세요';

  @override
  String get change => '변경';

  @override
  String get approvalFlow => '승인 흐름';

  @override
  String approverCount(Object count) {
    return '$count명의 승인자';
  }

  @override
  String get selectDate => '날짜 선택';

  @override
  String get selectOption => '옵션 선택';

  @override
  String get attachFile => '파일 첨부';

  @override
  String get fileUploadComingSoon => '파일 업로드 기능이 곧 제공됩니다';

  @override
  String pleaseFillField(Object fieldName) {
    return '$fieldName을(를) 입력하세요';
  }

  @override
  String get requestSubmittedSuccessfully => '요청이 성공적으로 제출되었습니다';

  @override
  String get exportPdf => 'PDF 내보내기';

  @override
  String get noWorkspaceSelectedError => '선택된 워크스페이스 없음';

  @override
  String get approveRequest => '요청 승인';

  @override
  String get rejectRequest => '요청 거부';

  @override
  String get reasonRequired => '사유 (필수)';

  @override
  String get commentOptional => '코멘트 (선택사항)';

  @override
  String get requestApproved => '요청이 승인되었습니다 ✓';

  @override
  String get requestRejected => '요청이 거부되었습니다';

  @override
  String submittedBy(Object name) {
    return '$name 님이 제출';
  }

  @override
  String get noFieldData => '사용 가능한 필드 데이터 없음';

  @override
  String get approvalHistory => '승인 기록';

  @override
  String get reject => '거부';

  @override
  String get approve => '승인';

  @override
  String get draft => '초안';

  @override
  String get pending => '대기 중';

  @override
  String get approved => '승인됨';

  @override
  String get rejected => '거부됨';

  @override
  String get revised => '수정됨';

  @override
  String get attachmentProvided => '첨부 파일 있음';

  @override
  String get status => '상태';

  @override
  String get notification => '알림';

  @override
  String get markAllRead => '모두 읽음으로 표시';

  @override
  String get noNotifications => '알림 없음';

  @override
  String get allCaughtUp => '모든 알림을 확인했습니다!';

  @override
  String noFilteredNotifications(Object filter) {
    return '$filter 알림 없음';
  }

  @override
  String get all => '전체';

  @override
  String get invitations => '초대';

  @override
  String get requests => '요청';

  @override
  String get invitationDismissed => '초대가 해제되었습니다';

  @override
  String get workspaceInvitation => '워크스페이스 초대';

  @override
  String invitedYou(Object name) {
    return '$name 님이 이 워크스페이스에 초대했습니다';
  }

  @override
  String get decline => '거절';

  @override
  String get accept => '수락';

  @override
  String get notificationDismissed => '알림이 해제되었습니다';

  @override
  String openingRequest(Object requestId) {
    return '요청 $requestId 열기...';
  }

  @override
  String get invitationAccepted => '초대가 수락되었습니다!';

  @override
  String failedToAcceptInvitation(Object error) {
    return '초대 수락 실패: $error';
  }

  @override
  String get unableToAcceptInvitation => '초대를 수락할 수 없습니다';

  @override
  String get unableToDeclineInvitation => '초대를 거절할 수 없습니다';

  @override
  String get invitationDeclined => '초대가 거절되었습니다';

  @override
  String failedToDeclineInvitation(Object error) {
    return '초대 거절 실패: $error';
  }

  @override
  String get justNow => '방금';

  @override
  String get analytics => '분석';

  @override
  String get overview => '개요';

  @override
  String get trends => '추이';

  @override
  String get performance => '성과';

  @override
  String get totalRequests => '총 요청 수';

  @override
  String get pendingCount => '대기 중';

  @override
  String get approvedCount => '승인됨';

  @override
  String get rejectedCount => '거부됨';

  @override
  String get approvalRate => '승인율';

  @override
  String get noData => '데이터 없음';

  @override
  String get workspaceInfo => '워크스페이스 정보';

  @override
  String get plan => '요금제';

  @override
  String get members => '멤버';

  @override
  String get created => '생성일';

  @override
  String get weeklyActivity => '주간 활동';

  @override
  String get requestTrends => '요청 추이';

  @override
  String get topPerformers => '우수 성과자';

  @override
  String performerStats(Object approved, Object rejected) {
    return '$approved 승인됨 • $rejected 거부됨';
  }

  @override
  String get averageApprovalTime => '평균 승인 시간';

  @override
  String level(Object level) {
    return '레벨 $level';
  }

  @override
  String get overall => '전체';

  @override
  String get monday => '월';

  @override
  String get tuesday => '화';

  @override
  String get wednesday => '수';

  @override
  String get thursday => '목';

  @override
  String get friday => '금';

  @override
  String get saturday => '토';

  @override
  String get sunday => '일';

  @override
  String get viewAnalytics => '분석 보기';

  @override
  String get exportReports => '보고서 내보내기';

  @override
  String get subscription => '구독';

  @override
  String get upgrade => '업그레이드';

  @override
  String get upgradePlan => '요금제 업그레이드';

  @override
  String get recommended => '추천';

  @override
  String currentPlan(Object plan) {
    return '현재 요금제: $plan';
  }

  @override
  String get compareAllPlans => '모든 요금제 비교';

  @override
  String get maybeLater => '나중에';

  @override
  String upgradeToPlan(Object plan) {
    return '$plan(으)로 업그레이드';
  }

  @override
  String get viewPlans => '요금제 보기';

  @override
  String planName(Object plan) {
    return '$plan';
  }

  @override
  String planPrice(Object price) {
    return '$price';
  }

  @override
  String get comparePlans => '요금제 비교';

  @override
  String get choosePlan => '필요에 맞는 요금제 선택';

  @override
  String get current => '현재';

  @override
  String get limitReached => '한도에 도달했습니다. 더 추가하려면 요금제를 업그레이드하세요.';

  @override
  String get approachingLimit => '한도에 근접했습니다. 업그레이드를 고려하세요.';

  @override
  String resourceLimitReached(Object resource) {
    return '$resource 한도 도달';
  }

  @override
  String limitReachedMessage(Object resource) {
    return '귀하의 요금제에서 허용하는 최대 $resource 수에 도달했습니다.';
  }

  @override
  String get noRecentActivity => '최근 활동 없음';

  @override
  String get recentActivityDescription => '요청과 승인이 여기에 표시됩니다';

  @override
  String get recentActivity => '최근 활동';

  @override
  String get viewAll => '전체 보기';

  @override
  String activityRequestTitle(Object templateName) {
    return '$templateName';
  }

  @override
  String activityStatus(Object status) {
    return '$status';
  }

  @override
  String timeAgo(Object time) {
    return '$time 전';
  }

  @override
  String get minutes => '분';

  @override
  String get hours => '시간';

  @override
  String get days => '일';

  @override
  String get yesterday => '어제';

  @override
  String get myPending => '내 대기 중';

  @override
  String get toApprove => '내가 승인할 것';

  @override
  String get myApproved => '내가 승인한 것';

  @override
  String get total => '총계';
}
