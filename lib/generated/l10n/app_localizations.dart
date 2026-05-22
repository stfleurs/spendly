import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ht.dart';

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
    Locale('fr'),
    Locale('ht'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Spendly'**
  String get appName;

  /// No description provided for @netWorth.
  ///
  /// In en, this message translates to:
  /// **'NET WORTH'**
  String get netWorth;

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNTS'**
  String get accounts;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'REPORTS'**
  String get reports;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'ACTIVITY'**
  String get activity;

  /// No description provided for @myBudget.
  ///
  /// In en, this message translates to:
  /// **'MY BUDGET'**
  String get myBudget;

  /// No description provided for @newTransaction.
  ///
  /// In en, this message translates to:
  /// **'NEW TRANSACTION'**
  String get newTransaction;

  /// No description provided for @saveTransaction.
  ///
  /// In en, this message translates to:
  /// **'SAVE TRANSACTION'**
  String get saveTransaction;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'LOG IN'**
  String get logIn;

  /// No description provided for @logOut.
  ///
  /// In en, this message translates to:
  /// **'LOG OUT'**
  String get logOut;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'SIGN UP'**
  String get signUp;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get createAccount;

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

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT NAME'**
  String get accountName;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT TYPE'**
  String get accountType;

  /// No description provided for @accountColor.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT COLOR'**
  String get accountColor;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'CURRENCY'**
  String get currency;

  /// No description provided for @initialBalance.
  ///
  /// In en, this message translates to:
  /// **'INITIAL BALANCE'**
  String get initialBalance;

  /// No description provided for @updateAccount.
  ///
  /// In en, this message translates to:
  /// **'UPDATE ACCOUNT'**
  String get updateAccount;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'DELETE ACCOUNT'**
  String get deleteAccount;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'CHECKING'**
  String get checking;

  /// No description provided for @savings.
  ///
  /// In en, this message translates to:
  /// **'SAVINGS'**
  String get savings;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'CASH'**
  String get cash;

  /// No description provided for @creditCard.
  ///
  /// In en, this message translates to:
  /// **'CREDIT CARD'**
  String get creditCard;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'THIS MONTH'**
  String get thisMonth;

  /// No description provided for @selectMonth.
  ///
  /// In en, this message translates to:
  /// **'SELECT MONTH'**
  String get selectMonth;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'INCOME'**
  String get income;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'EXPENSE'**
  String get expense;

  /// No description provided for @net.
  ///
  /// In en, this message translates to:
  /// **'NET'**
  String get net;

  /// No description provided for @spendingByCategory.
  ///
  /// In en, this message translates to:
  /// **'SPENDING BY CATEGORY'**
  String get spendingByCategory;

  /// No description provided for @noTransactionsMonth.
  ///
  /// In en, this message translates to:
  /// **'No transactions found for this month.'**
  String get noTransactionsMonth;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions this month.'**
  String get noTransactions;

  /// No description provided for @tapToAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add one.'**
  String get tapToAdd;

  /// No description provided for @assigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get assigned;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @overspent.
  ///
  /// In en, this message translates to:
  /// **'OVERSPENT'**
  String get overspent;

  /// No description provided for @leftToSpend.
  ///
  /// In en, this message translates to:
  /// **'Left to spend'**
  String get leftToSpend;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'CATEGORY'**
  String get category;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'GROUP'**
  String get group;

  /// No description provided for @targetAmount.
  ///
  /// In en, this message translates to:
  /// **'TARGET AMOUNT'**
  String get targetAmount;

  /// No description provided for @recurrence.
  ///
  /// In en, this message translates to:
  /// **'RECURRENCE'**
  String get recurrence;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @selectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select Account'**
  String get selectAccount;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT'**
  String get amount;

  /// No description provided for @payeeNote.
  ///
  /// In en, this message translates to:
  /// **'PAYEE / NOTE'**
  String get payeeNote;

  /// No description provided for @payeeHint.
  ///
  /// In en, this message translates to:
  /// **'Who or what for?'**
  String get payeeHint;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// No description provided for @updateTransaction.
  ///
  /// In en, this message translates to:
  /// **'UPDATE TRANSACTION'**
  String get updateTransaction;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'DELETE TRANSACTION'**
  String get deleteTransaction;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction?'**
  String get deleteConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get delete;

  /// No description provided for @usd.
  ///
  /// In en, this message translates to:
  /// **'USD'**
  String get usd;

  /// No description provided for @htg.
  ///
  /// In en, this message translates to:
  /// **'HTG'**
  String get htg;

  /// No description provided for @eur.
  ///
  /// In en, this message translates to:
  /// **'EUR'**
  String get eur;

  /// No description provided for @cad.
  ///
  /// In en, this message translates to:
  /// **'CAD'**
  String get cad;

  /// No description provided for @jan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get jan;

  /// No description provided for @feb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get feb;

  /// No description provided for @mar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get mar;

  /// No description provided for @apr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get apr;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @jun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get jun;

  /// No description provided for @jul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get jul;

  /// No description provided for @aug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get aug;

  /// No description provided for @sep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get sep;

  /// No description provided for @oct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get oct;

  /// No description provided for @nov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get nov;

  /// No description provided for @dec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get dec;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @preferredCurrency.
  ///
  /// In en, this message translates to:
  /// **'Preferred Currency'**
  String get preferredCurrency;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @haitianCreole.
  ///
  /// In en, this message translates to:
  /// **'Haitian Creole'**
  String get haitianCreole;

  /// No description provided for @welcomeSpendly.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Spendly'**
  String get welcomeSpendly;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your financial workspace in just a few steps.'**
  String get onboardingSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'GET STARTED'**
  String get getStarted;

  /// No description provided for @chooseCurrency.
  ///
  /// In en, this message translates to:
  /// **'CHOOSE YOUR CURRENCY'**
  String get chooseCurrency;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get next;

  /// No description provided for @yourFirstAccount.
  ///
  /// In en, this message translates to:
  /// **'YOUR FIRST ACCOUNT'**
  String get yourFirstAccount;

  /// No description provided for @accountNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. My Wallet, Bank'**
  String get accountNameHint;

  /// No description provided for @completeSetup.
  ///
  /// In en, this message translates to:
  /// **'COMPLETE SETUP'**
  String get completeSetup;

  /// No description provided for @addAnotherAccount.
  ///
  /// In en, this message translates to:
  /// **'ADD ANOTHER ACCOUNT'**
  String get addAnotherAccount;

  /// No description provided for @atLeastOneAccount.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one account'**
  String get atLeastOneAccount;

  /// No description provided for @deleteUserAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete My User Account'**
  String get deleteUserAccount;

  /// No description provided for @deleteUserAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and will delete all your data, including accounts, transactions, and budget settings. This cannot be undone.'**
  String get deleteUserAccountWarning;

  /// No description provided for @confirmDeleteUserAccount.
  ///
  /// In en, this message translates to:
  /// **'I understand, delete my account'**
  String get confirmDeleteUserAccount;

  /// No description provided for @reauthenticateRequired.
  ///
  /// In en, this message translates to:
  /// **'For security, you must re-authenticate before deleting your account.'**
  String get reauthenticateRequired;
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
      <String>['en', 'fr', 'ht'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'ht':
      return AppLocalizationsHt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
