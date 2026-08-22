import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fil.dart';

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
    Locale('fil'),
  ];

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginTitle;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @signUpHere.
  ///
  /// In en, this message translates to:
  /// **'Sign up here'**
  String get signUpHere;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// No description provided for @logInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Log In with Google'**
  String get logInWithGoogle;

  /// No description provided for @logInButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logInButton;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpTitle;

  /// No description provided for @displayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get displayNameLabel;

  /// No description provided for @displayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your display name'**
  String get displayNameHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get confirmPasswordHint;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @loginHere.
  ///
  /// In en, this message translates to:
  /// **'Login here'**
  String get loginHere;

  /// No description provided for @signUpWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up with Google'**
  String get signUpWithGoogle;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreated;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// No description provided for @captureImage.
  ///
  /// In en, this message translates to:
  /// **'Capture Image'**
  String get captureImage;

  /// No description provided for @captureUpload.
  ///
  /// In en, this message translates to:
  /// **'Capture or upload image to scan'**
  String get captureUpload;

  /// No description provided for @totalScans.
  ///
  /// In en, this message translates to:
  /// **'Total Scans'**
  String get totalScans;

  /// No description provided for @totalHealthy.
  ///
  /// In en, this message translates to:
  /// **'Total Healthy'**
  String get totalHealthy;

  /// No description provided for @mostFrequent.
  ///
  /// In en, this message translates to:
  /// **'Most Frequent'**
  String get mostFrequent;

  /// No description provided for @recentScans.
  ///
  /// In en, this message translates to:
  /// **'Recent Scans'**
  String get recentScans;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @scanHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your scan history will appear here.\nTap a button above to get started.'**
  String get scanHistoryEmpty;

  /// No description provided for @scanHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan History'**
  String get scanHistoryTitle;

  /// No description provided for @sourceScanned.
  ///
  /// In en, this message translates to:
  /// **'Captured'**
  String get sourceScanned;

  /// No description provided for @sourceUploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get sourceUploaded;

  /// No description provided for @clearHistoryButton.
  ///
  /// In en, this message translates to:
  /// **'Clear History'**
  String get clearHistoryButton;

  /// No description provided for @clearHistoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all scan history? This cannot be undone.'**
  String get clearHistoryConfirm;

  /// No description provided for @clearHistoryCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get clearHistoryCancel;

  /// No description provided for @clearHistoryConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearHistoryConfirmButton;

  /// No description provided for @noScanHistory.
  ///
  /// In en, this message translates to:
  /// **'No scan history yet.'**
  String get noScanHistory;

  /// No description provided for @completedScans.
  ///
  /// In en, this message translates to:
  /// **'Your completed scans will appear here.'**
  String get completedScans;

  /// No description provided for @scanResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Results'**
  String get scanResultsTitle;

  /// No description provided for @scanInformation.
  ///
  /// In en, this message translates to:
  /// **'Scan Information'**
  String get scanInformation;

  /// No description provided for @imageSource.
  ///
  /// In en, this message translates to:
  /// **'Image Source'**
  String get imageSource;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @pointsOfInterest.
  ///
  /// In en, this message translates to:
  /// **'Points of Interest'**
  String get pointsOfInterest;

  /// No description provided for @heatmapCaption.
  ///
  /// In en, this message translates to:
  /// **'Red areas show where the disease was found'**
  String get heatmapCaption;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @captureButton.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get captureButton;

  /// No description provided for @noImageSelected.
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get noImageSelected;

  /// No description provided for @tapBelowHint.
  ///
  /// In en, this message translates to:
  /// **'Tap below to take a photo or\nupload from your gallery'**
  String get tapBelowHint;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @takeNewPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take New Photo'**
  String get takeNewPhoto;

  /// No description provided for @uploadFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Upload from Gallery'**
  String get uploadFromGallery;

  /// No description provided for @chooseDifferentPhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose Different Photo'**
  String get chooseDifferentPhoto;

  /// No description provided for @analyzeButton.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get analyzeButton;

  /// No description provided for @notSavedToHistory.
  ///
  /// In en, this message translates to:
  /// **'Not saved to history'**
  String get notSavedToHistory;

  /// No description provided for @scanResultsShownBelow.
  ///
  /// In en, this message translates to:
  /// **'Your scan result is still shown below, but couldn\'t be saved to your history.'**
  String get scanResultsShownBelow;

  /// No description provided for @beforeYouScan.
  ///
  /// In en, this message translates to:
  /// **'Before you scan'**
  String get beforeYouScan;

  /// No description provided for @tipsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'A few tips for the best results'**
  String get tipsSubtitle;

  /// No description provided for @tip1.
  ///
  /// In en, this message translates to:
  /// **'Scan in good lighting for best results'**
  String get tip1;

  /// No description provided for @tip2.
  ///
  /// In en, this message translates to:
  /// **'Center the leaf within the frame'**
  String get tip2;

  /// No description provided for @tip3.
  ///
  /// In en, this message translates to:
  /// **'Hold your phone steady while scanning'**
  String get tip3;

  /// No description provided for @tip4.
  ///
  /// In en, this message translates to:
  /// **'Scan a single leaf at a time for accurate results'**
  String get tip4;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @displayMode.
  ///
  /// In en, this message translates to:
  /// **'Display Mode'**
  String get displayMode;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @aboutLabel.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutLabel;

  /// No description provided for @aboutAppLabel.
  ///
  /// In en, this message translates to:
  /// **'About the App'**
  String get aboutAppLabel;

  /// No description provided for @aboutMsg.
  ///
  /// In en, this message translates to:
  /// **'CapsiCAM is a chili pepper leaf disease classification app developed as part of an undergraduate thesis study.\n\nVersion 1.0.0'**
  String get aboutMsg;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @helpSupportmsg.
  ///
  /// In en, this message translates to:
  /// **'For questions or issues, please contact your system administrator or refer to the thesis documentation.'**
  String get helpSupportmsg;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get logOut;

  /// No description provided for @logOutSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logOutSure;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit Account'**
  String get editAccount;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @editDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Edit Display Name'**
  String get editDisplayName;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountDetails;

  /// No description provided for @dateCreated.
  ///
  /// In en, this message translates to:
  /// **'Date Created'**
  String get dateCreated;

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

  /// No description provided for @confirmNewPass.
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPass;

  /// No description provided for @errorEmptyEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address.'**
  String get errorEmptyEmail;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get errorInvalidEmail;

  /// No description provided for @errorEmptyPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get errorEmptyPassword;

  /// No description provided for @errorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get errorWrongPassword;

  /// No description provided for @errorEmailNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email.'**
  String get errorEmailNotFound;

  /// No description provided for @errorEmailNotVerified.
  ///
  /// In en, this message translates to:
  /// **'Please verify your email before logging in.'**
  String get errorEmailNotVerified;

  /// No description provided for @errorTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many login attempts. Please try again later.'**
  String get errorTooManyAttempts;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Please check your network.'**
  String get errorNetwork;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorServer;

  /// No description provided for @errorGoogleNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No account linked to this Google account.'**
  String get errorGoogleNoAccount;

  /// No description provided for @errorEmptyDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your display name.'**
  String get errorEmptyDisplayName;

  /// No description provided for @errorDisplayNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Display name must be at least 2 characters.'**
  String get errorDisplayNameTooShort;

  /// No description provided for @errorDisplayNameTooLong.
  ///
  /// In en, this message translates to:
  /// **'Display name must be no more than 32 characters.'**
  String get errorDisplayNameTooLong;

  /// No description provided for @errorEmptyConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password.'**
  String get errorEmptyConfirmPassword;

  /// No description provided for @errorPasswordsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get errorPasswordsNoMatch;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get errorPasswordTooShort;

  /// No description provided for @errorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account with this email already exists. Try logging in instead.'**
  String get errorEmailInUse;

  /// No description provided for @errorGoogleEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this Google account. Try logging in instead.'**
  String get errorGoogleEmailInUse;

  /// No description provided for @successDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display name updated successfully.'**
  String get successDisplayName;

  /// No description provided for @errorEmptyCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current password.'**
  String get errorEmptyCurrentPassword;

  /// No description provided for @errorEmptyNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new password.'**
  String get errorEmptyNewPassword;

  /// No description provided for @errorSamePassword.
  ///
  /// In en, this message translates to:
  /// **'New password must be different from your current password.'**
  String get errorSamePassword;

  /// No description provided for @errorEmptyConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new password.'**
  String get errorEmptyConfirmNewPassword;

  /// No description provided for @successPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed! You\'re all set.'**
  String get successPasswordChanged;

  /// No description provided for @offlineNoCache.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Showing what we could load.'**
  String get offlineNoCache;

  /// No description provided for @retryButton.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// No description provided for @cacheAgeJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get cacheAgeJustNow;

  /// No description provided for @cacheAgeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String cacheAgeMinutes(int count);

  /// No description provided for @cacheAgeHours.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String cacheAgeHours(int count);

  /// No description provided for @cacheAgeDays.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String cacheAgeDays(int count);

  /// No description provided for @dashboardOfflineCached.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Showing saved data from {age}.'**
  String dashboardOfflineCached(String age);

  /// No description provided for @dashboardRefreshFailedCached.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t refresh. Showing saved data from {age}.'**
  String dashboardRefreshFailedCached(String age);

  /// No description provided for @dashboardShowingCachedRefreshing.
  ///
  /// In en, this message translates to:
  /// **'Showing saved data from {age} — refreshing…'**
  String dashboardShowingCachedRefreshing(String age);

  /// No description provided for @dashboardLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your dashboard. Pull down or tap retry.'**
  String get dashboardLoadFailed;

  /// No description provided for @retrySnackbarStillOffline.
  ///
  /// In en, this message translates to:
  /// **'Still offline.'**
  String get retrySnackbarStillOffline;

  /// No description provided for @retrySnackbarCouldNotRefresh.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t refresh.'**
  String get retrySnackbarCouldNotRefresh;

  /// No description provided for @retrySnackbarDashboardRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Dashboard refreshed.'**
  String get retrySnackbarDashboardRefreshed;

  /// No description provided for @historyOfflineCached.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Showing saved history from {age}.'**
  String historyOfflineCached(String age);

  /// No description provided for @historyRefreshFailedCached.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t refresh. Showing saved history from {age}.'**
  String historyRefreshFailedCached(String age);

  /// No description provided for @historyLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your scan history. Pull down or tap retry.'**
  String get historyLoadFailed;

  /// No description provided for @offlineSavedData.
  ///
  /// In en, this message translates to:
  /// **'Offline · saved data'**
  String get offlineSavedData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fil'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fil':
      return AppLocalizationsFil();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
