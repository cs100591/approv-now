import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_th.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('id'),
    Locale('ja'),
    Locale('ko'),
    Locale('ms'),
    Locale('th'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant')
  ];

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @workspaces.
  ///
  /// In en, this message translates to:
  /// **'Workspaces'**
  String get workspaces;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// No description provided for @and.
  ///
  /// In en, this message translates to:
  /// **'and'**
  String get and;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayName;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'No Name'**
  String get noName;

  /// No description provided for @signInToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInToYourAccount;

  /// No description provided for @signUpToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Sign up to get started with Approve Now'**
  String get signUpToGetStarted;

  /// No description provided for @enterYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get enterYourEmail;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterYourPassword;

  /// No description provided for @enterYourFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterYourFullName;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @emailIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailIsRequired;

  /// No description provided for @pleaseEnterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// No description provided for @passwordIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordIsRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @nameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameIsRequired;

  /// No description provided for @pleaseConfirmYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmYourPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @accountCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreatedSuccessfully;

  /// No description provided for @registrationTimedOut.
  ///
  /// In en, this message translates to:
  /// **'Registration timed out. Please try again.'**
  String get registrationTimedOut;

  /// No description provided for @enableBiometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Enable Biometric Login?'**
  String get enableBiometricLogin;

  /// No description provided for @biometricLoginDescription.
  ///
  /// In en, this message translates to:
  /// **'Would you like to enable fingerprint or face ID for quick login?'**
  String get biometricLoginDescription;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @biometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get biometricLogin;

  /// No description provided for @useBiometric.
  ///
  /// In en, this message translates to:
  /// **'Use Biometric'**
  String get useBiometric;

  /// No description provided for @faceId.
  ///
  /// In en, this message translates to:
  /// **'Face ID'**
  String get faceId;

  /// No description provided for @fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get fingerprint;

  /// No description provided for @biometricEnabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric login enabled'**
  String get biometricEnabled;

  /// No description provided for @biometricDisabled.
  ///
  /// In en, this message translates to:
  /// **'Biometric login disabled'**
  String get biometricDisabled;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @logOutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logOutConfirmation;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile: {error}'**
  String failedToUpdateProfile(Object error);

  /// No description provided for @settingsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Settings coming soon'**
  String get settingsComingSoon;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Approve Now v{version}'**
  String version(Object version);

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© {year} Approve Now. All rights reserved.'**
  String copyright(Object year);

  /// No description provided for @workspace.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get workspace;

  /// No description provided for @manageWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'Manage Workspaces'**
  String get manageWorkspaces;

  /// No description provided for @joinWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Join Workspace'**
  String get joinWorkspace;

  /// No description provided for @createWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Create Workspace'**
  String get createWorkspace;

  /// No description provided for @switchWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Switch Workspace'**
  String get switchWorkspace;

  /// No description provided for @workspaceName.
  ///
  /// In en, this message translates to:
  /// **'Workspace Name'**
  String get workspaceName;

  /// No description provided for @workspaceDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get workspaceDescription;

  /// No description provided for @myCompany.
  ///
  /// In en, this message translates to:
  /// **'My Company'**
  String get myCompany;

  /// No description provided for @briefDescription.
  ///
  /// In en, this message translates to:
  /// **'Brief description'**
  String get briefDescription;

  /// No description provided for @noWorkspaces.
  ///
  /// In en, this message translates to:
  /// **'No Workspaces'**
  String get noWorkspaces;

  /// No description provided for @createFirstWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Create your first workspace to get started'**
  String get createFirstWorkspace;

  /// No description provided for @settingUpWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Setting up your workspace...'**
  String get settingUpWorkspace;

  /// No description provided for @loadingWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Loading your workspace...'**
  String get loadingWorkspace;

  /// No description provided for @workspaceLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Workspace Limit Reached'**
  String get workspaceLimitReached;

  /// No description provided for @workspaceLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You need to upgrade your plan to create more workspaces.'**
  String get workspaceLimitMessage;

  /// No description provided for @workspaceLimitReachedMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the maximum number of workspaces allowed by your plan.'**
  String get workspaceLimitReachedMessage;

  /// No description provided for @defaultWorkspaceCreated.
  ///
  /// In en, this message translates to:
  /// **'Welcome! Default workspace created successfully.'**
  String get defaultWorkspaceCreated;

  /// No description provided for @failedToCreateWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Failed to create workspace. Please try again.'**
  String get failedToCreateWorkspace;

  /// No description provided for @noWorkspaceFound.
  ///
  /// In en, this message translates to:
  /// **'No Workspace Found'**
  String get noWorkspaceFound;

  /// No description provided for @noWorkspaceFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to create a workspace at this time.'**
  String get noWorkspaceFoundMessage;

  /// No description provided for @createFirstWorkspaceButton.
  ///
  /// In en, this message translates to:
  /// **'Create Workspace'**
  String get createFirstWorkspaceButton;

  /// No description provided for @workspaceCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Workspace created successfully'**
  String get workspaceCreatedSuccessfully;

  /// No description provided for @switchedToWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Switched to {workspaceName}'**
  String switchedToWorkspace(Object workspaceName);

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @createNewWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Create New Workspace'**
  String get createNewWorkspace;

  /// No description provided for @teamMembers.
  ///
  /// In en, this message translates to:
  /// **'Team Members'**
  String get teamMembers;

  /// No description provided for @inviteNewMember.
  ///
  /// In en, this message translates to:
  /// **'Invite New Member'**
  String get inviteNewMember;

  /// No description provided for @noWorkspaceSelected.
  ///
  /// In en, this message translates to:
  /// **'No Workspace Selected'**
  String get noWorkspaceSelected;

  /// No description provided for @selectWorkspaceFirst.
  ///
  /// In en, this message translates to:
  /// **'Please select a workspace first'**
  String get selectWorkspaceFirst;

  /// No description provided for @pendingInvitation.
  ///
  /// In en, this message translates to:
  /// **'Pending Invitation'**
  String get pendingInvitation;

  /// No description provided for @changeRole.
  ///
  /// In en, this message translates to:
  /// **'Change Role'**
  String get changeRole;

  /// No description provided for @removeMember.
  ///
  /// In en, this message translates to:
  /// **'Remove Member'**
  String get removeMember;

  /// No description provided for @removeMemberConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {memberEmail}?'**
  String removeMemberConfirmation(Object memberEmail);

  /// No description provided for @cannotRemovePending.
  ///
  /// In en, this message translates to:
  /// **'Cannot remove pending invitation from here'**
  String get cannotRemovePending;

  /// No description provided for @memberRemoved.
  ///
  /// In en, this message translates to:
  /// **'{memberEmail} removed'**
  String memberRemoved(Object memberEmail);

  /// No description provided for @changeRoleForMember.
  ///
  /// In en, this message translates to:
  /// **'Change Role for {memberEmail}'**
  String changeRoleForMember(Object memberEmail);

  /// No description provided for @generateInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Generate Invite Code'**
  String get generateInviteCode;

  /// No description provided for @generateInviteCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Generate a 6-character invite code for team members to join.'**
  String get generateInviteCodeDescription;

  /// No description provided for @codeDetails.
  ///
  /// In en, this message translates to:
  /// **'Code Details'**
  String get codeDetails;

  /// No description provided for @codeDetailsDescription.
  ///
  /// In en, this message translates to:
  /// **'• Valid for 24 hours\n• Can be used by multiple people\n• New members join as Viewer role'**
  String get codeDetailsDescription;

  /// No description provided for @generateCode.
  ///
  /// In en, this message translates to:
  /// **'Generate Code'**
  String get generateCode;

  /// No description provided for @inviteCodeGenerated.
  ///
  /// In en, this message translates to:
  /// **'Invite Code Generated'**
  String get inviteCodeGenerated;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'Expires: {date}'**
  String expires(Object date);

  /// No description provided for @shareCodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Share this code with team members to invite them to your workspace.'**
  String get shareCodeDescription;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copyCode;

  /// No description provided for @codeCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get codeCopiedToClipboard;

  /// No description provided for @teamMemberLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Team Member Limit Reached'**
  String get teamMemberLimitReached;

  /// No description provided for @teamMemberLimitMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the maximum number of team members allowed by your plan.'**
  String get teamMemberLimitMessage;

  /// No description provided for @emailNotificationsDisabled.
  ///
  /// In en, this message translates to:
  /// **'Email notifications are currently disabled. Team members will need to check the app for invitations.'**
  String get emailNotificationsDisabled;

  /// No description provided for @templates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templates;

  /// No description provided for @template.
  ///
  /// In en, this message translates to:
  /// **'Template'**
  String get template;

  /// No description provided for @newTemplate.
  ///
  /// In en, this message translates to:
  /// **'New Template'**
  String get newTemplate;

  /// No description provided for @createTemplate.
  ///
  /// In en, this message translates to:
  /// **'Create Template'**
  String get createTemplate;

  /// No description provided for @noTemplates.
  ///
  /// In en, this message translates to:
  /// **'No Templates'**
  String get noTemplates;

  /// No description provided for @createFirstTemplate.
  ///
  /// In en, this message translates to:
  /// **'Create your first template to get started'**
  String get createFirstTemplate;

  /// No description provided for @contactAdminToCreateTemplate.
  ///
  /// In en, this message translates to:
  /// **'Contact workspace admin to create templates'**
  String get contactAdminToCreateTemplate;

  /// No description provided for @templateFields.
  ///
  /// In en, this message translates to:
  /// **'Form Fields'**
  String get templateFields;

  /// No description provided for @templateApprovalSteps.
  ///
  /// In en, this message translates to:
  /// **'Approval Steps'**
  String get templateApprovalSteps;

  /// No description provided for @templateInformation.
  ///
  /// In en, this message translates to:
  /// **'Template Information'**
  String get templateInformation;

  /// No description provided for @basicDetails.
  ///
  /// In en, this message translates to:
  /// **'Basic details about this template'**
  String get basicDetails;

  /// No description provided for @templateName.
  ///
  /// In en, this message translates to:
  /// **'Template Name'**
  String get templateName;

  /// No description provided for @templateDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get templateDescription;

  /// No description provided for @defineFormFields.
  ///
  /// In en, this message translates to:
  /// **'Define the fields users will fill out'**
  String get defineFormFields;

  /// No description provided for @noFieldsYet.
  ///
  /// In en, this message translates to:
  /// **'No fields yet'**
  String get noFieldsYet;

  /// No description provided for @addFirstField.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first field or use AI to generate'**
  String get addFirstField;

  /// No description provided for @whoNeedsToApprove.
  ///
  /// In en, this message translates to:
  /// **'Who needs to approve this request?'**
  String get whoNeedsToApprove;

  /// No description provided for @noApprovalSteps.
  ///
  /// In en, this message translates to:
  /// **'No approval steps'**
  String get noApprovalSteps;

  /// No description provided for @addAtLeastOneApprover.
  ///
  /// In en, this message translates to:
  /// **'Add at least one approver'**
  String get addAtLeastOneApprover;

  /// No description provided for @text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text;

  /// No description provided for @multiline.
  ///
  /// In en, this message translates to:
  /// **'Multiline'**
  String get multiline;

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get number;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @dropdown.
  ///
  /// In en, this message translates to:
  /// **'Dropdown'**
  String get dropdown;

  /// No description provided for @checkbox.
  ///
  /// In en, this message translates to:
  /// **'Checkbox'**
  String get checkbox;

  /// No description provided for @file.
  ///
  /// In en, this message translates to:
  /// **'File'**
  String get file;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @moveUp.
  ///
  /// In en, this message translates to:
  /// **'Move up'**
  String get moveUp;

  /// No description provided for @moveDown.
  ///
  /// In en, this message translates to:
  /// **'Move down'**
  String get moveDown;

  /// No description provided for @onlyOwnerCanCreateTemplate.
  ///
  /// In en, this message translates to:
  /// **'Only workspace owner or admin can create templates'**
  String get onlyOwnerCanCreateTemplate;

  /// No description provided for @generationFailed.
  ///
  /// In en, this message translates to:
  /// **'Generation Failed'**
  String get generationFailed;

  /// No description provided for @aiConfigApplied.
  ///
  /// In en, this message translates to:
  /// **'Applied AI configuration: {scenario}'**
  String aiConfigApplied(Object scenario);

  /// No description provided for @addField.
  ///
  /// In en, this message translates to:
  /// **'Add Field'**
  String get addField;

  /// No description provided for @editField.
  ///
  /// In en, this message translates to:
  /// **'Edit Field'**
  String get editField;

  /// No description provided for @fieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Field Label'**
  String get fieldLabel;

  /// No description provided for @fieldType.
  ///
  /// In en, this message translates to:
  /// **'Field Type'**
  String get fieldType;

  /// No description provided for @placeholder.
  ///
  /// In en, this message translates to:
  /// **'Placeholder (Optional)'**
  String get placeholder;

  /// No description provided for @hintText.
  ///
  /// In en, this message translates to:
  /// **'Hint text for this field'**
  String get hintText;

  /// No description provided for @dropdownOptions.
  ///
  /// In en, this message translates to:
  /// **'Dropdown Options'**
  String get dropdownOptions;

  /// No description provided for @addOption.
  ///
  /// In en, this message translates to:
  /// **'Add Option'**
  String get addOption;

  /// No description provided for @checkedByDefault.
  ///
  /// In en, this message translates to:
  /// **'Checked by default'**
  String get checkedByDefault;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required Field'**
  String get requiredField;

  /// No description provided for @usersMustFill.
  ///
  /// In en, this message translates to:
  /// **'Users must fill this field'**
  String get usersMustFill;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @pleaseEnterTemplateName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a template name'**
  String get pleaseEnterTemplateName;

  /// No description provided for @pleaseEnterFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Please enter a field label'**
  String get pleaseEnterFieldLabel;

  /// No description provided for @pleaseAddDropdownOption.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one dropdown option'**
  String get pleaseAddDropdownOption;

  /// No description provided for @pleaseAddOneField.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one field'**
  String get pleaseAddOneField;

  /// No description provided for @templateCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Template created successfully'**
  String get templateCreatedSuccessfully;

  /// No description provided for @failedToCreateTemplate.
  ///
  /// In en, this message translates to:
  /// **'Failed to create template. Please try again.'**
  String get failedToCreateTemplate;

  /// No description provided for @approvalStep.
  ///
  /// In en, this message translates to:
  /// **'Approval Step {level}'**
  String approvalStep(Object level);

  /// No description provided for @addApproversForStep.
  ///
  /// In en, this message translates to:
  /// **'Add approvers for this step'**
  String get addApproversForStep;

  /// No description provided for @stepName.
  ///
  /// In en, this message translates to:
  /// **'Step Name'**
  String get stepName;

  /// No description provided for @noWorkspaceMembers.
  ///
  /// In en, this message translates to:
  /// **'No workspace members available. Please add members first.'**
  String get noWorkspaceMembers;

  /// No description provided for @selectApprover.
  ///
  /// In en, this message translates to:
  /// **'Select Approver'**
  String get selectApprover;

  /// No description provided for @chooseFromMembers.
  ///
  /// In en, this message translates to:
  /// **'Choose from workspace members'**
  String get chooseFromMembers;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get owner;

  /// No description provided for @requireAllApprovers.
  ///
  /// In en, this message translates to:
  /// **'Require all approvers'**
  String get requireAllApprovers;

  /// No description provided for @everyoneMustApprove.
  ///
  /// In en, this message translates to:
  /// **'Everyone must approve to proceed'**
  String get everyoneMustApprove;

  /// No description provided for @pleaseEnterStepName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a step name'**
  String get pleaseEnterStepName;

  /// No description provided for @pleaseAddOneApprover.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one approver'**
  String get pleaseAddOneApprover;

  /// No description provided for @deleteTemplate.
  ///
  /// In en, this message translates to:
  /// **'Delete Template'**
  String get deleteTemplate;

  /// No description provided for @deleteTemplateConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{templateName}\"?'**
  String deleteTemplateConfirmation(Object templateName);

  /// No description provided for @useTemplate.
  ///
  /// In en, this message translates to:
  /// **'Use Template'**
  String get useTemplate;

  /// No description provided for @fieldCount.
  ///
  /// In en, this message translates to:
  /// **'{count} fields'**
  String fieldCount(Object count);

  /// No description provided for @stepCount.
  ///
  /// In en, this message translates to:
  /// **'{count} steps'**
  String stepCount(Object count);

  /// No description provided for @templateStatusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get templateStatusActive;

  /// No description provided for @templateStatusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get templateStatusInactive;

  /// No description provided for @briefDescriptionOfTemplate.
  ///
  /// In en, this message translates to:
  /// **'Brief description of this template'**
  String get briefDescriptionOfTemplate;

  /// No description provided for @eG.
  ///
  /// In en, this message translates to:
  /// **'eG,'**
  String get eG;

  /// No description provided for @eGdepartment.
  ///
  /// In en, this message translates to:
  /// **'eG, Department, Amount'**
  String get eGdepartment;

  /// No description provided for @eGmarketing.
  ///
  /// In en, this message translates to:
  /// **'eG, Marketing'**
  String get eGmarketing;

  /// No description provided for @eGmanager.
  ///
  /// In en, this message translates to:
  /// **'eG, Manager Review'**
  String get eGmanager;

  /// No description provided for @eGbudget.
  ///
  /// In en, this message translates to:
  /// **'eG, Budget Approval'**
  String get eGbudget;

  /// No description provided for @newRequest.
  ///
  /// In en, this message translates to:
  /// **'New Request'**
  String get newRequest;

  /// No description provided for @requestDetails.
  ///
  /// In en, this message translates to:
  /// **'Request Details'**
  String get requestDetails;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get submitRequest;

  /// No description provided for @templateNotFound.
  ///
  /// In en, this message translates to:
  /// **'Template not found. Please select a template from the list.'**
  String get templateNotFound;

  /// No description provided for @noTemplatesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No Templates Available'**
  String get noTemplatesAvailable;

  /// No description provided for @createTemplateFirst.
  ///
  /// In en, this message translates to:
  /// **'Create a template first to submit a request'**
  String get createTemplateFirst;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @approvalFlow.
  ///
  /// In en, this message translates to:
  /// **'Approval Flow'**
  String get approvalFlow;

  /// No description provided for @approverCount.
  ///
  /// In en, this message translates to:
  /// **'{count} approver(s)'**
  String approverCount(Object count);

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get selectDate;

  /// No description provided for @selectOption.
  ///
  /// In en, this message translates to:
  /// **'Select an option'**
  String get selectOption;

  /// No description provided for @attachFile.
  ///
  /// In en, this message translates to:
  /// **'Attach a file'**
  String get attachFile;

  /// No description provided for @fileUploadComingSoon.
  ///
  /// In en, this message translates to:
  /// **'File upload coming soon'**
  String get fileUploadComingSoon;

  /// No description provided for @pleaseFillField.
  ///
  /// In en, this message translates to:
  /// **'Please fill in {fieldName}'**
  String pleaseFillField(Object fieldName);

  /// No description provided for @requestSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Request submitted successfully'**
  String get requestSubmittedSuccessfully;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @noWorkspaceSelectedError.
  ///
  /// In en, this message translates to:
  /// **'No workspace selected'**
  String get noWorkspaceSelectedError;

  /// No description provided for @approveRequest.
  ///
  /// In en, this message translates to:
  /// **'Approve Request'**
  String get approveRequest;

  /// No description provided for @rejectRequest.
  ///
  /// In en, this message translates to:
  /// **'Reject Request'**
  String get rejectRequest;

  /// No description provided for @reasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Reason (required)'**
  String get reasonRequired;

  /// No description provided for @commentOptional.
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get commentOptional;

  /// No description provided for @requestApproved.
  ///
  /// In en, this message translates to:
  /// **'Request approved ✓'**
  String get requestApproved;

  /// No description provided for @requestRejected.
  ///
  /// In en, this message translates to:
  /// **'Request rejected'**
  String get requestRejected;

  /// No description provided for @submittedBy.
  ///
  /// In en, this message translates to:
  /// **'Submitted by {name}'**
  String submittedBy(Object name);

  /// No description provided for @noFieldData.
  ///
  /// In en, this message translates to:
  /// **'No field data available'**
  String get noFieldData;

  /// No description provided for @approvalHistory.
  ///
  /// In en, this message translates to:
  /// **'Approval History'**
  String get approvalHistory;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @approve.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get approve;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @approved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approved;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @revised.
  ///
  /// In en, this message translates to:
  /// **'Revised'**
  String get revised;

  /// No description provided for @attachmentProvided.
  ///
  /// In en, this message translates to:
  /// **'Attachment provided'**
  String get attachmentProvided;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @notification.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notification;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No Notifications'**
  String get noNotifications;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get allCaughtUp;

  /// No description provided for @noFilteredNotifications.
  ///
  /// In en, this message translates to:
  /// **'No {filter} notifications'**
  String noFilteredNotifications(Object filter);

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @invitations.
  ///
  /// In en, this message translates to:
  /// **'Invitations'**
  String get invitations;

  /// No description provided for @requests.
  ///
  /// In en, this message translates to:
  /// **'Requests'**
  String get requests;

  /// No description provided for @invitationDismissed.
  ///
  /// In en, this message translates to:
  /// **'Invitation dismissed'**
  String get invitationDismissed;

  /// No description provided for @workspaceInvitation.
  ///
  /// In en, this message translates to:
  /// **'Workspace Invitation'**
  String get workspaceInvitation;

  /// No description provided for @invitedYou.
  ///
  /// In en, this message translates to:
  /// **'{name} invited you to join this workspace'**
  String invitedYou(Object name);

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @notificationDismissed.
  ///
  /// In en, this message translates to:
  /// **'Notification dismissed'**
  String get notificationDismissed;

  /// No description provided for @openingRequest.
  ///
  /// In en, this message translates to:
  /// **'Opening request {requestId}...'**
  String openingRequest(Object requestId);

  /// No description provided for @invitationAccepted.
  ///
  /// In en, this message translates to:
  /// **'Invitation accepted!'**
  String get invitationAccepted;

  /// No description provided for @failedToAcceptInvitation.
  ///
  /// In en, this message translates to:
  /// **'Failed to accept invitation: {error}'**
  String failedToAcceptInvitation(Object error);

  /// No description provided for @unableToAcceptInvitation.
  ///
  /// In en, this message translates to:
  /// **'Unable to accept invitation'**
  String get unableToAcceptInvitation;

  /// No description provided for @unableToDeclineInvitation.
  ///
  /// In en, this message translates to:
  /// **'Unable to decline invitation'**
  String get unableToDeclineInvitation;

  /// No description provided for @invitationDeclined.
  ///
  /// In en, this message translates to:
  /// **'Invitation declined'**
  String get invitationDeclined;

  /// No description provided for @failedToDeclineInvitation.
  ///
  /// In en, this message translates to:
  /// **'Failed to decline invitation: {error}'**
  String failedToDeclineInvitation(Object error);

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @trends.
  ///
  /// In en, this message translates to:
  /// **'Trends'**
  String get trends;

  /// No description provided for @performance.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// No description provided for @totalRequests.
  ///
  /// In en, this message translates to:
  /// **'Total Requests'**
  String get totalRequests;

  /// No description provided for @pendingCount.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pendingCount;

  /// No description provided for @approvedCount.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get approvedCount;

  /// No description provided for @rejectedCount.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejectedCount;

  /// No description provided for @approvalRate.
  ///
  /// In en, this message translates to:
  /// **'Approval Rate'**
  String get approvalRate;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get noData;

  /// No description provided for @workspaceInfo.
  ///
  /// In en, this message translates to:
  /// **'Workspace Info'**
  String get workspaceInfo;

  /// No description provided for @plan.
  ///
  /// In en, this message translates to:
  /// **'Plan'**
  String get plan;

  /// No description provided for @members.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get members;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @weeklyActivity.
  ///
  /// In en, this message translates to:
  /// **'Weekly Activity'**
  String get weeklyActivity;

  /// No description provided for @requestTrends.
  ///
  /// In en, this message translates to:
  /// **'Request Trends'**
  String get requestTrends;

  /// No description provided for @topPerformers.
  ///
  /// In en, this message translates to:
  /// **'Top Performers'**
  String get topPerformers;

  /// No description provided for @performerStats.
  ///
  /// In en, this message translates to:
  /// **'{approved} approved • {rejected} rejected'**
  String performerStats(Object approved, Object rejected);

  /// No description provided for @averageApprovalTime.
  ///
  /// In en, this message translates to:
  /// **'Average Approval Time'**
  String get averageApprovalTime;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String level(Object level);

  /// No description provided for @overall.
  ///
  /// In en, this message translates to:
  /// **'Overall'**
  String get overall;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunday;

  /// No description provided for @viewAnalytics.
  ///
  /// In en, this message translates to:
  /// **'View Analytics'**
  String get viewAnalytics;

  /// No description provided for @exportReports.
  ///
  /// In en, this message translates to:
  /// **'Export Reports'**
  String get exportReports;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @upgradePlan.
  ///
  /// In en, this message translates to:
  /// **'Upgrade Plan'**
  String get upgradePlan;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED'**
  String get recommended;

  /// No description provided for @currentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current Plan: {plan}'**
  String currentPlan(Object plan);

  /// No description provided for @compareAllPlans.
  ///
  /// In en, this message translates to:
  /// **'Compare All Plans'**
  String get compareAllPlans;

  /// No description provided for @maybeLater.
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLater;

  /// No description provided for @upgradeToPlan.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to {plan}'**
  String upgradeToPlan(Object plan);

  /// No description provided for @viewPlans.
  ///
  /// In en, this message translates to:
  /// **'View Plans'**
  String get viewPlans;

  /// No description provided for @planName.
  ///
  /// In en, this message translates to:
  /// **'{plan}'**
  String planName(Object plan);

  /// No description provided for @planPrice.
  ///
  /// In en, this message translates to:
  /// **'{price}'**
  String planPrice(Object price);

  /// No description provided for @comparePlans.
  ///
  /// In en, this message translates to:
  /// **'Compare Plans'**
  String get comparePlans;

  /// No description provided for @choosePlan.
  ///
  /// In en, this message translates to:
  /// **'Choose the plan that fits your needs'**
  String get choosePlan;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'CURRENT'**
  String get current;

  /// No description provided for @limitReached.
  ///
  /// In en, this message translates to:
  /// **'Limit reached. Upgrade your plan to add more.'**
  String get limitReached;

  /// No description provided for @approachingLimit.
  ///
  /// In en, this message translates to:
  /// **'Approaching limit. Consider upgrading soon.'**
  String get approachingLimit;

  /// No description provided for @resourceLimitReached.
  ///
  /// In en, this message translates to:
  /// **'{resource} Limit Reached'**
  String resourceLimitReached(Object resource);

  /// No description provided for @limitReachedMessage.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the maximum number of {resource} allowed by your plan.'**
  String limitReachedMessage(Object resource);

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get noRecentActivity;

  /// No description provided for @recentActivityDescription.
  ///
  /// In en, this message translates to:
  /// **'Your requests and approvals will appear here'**
  String get recentActivityDescription;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @activityRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'{templateName}'**
  String activityRequestTitle(Object templateName);

  /// No description provided for @activityStatus.
  ///
  /// In en, this message translates to:
  /// **'{status}'**
  String activityStatus(Object status);

  /// No description provided for @timeAgo.
  ///
  /// In en, this message translates to:
  /// **'{time} ago'**
  String timeAgo(Object time);

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get minutes;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hours;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'d'**
  String get days;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @myPending.
  ///
  /// In en, this message translates to:
  /// **'My Pending'**
  String get myPending;

  /// No description provided for @toApprove.
  ///
  /// In en, this message translates to:
  /// **'To Approve'**
  String get toApprove;

  /// No description provided for @myApproved.
  ///
  /// In en, this message translates to:
  /// **'My Approved'**
  String get myApproved;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'en',
        'es',
        'id',
        'ja',
        'ko',
        'ms',
        'th',
        'vi',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'ms':
      return AppLocalizationsMs();
    case 'th':
      return AppLocalizationsTh();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
