import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

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
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Document Vault BD'**
  String get appName;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @unlockVault.
  ///
  /// In en, this message translates to:
  /// **'Unlock Document Vault'**
  String get unlockVault;

  /// No description provided for @preparingVault.
  ///
  /// In en, this message translates to:
  /// **'Preparing your vault'**
  String get preparingVault;

  /// No description provided for @scanNewDocument.
  ///
  /// In en, this message translates to:
  /// **'Scan new document'**
  String get scanNewDocument;

  /// No description provided for @noDocumentsYet.
  ///
  /// In en, this message translates to:
  /// **'No documents yet'**
  String get noDocumentsYet;

  /// No description provided for @noDocumentsYetMessage.
  ///
  /// In en, this message translates to:
  /// **'Scan or import a document to build your private vault.'**
  String get noDocumentsYetMessage;

  /// No description provided for @readyToAddDocument.
  ///
  /// In en, this message translates to:
  /// **'Ready to add a document'**
  String get readyToAddDocument;

  /// No description provided for @readyToAddDocumentMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose Scan, Import photos, or Import PDF from the add-document flow.'**
  String get readyToAddDocumentMessage;

  /// No description provided for @noUpcomingReminders.
  ///
  /// In en, this message translates to:
  /// **'No upcoming reminders'**
  String get noUpcomingReminders;

  /// No description provided for @noUpcomingRemindersMessage.
  ///
  /// In en, this message translates to:
  /// **'Expiry reminders will appear here and never show document numbers.'**
  String get noUpcomingRemindersMessage;

  /// No description provided for @family.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tags;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @trash.
  ///
  /// In en, this message translates to:
  /// **'Trash'**
  String get trash;

  /// No description provided for @backupAndRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupAndRestore;

  /// No description provided for @storage.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storage;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @helpAndAbout.
  ///
  /// In en, this message translates to:
  /// **'Help & About'**
  String get helpAndAbout;

  /// No description provided for @familyEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add family members to organise documents by person.'**
  String get familyEmptyMessage;

  /// No description provided for @categoriesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'System categories will organise your documents.'**
  String get categoriesEmptyMessage;

  /// No description provided for @tagsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Create tags to group related documents.'**
  String get tagsEmptyMessage;

  /// No description provided for @archiveEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No archived documents'**
  String get archiveEmptyMessage;

  /// No description provided for @trashEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Trash is empty'**
  String get trashEmptyMessage;

  /// No description provided for @moreEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose an option from More after your vault is unlocked.'**
  String get moreEmptyMessage;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep your important documents safe and organized'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeOffline.
  ///
  /// In en, this message translates to:
  /// **'Works offline'**
  String get onboardingWelcomeOffline;

  /// No description provided for @onboardingWelcomeDevice.
  ///
  /// In en, this message translates to:
  /// **'Stored on this device'**
  String get onboardingWelcomeDevice;

  /// No description provided for @onboardingWelcomeBackup.
  ///
  /// In en, this message translates to:
  /// **'Expiry reminders and encrypted backup'**
  String get onboardingWelcomeBackup;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get changeLanguage;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose language'**
  String get chooseLanguage;

  /// No description provided for @languageBangla.
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get languageBangla;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your documents stay with you'**
  String get privacyTitle;

  /// No description provided for @privacyDevice.
  ///
  /// In en, this message translates to:
  /// **'Stored on your device'**
  String get privacyDevice;

  /// No description provided for @privacyNoAccount.
  ///
  /// In en, this message translates to:
  /// **'No app account required'**
  String get privacyNoAccount;

  /// No description provided for @privacyBackup.
  ///
  /// In en, this message translates to:
  /// **'Keep an encrypted backup'**
  String get privacyBackup;

  /// No description provided for @privacySharing.
  ///
  /// In en, this message translates to:
  /// **'Be careful when sharing'**
  String get privacySharing;

  /// No description provided for @understandContinue.
  ///
  /// In en, this message translates to:
  /// **'I understand — continue'**
  String get understandContinue;

  /// No description provided for @createVaultPin.
  ///
  /// In en, this message translates to:
  /// **'Create vault PIN'**
  String get createVaultPin;

  /// No description provided for @pinSetupInstruction.
  ///
  /// In en, this message translates to:
  /// **'Use a 6-digit PIN to unlock your vault.'**
  String get pinSetupInstruction;

  /// No description provided for @pinSetupWarning.
  ///
  /// In en, this message translates to:
  /// **'Do not use an easy PIN such as 123456.'**
  String get pinSetupWarning;

  /// No description provided for @usePin.
  ///
  /// In en, this message translates to:
  /// **'Use PIN'**
  String get usePin;

  /// No description provided for @forgotPin.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get forgotPin;

  /// No description provided for @unlockVaultDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlock your private document vault'**
  String get unlockVaultDescription;

  /// No description provided for @expiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring soon'**
  String get expiringSoon;

  /// No description provided for @categoryIdentity.
  ///
  /// In en, this message translates to:
  /// **'Identity'**
  String get categoryIdentity;

  /// No description provided for @categoryNid.
  ///
  /// In en, this message translates to:
  /// **'National ID (NID)'**
  String get categoryNid;

  /// No description provided for @categoryBirthCertificate.
  ///
  /// In en, this message translates to:
  /// **'Birth certificate'**
  String get categoryBirthCertificate;

  /// No description provided for @categoryPassport.
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get categoryPassport;

  /// No description provided for @categoryTaxFinancial.
  ///
  /// In en, this message translates to:
  /// **'Tax and Financial'**
  String get categoryTaxFinancial;

  /// No description provided for @categoryTin.
  ///
  /// In en, this message translates to:
  /// **'Taxpayer Identification Number (TIN)'**
  String get categoryTin;

  /// No description provided for @categoryBank.
  ///
  /// In en, this message translates to:
  /// **'Banking and finance'**
  String get categoryBank;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryCertificate.
  ///
  /// In en, this message translates to:
  /// **'Certificate and academic record'**
  String get categoryCertificate;

  /// No description provided for @categoryLandProperty.
  ///
  /// In en, this message translates to:
  /// **'Land and Property'**
  String get categoryLandProperty;

  /// No description provided for @categoryKhatian.
  ///
  /// In en, this message translates to:
  /// **'Khatian / খতিয়ান'**
  String get categoryKhatian;

  /// No description provided for @categoryMutation.
  ///
  /// In en, this message translates to:
  /// **'Mutation / নামজারি'**
  String get categoryMutation;

  /// No description provided for @categoryVehicle.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get categoryVehicle;

  /// No description provided for @categoryVehicleRegistration.
  ///
  /// In en, this message translates to:
  /// **'Vehicle registration'**
  String get categoryVehicleRegistration;

  /// No description provided for @categoryMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get categoryMedical;

  /// No description provided for @categoryPrescription.
  ///
  /// In en, this message translates to:
  /// **'Prescription'**
  String get categoryPrescription;

  /// No description provided for @categoryMarriageFamily.
  ///
  /// In en, this message translates to:
  /// **'Marriage and Family'**
  String get categoryMarriageFamily;

  /// No description provided for @categoryNikahnama.
  ///
  /// In en, this message translates to:
  /// **'Marriage certificate / Nikahnama'**
  String get categoryNikahnama;

  /// No description provided for @categoryEmployment.
  ///
  /// In en, this message translates to:
  /// **'Employment'**
  String get categoryEmployment;

  /// No description provided for @categoryAppointmentLetter.
  ///
  /// In en, this message translates to:
  /// **'Appointment letter'**
  String get categoryAppointmentLetter;

  /// No description provided for @categoryBusiness.
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get categoryBusiness;

  /// No description provided for @categoryTradeLicence.
  ///
  /// In en, this message translates to:
  /// **'Trade licence'**
  String get categoryTradeLicence;

  /// No description provided for @categorySchoolChildren.
  ///
  /// In en, this message translates to:
  /// **'School and Children'**
  String get categorySchoolChildren;

  /// No description provided for @categorySchoolAdmission.
  ///
  /// In en, this message translates to:
  /// **'School admission'**
  String get categorySchoolAdmission;

  /// No description provided for @categoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get categoryTravel;

  /// No description provided for @categoryVisa.
  ///
  /// In en, this message translates to:
  /// **'Visa'**
  String get categoryVisa;

  /// No description provided for @categoryWarrantyPurchases.
  ///
  /// In en, this message translates to:
  /// **'Warranty and Purchases'**
  String get categoryWarrantyPurchases;

  /// No description provided for @categoryPurchaseReceipt.
  ///
  /// In en, this message translates to:
  /// **'Purchase receipt'**
  String get categoryPurchaseReceipt;

  /// No description provided for @categoryLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get categoryLegal;

  /// No description provided for @categoryAffidavit.
  ///
  /// In en, this message translates to:
  /// **'Affidavit'**
  String get categoryAffidavit;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;
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
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
