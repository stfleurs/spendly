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

  /// The name of the app
  ///
  /// In en, this message translates to:
  /// **'Receet Pro'**
  String get appName;

  /// Label for net worth section
  ///
  /// In en, this message translates to:
  /// **'NET WORTH'**
  String get netWorth;

  /// Label for accounts section
  ///
  /// In en, this message translates to:
  /// **'ACCOUNTS'**
  String get accounts;

  /// Label for reports section
  ///
  /// In en, this message translates to:
  /// **'REPORTS'**
  String get reports;

  /// Label for activity section
  ///
  /// In en, this message translates to:
  /// **'ACTIVITY'**
  String get activity;

  /// Label for budget section
  ///
  /// In en, this message translates to:
  /// **'MY BUDGET'**
  String get myBudget;

  /// Button label to create a new transaction
  ///
  /// In en, this message translates to:
  /// **'NEW TRANSACTION'**
  String get newTransaction;

  /// Button label to save a transaction
  ///
  /// In en, this message translates to:
  /// **'SAVE TRANSACTION'**
  String get saveTransaction;

  /// Button label to log in
  ///
  /// In en, this message translates to:
  /// **'LOG IN'**
  String get logIn;

  /// Button label to log out
  ///
  /// In en, this message translates to:
  /// **'LOG OUT'**
  String get logOut;

  /// Button label to sign up
  ///
  /// In en, this message translates to:
  /// **'SIGN UP'**
  String get signUp;

  /// Button label to create an account
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get createAccount;

  /// Label for email input field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Label for password input field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Label for confirm password input field
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Label for account name input
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT NAME'**
  String get accountName;

  /// Label for account type selector
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT TYPE'**
  String get accountType;

  /// Label for account color picker
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT COLOR'**
  String get accountColor;

  /// Label for currency selector
  ///
  /// In en, this message translates to:
  /// **'CURRENCY'**
  String get currency;

  /// Label for initial balance input
  ///
  /// In en, this message translates to:
  /// **'INITIAL BALANCE'**
  String get initialBalance;

  /// Button label to update an account
  ///
  /// In en, this message translates to:
  /// **'UPDATE ACCOUNT'**
  String get updateAccount;

  /// Button label to delete an account
  ///
  /// In en, this message translates to:
  /// **'DELETE ACCOUNT'**
  String get deleteAccount;

  /// Account type: checking
  ///
  /// In en, this message translates to:
  /// **'CHECKING'**
  String get checking;

  /// Account type: savings
  ///
  /// In en, this message translates to:
  /// **'SAVINGS'**
  String get savings;

  /// Account type: cash
  ///
  /// In en, this message translates to:
  /// **'CASH'**
  String get cash;

  /// Account type: credit card
  ///
  /// In en, this message translates to:
  /// **'CREDIT CARD'**
  String get creditCard;

  /// Label for current month view
  ///
  /// In en, this message translates to:
  /// **'THIS MONTH'**
  String get thisMonth;

  /// Label for month selector
  ///
  /// In en, this message translates to:
  /// **'SELECT MONTH'**
  String get selectMonth;

  /// Label for income total
  ///
  /// In en, this message translates to:
  /// **'INCOME'**
  String get income;

  /// Label for expense total
  ///
  /// In en, this message translates to:
  /// **'EXPENSE'**
  String get expense;

  /// Label for net total
  ///
  /// In en, this message translates to:
  /// **'NET'**
  String get net;

  /// Heading for spending by category chart
  ///
  /// In en, this message translates to:
  /// **'SPENDING BY CATEGORY'**
  String get spendingByCategory;

  /// Message shown when no transactions exist for a selected month
  ///
  /// In en, this message translates to:
  /// **'No transactions found for this month.'**
  String get noTransactionsMonth;

  /// Message shown when there are no transactions in the current month
  ///
  /// In en, this message translates to:
  /// **'No transactions this month.'**
  String get noTransactions;

  /// Hint text suggesting user tap the add button
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add one.'**
  String get tapToAdd;

  /// Placeholder hint for the transaction search bar
  ///
  /// In en, this message translates to:
  /// **'Search merchant, category...'**
  String get transactionsSearchHint;

  /// Filter option to show all transactions
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Filter option to show only expenses
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get filterExpense;

  /// Filter option to show only income
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get filterIncome;

  /// Filter option to show only transactions with receipts
  ///
  /// In en, this message translates to:
  /// **'With Receipt'**
  String get filterWithReceipt;

  /// Message shown when no search results match
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// Suggestion text when no results found
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters'**
  String get tryAdjustingFilters;

  /// Budget label for assigned amount
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get assigned;

  /// Budget label for spent amount
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// Budget label for overspent amount
  ///
  /// In en, this message translates to:
  /// **'OVERSPENT'**
  String get overspent;

  /// Budget label for remaining amount to spend
  ///
  /// In en, this message translates to:
  /// **'Left to spend'**
  String get leftToSpend;

  /// Label for category selector
  ///
  /// In en, this message translates to:
  /// **'CATEGORY'**
  String get category;

  /// Label for budget group
  ///
  /// In en, this message translates to:
  /// **'GROUP'**
  String get group;

  /// Label for budget target amount input
  ///
  /// In en, this message translates to:
  /// **'TARGET AMOUNT'**
  String get targetAmount;

  /// Label for budget recurrence selector
  ///
  /// In en, this message translates to:
  /// **'RECURRENCE'**
  String get recurrence;

  /// Recurrence option: weekly
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// Recurrence option: monthly
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// Recurrence option: yearly
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// Placeholder for account dropdown selector
  ///
  /// In en, this message translates to:
  /// **'Select Account'**
  String get selectAccount;

  /// Placeholder for category dropdown selector
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// Label for amount input field
  ///
  /// In en, this message translates to:
  /// **'AMOUNT'**
  String get amount;

  /// Label for payee or note input
  ///
  /// In en, this message translates to:
  /// **'PAYEE / NOTE'**
  String get payeeNote;

  /// Placeholder hint for payee input
  ///
  /// In en, this message translates to:
  /// **'Who or what for?'**
  String get payeeHint;

  /// Title for editing a transaction
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransaction;

  /// Button label to update a transaction
  ///
  /// In en, this message translates to:
  /// **'UPDATE TRANSACTION'**
  String get updateTransaction;

  /// Button label to delete a transaction
  ///
  /// In en, this message translates to:
  /// **'DELETE TRANSACTION'**
  String get deleteTransaction;

  /// Title for delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteConfirmTitle;

  /// Message for delete confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction?'**
  String get deleteConfirmMessage;

  /// Button label to cancel
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// Button label to confirm deletion
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get delete;

  /// Currency code for US Dollar
  ///
  /// In en, this message translates to:
  /// **'USD'**
  String get usd;

  /// Currency code for Haitian Gourde
  ///
  /// In en, this message translates to:
  /// **'HTG'**
  String get htg;

  /// Currency code for Euro
  ///
  /// In en, this message translates to:
  /// **'EUR'**
  String get eur;

  /// Currency code for Canadian Dollar
  ///
  /// In en, this message translates to:
  /// **'CAD'**
  String get cad;

  /// Abbreviation for January
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get jan;

  /// Abbreviation for February
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get feb;

  /// Abbreviation for March
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get mar;

  /// Abbreviation for April
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get apr;

  /// Abbreviation for May
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// Abbreviation for June
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get jun;

  /// Abbreviation for July
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get jul;

  /// Abbreviation for August
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get aug;

  /// Abbreviation for September
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get sep;

  /// Abbreviation for October
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get oct;

  /// Abbreviation for November
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get nov;

  /// Abbreviation for December
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get dec;

  /// Label for settings section
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Label for language selector
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Label for preferred currency selector
  ///
  /// In en, this message translates to:
  /// **'Preferred Currency'**
  String get preferredCurrency;

  /// Language option: English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Language option: French
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// Language option: Haitian Creole
  ///
  /// In en, this message translates to:
  /// **'Haitian Creole'**
  String get haitianCreole;

  /// Welcome title shown on onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to Receet Pro'**
  String get welcomeSpendly;

  /// Subtitle text for the onboarding screen
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your financial workspace in just a few steps.'**
  String get onboardingSubtitle;

  /// Button label to begin onboarding
  ///
  /// In en, this message translates to:
  /// **'GET STARTED'**
  String get getStarted;

  /// Heading for currency selection step
  ///
  /// In en, this message translates to:
  /// **'CHOOSE YOUR CURRENCY'**
  String get chooseCurrency;

  /// Button label to proceed to next step
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get next;

  /// Heading for first account creation step
  ///
  /// In en, this message translates to:
  /// **'YOUR FIRST ACCOUNT'**
  String get yourFirstAccount;

  /// Placeholder hint for account name input
  ///
  /// In en, this message translates to:
  /// **'e.g. My Wallet, Bank'**
  String get accountNameHint;

  /// Button label to finish setup
  ///
  /// In en, this message translates to:
  /// **'COMPLETE SETUP'**
  String get completeSetup;

  /// Button label to add another account during setup
  ///
  /// In en, this message translates to:
  /// **'ADD ANOTHER ACCOUNT'**
  String get addAnotherAccount;

  /// Validation message when no accounts have been created
  ///
  /// In en, this message translates to:
  /// **'Please add at least one account'**
  String get atLeastOneAccount;

  /// Button label to delete the user's entire account
  ///
  /// In en, this message translates to:
  /// **'Delete My User Account'**
  String get deleteUserAccount;

  /// Warning message shown before account deletion
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and will delete all your data, including accounts, transactions, and budget settings. This cannot be undone.'**
  String get deleteUserAccountWarning;

  /// Confirmation button text for account deletion
  ///
  /// In en, this message translates to:
  /// **'I understand, delete my account'**
  String get confirmDeleteUserAccount;

  /// Message prompting re-authentication before account deletion
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
