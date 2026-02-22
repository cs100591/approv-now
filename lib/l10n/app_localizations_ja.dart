// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get language => '言語';

  @override
  String get selectLanguage => '言語を選択';

  @override
  String get dashboard => 'ダッシュボード';

  @override
  String get workspaces => 'ワークスペース';

  @override
  String get profile => 'プロフィール';

  @override
  String get account => 'アカウント';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get delete => '削除';

  @override
  String get create => '作成';

  @override
  String get submit => '送信';

  @override
  String get edit => '編集';

  @override
  String get add => '追加';

  @override
  String get remove => '削除';

  @override
  String get confirm => '確認';

  @override
  String get back => '戻る';

  @override
  String get next => '次へ';

  @override
  String get done => '完了';

  @override
  String get close => '閉じる';

  @override
  String get retry => '再試行';

  @override
  String get loading => '読み込み中...';

  @override
  String get error => 'エラー';

  @override
  String get success => '成功';

  @override
  String get warning => '警告';

  @override
  String get info => '情報';

  @override
  String get yes => 'はい';

  @override
  String get no => 'いいえ';

  @override
  String get or => 'または';

  @override
  String get and => 'および';

  @override
  String get email => 'メールアドレス';

  @override
  String get password => 'パスワード';

  @override
  String get name => '名前';

  @override
  String get description => '説明';

  @override
  String get settings => '設定';

  @override
  String get notifications => '通知';

  @override
  String get logout => 'ログアウト';

  @override
  String get login => 'ログイン';

  @override
  String get register => '登録';

  @override
  String get signIn => 'ログイン';

  @override
  String get signOut => 'ログアウト';

  @override
  String get createAccount => 'アカウント作成';

  @override
  String get forgotPassword => 'パスワードを忘れた？';

  @override
  String get resetPassword => 'パスワードリセット';

  @override
  String get changePassword => 'パスワード変更';

  @override
  String get currentPassword => '現在のパスワード';

  @override
  String get newPassword => '新しいパスワード';

  @override
  String get confirmPassword => 'パスワード確認';

  @override
  String get fullName => 'フルネーム';

  @override
  String get displayName => '表示名';

  @override
  String get notLoggedIn => 'ログインしていません';

  @override
  String get noName => '名前なし';

  @override
  String get signInToYourAccount => 'アカウントにログイン';

  @override
  String get signUpToGetStarted => 'Approve Now を始めるには登録してください';

  @override
  String get enterYourEmail => 'メールアドレスを入力';

  @override
  String get enterYourPassword => 'パスワードを入力';

  @override
  String get enterYourFullName => 'フルネームを入力';

  @override
  String get yourName => 'あなたの名前';

  @override
  String get emailIsRequired => 'メールアドレスは必須です';

  @override
  String get pleaseEnterValidEmail => '有効なメールアドレスを入力してください';

  @override
  String get passwordIsRequired => 'パスワードは必須です';

  @override
  String get passwordMinLength => 'パスワードは6文字以上である必要があります';

  @override
  String get nameIsRequired => '名前は必須です';

  @override
  String get pleaseConfirmYourPassword => 'パスワードを確認してください';

  @override
  String get passwordsDoNotMatch => 'パスワードが一致しません';

  @override
  String get accountCreatedSuccessfully => 'アカウントが正常に作成されました！';

  @override
  String get registrationTimedOut => '登録がタイムアウトしました。もう一度お試しください。';

  @override
  String get enableBiometricLogin => '生体認証ログインを有効にしますか？';

  @override
  String get biometricLoginDescription => '指紋またはFace IDで素早くログインしたいですか？';

  @override
  String get notNow => '今はしない';

  @override
  String get enable => '有効にする';

  @override
  String get biometricLogin => '生体認証ログイン';

  @override
  String get useBiometric => '生体認証を使用';

  @override
  String get faceId => 'Face ID';

  @override
  String get fingerprint => '指紋';

  @override
  String get biometricEnabled => '生体認証ログインが有効になりました';

  @override
  String get biometricDisabled => '生体認証ログインが無効になりました';

  @override
  String get dontHaveAccount => 'アカウントをお持ちでないですか？';

  @override
  String get alreadyHaveAccount => 'すでにアカウントをお持ちですか？';

  @override
  String get logOutConfirmation => 'ログアウトしてもよろしいですか？';

  @override
  String get logOut => 'ログアウト';

  @override
  String get profileUpdatedSuccessfully => 'プロフィールが正常に更新されました';

  @override
  String failedToUpdateProfile(Object error) {
    return 'プロフィールの更新に失敗しました：$error';
  }

  @override
  String get settingsComingSoon => '設定機能は近日公開予定です';

  @override
  String get comingSoon => '近日公開';

  @override
  String version(Object version) {
    return 'Approve Now v$version';
  }

  @override
  String copyright(Object year) {
    return '© $year Approve Now. All rights reserved.';
  }

  @override
  String get workspace => 'ワークスペース';

  @override
  String get manageWorkspaces => 'ワークスペースを管理';

  @override
  String get joinWorkspace => 'ワークスペースに参加';

  @override
  String get createWorkspace => 'ワークスペースを作成';

  @override
  String get switchWorkspace => 'ワークスペースを切り替え';

  @override
  String get workspaceName => 'ワークスペース名';

  @override
  String get workspaceDescription => '説明（任意）';

  @override
  String get myCompany => '私の会社';

  @override
  String get briefDescription => '簡単な説明';

  @override
  String get noWorkspaces => 'ワークスペースがありません';

  @override
  String get createFirstWorkspace => '最初のワークスペースを作成して始めましょう';

  @override
  String get settingUpWorkspace => 'ワークスペースを設定中...';

  @override
  String get loadingWorkspace => 'ワークスペースを読み込み中...';

  @override
  String get workspaceLimitReached => 'ワークスペース数の上限に達しました';

  @override
  String get workspaceLimitMessage => 'より多くのワークスペースを作成するにはプランをアップグレードしてください。';

  @override
  String get workspaceLimitReachedMessage => 'ご利用のプランで許可されている最大ワークスペース数に達しました。';

  @override
  String get defaultWorkspaceCreated => 'ようこそ！デフォルトのワークスペースが正常に作成されました。';

  @override
  String get failedToCreateWorkspace => 'ワークスペースの作成に失敗しました。もう一度お試しください。';

  @override
  String get noWorkspaceFound => 'ワークスペースが見つかりません';

  @override
  String get noWorkspaceFoundMessage => '現在ワークスペースを作成できません。';

  @override
  String get createFirstWorkspaceButton => 'ワークスペースを作成';

  @override
  String get workspaceCreatedSuccessfully => 'ワークスペースが正常に作成されました';

  @override
  String switchedToWorkspace(Object workspaceName) {
    return '$workspaceName に切り替えました';
  }

  @override
  String get active => 'アクティブ';

  @override
  String get createNewWorkspace => '新しいワークスペースを作成';

  @override
  String get teamMembers => 'チームメンバー';

  @override
  String get inviteNewMember => '新しいメンバーを招待';

  @override
  String get noWorkspaceSelected => 'ワークスペースが選択されていません';

  @override
  String get selectWorkspaceFirst => 'まずワークスペースを選択してください';

  @override
  String get pendingInvitation => '招待待ち';

  @override
  String get changeRole => '役割を変更';

  @override
  String get removeMember => 'メンバーを削除';

  @override
  String removeMemberConfirmation(Object memberEmail) {
    return '$memberEmail を削除してもよろしいですか？';
  }

  @override
  String get cannotRemovePending => 'ここから招待待ちのメンバーを削除することはできません';

  @override
  String memberRemoved(Object memberEmail) {
    return '$memberEmail が削除されました';
  }

  @override
  String changeRoleForMember(Object memberEmail) {
    return '$memberEmail の役割を変更';
  }

  @override
  String get generateInviteCode => '招待コードを生成';

  @override
  String get generateInviteCodeDescription => 'チームメンバーが参加するための6文字の招待コードを生成します。';

  @override
  String get codeDetails => 'コードの詳細';

  @override
  String get codeDetailsDescription =>
      '• 24時間有効\n• 複数人が使用可能\n• 新しいメンバーは閲覧者として参加';

  @override
  String get generateCode => 'コードを生成';

  @override
  String get inviteCodeGenerated => '招待コードが生成されました';

  @override
  String expires(Object date) {
    return '有効期限：$date';
  }

  @override
  String get shareCodeDescription => 'この招待コードをチームメンバーと共有して、ワークスペースに招待してください。';

  @override
  String get copyCode => 'コードをコピー';

  @override
  String get codeCopiedToClipboard => 'コードをクリップボードにコピーしました';

  @override
  String get teamMemberLimitReached => 'チームメンバー数の上限に達しました';

  @override
  String get teamMemberLimitMessage => 'ご利用のプランで許可されている最大チームメンバー数に達しました。';

  @override
  String get emailNotificationsDisabled =>
      'メール通知は現在無効になっています。チームメンバーはアプリで招待を確認する必要があります。';

  @override
  String get templates => 'テンプレート';

  @override
  String get template => 'テンプレート';

  @override
  String get newTemplate => '新しいテンプレート';

  @override
  String get createTemplate => 'テンプレートを作成';

  @override
  String get noTemplates => 'テンプレートがありません';

  @override
  String get createFirstTemplate => '最初のテンプレートを作成して始めましょう';

  @override
  String get contactAdminToCreateTemplate => 'テンプレートを作成するにはワークスペース管理者に連絡してください';

  @override
  String get templateFields => 'フォームフィールド';

  @override
  String get templateApprovalSteps => '承認ステップ';

  @override
  String get templateInformation => 'テンプレート情報';

  @override
  String get basicDetails => 'このテンプレートの基本情報';

  @override
  String get templateName => 'テンプレート名';

  @override
  String get templateDescription => '説明';

  @override
  String get defineFormFields => 'ユーザーが記入するフィールドを定義';

  @override
  String get noFieldsYet => 'まだフィールドがありません';

  @override
  String get addFirstField => '+ をタップして最初のフィールドを追加するか、AIで生成してください';

  @override
  String get whoNeedsToApprove => 'このリクエストを承認する必要がある人は？';

  @override
  String get noApprovalSteps => '承認ステップがありません';

  @override
  String get addAtLeastOneApprover => '少なくとも1人の承認者を追加してください';

  @override
  String get text => 'テキスト';

  @override
  String get multiline => '複数行';

  @override
  String get number => '数値';

  @override
  String get currency => '通貨';

  @override
  String get date => '日付';

  @override
  String get dropdown => 'ドロップダウン';

  @override
  String get checkbox => 'チェックボックス';

  @override
  String get file => 'ファイル';

  @override
  String get required => '必須';

  @override
  String get moveUp => '上へ移動';

  @override
  String get moveDown => '下へ移動';

  @override
  String get onlyOwnerCanCreateTemplate =>
      'テンプレートを作成できるのはワークスペースのオーナーまたは管理者のみです';

  @override
  String get generationFailed => '生成に失敗しました';

  @override
  String aiConfigApplied(Object scenario) {
    return 'AI設定を適用しました：$scenario';
  }

  @override
  String get addField => 'フィールドを追加';

  @override
  String get editField => 'フィールドを編集';

  @override
  String get fieldLabel => 'フィールドラベル';

  @override
  String get fieldType => 'フィールドタイプ';

  @override
  String get placeholder => 'プレースホルダー（任意）';

  @override
  String get hintText => 'このフィールドのヒントテキスト';

  @override
  String get dropdownOptions => 'ドロップダウンオプション';

  @override
  String get addOption => 'オプションを追加';

  @override
  String get checkedByDefault => 'デフォルトでチェック';

  @override
  String get requiredField => '必須フィールド';

  @override
  String get usersMustFill => 'ユーザーはこのフィールドを記入する必要があります';

  @override
  String get saveChanges => '変更を保存';

  @override
  String get pleaseEnterTemplateName => 'テンプレート名を入力してください';

  @override
  String get pleaseEnterFieldLabel => 'フィールドラベルを入力してください';

  @override
  String get pleaseAddDropdownOption => '少なくとも1つのドロップダウンオプションを追加してください';

  @override
  String get pleaseAddOneField => '少なくとも1つのフィールドを追加してください';

  @override
  String get templateCreatedSuccessfully => 'テンプレートが正常に作成されました';

  @override
  String get failedToCreateTemplate => 'テンプレートの作成に失敗しました。もう一度お試しください。';

  @override
  String approvalStep(Object level) {
    return '承認ステップ $level';
  }

  @override
  String get addApproversForStep => 'このステップの承認者を追加';

  @override
  String get stepName => 'ステップ名';

  @override
  String get noWorkspaceMembers => '利用可能なワークスペースメンバーがいません。まずメンバーを追加してください。';

  @override
  String get selectApprover => '承認者を選択';

  @override
  String get chooseFromMembers => 'ワークスペースメンバーから選択';

  @override
  String get owner => 'オーナー';

  @override
  String get requireAllApprovers => 'すべての承認者が必要';

  @override
  String get everyoneMustApprove => '進むには全員の承認が必要です';

  @override
  String get pleaseEnterStepName => 'ステップ名を入力してください';

  @override
  String get pleaseAddOneApprover => '少なくとも1人の承認者を追加してください';

  @override
  String get deleteTemplate => 'テンプレートを削除';

  @override
  String deleteTemplateConfirmation(Object templateName) {
    return '「$templateName」を削除してもよろしいですか？';
  }

  @override
  String get useTemplate => 'テンプレートを使用';

  @override
  String fieldCount(Object count) {
    return '$count フィールド';
  }

  @override
  String stepCount(Object count) {
    return '$count ステップ';
  }

  @override
  String get templateStatusActive => 'アクティブ';

  @override
  String get templateStatusInactive => '非アクティブ';

  @override
  String get briefDescriptionOfTemplate => 'テンプレートの簡単な説明';

  @override
  String get eG => '例：';

  @override
  String get eGdepartment => '例：部門、金額';

  @override
  String get eGmarketing => '例：マーケティング';

  @override
  String get eGmanager => '例：マネージャー審査';

  @override
  String get eGbudget => '例：予算承認';

  @override
  String get newRequest => '新しいリクエスト';

  @override
  String get requestDetails => 'リクエスト詳細';

  @override
  String get submitRequest => 'リクエストを送信';

  @override
  String get templateNotFound => 'テンプレートが見つかりません。リストからテンプレートを選択してください。';

  @override
  String get noTemplatesAvailable => '利用可能なテンプレートがありません';

  @override
  String get createTemplateFirst => 'リクエストを送信する前にテンプレートを作成してください';

  @override
  String get change => '変更';

  @override
  String get approvalFlow => '承認フロー';

  @override
  String approverCount(Object count) {
    return '$count 承認者';
  }

  @override
  String get selectDate => '日付を選択';

  @override
  String get selectOption => 'オプションを選択';

  @override
  String get attachFile => 'ファイルを添付';

  @override
  String get fileUploadComingSoon => 'ファイルアップロードは近日公開予定です';

  @override
  String pleaseFillField(Object fieldName) {
    return '$fieldName を入力してください';
  }

  @override
  String get requestSubmittedSuccessfully => 'リクエストが正常に送信されました';

  @override
  String get exportPdf => 'PDFをエクスポート';

  @override
  String get noWorkspaceSelectedError => 'ワークスペースが選択されていません';

  @override
  String get approveRequest => 'リクエストを承認';

  @override
  String get rejectRequest => 'リクエストを拒否';

  @override
  String get reasonRequired => '理由（必須）';

  @override
  String get commentOptional => 'コメント（任意）';

  @override
  String get requestApproved => 'リクエストが承認されました ✓';

  @override
  String get requestRejected => 'リクエストが拒否されました';

  @override
  String submittedBy(Object name) {
    return '$name が提出';
  }

  @override
  String get noFieldData => 'フィールドデータがありません';

  @override
  String get approvalHistory => '承認履歴';

  @override
  String get reject => '拒否';

  @override
  String get approve => '承認';

  @override
  String get draft => 'ドラフト';

  @override
  String get pending => '保留中';

  @override
  String get approved => '承認済み';

  @override
  String get rejected => '拒否済み';

  @override
  String get revised => '修正済み';

  @override
  String get attachmentProvided => '添付ファイルあり';

  @override
  String get status => 'ステータス';

  @override
  String get notification => '通知';

  @override
  String get markAllRead => 'すべて既読にする';

  @override
  String get noNotifications => '通知はありません';

  @override
  String get allCaughtUp => 'すべて読みました！';

  @override
  String noFilteredNotifications(Object filter) {
    return '$filterの通知はありません';
  }

  @override
  String get all => 'すべて';

  @override
  String get invitations => '招待';

  @override
  String get requests => 'リクエスト';

  @override
  String get invitationDismissed => '招待が閉じられました';

  @override
  String get workspaceInvitation => 'ワークスペース招待';

  @override
  String invitedYou(Object name) {
    return '$name がこのワークスペースに招待しています';
  }

  @override
  String get decline => '辞退';

  @override
  String get accept => '承諾';

  @override
  String get notificationDismissed => '通知が閉じられました';

  @override
  String openingRequest(Object requestId) {
    return 'リクエスト $requestId を開いています...';
  }

  @override
  String get invitationAccepted => '招待を承諾しました！';

  @override
  String failedToAcceptInvitation(Object error) {
    return '招待の承諾に失敗しました：$error';
  }

  @override
  String get unableToAcceptInvitation => '招待を承諾できません';

  @override
  String get unableToDeclineInvitation => '招待を辞退できません';

  @override
  String get invitationDeclined => '招待を辞退しました';

  @override
  String failedToDeclineInvitation(Object error) {
    return '招待の辞退に失敗しました：$error';
  }

  @override
  String get justNow => 'たった今';

  @override
  String get analytics => '分析';

  @override
  String get overview => '概要';

  @override
  String get trends => '傾向';

  @override
  String get performance => 'パフォーマンス';

  @override
  String get totalRequests => '総リクエスト数';

  @override
  String get pendingCount => '保留中';

  @override
  String get approvedCount => '承認済み';

  @override
  String get rejectedCount => '拒否済み';

  @override
  String get approvalRate => '承認率';

  @override
  String get noData => 'データなし';

  @override
  String get workspaceInfo => 'ワークスペース情報';

  @override
  String get plan => 'プラン';

  @override
  String get members => 'メンバー';

  @override
  String get created => '作成日';

  @override
  String get weeklyActivity => '週間アクティビティ';

  @override
  String get requestTrends => 'リクエスト傾向';

  @override
  String get topPerformers => 'トップパフォーマー';

  @override
  String performerStats(Object approved, Object rejected) {
    return '$approved 承認済み • $rejected 拒否済み';
  }

  @override
  String get averageApprovalTime => '平均承認時間';

  @override
  String level(Object level) {
    return 'レベル $level';
  }

  @override
  String get overall => '全体';

  @override
  String get monday => '月';

  @override
  String get tuesday => '火';

  @override
  String get wednesday => '水';

  @override
  String get thursday => '木';

  @override
  String get friday => '金';

  @override
  String get saturday => '土';

  @override
  String get sunday => '日';

  @override
  String get viewAnalytics => '分析を表示';

  @override
  String get exportReports => 'レポートをエクスポート';

  @override
  String get subscription => 'サブスクリプション';

  @override
  String get upgrade => 'アップグレード';

  @override
  String get upgradePlan => 'プランをアップグレード';

  @override
  String get recommended => 'おすすめ';

  @override
  String currentPlan(Object plan) {
    return '現在のプラン：$plan';
  }

  @override
  String get compareAllPlans => 'すべてのプランを比較';

  @override
  String get maybeLater => '後で';

  @override
  String upgradeToPlan(Object plan) {
    return '$plan にアップグレード';
  }

  @override
  String get viewPlans => 'プランを表示';

  @override
  String planName(Object plan) {
    return '$plan';
  }

  @override
  String planPrice(Object price) {
    return '$price';
  }

  @override
  String get comparePlans => 'プランを比較';

  @override
  String get choosePlan => 'ニーズに合ったプランを選択';

  @override
  String get current => '現在';

  @override
  String get limitReached => '制限に達しました。より多く追加するにはプランをアップグレードしてください。';

  @override
  String get approachingLimit => '制限に近づいています。アップグレードを検討してください。';

  @override
  String resourceLimitReached(Object resource) {
    return '$resource の制限に達しました';
  }

  @override
  String limitReachedMessage(Object resource) {
    return 'ご利用のプランで許可されている最大 $resource 数に達しました。';
  }

  @override
  String get noRecentActivity => '最近のアクティビティはありません';

  @override
  String get recentActivityDescription => 'リクエストと承認がここに表示されます';

  @override
  String get recentActivity => '最近のアクティビティ';

  @override
  String get viewAll => 'すべて表示';

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
    return '$time 前';
  }

  @override
  String get minutes => '分';

  @override
  String get hours => '時間';

  @override
  String get days => '日';

  @override
  String get yesterday => '昨日';

  @override
  String get myPending => '保留中のもの';

  @override
  String get toApprove => '承認待ち';

  @override
  String get myApproved => '承認済み';

  @override
  String get total => '合計';
}
