// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get language => '语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get dashboard => '仪表板';

  @override
  String get workspaces => '工作空间';

  @override
  String get profile => '个人资料';

  @override
  String get account => '账户';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get create => '创建';

  @override
  String get submit => '提交';

  @override
  String get edit => '编辑';

  @override
  String get add => '添加';

  @override
  String get remove => '移除';

  @override
  String get confirm => '确认';

  @override
  String get back => '返回';

  @override
  String get next => '下一步';

  @override
  String get done => '完成';

  @override
  String get close => '关闭';

  @override
  String get retry => '重试';

  @override
  String get loading => '加载中...';

  @override
  String get error => '错误';

  @override
  String get success => '成功';

  @override
  String get warning => '警告';

  @override
  String get info => '信息';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get or => '或';

  @override
  String get and => '和';

  @override
  String get email => '电子邮箱';

  @override
  String get password => '密码';

  @override
  String get name => '姓名';

  @override
  String get description => '描述';

  @override
  String get settings => '设置';

  @override
  String get notifications => '通知';

  @override
  String get logout => '退出登录';

  @override
  String get login => '登录';

  @override
  String get register => '注册';

  @override
  String get signIn => '登录';

  @override
  String get signOut => '退出登录';

  @override
  String get createAccount => '创建账户';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get resetPassword => '重置密码';

  @override
  String get changePassword => '更改密码';

  @override
  String get currentPassword => '当前密码';

  @override
  String get newPassword => '新密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get fullName => '全名';

  @override
  String get displayName => '显示名称';

  @override
  String get notLoggedIn => '未登录';

  @override
  String get noName => '无名称';

  @override
  String get signInToYourAccount => '登录您的账户';

  @override
  String get signUpToGetStarted => '注册开始使用 Approve Now';

  @override
  String get enterYourEmail => '输入您的电子邮箱';

  @override
  String get enterYourPassword => '输入您的密码';

  @override
  String get enterYourFullName => '输入您的全名';

  @override
  String get yourName => '您的姓名';

  @override
  String get emailIsRequired => '电子邮箱为必填项';

  @override
  String get pleaseEnterValidEmail => '请输入有效的电子邮箱';

  @override
  String get passwordIsRequired => '密码为必填项';

  @override
  String get passwordMinLength => '密码必须至少包含6个字符';

  @override
  String get nameIsRequired => '姓名为必填项';

  @override
  String get pleaseConfirmYourPassword => '请确认您的密码';

  @override
  String get passwordsDoNotMatch => '密码不匹配';

  @override
  String get accountCreatedSuccessfully => '账户创建成功！';

  @override
  String get registrationTimedOut => '注册超时，请重试';

  @override
  String get enableBiometricLogin => '启用生物识别登录？';

  @override
  String get biometricLoginDescription => '您想启用指纹或面容ID以便快速登录吗？';

  @override
  String get notNow => '暂不';

  @override
  String get enable => '启用';

  @override
  String get biometricLogin => '生物识别登录';

  @override
  String get useBiometric => '使用生物识别';

  @override
  String get faceId => '面容ID';

  @override
  String get fingerprint => '指纹';

  @override
  String get biometricEnabled => '生物识别登录已启用';

  @override
  String get biometricDisabled => '生物识别登录已禁用';

  @override
  String get dontHaveAccount => '没有账户？';

  @override
  String get alreadyHaveAccount => '已有账户？';

  @override
  String get logOutConfirmation => '您确定要退出登录吗？';

  @override
  String get logOut => '退出登录';

  @override
  String get profileUpdatedSuccessfully => '个人资料更新成功';

  @override
  String failedToUpdateProfile(Object error) {
    return '更新个人资料失败：$error';
  }

  @override
  String get settingsComingSoon => '设置即将推出';

  @override
  String get comingSoon => '即将推出';

  @override
  String version(Object version) {
    return 'Approve Now v$version';
  }

  @override
  String copyright(Object year) {
    return '© $year Approve Now. 保留所有权利。';
  }

  @override
  String get workspace => '工作空间';

  @override
  String get manageWorkspaces => '管理工作空间';

  @override
  String get joinWorkspace => '加入工作空间';

  @override
  String get createWorkspace => '创建工作空间';

  @override
  String get switchWorkspace => '切换工作空间';

  @override
  String get workspaceName => '工作空间名称';

  @override
  String get workspaceDescription => '描述（可选）';

  @override
  String get myCompany => '我的公司';

  @override
  String get briefDescription => '简短描述';

  @override
  String get noWorkspaces => '无工作空间';

  @override
  String get createFirstWorkspace => '创建您的第一个工作空间以开始使用';

  @override
  String get settingUpWorkspace => '正在设置您的工作空间...';

  @override
  String get loadingWorkspace => '正在加载您的工作空间...';

  @override
  String get workspaceLimitReached => '工作空间数量已达上限';

  @override
  String get workspaceLimitMessage => '您需要升级套餐以创建更多工作空间。';

  @override
  String get workspaceLimitReachedMessage => '您已达到套餐允许的最大工作空间数量。';

  @override
  String get defaultWorkspaceCreated => '欢迎！默认工作空间创建成功。';

  @override
  String get failedToCreateWorkspace => '创建工作空间失败，请重试。';

  @override
  String get noWorkspaceFound => '未找到工作空间';

  @override
  String get noWorkspaceFoundMessage => '目前无法创建工作空间。';

  @override
  String get createFirstWorkspaceButton => '创建工作空间';

  @override
  String get workspaceCreatedSuccessfully => '工作空间创建成功';

  @override
  String switchedToWorkspace(Object workspaceName) {
    return '已切换至 $workspaceName';
  }

  @override
  String get active => '活跃';

  @override
  String get createNewWorkspace => '创建新工作空间';

  @override
  String get teamMembers => '团队成员';

  @override
  String get inviteNewMember => '邀请新成员';

  @override
  String get noWorkspaceSelected => '未选择工作空间';

  @override
  String get selectWorkspaceFirst => '请先选择工作空间';

  @override
  String get pendingInvitation => '待处理邀请';

  @override
  String get changeRole => '更改角色';

  @override
  String get removeMember => '移除成员';

  @override
  String removeMemberConfirmation(Object memberEmail) {
    return '您确定要移除 $memberEmail 吗？';
  }

  @override
  String get cannotRemovePending => '无法从此处移除待处理邀请';

  @override
  String memberRemoved(Object memberEmail) {
    return '已移除 $memberEmail';
  }

  @override
  String changeRoleForMember(Object memberEmail) {
    return '为 $memberEmail 更改角色';
  }

  @override
  String get generateInviteCode => '生成邀请码';

  @override
  String get generateInviteCodeDescription => '生成6位字符的邀请码供团队成员加入。';

  @override
  String get codeDetails => '邀请码详情';

  @override
  String get codeDetailsDescription => '• 有效期24小时\n• 可供多人使用\n• 新成员以观察者角色加入';

  @override
  String get generateCode => '生成邀请码';

  @override
  String get inviteCodeGenerated => '邀请码已生成';

  @override
  String expires(Object date) {
    return '过期时间：$date';
  }

  @override
  String get shareCodeDescription => '与团队成员分享此邀请码以邀请他们加入您的工作空间。';

  @override
  String get copyCode => '复制邀请码';

  @override
  String get codeCopiedToClipboard => '邀请码已复制到剪贴板';

  @override
  String get teamMemberLimitReached => '团队成员数量已达上限';

  @override
  String get teamMemberLimitMessage => '您已达到套餐允许的最大团队成员数量。';

  @override
  String get emailNotificationsDisabled => '电子邮件通知当前已禁用。团队成员需要在应用中查看邀请。';

  @override
  String get templates => '模板';

  @override
  String get template => '模板';

  @override
  String get newTemplate => '新建模板';

  @override
  String get createTemplate => '创建模板';

  @override
  String get noTemplates => '无模板';

  @override
  String get createFirstTemplate => '创建您的第一个模板以开始使用';

  @override
  String get contactAdminToCreateTemplate => '请联系工作空间管理员创建模板';

  @override
  String get templateFields => '表单字段';

  @override
  String get templateApprovalSteps => '审批步骤';

  @override
  String get templateInformation => '模板信息';

  @override
  String get basicDetails => '关于此模板的基本信息';

  @override
  String get templateName => '模板名称';

  @override
  String get templateDescription => '描述';

  @override
  String get defineFormFields => '定义用户将填写的字段';

  @override
  String get noFieldsYet => '尚无字段';

  @override
  String get addFirstField => '点击 + 添加第一个字段或使用AI生成';

  @override
  String get whoNeedsToApprove => '谁需要审批此请求？';

  @override
  String get noApprovalSteps => '无审批步骤';

  @override
  String get addAtLeastOneApprover => '请至少添加一名审批人';

  @override
  String get text => '文本';

  @override
  String get multiline => '多行文本';

  @override
  String get number => '数字';

  @override
  String get currency => '货币';

  @override
  String get date => '日期';

  @override
  String get dropdown => '下拉选项';

  @override
  String get checkbox => '复选框';

  @override
  String get file => '文件';

  @override
  String get required => '必填';

  @override
  String get moveUp => '上移';

  @override
  String get moveDown => '下移';

  @override
  String get onlyOwnerCanCreateTemplate => '只有工作空间所有者或管理员可以创建模板';

  @override
  String get generationFailed => '生成失败';

  @override
  String aiConfigApplied(Object scenario) {
    return '已应用AI配置：$scenario';
  }

  @override
  String get addField => '添加字段';

  @override
  String get editField => '编辑字段';

  @override
  String get fieldLabel => '字段标签';

  @override
  String get fieldType => '字段类型';

  @override
  String get placeholder => '占位文本（可选）';

  @override
  String get hintText => '此字段的提示文本';

  @override
  String get dropdownOptions => '下拉选项';

  @override
  String get addOption => '添加选项';

  @override
  String get checkedByDefault => '默认选中';

  @override
  String get requiredField => '必填字段';

  @override
  String get usersMustFill => '用户必须填写此字段';

  @override
  String get saveChanges => '保存更改';

  @override
  String get pleaseEnterTemplateName => '请输入模板名称';

  @override
  String get pleaseEnterFieldLabel => '请输入字段标签';

  @override
  String get pleaseAddDropdownOption => '请至少添加一个下拉选项';

  @override
  String get pleaseAddOneField => '请至少添加一个字段';

  @override
  String get templateCreatedSuccessfully => '模板创建成功';

  @override
  String get failedToCreateTemplate => '创建模板失败，请重试。';

  @override
  String approvalStep(Object level) {
    return '审批步骤 $level';
  }

  @override
  String get addApproversForStep => '为此步骤添加审批人';

  @override
  String get stepName => '步骤名称';

  @override
  String get noWorkspaceMembers => '无可用工作空间成员。请先添加成员。';

  @override
  String get selectApprover => '选择审批人';

  @override
  String get chooseFromMembers => '从工作空间成员中选择';

  @override
  String get owner => '所有者';

  @override
  String get requireAllApprovers => '需要所有审批人';

  @override
  String get everyoneMustApprove => '所有人都必须审批才能继续';

  @override
  String get pleaseEnterStepName => '请输入步骤名称';

  @override
  String get pleaseAddOneApprover => '请至少添加一名审批人';

  @override
  String get deleteTemplate => '删除模板';

  @override
  String deleteTemplateConfirmation(Object templateName) {
    return '您确定要删除 \"$templateName\" 吗？';
  }

  @override
  String get useTemplate => '使用模板';

  @override
  String fieldCount(Object count) {
    return '$count 个字段';
  }

  @override
  String stepCount(Object count) {
    return '$count 个步骤';
  }

  @override
  String get templateStatusActive => '活跃';

  @override
  String get templateStatusInactive => '非活跃';

  @override
  String get briefDescriptionOfTemplate => '关于此模板的简短描述';

  @override
  String get eG => '例如';

  @override
  String get eGdepartment => '例如：部门、金额';

  @override
  String get eGmarketing => '例如：市场部';

  @override
  String get eGmanager => '例如：经理审核';

  @override
  String get eGbudget => '例如：预算审批';

  @override
  String get newRequest => '新建请求';

  @override
  String get requestDetails => '请求详情';

  @override
  String get submitRequest => '提交请求';

  @override
  String get templateNotFound => '未找到模板。请从列表中选择一个模板。';

  @override
  String get noTemplatesAvailable => '无可用模板';

  @override
  String get createTemplateFirst => '请先创建模板以提交请求';

  @override
  String get change => '更改';

  @override
  String get approvalFlow => '审批流程';

  @override
  String approverCount(Object count) {
    return '$count 位审批人';
  }

  @override
  String get selectDate => '选择日期';

  @override
  String get selectOption => '选择选项';

  @override
  String get attachFile => '附加文件';

  @override
  String get fileUploadComingSoon => '文件上传功能即将推出';

  @override
  String pleaseFillField(Object fieldName) {
    return '请填写 $fieldName';
  }

  @override
  String get requestSubmittedSuccessfully => '请求提交成功';

  @override
  String get exportPdf => '导出PDF';

  @override
  String get noWorkspaceSelectedError => '未选择工作空间';

  @override
  String get approveRequest => '批准请求';

  @override
  String get rejectRequest => '拒绝请求';

  @override
  String get reasonRequired => '原因（必填）';

  @override
  String get commentOptional => '评论（可选）';

  @override
  String get requestApproved => '请求已批准 ✓';

  @override
  String get requestRejected => '请求已拒绝';

  @override
  String submittedBy(Object name) {
    return '由 $name 提交';
  }

  @override
  String get noFieldData => '无可用字段数据';

  @override
  String get approvalHistory => '审批历史';

  @override
  String get reject => '拒绝';

  @override
  String get approve => '批准';

  @override
  String get draft => '草稿';

  @override
  String get pending => '待处理';

  @override
  String get approved => '已批准';

  @override
  String get rejected => '已拒绝';

  @override
  String get revised => '已修订';

  @override
  String get attachmentProvided => '已提供附件';

  @override
  String get status => '状态';

  @override
  String get notification => '通知';

  @override
  String get markAllRead => '标记全部为已读';

  @override
  String get noNotifications => '无通知';

  @override
  String get allCaughtUp => '您已跟上进度！';

  @override
  String noFilteredNotifications(Object filter) {
    return '无 $filter 通知';
  }

  @override
  String get all => '全部';

  @override
  String get invitations => '邀请';

  @override
  String get requests => 'Requests';

  @override
  String get invitationDismissed => '邀请已关闭';

  @override
  String get workspaceInvitation => '工作空间邀请';

  @override
  String invitedYou(Object name) {
    return '$name 邀请您加入此工作空间';
  }

  @override
  String get decline => '拒绝';

  @override
  String get accept => '接受';

  @override
  String get notificationDismissed => '通知已关闭';

  @override
  String openingRequest(Object requestId) {
    return '正在打开请求 $requestId...';
  }

  @override
  String get invitationAccepted => '邀请已接受！';

  @override
  String failedToAcceptInvitation(Object error) {
    return '接受邀请失败：$error';
  }

  @override
  String get unableToAcceptInvitation => '无法接受邀请';

  @override
  String get unableToDeclineInvitation => '无法拒绝邀请';

  @override
  String get invitationDeclined => '邀请已拒绝';

  @override
  String failedToDeclineInvitation(Object error) {
    return '拒绝邀请失败：$error';
  }

  @override
  String get justNow => '刚刚';

  @override
  String get analytics => '分析';

  @override
  String get overview => '概览';

  @override
  String get trends => '趋势';

  @override
  String get performance => '绩效';

  @override
  String get totalRequests => '请求总数';

  @override
  String get pendingCount => '待处理';

  @override
  String get approvedCount => '已批准';

  @override
  String get rejectedCount => '已拒绝';

  @override
  String get approvalRate => '批准率';

  @override
  String get noData => '无数据';

  @override
  String get workspaceInfo => '工作空间信息';

  @override
  String get plan => '套餐';

  @override
  String get members => '成员';

  @override
  String get created => '创建时间';

  @override
  String get weeklyActivity => '每周活动';

  @override
  String get requestTrends => '请求趋势';

  @override
  String get topPerformers => '最佳表现者';

  @override
  String performerStats(Object approved, Object rejected) {
    return '$approved 已批准 • $rejected 已拒绝';
  }

  @override
  String get averageApprovalTime => '平均审批时间';

  @override
  String level(Object level) {
    return '级别 $level';
  }

  @override
  String get overall => '总体';

  @override
  String get monday => '周一';

  @override
  String get tuesday => '周二';

  @override
  String get wednesday => '周三';

  @override
  String get thursday => '周四';

  @override
  String get friday => '周五';

  @override
  String get saturday => '周六';

  @override
  String get sunday => '周日';

  @override
  String get viewAnalytics => '查看分析';

  @override
  String get exportReports => '导出报告';

  @override
  String get subscription => '订阅';

  @override
  String get upgrade => '升级';

  @override
  String get upgradePlan => '升级套餐';

  @override
  String get recommended => '推荐';

  @override
  String currentPlan(Object plan) {
    return '当前套餐：$plan';
  }

  @override
  String get compareAllPlans => '比较所有套餐';

  @override
  String get maybeLater => '稍后';

  @override
  String upgradeToPlan(Object plan) {
    return '升级至 $plan';
  }

  @override
  String get viewPlans => '查看套餐';

  @override
  String planName(Object plan) {
    return '$plan';
  }

  @override
  String planPrice(Object price) {
    return '$price';
  }

  @override
  String get comparePlans => '比较套餐';

  @override
  String get choosePlan => '选择适合您需求的套餐';

  @override
  String get current => '当前';

  @override
  String get limitReached => '已达上限。升级您的套餐以添加更多。';

  @override
  String get approachingLimit => '接近上限。请考虑尽快升级。';

  @override
  String resourceLimitReached(Object resource) {
    return '$resource 已达上限';
  }

  @override
  String limitReachedMessage(Object resource) {
    return '您已达到套餐允许的最大 $resource 数量。';
  }

  @override
  String get noRecentActivity => '无近期活动';

  @override
  String get recentActivityDescription => '您的请求和审批将显示在此处';

  @override
  String get recentActivity => '近期活动';

  @override
  String get viewAll => '查看全部';

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
  String get minutes => '分钟';

  @override
  String get hours => '小时';

  @override
  String get days => '天';

  @override
  String get yesterday => '昨天';

  @override
  String get myPending => '我的待处理';

  @override
  String get toApprove => '待审批';

  @override
  String get myApproved => '我的已批准';

  @override
  String get total => '总计';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get language => '语言';

  @override
  String get selectLanguage => '选择语言';

  @override
  String get dashboard => '仪表盘';

  @override
  String get workspaces => '工作区';

  @override
  String get profile => '个人资料';

  @override
  String get account => '账户';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get delete => '删除';

  @override
  String get create => '创建';

  @override
  String get submit => '提交';

  @override
  String get edit => '编辑';

  @override
  String get add => '添加';

  @override
  String get remove => '移除';

  @override
  String get confirm => '确认';

  @override
  String get back => '返回';

  @override
  String get next => '下一步';

  @override
  String get done => '完成';

  @override
  String get close => '关闭';

  @override
  String get retry => '重试';

  @override
  String get loading => '加载中...';

  @override
  String get error => '错误';

  @override
  String get success => '成功';

  @override
  String get warning => '警告';

  @override
  String get info => '信息';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get or => '或';

  @override
  String get and => '和';

  @override
  String get email => '电子邮箱';

  @override
  String get password => '密码';

  @override
  String get name => '姓名';

  @override
  String get description => '描述';

  @override
  String get settings => '设置';

  @override
  String get notifications => '通知';

  @override
  String get logout => '退出登录';

  @override
  String get login => '登录';

  @override
  String get register => '注册';

  @override
  String get signIn => '登录';

  @override
  String get signOut => '退出';

  @override
  String get createAccount => '创建账户';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get resetPassword => '重置密码';

  @override
  String get changePassword => '修改密码';

  @override
  String get currentPassword => '当前密码';

  @override
  String get newPassword => '新密码';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get fullName => '全名';

  @override
  String get displayName => '显示名称';

  @override
  String get notLoggedIn => '未登录';

  @override
  String get noName => '无名称';

  @override
  String get signInToYourAccount => '登录您的账户';

  @override
  String get signUpToGetStarted => '注册以开始使用 Approve Now';

  @override
  String get enterYourEmail => '输入您的电子邮箱';

  @override
  String get enterYourPassword => '输入您的密码';

  @override
  String get enterYourFullName => '输入您的全名';

  @override
  String get yourName => '您的姓名';

  @override
  String get emailIsRequired => '电子邮箱是必填项';

  @override
  String get pleaseEnterValidEmail => '请输入有效的电子邮箱';

  @override
  String get passwordIsRequired => '密码是必填项';

  @override
  String get passwordMinLength => '密码必须至少6个字符';

  @override
  String get nameIsRequired => '姓名是必填项';

  @override
  String get pleaseConfirmYourPassword => '请确认您的密码';

  @override
  String get passwordsDoNotMatch => '密码不匹配';

  @override
  String get accountCreatedSuccessfully => '账户创建成功！';

  @override
  String get registrationTimedOut => '注册超时，请重试。';

  @override
  String get enableBiometricLogin => '启用生物识别登录？';

  @override
  String get biometricLoginDescription => '您想启用指纹或面容ID快速登录吗？';

  @override
  String get notNow => '稍后再说';

  @override
  String get enable => '启用';

  @override
  String get biometricLogin => '生物识别登录';

  @override
  String get useBiometric => '使用生物识别';

  @override
  String get faceId => '面容ID';

  @override
  String get fingerprint => '指纹识别';

  @override
  String get biometricEnabled => '生物识别登录已启用';

  @override
  String get biometricDisabled => '生物识别登录已禁用';

  @override
  String get dontHaveAccount => '还没有账户？';

  @override
  String get alreadyHaveAccount => '已有账户？';

  @override
  String get logOutConfirmation => '确定要退出登录吗？';

  @override
  String get logOut => '退出登录';

  @override
  String get profileUpdatedSuccessfully => '个人资料更新成功';

  @override
  String failedToUpdateProfile(Object error) {
    return '更新个人资料失败：$error';
  }

  @override
  String get settingsComingSoon => '设置功能即将推出';

  @override
  String get comingSoon => '即将推出';

  @override
  String version(Object version) {
    return 'Approve Now v$version';
  }

  @override
  String copyright(Object year) {
    return '© $year Approve Now。保留所有权利。';
  }

  @override
  String get workspace => '工作区';

  @override
  String get manageWorkspaces => '管理工作区';

  @override
  String get joinWorkspace => '加入工作区';

  @override
  String get createWorkspace => '创建工作区';

  @override
  String get switchWorkspace => '切换工作区';

  @override
  String get workspaceName => '工作区名称';

  @override
  String get workspaceDescription => '描述（可选）';

  @override
  String get myCompany => '我的公司';

  @override
  String get briefDescription => '简要描述';

  @override
  String get noWorkspaces => '没有工作区';

  @override
  String get createFirstWorkspace => '创建您的第一个工作区开始使用';

  @override
  String get settingUpWorkspace => '正在设置工作区...';

  @override
  String get loadingWorkspace => '正在加载工作区...';

  @override
  String get workspaceLimitReached => '已达到工作区数量限制';

  @override
  String get workspaceLimitMessage => '您需要升级套餐才能创建更多工作区。';

  @override
  String get workspaceLimitReachedMessage => '您已达到当前套餐允许的最大工作区数量。';

  @override
  String get defaultWorkspaceCreated => '欢迎！默认工作区创建成功。';

  @override
  String get failedToCreateWorkspace => '创建工作区失败，请重试。';

  @override
  String get noWorkspaceFound => '未找到工作区';

  @override
  String get noWorkspaceFoundMessage => '暂时无法创建工作区。';

  @override
  String get createFirstWorkspaceButton => '创建工作区';

  @override
  String get workspaceCreatedSuccessfully => '工作区创建成功';

  @override
  String switchedToWorkspace(Object workspaceName) {
    return '已切换到 $workspaceName';
  }

  @override
  String get active => '活跃';

  @override
  String get createNewWorkspace => '创建新工作区';

  @override
  String get teamMembers => '团队成员';

  @override
  String get inviteNewMember => '邀请新成员';

  @override
  String get noWorkspaceSelected => '未选择工作区';

  @override
  String get selectWorkspaceFirst => '请先选择工作区';

  @override
  String get pendingInvitation => '待处理邀请';

  @override
  String get changeRole => '更改角色';

  @override
  String get removeMember => '移除成员';

  @override
  String removeMemberConfirmation(Object memberEmail) {
    return '确定要移除 $memberEmail 吗？';
  }

  @override
  String get cannotRemovePending => '无法从此处移除待处理邀请';

  @override
  String memberRemoved(Object memberEmail) {
    return '$memberEmail 已移除';
  }

  @override
  String changeRoleForMember(Object memberEmail) {
    return '更改 $memberEmail 的角色';
  }

  @override
  String get generateInviteCode => '生成邀请码';

  @override
  String get generateInviteCodeDescription => '生成一个6位字符邀请码供团队成员加入。';

  @override
  String get codeDetails => '邀请码详情';

  @override
  String get codeDetailsDescription => '• 有效期24小时\n• 可多人使用\n• 新成员以观察者身份加入';

  @override
  String get generateCode => '生成邀请码';

  @override
  String get inviteCodeGenerated => '邀请码已生成';

  @override
  String expires(Object date) {
    return '到期时间：$date';
  }

  @override
  String get shareCodeDescription => '与团队成员分享此邀请码以邀请他们加入工作区。';

  @override
  String get copyCode => '复制邀请码';

  @override
  String get codeCopiedToClipboard => '邀请码已复制到剪贴板';

  @override
  String get teamMemberLimitReached => '已达到团队成员数量限制';

  @override
  String get teamMemberLimitMessage => '您已达到当前套餐允许的最大团队成员数量。';

  @override
  String get emailNotificationsDisabled => '电子邮件通知当前已禁用。团队成员需要打开应用查看邀请。';

  @override
  String get templates => '模板';

  @override
  String get template => '模板';

  @override
  String get newTemplate => '新建模板';

  @override
  String get createTemplate => '创建模板';

  @override
  String get noTemplates => '没有模板';

  @override
  String get createFirstTemplate => '创建您的第一个模板开始使用';

  @override
  String get contactAdminToCreateTemplate => '请联系工作区管理员创建模板';

  @override
  String get templateFields => '表单字段';

  @override
  String get templateApprovalSteps => '审批步骤';

  @override
  String get templateInformation => '模板信息';

  @override
  String get basicDetails => '此模板的基本信息';

  @override
  String get templateName => '模板名称';

  @override
  String get templateDescription => '描述';

  @override
  String get defineFormFields => '定义用户需要填写的字段';

  @override
  String get noFieldsYet => '暂无字段';

  @override
  String get addFirstField => '点击 + 添加第一个字段或使用AI生成';

  @override
  String get whoNeedsToApprove => '谁需要审批此请求？';

  @override
  String get noApprovalSteps => '暂无审批步骤';

  @override
  String get addAtLeastOneApprover => '请添加至少一位审批人';

  @override
  String get text => '文本';

  @override
  String get multiline => '多行文本';

  @override
  String get number => '数字';

  @override
  String get currency => '货币';

  @override
  String get date => '日期';

  @override
  String get dropdown => '下拉菜单';

  @override
  String get checkbox => '复选框';

  @override
  String get file => '文件';

  @override
  String get required => '必填';

  @override
  String get moveUp => '上移';

  @override
  String get moveDown => '下移';

  @override
  String get onlyOwnerCanCreateTemplate => '只有工作区所有者或管理员可以创建模板';

  @override
  String get generationFailed => '生成失败';

  @override
  String aiConfigApplied(Object scenario) {
    return '已应用AI配置：$scenario';
  }

  @override
  String get addField => '添加字段';

  @override
  String get editField => '编辑字段';

  @override
  String get fieldLabel => '字段标签';

  @override
  String get fieldType => '字段类型';

  @override
  String get placeholder => '占位符（可选）';

  @override
  String get hintText => '此字段的提示文本';

  @override
  String get dropdownOptions => '下拉选项';

  @override
  String get addOption => '添加选项';

  @override
  String get checkedByDefault => '默认选中';

  @override
  String get requiredField => '必填字段';

  @override
  String get usersMustFill => '用户必须填写此字段';

  @override
  String get saveChanges => '保存更改';

  @override
  String get pleaseEnterTemplateName => '请输入模板名称';

  @override
  String get pleaseEnterFieldLabel => '请输入字段标签';

  @override
  String get pleaseAddDropdownOption => '请添加至少一个下拉选项';

  @override
  String get pleaseAddOneField => '请添加至少一个字段';

  @override
  String get templateCreatedSuccessfully => '模板创建成功';

  @override
  String get failedToCreateTemplate => '创建模板失败，请重试。';

  @override
  String approvalStep(Object level) {
    return '审批步骤 $level';
  }

  @override
  String get addApproversForStep => '为此步骤添加审批人';

  @override
  String get stepName => '步骤名称';

  @override
  String get noWorkspaceMembers => '没有可用的工作区成员。请先添加成员。';

  @override
  String get selectApprover => '选择审批人';

  @override
  String get chooseFromMembers => '从工作区成员中选择';

  @override
  String get owner => '所有者';

  @override
  String get requireAllApprovers => '要求所有审批人';

  @override
  String get everyoneMustApprove => '所有人必须批准才能继续';

  @override
  String get pleaseEnterStepName => '请输入步骤名称';

  @override
  String get pleaseAddOneApprover => '请添加至少一位审批人';

  @override
  String get deleteTemplate => '删除模板';

  @override
  String deleteTemplateConfirmation(Object templateName) {
    return '确定要删除 \"$templateName\" 吗？';
  }

  @override
  String get useTemplate => '使用模板';

  @override
  String fieldCount(Object count) {
    return '$count 个字段';
  }

  @override
  String stepCount(Object count) {
    return '$count 个步骤';
  }

  @override
  String get templateStatusActive => '活跃';

  @override
  String get templateStatusInactive => '非活跃';

  @override
  String get briefDescriptionOfTemplate => '模板的简要描述';

  @override
  String get eG => '例如，';

  @override
  String get eGdepartment => '例如，部门、金额';

  @override
  String get eGmarketing => '例如，市场营销';

  @override
  String get eGmanager => '例如，经理审核';

  @override
  String get eGbudget => '例如，预算审批';

  @override
  String get newRequest => '新建请求';

  @override
  String get requestDetails => '请求详情';

  @override
  String get submitRequest => '提交请求';

  @override
  String get templateNotFound => '未找到模板。请从列表中选择一个模板。';

  @override
  String get noTemplatesAvailable => '没有可用模板';

  @override
  String get createTemplateFirst => '请先创建模板再提交请求';

  @override
  String get change => '更改';

  @override
  String get approvalFlow => '审批流程';

  @override
  String approverCount(Object count) {
    return '$count 位审批人';
  }

  @override
  String get selectDate => '选择日期';

  @override
  String get selectOption => '选择一个选项';

  @override
  String get attachFile => '附加文件';

  @override
  String get fileUploadComingSoon => '文件上传功能即将推出';

  @override
  String pleaseFillField(Object fieldName) {
    return '请填写 $fieldName';
  }

  @override
  String get requestSubmittedSuccessfully => '请求提交成功';

  @override
  String get exportPdf => '导出PDF';

  @override
  String get noWorkspaceSelectedError => '未选择工作区';

  @override
  String get approveRequest => '批准请求';

  @override
  String get rejectRequest => '拒绝请求';

  @override
  String get reasonRequired => '原因（必填）';

  @override
  String get commentOptional => '备注（可选）';

  @override
  String get requestApproved => '请求已批准 ✓';

  @override
  String get requestRejected => '请求已拒绝';

  @override
  String submittedBy(Object name) {
    return '由 $name 提交';
  }

  @override
  String get noFieldData => '没有可用字段数据';

  @override
  String get approvalHistory => '审批历史';

  @override
  String get reject => '拒绝';

  @override
  String get approve => '批准';

  @override
  String get draft => '草稿';

  @override
  String get pending => '待处理';

  @override
  String get approved => '已批准';

  @override
  String get rejected => '已拒绝';

  @override
  String get revised => '已修订';

  @override
  String get attachmentProvided => '已提供附件';

  @override
  String get status => '状态';

  @override
  String get notification => '通知';

  @override
  String get markAllRead => '全部标为已读';

  @override
  String get noNotifications => '没有通知';

  @override
  String get allCaughtUp => '您已经看完了所有通知！';

  @override
  String noFilteredNotifications(Object filter) {
    return '没有$filter通知';
  }

  @override
  String get all => '全部';

  @override
  String get invitations => '邀请';

  @override
  String get requests => '请求';

  @override
  String get invitationDismissed => '邀请已取消';

  @override
  String get workspaceInvitation => '工作区邀请';

  @override
  String invitedYou(Object name) {
    return '$name 邀请您加入此工作区';
  }

  @override
  String get decline => '拒绝';

  @override
  String get accept => '接受';

  @override
  String get notificationDismissed => '通知已关闭';

  @override
  String openingRequest(Object requestId) {
    return '正在打开请求 $requestId...';
  }

  @override
  String get invitationAccepted => '邀请已接受！';

  @override
  String failedToAcceptInvitation(Object error) {
    return '接受邀请失败：$error';
  }

  @override
  String get unableToAcceptInvitation => '无法接受邀请';

  @override
  String get unableToDeclineInvitation => '无法拒绝邀请';

  @override
  String get invitationDeclined => '邀请已拒绝';

  @override
  String failedToDeclineInvitation(Object error) {
    return '拒绝邀请失败：$error';
  }

  @override
  String get justNow => '刚刚';

  @override
  String get analytics => '分析';

  @override
  String get overview => '概览';

  @override
  String get trends => '趋势';

  @override
  String get performance => '表现';

  @override
  String get totalRequests => '总请求数';

  @override
  String get pendingCount => '待处理';

  @override
  String get approvedCount => '已批准';

  @override
  String get rejectedCount => '已拒绝';

  @override
  String get approvalRate => '批准率';

  @override
  String get noData => '暂无数据';

  @override
  String get workspaceInfo => '工作区信息';

  @override
  String get plan => '套餐';

  @override
  String get members => '成员';

  @override
  String get created => '创建时间';

  @override
  String get weeklyActivity => '每周活动';

  @override
  String get requestTrends => '请求趋势';

  @override
  String get topPerformers => '最佳表现者';

  @override
  String performerStats(Object approved, Object rejected) {
    return '$approved 已批准 • $rejected 已拒绝';
  }

  @override
  String get averageApprovalTime => '平均审批时间';

  @override
  String level(Object level) {
    return '级别 $level';
  }

  @override
  String get overall => '整体';

  @override
  String get monday => '周一';

  @override
  String get tuesday => '周二';

  @override
  String get wednesday => '周三';

  @override
  String get thursday => '周四';

  @override
  String get friday => '周五';

  @override
  String get saturday => '周六';

  @override
  String get sunday => '周日';

  @override
  String get viewAnalytics => '查看分析';

  @override
  String get exportReports => '导出报告';

  @override
  String get subscription => '订阅';

  @override
  String get upgrade => '升级';

  @override
  String get upgradePlan => '升级套餐';

  @override
  String get recommended => '推荐';

  @override
  String currentPlan(Object plan) {
    return '当前套餐：$plan';
  }

  @override
  String get compareAllPlans => '比较所有套餐';

  @override
  String get maybeLater => '稍后再说';

  @override
  String upgradeToPlan(Object plan) {
    return '升级到 $plan';
  }

  @override
  String get viewPlans => '查看套餐';

  @override
  String planName(Object plan) {
    return '$plan';
  }

  @override
  String planPrice(Object price) {
    return '$price';
  }

  @override
  String get comparePlans => '比较套餐';

  @override
  String get choosePlan => '选择适合您的套餐';

  @override
  String get current => '当前';

  @override
  String get limitReached => '已达到限制。升级套餐以添加更多。';

  @override
  String get approachingLimit => '接近限制。请考虑尽快升级。';

  @override
  String resourceLimitReached(Object resource) {
    return '$resource 数量限制已达';
  }

  @override
  String limitReachedMessage(Object resource) {
    return '您已达到当前套餐允许的最大 $resource 数量。';
  }

  @override
  String get noRecentActivity => '没有近期活动';

  @override
  String get recentActivityDescription => '您的请求和审批将显示在这里';

  @override
  String get recentActivity => '近期活动';

  @override
  String get viewAll => '查看全部';

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
  String get minutes => '分钟';

  @override
  String get hours => '小时';

  @override
  String get days => '天';

  @override
  String get yesterday => '昨天';

  @override
  String get myPending => '我的待处理';

  @override
  String get toApprove => '待我审批';

  @override
  String get myApproved => '我已批准';

  @override
  String get total => '总计';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get language => '語言';

  @override
  String get selectLanguage => '選擇語言';

  @override
  String get dashboard => '儀表板';

  @override
  String get workspaces => '工作區';

  @override
  String get profile => '個人資料';

  @override
  String get account => '帳戶';

  @override
  String get cancel => '取消';

  @override
  String get save => '儲存';

  @override
  String get delete => '刪除';

  @override
  String get create => '建立';

  @override
  String get submit => '提交';

  @override
  String get edit => '編輯';

  @override
  String get add => '新增';

  @override
  String get remove => '移除';

  @override
  String get confirm => '確認';

  @override
  String get back => '返回';

  @override
  String get next => '下一步';

  @override
  String get done => '完成';

  @override
  String get close => '關閉';

  @override
  String get retry => '重試';

  @override
  String get loading => '載入中...';

  @override
  String get error => '錯誤';

  @override
  String get success => '成功';

  @override
  String get warning => '警告';

  @override
  String get info => '資訊';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get or => '或';

  @override
  String get and => '和';

  @override
  String get email => '電子郵件';

  @override
  String get password => '密碼';

  @override
  String get name => '姓名';

  @override
  String get description => '描述';

  @override
  String get settings => '設定';

  @override
  String get notifications => '通知';

  @override
  String get logout => '登出';

  @override
  String get login => '登入';

  @override
  String get register => '註冊';

  @override
  String get signIn => '登入';

  @override
  String get signOut => '登出';

  @override
  String get createAccount => '建立帳戶';

  @override
  String get forgotPassword => '忘記密碼？';

  @override
  String get resetPassword => '重設密碼';

  @override
  String get changePassword => '變更密碼';

  @override
  String get currentPassword => '目前密碼';

  @override
  String get newPassword => '新密碼';

  @override
  String get confirmPassword => '確認密碼';

  @override
  String get fullName => '全名';

  @override
  String get displayName => '顯示名稱';

  @override
  String get notLoggedIn => '未登入';

  @override
  String get noName => '無名稱';

  @override
  String get signInToYourAccount => '登入您的帳戶';

  @override
  String get signUpToGetStarted => '註冊以開始使用 Approve Now';

  @override
  String get enterYourEmail => '輸入您的電子郵件';

  @override
  String get enterYourPassword => '輸入您的密碼';

  @override
  String get enterYourFullName => '輸入您的全名';

  @override
  String get yourName => '您的姓名';

  @override
  String get emailIsRequired => '電子郵件為必填項目';

  @override
  String get pleaseEnterValidEmail => '請輸入有效的電子郵件';

  @override
  String get passwordIsRequired => '密碼為必填項目';

  @override
  String get passwordMinLength => '密碼必須至少6個字元';

  @override
  String get nameIsRequired => '姓名為必填項目';

  @override
  String get pleaseConfirmYourPassword => '請確認您的密碼';

  @override
  String get passwordsDoNotMatch => '密碼不相符';

  @override
  String get accountCreatedSuccessfully => '帳戶建立成功！';

  @override
  String get registrationTimedOut => '註冊逾時，請重試。';

  @override
  String get enableBiometricLogin => '啟用生物辨識登入？';

  @override
  String get biometricLoginDescription => '您想啟用指紋或Face ID快速登入嗎？';

  @override
  String get notNow => '稍後再說';

  @override
  String get enable => '啟用';

  @override
  String get biometricLogin => '生物辨識登入';

  @override
  String get useBiometric => '使用生物辨識';

  @override
  String get faceId => 'Face ID';

  @override
  String get fingerprint => '指紋辨識';

  @override
  String get biometricEnabled => '生物辨識登入已啟用';

  @override
  String get biometricDisabled => '生物辨識登入已停用';

  @override
  String get dontHaveAccount => '還沒有帳戶？';

  @override
  String get alreadyHaveAccount => '已有帳戶？';

  @override
  String get logOutConfirmation => '確定要登出嗎？';

  @override
  String get logOut => '登出';

  @override
  String get profileUpdatedSuccessfully => '個人資料更新成功';

  @override
  String failedToUpdateProfile(Object error) {
    return '更新個人資料失敗：$error';
  }

  @override
  String get settingsComingSoon => '設定功能即將推出';

  @override
  String get comingSoon => '即將推出';

  @override
  String version(Object version) {
    return 'Approve Now v$version';
  }

  @override
  String copyright(Object year) {
    return '© $year Approve Now。保留所有權利。';
  }

  @override
  String get workspace => '工作區';

  @override
  String get manageWorkspaces => '管理工作區';

  @override
  String get joinWorkspace => '加入工作區';

  @override
  String get createWorkspace => '建立工作區';

  @override
  String get switchWorkspace => '切換工作區';

  @override
  String get workspaceName => '工作區名稱';

  @override
  String get workspaceDescription => '描述（選填）';

  @override
  String get myCompany => '我的公司';

  @override
  String get briefDescription => '簡要描述';

  @override
  String get noWorkspaces => '沒有工作區';

  @override
  String get createFirstWorkspace => '建立您的第一個工作區開始使用';

  @override
  String get settingUpWorkspace => '正在設定工作區...';

  @override
  String get loadingWorkspace => '正在載入工作區...';

  @override
  String get workspaceLimitReached => '已達工作區數量限制';

  @override
  String get workspaceLimitMessage => '您需要升級方案才能建立更多工作區。';

  @override
  String get workspaceLimitReachedMessage => '您已達目前方案允許的最大工作區數量。';

  @override
  String get defaultWorkspaceCreated => '歡迎！預設工作區建立成功。';

  @override
  String get failedToCreateWorkspace => '建立工作區失敗，請重試。';

  @override
  String get noWorkspaceFound => '找不到工作區';

  @override
  String get noWorkspaceFoundMessage => '暫時無法建立工作區。';

  @override
  String get createFirstWorkspaceButton => '建立工作區';

  @override
  String get workspaceCreatedSuccessfully => '工作區建立成功';

  @override
  String switchedToWorkspace(Object workspaceName) {
    return '已切換至 $workspaceName';
  }

  @override
  String get active => '使用中';

  @override
  String get createNewWorkspace => '建立新工作區';

  @override
  String get teamMembers => '團隊成員';

  @override
  String get inviteNewMember => '邀請新成員';

  @override
  String get noWorkspaceSelected => '未選擇工作區';

  @override
  String get selectWorkspaceFirst => '請先選擇工作區';

  @override
  String get pendingInvitation => '待處理邀請';

  @override
  String get changeRole => '變更角色';

  @override
  String get removeMember => '移除成員';

  @override
  String removeMemberConfirmation(Object memberEmail) {
    return '確定要移除 $memberEmail 嗎？';
  }

  @override
  String get cannotRemovePending => '無法從此處移除待處理邀請';

  @override
  String memberRemoved(Object memberEmail) {
    return '$memberEmail 已移除';
  }

  @override
  String changeRoleForMember(Object memberEmail) {
    return '變更 $memberEmail 的角色';
  }

  @override
  String get generateInviteCode => '產生邀請碼';

  @override
  String get generateInviteCodeDescription => '產生一個6位字元邀請碼供團隊成員加入。';

  @override
  String get codeDetails => '邀請碼詳情';

  @override
  String get codeDetailsDescription => '• 有效期限24小時\n• 可多人使用\n• 新成員以觀察者身份加入';

  @override
  String get generateCode => '產生邀請碼';

  @override
  String get inviteCodeGenerated => '邀請碼已產生';

  @override
  String expires(Object date) {
    return '到期時間：$date';
  }

  @override
  String get shareCodeDescription => '與團隊成員分享此邀請碼以邀請他們加入工作區。';

  @override
  String get copyCode => '複製邀請碼';

  @override
  String get codeCopiedToClipboard => '邀請碼已複製到剪貼簿';

  @override
  String get teamMemberLimitReached => '已達團隊成員數量限制';

  @override
  String get teamMemberLimitMessage => '您已達目前方案允許的最大團隊成員數量。';

  @override
  String get emailNotificationsDisabled => '電子郵件通知目前已停用。團隊成員需要開啟應用程式查看邀請。';

  @override
  String get templates => '範本';

  @override
  String get template => '範本';

  @override
  String get newTemplate => '新增範本';

  @override
  String get createTemplate => '建立範本';

  @override
  String get noTemplates => '沒有範本';

  @override
  String get createFirstTemplate => '建立您的第一個範本開始使用';

  @override
  String get contactAdminToCreateTemplate => '請聯絡工作區管理員建立範本';

  @override
  String get templateFields => '表單欄位';

  @override
  String get templateApprovalSteps => '審批步驟';

  @override
  String get templateInformation => '範本資訊';

  @override
  String get basicDetails => '此範本的基本資訊';

  @override
  String get templateName => '範本名稱';

  @override
  String get templateDescription => '描述';

  @override
  String get defineFormFields => '定義使用者需要填寫的欄位';

  @override
  String get noFieldsYet => '尚無欄位';

  @override
  String get addFirstField => '點擊 + 新增第一個欄位或使用AI產生';

  @override
  String get whoNeedsToApprove => '誰需要審批此請求？';

  @override
  String get noApprovalSteps => '尚無審批步驟';

  @override
  String get addAtLeastOneApprover => '請新增至少一位審批人';

  @override
  String get text => '文字';

  @override
  String get multiline => '多行文字';

  @override
  String get number => '數字';

  @override
  String get currency => '貨幣';

  @override
  String get date => '日期';

  @override
  String get dropdown => '下拉選單';

  @override
  String get checkbox => '核取方塊';

  @override
  String get file => '檔案';

  @override
  String get required => '必填';

  @override
  String get moveUp => '上移';

  @override
  String get moveDown => '下移';

  @override
  String get onlyOwnerCanCreateTemplate => '只有工作區擁有者或管理員可以建立範本';

  @override
  String get generationFailed => '產生失敗';

  @override
  String aiConfigApplied(Object scenario) {
    return '已套用AI設定：$scenario';
  }

  @override
  String get addField => '新增欄位';

  @override
  String get editField => '編輯欄位';

  @override
  String get fieldLabel => '欄位標籤';

  @override
  String get fieldType => '欄位類型';

  @override
  String get placeholder => '預留位置（選填）';

  @override
  String get hintText => '此欄位的提示文字';

  @override
  String get dropdownOptions => '下拉選項';

  @override
  String get addOption => '新增選項';

  @override
  String get checkedByDefault => '預設選取';

  @override
  String get requiredField => '必填欄位';

  @override
  String get usersMustFill => '使用者必須填寫此欄位';

  @override
  String get saveChanges => '儲存變更';

  @override
  String get pleaseEnterTemplateName => '請輸入範本名稱';

  @override
  String get pleaseEnterFieldLabel => '請輸入欄位標籤';

  @override
  String get pleaseAddDropdownOption => '請新增至少一個下拉選項';

  @override
  String get pleaseAddOneField => '請新增至少一個欄位';

  @override
  String get templateCreatedSuccessfully => '範本建立成功';

  @override
  String get failedToCreateTemplate => '建立範本失敗，請重試。';

  @override
  String approvalStep(Object level) {
    return '審批步驟 $level';
  }

  @override
  String get addApproversForStep => '為此步驟新增審批人';

  @override
  String get stepName => '步驟名稱';

  @override
  String get noWorkspaceMembers => '沒有可用的工作區成員。請先新增成員。';

  @override
  String get selectApprover => '選擇審批人';

  @override
  String get chooseFromMembers => '從工作區成員中選擇';

  @override
  String get owner => '擁有者';

  @override
  String get requireAllApprovers => '要求所有審批人';

  @override
  String get everyoneMustApprove => '所有人都必須核准才能繼續';

  @override
  String get pleaseEnterStepName => '請輸入步驟名稱';

  @override
  String get pleaseAddOneApprover => '請新增至少一位審批人';

  @override
  String get deleteTemplate => '刪除範本';

  @override
  String deleteTemplateConfirmation(Object templateName) {
    return '確定要刪除 \"$templateName\" 嗎？';
  }

  @override
  String get useTemplate => '使用範本';

  @override
  String fieldCount(Object count) {
    return '$count 個欄位';
  }

  @override
  String stepCount(Object count) {
    return '$count 個步驟';
  }

  @override
  String get templateStatusActive => '使用中';

  @override
  String get templateStatusInactive => '非使用中';

  @override
  String get briefDescriptionOfTemplate => '範本的簡要描述';

  @override
  String get eG => '例如，';

  @override
  String get eGdepartment => '例如，部門、金額';

  @override
  String get eGmarketing => '例如，行銷';

  @override
  String get eGmanager => '例如，經理審核';

  @override
  String get eGbudget => '例如，預算審批';

  @override
  String get newRequest => '新增請求';

  @override
  String get requestDetails => '請求詳情';

  @override
  String get submitRequest => '提交請求';

  @override
  String get templateNotFound => '找不到範本。請從列表中選擇一個範本。';

  @override
  String get noTemplatesAvailable => '沒有可用範本';

  @override
  String get createTemplateFirst => '請先建立範本再提交請求';

  @override
  String get change => '變更';

  @override
  String get approvalFlow => '審批流程';

  @override
  String approverCount(Object count) {
    return '$count 位審批人';
  }

  @override
  String get selectDate => '選擇日期';

  @override
  String get selectOption => '選擇一個選項';

  @override
  String get attachFile => '附加檔案';

  @override
  String get fileUploadComingSoon => '檔案上傳功能即將推出';

  @override
  String pleaseFillField(Object fieldName) {
    return '請填寫 $fieldName';
  }

  @override
  String get requestSubmittedSuccessfully => '請求提交成功';

  @override
  String get exportPdf => '匯出PDF';

  @override
  String get noWorkspaceSelectedError => '未選擇工作區';

  @override
  String get approveRequest => '核准請求';

  @override
  String get rejectRequest => '拒絕請求';

  @override
  String get reasonRequired => '原因（必填）';

  @override
  String get commentOptional => '備註（選填）';

  @override
  String get requestApproved => '請求已核准 ✓';

  @override
  String get requestRejected => '請求已拒絕';

  @override
  String submittedBy(Object name) {
    return '由 $name 提交';
  }

  @override
  String get noFieldData => '沒有可用欄位資料';

  @override
  String get approvalHistory => '審批歷史';

  @override
  String get reject => '拒絕';

  @override
  String get approve => '核准';

  @override
  String get draft => '草稿';

  @override
  String get pending => '待處理';

  @override
  String get approved => '已核准';

  @override
  String get rejected => '已拒絕';

  @override
  String get revised => '已修訂';

  @override
  String get attachmentProvided => '已提供附件';

  @override
  String get status => '狀態';

  @override
  String get notification => '通知';

  @override
  String get markAllRead => '全部標為已讀';

  @override
  String get noNotifications => '沒有通知';

  @override
  String get allCaughtUp => '您已經看完所有通知！';

  @override
  String noFilteredNotifications(Object filter) {
    return '沒有$filter通知';
  }

  @override
  String get all => '全部';

  @override
  String get invitations => '邀請';

  @override
  String get requests => '請求';

  @override
  String get invitationDismissed => '邀請已關閉';

  @override
  String get workspaceInvitation => '工作區邀請';

  @override
  String invitedYou(Object name) {
    return '$name 邀請您加入此工作區';
  }

  @override
  String get decline => '拒絕';

  @override
  String get accept => '接受';

  @override
  String get notificationDismissed => '通知已關閉';

  @override
  String openingRequest(Object requestId) {
    return '正在開啟請求 $requestId...';
  }

  @override
  String get invitationAccepted => '邀請已接受！';

  @override
  String failedToAcceptInvitation(Object error) {
    return '接受邀請失敗：$error';
  }

  @override
  String get unableToAcceptInvitation => '無法接受邀請';

  @override
  String get unableToDeclineInvitation => '無法拒絕邀請';

  @override
  String get invitationDeclined => '邀請已拒絕';

  @override
  String failedToDeclineInvitation(Object error) {
    return '拒絕邀請失敗：$error';
  }

  @override
  String get justNow => '剛剛';

  @override
  String get analytics => '分析';

  @override
  String get overview => '概覽';

  @override
  String get trends => '趨勢';

  @override
  String get performance => '表現';

  @override
  String get totalRequests => '總請求數';

  @override
  String get pendingCount => '待處理';

  @override
  String get approvedCount => '已核准';

  @override
  String get rejectedCount => '已拒絕';

  @override
  String get approvalRate => '核准率';

  @override
  String get noData => '暫無資料';

  @override
  String get workspaceInfo => '工作區資訊';

  @override
  String get plan => '方案';

  @override
  String get members => '成員';

  @override
  String get created => '建立時間';

  @override
  String get weeklyActivity => '每週活動';

  @override
  String get requestTrends => '請求趨勢';

  @override
  String get topPerformers => '最佳表現者';

  @override
  String performerStats(Object approved, Object rejected) {
    return '$approved 已核准 • $rejected 已拒絕';
  }

  @override
  String get averageApprovalTime => '平均審批時間';

  @override
  String level(Object level) {
    return '級別 $level';
  }

  @override
  String get overall => '整體';

  @override
  String get monday => '週一';

  @override
  String get tuesday => '週二';

  @override
  String get wednesday => '週三';

  @override
  String get thursday => '週四';

  @override
  String get friday => '週五';

  @override
  String get saturday => '週六';

  @override
  String get sunday => '週日';

  @override
  String get viewAnalytics => '查看分析';

  @override
  String get exportReports => '匯出報告';

  @override
  String get subscription => '訂閱';

  @override
  String get upgrade => '升級';

  @override
  String get upgradePlan => '升級方案';

  @override
  String get recommended => '推薦';

  @override
  String currentPlan(Object plan) {
    return '目前方案：$plan';
  }

  @override
  String get compareAllPlans => '比較所有方案';

  @override
  String get maybeLater => '稍後再說';

  @override
  String upgradeToPlan(Object plan) {
    return '升級至 $plan';
  }

  @override
  String get viewPlans => '查看方案';

  @override
  String planName(Object plan) {
    return '$plan';
  }

  @override
  String planPrice(Object price) {
    return '$price';
  }

  @override
  String get comparePlans => '比較方案';

  @override
  String get choosePlan => '選擇適合您的方案';

  @override
  String get current => '目前';

  @override
  String get limitReached => '已達限制。升級方案以新增更多。';

  @override
  String get approachingLimit => '接近限制。請考慮盡快升級。';

  @override
  String resourceLimitReached(Object resource) {
    return '$resource 數量限制已達';
  }

  @override
  String limitReachedMessage(Object resource) {
    return '您已達目前方案允許的最大 $resource 數量。';
  }

  @override
  String get noRecentActivity => '沒有近期活動';

  @override
  String get recentActivityDescription => '您的請求和審批將顯示在這裡';

  @override
  String get recentActivity => '近期活動';

  @override
  String get viewAll => '查看全部';

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
  String get minutes => '分鐘';

  @override
  String get hours => '小時';

  @override
  String get days => '天';

  @override
  String get yesterday => '昨天';

  @override
  String get myPending => '我的待處理';

  @override
  String get toApprove => '待我審批';

  @override
  String get myApproved => '我已核准';

  @override
  String get total => '總計';
}
