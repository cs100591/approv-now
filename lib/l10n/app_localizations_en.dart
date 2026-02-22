// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get workspaces => 'Workspaces';

  @override
  String get profile => 'Profile';

  @override
  String get account => 'Account';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get create => 'Create';

  @override
  String get submit => 'Submit';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get confirm => 'Confirm';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get done => 'Done';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get or => 'OR';

  @override
  String get and => 'and';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get name => 'Name';

  @override
  String get description => 'Description';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get logout => 'Logout';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get signIn => 'Sign In';

  @override
  String get signOut => 'Sign Out';

  @override
  String get createAccount => 'Create Account';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get displayName => 'Display Name';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get noName => 'No Name';

  @override
  String get signInToYourAccount => 'Sign in to your account';

  @override
  String get signUpToGetStarted => 'Sign up to get started with Approve Now';

  @override
  String get enterYourEmail => 'Enter your email';

  @override
  String get enterYourPassword => 'Enter your password';

  @override
  String get enterYourFullName => 'Enter your full name';

  @override
  String get yourName => 'Your name';

  @override
  String get emailIsRequired => 'Email is required';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get passwordIsRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get nameIsRequired => 'Name is required';

  @override
  String get pleaseConfirmYourPassword => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get accountCreatedSuccessfully => 'Account created successfully!';

  @override
  String get registrationTimedOut =>
      'Registration timed out. Please try again.';

  @override
  String get enableBiometricLogin => 'Enable Biometric Login?';

  @override
  String get biometricLoginDescription =>
      'Would you like to enable fingerprint or face ID for quick login?';

  @override
  String get notNow => 'Not Now';

  @override
  String get enable => 'Enable';

  @override
  String get biometricLogin => 'Biometric Login';

  @override
  String get useBiometric => 'Use Biometric';

  @override
  String get faceId => 'Face ID';

  @override
  String get fingerprint => 'Fingerprint';

  @override
  String get biometricEnabled => 'Biometric login enabled';

  @override
  String get biometricDisabled => 'Biometric login disabled';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get logOutConfirmation => 'Are you sure you want to log out?';

  @override
  String get logOut => 'Log Out';

  @override
  String get profileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String failedToUpdateProfile(Object error) {
    return 'Failed to update profile: $error';
  }

  @override
  String get settingsComingSoon => 'Settings coming soon';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String version(Object version) {
    return 'Approve Now v$version';
  }

  @override
  String copyright(Object year) {
    return '© $year Approve Now. All rights reserved.';
  }

  @override
  String get workspace => 'Workspace';

  @override
  String get manageWorkspaces => 'Manage Workspaces';

  @override
  String get joinWorkspace => 'Join Workspace';

  @override
  String get createWorkspace => 'Create Workspace';

  @override
  String get switchWorkspace => 'Switch Workspace';

  @override
  String get workspaceName => 'Workspace Name';

  @override
  String get workspaceDescription => 'Description (Optional)';

  @override
  String get myCompany => 'My Company';

  @override
  String get briefDescription => 'Brief description';

  @override
  String get noWorkspaces => 'No Workspaces';

  @override
  String get createFirstWorkspace =>
      'Create your first workspace to get started';

  @override
  String get settingUpWorkspace => 'Setting up your workspace...';

  @override
  String get loadingWorkspace => 'Loading your workspace...';

  @override
  String get workspaceLimitReached => 'Workspace Limit Reached';

  @override
  String get workspaceLimitMessage =>
      'You need to upgrade your plan to create more workspaces.';

  @override
  String get workspaceLimitReachedMessage =>
      'You\'ve reached the maximum number of workspaces allowed by your plan.';

  @override
  String get defaultWorkspaceCreated =>
      'Welcome! Default workspace created successfully.';

  @override
  String get failedToCreateWorkspace =>
      'Failed to create workspace. Please try again.';

  @override
  String get noWorkspaceFound => 'No Workspace Found';

  @override
  String get noWorkspaceFoundMessage =>
      'Unable to create a workspace at this time.';

  @override
  String get createFirstWorkspaceButton => 'Create Workspace';

  @override
  String get workspaceCreatedSuccessfully => 'Workspace created successfully';

  @override
  String switchedToWorkspace(Object workspaceName) {
    return 'Switched to $workspaceName';
  }

  @override
  String get active => 'Active';

  @override
  String get createNewWorkspace => 'Create New Workspace';

  @override
  String get teamMembers => 'Team Members';

  @override
  String get inviteNewMember => 'Invite New Member';

  @override
  String get noWorkspaceSelected => 'No Workspace Selected';

  @override
  String get selectWorkspaceFirst => 'Please select a workspace first';

  @override
  String get pendingInvitation => 'Pending Invitation';

  @override
  String get changeRole => 'Change Role';

  @override
  String get removeMember => 'Remove Member';

  @override
  String removeMemberConfirmation(Object memberEmail) {
    return 'Are you sure you want to remove $memberEmail?';
  }

  @override
  String get cannotRemovePending =>
      'Cannot remove pending invitation from here';

  @override
  String memberRemoved(Object memberEmail) {
    return '$memberEmail removed';
  }

  @override
  String changeRoleForMember(Object memberEmail) {
    return 'Change Role for $memberEmail';
  }

  @override
  String get generateInviteCode => 'Generate Invite Code';

  @override
  String get generateInviteCodeDescription =>
      'Generate a 6-character invite code for team members to join.';

  @override
  String get codeDetails => 'Code Details';

  @override
  String get codeDetailsDescription =>
      '• Valid for 24 hours\n• Can be used by multiple people\n• New members join as Viewer role';

  @override
  String get generateCode => 'Generate Code';

  @override
  String get inviteCodeGenerated => 'Invite Code Generated';

  @override
  String expires(Object date) {
    return 'Expires: $date';
  }

  @override
  String get shareCodeDescription =>
      'Share this code with team members to invite them to your workspace.';

  @override
  String get copyCode => 'Copy Code';

  @override
  String get codeCopiedToClipboard => 'Code copied to clipboard';

  @override
  String get teamMemberLimitReached => 'Team Member Limit Reached';

  @override
  String get teamMemberLimitMessage =>
      'You\'ve reached the maximum number of team members allowed by your plan.';

  @override
  String get emailNotificationsDisabled =>
      'Email notifications are currently disabled. Team members will need to check the app for invitations.';

  @override
  String get templates => 'Templates';

  @override
  String get template => 'Template';

  @override
  String get newTemplate => 'New Template';

  @override
  String get createTemplate => 'Create Template';

  @override
  String get noTemplates => 'No Templates';

  @override
  String get createFirstTemplate => 'Create your first template to get started';

  @override
  String get contactAdminToCreateTemplate =>
      'Contact workspace admin to create templates';

  @override
  String get templateFields => 'Form Fields';

  @override
  String get templateApprovalSteps => 'Approval Steps';

  @override
  String get templateInformation => 'Template Information';

  @override
  String get basicDetails => 'Basic details about this template';

  @override
  String get templateName => 'Template Name';

  @override
  String get templateDescription => 'Description';

  @override
  String get defineFormFields => 'Define the fields users will fill out';

  @override
  String get noFieldsYet => 'No fields yet';

  @override
  String get addFirstField =>
      'Tap + to add your first field or use AI to generate';

  @override
  String get whoNeedsToApprove => 'Who needs to approve this request?';

  @override
  String get noApprovalSteps => 'No approval steps';

  @override
  String get addAtLeastOneApprover => 'Add at least one approver';

  @override
  String get text => 'Text';

  @override
  String get multiline => 'Multiline';

  @override
  String get number => 'Number';

  @override
  String get currency => 'Currency';

  @override
  String get date => 'Date';

  @override
  String get dropdown => 'Dropdown';

  @override
  String get checkbox => 'Checkbox';

  @override
  String get file => 'File';

  @override
  String get required => 'Required';

  @override
  String get moveUp => 'Move up';

  @override
  String get moveDown => 'Move down';

  @override
  String get onlyOwnerCanCreateTemplate =>
      'Only workspace owner or admin can create templates';

  @override
  String get generationFailed => 'Generation Failed';

  @override
  String aiConfigApplied(Object scenario) {
    return 'Applied AI configuration: $scenario';
  }

  @override
  String get addField => 'Add Field';

  @override
  String get editField => 'Edit Field';

  @override
  String get fieldLabel => 'Field Label';

  @override
  String get fieldType => 'Field Type';

  @override
  String get placeholder => 'Placeholder (Optional)';

  @override
  String get hintText => 'Hint text for this field';

  @override
  String get dropdownOptions => 'Dropdown Options';

  @override
  String get addOption => 'Add Option';

  @override
  String get checkedByDefault => 'Checked by default';

  @override
  String get requiredField => 'Required Field';

  @override
  String get usersMustFill => 'Users must fill this field';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get pleaseEnterTemplateName => 'Please enter a template name';

  @override
  String get pleaseEnterFieldLabel => 'Please enter a field label';

  @override
  String get pleaseAddDropdownOption =>
      'Please add at least one dropdown option';

  @override
  String get pleaseAddOneField => 'Please add at least one field';

  @override
  String get templateCreatedSuccessfully => 'Template created successfully';

  @override
  String get failedToCreateTemplate =>
      'Failed to create template. Please try again.';

  @override
  String approvalStep(Object level) {
    return 'Approval Step $level';
  }

  @override
  String get addApproversForStep => 'Add approvers for this step';

  @override
  String get stepName => 'Step Name';

  @override
  String get noWorkspaceMembers =>
      'No workspace members available. Please add members first.';

  @override
  String get selectApprover => 'Select Approver';

  @override
  String get chooseFromMembers => 'Choose from workspace members';

  @override
  String get owner => 'Owner';

  @override
  String get requireAllApprovers => 'Require all approvers';

  @override
  String get everyoneMustApprove => 'Everyone must approve to proceed';

  @override
  String get pleaseEnterStepName => 'Please enter a step name';

  @override
  String get pleaseAddOneApprover => 'Please add at least one approver';

  @override
  String get deleteTemplate => 'Delete Template';

  @override
  String deleteTemplateConfirmation(Object templateName) {
    return 'Are you sure you want to delete \"$templateName\"?';
  }

  @override
  String get useTemplate => 'Use Template';

  @override
  String fieldCount(Object count) {
    return '$count fields';
  }

  @override
  String stepCount(Object count) {
    return '$count steps';
  }

  @override
  String get templateStatusActive => 'Active';

  @override
  String get templateStatusInactive => 'Inactive';

  @override
  String get briefDescriptionOfTemplate => 'Brief description of this template';

  @override
  String get eG => 'eG,';

  @override
  String get eGdepartment => 'eG, Department, Amount';

  @override
  String get eGmarketing => 'eG, Marketing';

  @override
  String get eGmanager => 'eG, Manager Review';

  @override
  String get eGbudget => 'eG, Budget Approval';

  @override
  String get newRequest => 'New Request';

  @override
  String get requestDetails => 'Request Details';

  @override
  String get submitRequest => 'Submit Request';

  @override
  String get templateNotFound =>
      'Template not found. Please select a template from the list.';

  @override
  String get noTemplatesAvailable => 'No Templates Available';

  @override
  String get createTemplateFirst =>
      'Create a template first to submit a request';

  @override
  String get change => 'Change';

  @override
  String get approvalFlow => 'Approval Flow';

  @override
  String approverCount(Object count) {
    return '$count approver(s)';
  }

  @override
  String get selectDate => 'Select a date';

  @override
  String get selectOption => 'Select an option';

  @override
  String get attachFile => 'Attach a file';

  @override
  String get fileUploadComingSoon => 'File upload coming soon';

  @override
  String pleaseFillField(Object fieldName) {
    return 'Please fill in $fieldName';
  }

  @override
  String get requestSubmittedSuccessfully => 'Request submitted successfully';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get noWorkspaceSelectedError => 'No workspace selected';

  @override
  String get approveRequest => 'Approve Request';

  @override
  String get rejectRequest => 'Reject Request';

  @override
  String get reasonRequired => 'Reason (required)';

  @override
  String get commentOptional => 'Comment (optional)';

  @override
  String get requestApproved => 'Request approved ✓';

  @override
  String get requestRejected => 'Request rejected';

  @override
  String submittedBy(Object name) {
    return 'Submitted by $name';
  }

  @override
  String get noFieldData => 'No field data available';

  @override
  String get approvalHistory => 'Approval History';

  @override
  String get reject => 'Reject';

  @override
  String get approve => 'Approve';

  @override
  String get draft => 'Draft';

  @override
  String get pending => 'Pending';

  @override
  String get approved => 'Approved';

  @override
  String get rejected => 'Rejected';

  @override
  String get revised => 'Revised';

  @override
  String get attachmentProvided => 'Attachment provided';

  @override
  String get status => 'Status';

  @override
  String get notification => 'Notification';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get noNotifications => 'No Notifications';

  @override
  String get allCaughtUp => 'You\'re all caught up!';

  @override
  String noFilteredNotifications(Object filter) {
    return 'No $filter notifications';
  }

  @override
  String get all => 'All';

  @override
  String get invitations => 'Invitations';

  @override
  String get requests => 'Requests';

  @override
  String get invitationDismissed => 'Invitation dismissed';

  @override
  String get workspaceInvitation => 'Workspace Invitation';

  @override
  String invitedYou(Object name) {
    return '$name invited you to join this workspace';
  }

  @override
  String get decline => 'Decline';

  @override
  String get accept => 'Accept';

  @override
  String get notificationDismissed => 'Notification dismissed';

  @override
  String openingRequest(Object requestId) {
    return 'Opening request $requestId...';
  }

  @override
  String get invitationAccepted => 'Invitation accepted!';

  @override
  String failedToAcceptInvitation(Object error) {
    return 'Failed to accept invitation: $error';
  }

  @override
  String get unableToAcceptInvitation => 'Unable to accept invitation';

  @override
  String get unableToDeclineInvitation => 'Unable to decline invitation';

  @override
  String get invitationDeclined => 'Invitation declined';

  @override
  String failedToDeclineInvitation(Object error) {
    return 'Failed to decline invitation: $error';
  }

  @override
  String get justNow => 'Just now';

  @override
  String get analytics => 'Analytics';

  @override
  String get overview => 'Overview';

  @override
  String get trends => 'Trends';

  @override
  String get performance => 'Performance';

  @override
  String get totalRequests => 'Total Requests';

  @override
  String get pendingCount => 'Pending';

  @override
  String get approvedCount => 'Approved';

  @override
  String get rejectedCount => 'Rejected';

  @override
  String get approvalRate => 'Approval Rate';

  @override
  String get noData => 'No Data';

  @override
  String get workspaceInfo => 'Workspace Info';

  @override
  String get plan => 'Plan';

  @override
  String get members => 'Members';

  @override
  String get created => 'Created';

  @override
  String get weeklyActivity => 'Weekly Activity';

  @override
  String get requestTrends => 'Request Trends';

  @override
  String get topPerformers => 'Top Performers';

  @override
  String performerStats(Object approved, Object rejected) {
    return '$approved approved • $rejected rejected';
  }

  @override
  String get averageApprovalTime => 'Average Approval Time';

  @override
  String level(Object level) {
    return 'Level $level';
  }

  @override
  String get overall => 'Overall';

  @override
  String get monday => 'Mon';

  @override
  String get tuesday => 'Tue';

  @override
  String get wednesday => 'Wed';

  @override
  String get thursday => 'Thu';

  @override
  String get friday => 'Fri';

  @override
  String get saturday => 'Sat';

  @override
  String get sunday => 'Sun';

  @override
  String get viewAnalytics => 'View Analytics';

  @override
  String get exportReports => 'Export Reports';

  @override
  String get subscription => 'Subscription';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get upgradePlan => 'Upgrade Plan';

  @override
  String get recommended => 'RECOMMENDED';

  @override
  String currentPlan(Object plan) {
    return 'Current Plan: $plan';
  }

  @override
  String get compareAllPlans => 'Compare All Plans';

  @override
  String get maybeLater => 'Maybe Later';

  @override
  String upgradeToPlan(Object plan) {
    return 'Upgrade to $plan';
  }

  @override
  String get viewPlans => 'View Plans';

  @override
  String planName(Object plan) {
    return '$plan';
  }

  @override
  String planPrice(Object price) {
    return '$price';
  }

  @override
  String get comparePlans => 'Compare Plans';

  @override
  String get choosePlan => 'Choose the plan that fits your needs';

  @override
  String get current => 'CURRENT';

  @override
  String get limitReached => 'Limit reached. Upgrade your plan to add more.';

  @override
  String get approachingLimit => 'Approaching limit. Consider upgrading soon.';

  @override
  String resourceLimitReached(Object resource) {
    return '$resource Limit Reached';
  }

  @override
  String limitReachedMessage(Object resource) {
    return 'You\'ve reached the maximum number of $resource allowed by your plan.';
  }

  @override
  String get noRecentActivity => 'No recent activity';

  @override
  String get recentActivityDescription =>
      'Your requests and approvals will appear here';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get viewAll => 'View All';

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
    return '$time ago';
  }

  @override
  String get minutes => 'm';

  @override
  String get hours => 'h';

  @override
  String get days => 'd';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get myPending => 'My Pending';

  @override
  String get toApprove => 'To Approve';

  @override
  String get myApproved => 'My Approved';

  @override
  String get total => 'Total';
}
