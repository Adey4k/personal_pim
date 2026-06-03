import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_uk.dart';

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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pl'),
    Locale('uk'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal PIM'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @appMenu.
  ///
  /// In en, this message translates to:
  /// **'App Menu'**
  String get appMenu;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @calendarPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Here will be a calendar with dates, reminder settings and a task manager'**
  String get calendarPlaceholder;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @ukrainian.
  ///
  /// In en, this message translates to:
  /// **'Ukrainian'**
  String get ukrainian;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @polish.
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get polish;

  /// No description provided for @myContacts.
  ///
  /// In en, this message translates to:
  /// **'My Contacts'**
  String get myContacts;

  /// No description provided for @addContact.
  ///
  /// In en, this message translates to:
  /// **'Add Contact'**
  String get addContact;

  /// No description provided for @configureColumns.
  ///
  /// In en, this message translates to:
  /// **'Configure Columns'**
  String get configureColumns;

  /// No description provided for @configureTable.
  ///
  /// In en, this message translates to:
  /// **'Table Settings'**
  String get configureTable;

  /// No description provided for @columnReorderInstruction.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder. Tap ❌ to hide a column.'**
  String get columnReorderInstruction;

  /// No description provided for @availableFieldsToAdd.
  ///
  /// In en, this message translates to:
  /// **'Available fields to add:'**
  String get availableFieldsToAdd;

  /// No description provided for @allFieldsAlreadyInTable.
  ///
  /// In en, this message translates to:
  /// **'All existing fields are already in the table'**
  String get allFieldsAlreadyInTable;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'No Name'**
  String get noName;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login to App'**
  String get loginTitle;

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

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Login with Google'**
  String get loginWithGoogle;

  /// No description provided for @pleaseEnterEmailAndPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter email and password'**
  String get pleaseEnterEmailAndPassword;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get fillAllFields;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @verificationEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent to your mail!'**
  String get verificationEmailSent;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Verification'**
  String get verifyEmailTitle;

  /// No description provided for @verificationEmailSentTo.
  ///
  /// In en, this message translates to:
  /// **'A confirmation email has been sent to:\n{email}'**
  String verificationEmailSentTo(String email);

  /// No description provided for @checkEmailInstructions.
  ///
  /// In en, this message translates to:
  /// **'Please check your inbox and click on the link in the email to activate your account.\n\nIf there is no email within a few minutes, be sure to check your \"Spam\" folder.'**
  String get checkEmailInstructions;

  /// No description provided for @emailResent.
  ///
  /// In en, this message translates to:
  /// **'Email resent successfully!'**
  String get emailResent;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend email'**
  String get resendEmail;

  /// No description provided for @cancelAndReturn.
  ///
  /// In en, this message translates to:
  /// **'Cancel and return'**
  String get cancelAndReturn;

  /// No description provided for @enterEmailToResetPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter email to reset password'**
  String get enterEmailToResetPassword;

  /// No description provided for @passwordResetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'If account exists, reset email sent!'**
  String get passwordResetEmailSent;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteContact.
  ///
  /// In en, this message translates to:
  /// **'Delete Contact'**
  String get deleteContact;

  /// No description provided for @deleteContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Contact'**
  String get deleteContactTitle;

  /// No description provided for @deleteContactConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?\nThis action cannot be undone.'**
  String deleteContactConfirmation(Object name);

  /// No description provided for @contactDeleted.
  ///
  /// In en, this message translates to:
  /// **'Contact deleted'**
  String get contactDeleted;

  /// No description provided for @hideEmptyFields.
  ///
  /// In en, this message translates to:
  /// **'Hide empty fields'**
  String get hideEmptyFields;

  /// No description provided for @showEmptyFields.
  ///
  /// In en, this message translates to:
  /// **'Show empty fields'**
  String get showEmptyFields;

  /// No description provided for @addField.
  ///
  /// In en, this message translates to:
  /// **'Add field'**
  String get addField;

  /// No description provided for @intelligentInput.
  ///
  /// In en, this message translates to:
  /// **'Intelligent input'**
  String get intelligentInput;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// No description provided for @tapToSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap the microphone to speak'**
  String get tapToSpeak;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @aiInputHint.
  ///
  /// In en, this message translates to:
  /// **'Write/paste copied text or dictate...'**
  String get aiInputHint;

  /// No description provided for @recognize.
  ///
  /// In en, this message translates to:
  /// **'Recognize'**
  String get recognize;

  /// No description provided for @newField.
  ///
  /// In en, this message translates to:
  /// **'New field'**
  String get newField;

  /// No description provided for @fieldNameHint.
  ///
  /// In en, this message translates to:
  /// **'Name (e.g. Telegram)'**
  String get fieldNameHint;

  /// No description provided for @dataType.
  ///
  /// In en, this message translates to:
  /// **'Data type:'**
  String get dataType;

  /// No description provided for @textType.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get textType;

  /// No description provided for @numberType.
  ///
  /// In en, this message translates to:
  /// **'Number/Phone'**
  String get numberType;

  /// No description provided for @dateType.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateType;

  /// No description provided for @booleanType.
  ///
  /// In en, this message translates to:
  /// **'Boolean (Yes/No)'**
  String get booleanType;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @chooseFieldType.
  ///
  /// In en, this message translates to:
  /// **'Choose field type'**
  String get chooseFieldType;

  /// No description provided for @deleteFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete field'**
  String get deleteFieldTitle;

  /// No description provided for @deleteFieldConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete field \"{name}\"?\nThis action cannot be undone.'**
  String deleteFieldConfirmation(Object name);

  /// No description provided for @deleteFieldUsageWarning.
  ///
  /// In en, this message translates to:
  /// **'This field has data in {count} contacts. Delete it for everyone?'**
  String deleteFieldUsageWarning(int count);

  /// No description provided for @fieldDeleted.
  ///
  /// In en, this message translates to:
  /// **'Field deleted'**
  String get fieldDeleted;

  /// No description provided for @changeFieldType.
  ///
  /// In en, this message translates to:
  /// **'Change field type'**
  String get changeFieldType;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @copyValue.
  ///
  /// In en, this message translates to:
  /// **'Copy value'**
  String get copyValue;

  /// No description provided for @valueCopied.
  ///
  /// In en, this message translates to:
  /// **'Value copied!'**
  String get valueCopied;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Field name'**
  String get fieldName;

  /// No description provided for @tapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select...'**
  String get tapToSelect;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterName;

  /// No description provided for @groupSettings.
  ///
  /// In en, this message translates to:
  /// **'Group settings'**
  String get groupSettings;

  /// No description provided for @manageGroups.
  ///
  /// In en, this message translates to:
  /// **'Manage groups'**
  String get manageGroups;

  /// No description provided for @createNewGroup.
  ///
  /// In en, this message translates to:
  /// **'Create new group...'**
  String get createNewGroup;

  /// No description provided for @noGroupsYet.
  ///
  /// In en, this message translates to:
  /// **'No groups yet'**
  String get noGroupsYet;

  /// No description provided for @configure.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get configure;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupName;

  /// No description provided for @nameWithoutCommas.
  ///
  /// In en, this message translates to:
  /// **'Name without commas'**
  String get nameWithoutCommas;

  /// No description provided for @deleteGroupFromSystem.
  ///
  /// In en, this message translates to:
  /// **'Delete group from system'**
  String get deleteGroupFromSystem;

  /// No description provided for @groupDeleted.
  ///
  /// In en, this message translates to:
  /// **'Group deleted'**
  String get groupDeleted;

  /// No description provided for @groupNameNoCommas.
  ///
  /// In en, this message translates to:
  /// **'Group name cannot contain commas!'**
  String get groupNameNoCommas;

  /// No description provided for @max10Groups.
  ///
  /// In en, this message translates to:
  /// **'Maximum 10 groups!'**
  String get max10Groups;

  /// No description provided for @max10SelectedGroups.
  ///
  /// In en, this message translates to:
  /// **'Maximum 10 groups can be selected'**
  String get max10SelectedGroups;

  /// No description provided for @failedToRecognizeAi.
  ///
  /// In en, this message translates to:
  /// **'Failed to recognize contact data in text.'**
  String get failedToRecognizeAi;

  /// No description provided for @recognitionError.
  ///
  /// In en, this message translates to:
  /// **'Recognition error'**
  String get recognitionError;

  /// No description provided for @geminiApiKeyNotFound.
  ///
  /// In en, this message translates to:
  /// **'GEMINI_API_KEY not found'**
  String get geminiApiKeyNotFound;

  /// No description provided for @serverOverloaded.
  ///
  /// In en, this message translates to:
  /// **'Server overloaded. Try again later.'**
  String get serverOverloaded;

  /// No description provided for @aiReturnedEmptyResponse.
  ///
  /// In en, this message translates to:
  /// **'AI returned empty response'**
  String get aiReturnedEmptyResponse;

  /// No description provided for @contactListEmpty.
  ///
  /// In en, this message translates to:
  /// **'Contact list is empty'**
  String get contactListEmpty;

  /// No description provided for @selectAtLeastOneColumn.
  ///
  /// In en, this message translates to:
  /// **'Select at least one column in settings'**
  String get selectAtLeastOneColumn;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found for your query'**
  String get noResultsFound;

  /// No description provided for @reorderingDisabledWhileFiltering.
  ///
  /// In en, this message translates to:
  /// **'Reordering is disabled during search or filtering'**
  String get reorderingDisabledWhileFiltering;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeMode;

  /// No description provided for @themeColor.
  ///
  /// In en, this message translates to:
  /// **'Theme Color'**
  String get themeColor;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// No description provided for @importSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Data imported successfully'**
  String get importSuccessful;

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to import data'**
  String get importFailed;

  /// No description provided for @exportSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully'**
  String get exportSuccessful;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to export data'**
  String get exportFailed;

  /// No description provided for @invalidFileFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid file format'**
  String get invalidFileFormat;

  /// No description provided for @noDataToExport.
  ///
  /// In en, this message translates to:
  /// **'No data to export'**
  String get noDataToExport;

  /// No description provided for @importFromPhone.
  ///
  /// In en, this message translates to:
  /// **'Import from Phone Book'**
  String get importFromPhone;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied'**
  String get permissionDenied;

  /// No description provided for @selectContacts.
  ///
  /// In en, this message translates to:
  /// **'Select Contacts'**
  String get selectContacts;

  /// No description provided for @importNContacts.
  ///
  /// In en, this message translates to:
  /// **'Import {count} contacts'**
  String importNContacts(int count);

  /// No description provided for @eventsOnThisDay.
  ///
  /// In en, this message translates to:
  /// **'Events on this day'**
  String get eventsOnThisDay;

  /// No description provided for @noEventsOnThisDay.
  ///
  /// In en, this message translates to:
  /// **'There are no events on this day'**
  String get noEventsOnThisDay;

  /// No description provided for @birthdayEvent.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthdayEvent;

  /// No description provided for @remindEveryYear.
  ///
  /// In en, this message translates to:
  /// **'Remind every year'**
  String get remindEveryYear;

  /// No description provided for @remindBefore.
  ///
  /// In en, this message translates to:
  /// **'Remind in advance:'**
  String get remindBefore;

  /// No description provided for @halfYear.
  ///
  /// In en, this message translates to:
  /// **'half a year'**
  String get halfYear;

  /// No description provided for @threeMonths.
  ///
  /// In en, this message translates to:
  /// **'three months'**
  String get threeMonths;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;

  /// No description provided for @twoWeeks.
  ///
  /// In en, this message translates to:
  /// **'two weeks'**
  String get twoWeeks;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'week'**
  String get week;

  /// No description provided for @threeDays.
  ///
  /// In en, this message translates to:
  /// **'3 days'**
  String get threeDays;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'on the day'**
  String get today;

  /// No description provided for @reminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder Time'**
  String get reminderTime;

  /// No description provided for @reminderSettings.
  ///
  /// In en, this message translates to:
  /// **'Reminder Settings'**
  String get reminderSettings;

  /// No description provided for @todos.
  ///
  /// In en, this message translates to:
  /// **'To-dos'**
  String get todos;

  /// No description provided for @addTodo.
  ///
  /// In en, this message translates to:
  /// **'Add To-do'**
  String get addTodo;

  /// No description provided for @editTodo.
  ///
  /// In en, this message translates to:
  /// **'Edit To-do'**
  String get editTodo;

  /// No description provided for @todoTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get todoTitle;

  /// No description provided for @todoDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get todoDescription;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @todoDeleted.
  ///
  /// In en, this message translates to:
  /// **'To-do deleted'**
  String get todoDeleted;

  /// No description provided for @deleteTodoConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this to-do?'**
  String get deleteTodoConfirmation;
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
    'de',
    'en',
    'es',
    'fr',
    'pl',
    'uk',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pl':
      return AppLocalizationsPl();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
