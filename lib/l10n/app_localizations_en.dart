// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Personal PIM';

  @override
  String get settings => 'Settings';

  @override
  String get appMenu => 'App Menu';

  @override
  String get home => 'Home';

  @override
  String get calendar => 'Calendar';

  @override
  String get calendarPlaceholder =>
      'Here will be a calendar with dates, reminder settings and a task manager';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get ukrainian => 'Ukrainian';

  @override
  String get german => 'German';

  @override
  String get french => 'French';

  @override
  String get spanish => 'Spanish';

  @override
  String get polish => 'Polish';

  @override
  String get myContacts => 'My Contacts';

  @override
  String get addContact => 'Add Contact';

  @override
  String get configureColumns => 'Configure Columns';

  @override
  String get configureTable => 'Table Settings';

  @override
  String get columnReorderInstruction =>
      'Drag to reorder. Tap ❌ to hide a column.';

  @override
  String get availableFieldsToAdd => 'Available fields to add:';

  @override
  String get allFieldsAlreadyInTable =>
      'All existing fields are already in the table';

  @override
  String get search => 'Search';

  @override
  String get all => 'All';

  @override
  String get noName => 'No Name';

  @override
  String get error => 'Error';

  @override
  String get loading => 'Loading';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get loginSubtitle => 'Please sign in to your account';

  @override
  String get login => 'Login';

  @override
  String get loginTitle => 'Login to App';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get register => 'Register';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get loginWithGoogle => 'Login with Google';

  @override
  String get pleaseEnterEmailAndPassword => 'Please enter email and password';

  @override
  String get fillAllFields => 'Please fill all fields';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get verificationEmailSent => 'Verification email sent to your mail!';

  @override
  String get verifyEmailTitle => 'Email Verification';

  @override
  String verificationEmailSentTo(String email) {
    return 'A confirmation email has been sent to:\n$email';
  }

  @override
  String get checkEmailInstructions =>
      'Please check your inbox and click on the link in the email to activate your account.\n\nIf there is no email within a few minutes, be sure to check your \"Spam\" folder.';

  @override
  String get emailResent => 'Email resent successfully!';

  @override
  String get resendEmail => 'Resend email';

  @override
  String get cancelAndReturn => 'Cancel and return';

  @override
  String get enterEmailToResetPassword => 'Enter email to reset password';

  @override
  String get passwordResetEmailSent => 'If account exists, reset email sent!';

  @override
  String get logout => 'Logout';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get name => 'Name';

  @override
  String get birthday => 'Birthday';

  @override
  String get groups => 'Groups';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get deleteContact => 'Delete Contact';

  @override
  String get deleteContactTitle => 'Delete Contact';

  @override
  String deleteContactConfirmation(Object name) {
    return 'Are you sure you want to delete \"$name\"?\nThis action cannot be undone.';
  }

  @override
  String get contactDeleted => 'Contact deleted';

  @override
  String get hideEmptyFields => 'Hide empty fields';

  @override
  String get showEmptyFields => 'Show empty fields';

  @override
  String get addField => 'Add field';

  @override
  String get intelligentInput => 'Intelligent input';

  @override
  String get listening => 'Listening...';

  @override
  String get tapToSpeak => 'Tap the microphone to speak';

  @override
  String get stop => 'Stop';

  @override
  String get aiInputHint => 'Write/paste copied text or dictate...';

  @override
  String get recognize => 'Recognize';

  @override
  String get newField => 'New field';

  @override
  String get fieldNameHint => 'Name (e.g. Telegram)';

  @override
  String get dataType => 'Data type:';

  @override
  String get textType => 'Text';

  @override
  String get numberType => 'Number/Phone';

  @override
  String get dateType => 'Date';

  @override
  String get booleanType => 'Boolean (Yes/No)';

  @override
  String get add => 'Add';

  @override
  String get chooseFieldType => 'Choose field type';

  @override
  String get deleteFieldTitle => 'Delete field';

  @override
  String deleteFieldConfirmation(Object name) {
    return 'Are you sure you want to delete field \"$name\"?\nThis action cannot be undone.';
  }

  @override
  String deleteFieldUsageWarning(int count) {
    return 'This field has data in $count contacts. Delete it for everyone?';
  }

  @override
  String get fieldDeleted => 'Field deleted';

  @override
  String get changeFieldType => 'Change field type';

  @override
  String get rename => 'Rename';

  @override
  String get copyValue => 'Copy value';

  @override
  String get valueCopied => 'Value copied!';

  @override
  String get fieldName => 'Field name';

  @override
  String get tapToSelect => 'Tap to select...';

  @override
  String get selectDate => 'Select date';

  @override
  String get enterName => 'Enter name';

  @override
  String get groupSettings => 'Group settings';

  @override
  String get manageGroups => 'Manage groups';

  @override
  String get createNewGroup => 'Create new group...';

  @override
  String get noGroupsYet => 'No groups yet';

  @override
  String get configure => 'Configure';

  @override
  String get groupName => 'Group name';

  @override
  String get nameWithoutCommas => 'Name without commas';

  @override
  String get deleteGroupFromSystem => 'Delete group from system';

  @override
  String get groupDeleted => 'Group deleted';

  @override
  String get groupNameNoCommas => 'Group name cannot contain commas!';

  @override
  String get maxGroups => 'Maximum 15 groups!';

  @override
  String get maxSelectedGroups => 'Maximum 15 groups can be selected';

  @override
  String get failedToRecognizeAi => 'Failed to recognize contact data in text.';

  @override
  String get recognitionError => 'Recognition error';

  @override
  String get geminiApiKeyNotFound => 'GEMINI_API_KEY not found';

  @override
  String get serverOverloaded => 'Server overloaded. Try again later.';

  @override
  String get aiReturnedEmptyResponse => 'AI returned empty response';

  @override
  String get contactListEmpty => 'Contact list is empty';

  @override
  String get selectAtLeastOneColumn => 'Select at least one column in settings';

  @override
  String get noResultsFound => 'No results found for your query';

  @override
  String get reorderingDisabledWhileFiltering =>
      'Reordering is disabled during search or filtering';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get themeColor => 'Theme Color';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get importData => 'Import Data';

  @override
  String get exportData => 'Export Data';

  @override
  String get importSuccessful => 'Data imported successfully';

  @override
  String get importFailed => 'Failed to import data';

  @override
  String get exportSuccessful => 'Data exported successfully';

  @override
  String get exportFailed => 'Failed to export data';

  @override
  String get invalidFileFormat => 'Invalid file format';

  @override
  String get noDataToExport => 'No data to export';

  @override
  String get importFromPhone => 'Import from Phone Book';

  @override
  String get permissionDenied => 'Permission denied';

  @override
  String get selectContacts => 'Select Contacts';

  @override
  String importNContacts(int count) {
    return 'Import $count contacts';
  }

  @override
  String get eventsOnThisDay => 'Events on this day';

  @override
  String get noEventsOnThisDay => 'There are no events on this day';

  @override
  String get birthdayEvent => 'Birthday';

  @override
  String get remindEveryYear => 'Remind every year';

  @override
  String get remindBefore => 'Remind in advance:';

  @override
  String get halfYear => 'half a year';

  @override
  String get threeMonths => 'three months';

  @override
  String get month => 'month';

  @override
  String get twoWeeks => 'two weeks';

  @override
  String get week => 'week';

  @override
  String get threeDays => '3 days';

  @override
  String get day => 'day';

  @override
  String get today => 'on the day';

  @override
  String get reminderTime => 'Reminder Time';

  @override
  String get reminderSettings => 'Reminder Settings';

  @override
  String get todos => 'To-dos';

  @override
  String get addTodo => 'Add To-do';

  @override
  String get editTodo => 'Edit To-do';

  @override
  String get todoTitle => 'Title';

  @override
  String get todoDescription => 'Description';

  @override
  String get dueDate => 'Due Date';

  @override
  String get priority => 'Priority';

  @override
  String get low => 'Low';

  @override
  String get medium => 'Medium';

  @override
  String get high => 'High';

  @override
  String get todoDeleted => 'To-do deleted';

  @override
  String get deleteTodoConfirmation =>
      'Are you sure you want to delete this to-do?';

  @override
  String get invalidEmail => 'Invalid email format.';

  @override
  String get userNotFound => 'User not found.';

  @override
  String get wrongPassword => 'Wrong password.';

  @override
  String get invalidCredential => 'Invalid email or password.';

  @override
  String get emailAlreadyInUse => 'This email is already registered.';

  @override
  String get weakPassword => 'Password is too weak (minimum 6 characters).';

  @override
  String get tooManyRequests => 'Too many attempts. Try again later.';

  @override
  String get userDisabled => 'This account is disabled.';

  @override
  String get authError => 'Authentication error occurred.';

  @override
  String get googleClientIdNotFound => 'GOOGLE_CLIENT_ID not found.';

  @override
  String get authGoogleError => 'Google authentication error.';

  @override
  String get unknownLoginError => 'Unknown login error.';

  @override
  String get unknownRegistrationError => 'Unknown registration error.';

  @override
  String get userNotAuthenticated => 'User not authenticated.';

  @override
  String get unknownError => 'Unknown error.';

  @override
  String waitCooldown(int seconds) {
    return 'Wait $seconds sec. before resending.';
  }

  @override
  String get createAccount => 'Create Account';

  @override
  String get registerSubtitle => 'Please fill in the details to register';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Register';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get enterTextToRecognize => 'Enter text to recognize';

  @override
  String get stopRecordingToRecognize => 'Stop recording first to recognize';

  @override
  String get onboardingHomeTitle => 'Welcome to Personal PIM!';

  @override
  String get onboardingHomeDesc =>
      'Manage your contacts here. You can drag and drop rows to change their order, and clicking on a column header will sort the list by that field.';

  @override
  String get onboardingAddContactTitle => 'Add Contacts';

  @override
  String get onboardingAddContactDesc =>
      'Tap here to add a new contact manually or using AI.';

  @override
  String get onboardingCalendarTitle => 'Calendar & Tasks';

  @override
  String get onboardingCalendarDesc =>
      'View birthdays and your task list here.';

  @override
  String get onboardingSettingsTitle => 'App Settings';

  @override
  String get onboardingSettingsDesc =>
      'Customize the app, import/export data. Don\'t forget that you can add widgets to your home screen!';

  @override
  String get onboardingIntelligentInputTitle => 'Intelligent Input';

  @override
  String get onboardingIntelligentInputDesc =>
      'Paste any text about a contact (e.g., a message from a messenger), and AI will try to find fields and fill them automatically.';

  @override
  String get onboardingWidgetTitle => 'Add Widgets';

  @override
  String get onboardingWidgetDesc =>
      'Don\'t forget to add our widget to your home screen to see upcoming birthdays!';

  @override
  String get onboardingContactMeTitle => 'Contact Support';

  @override
  String get onboardingContactMeDesc => 'ladikovmax@gmail.com';

  @override
  String get withoutYear => 'Without year';

  @override
  String get orText => 'OR';

  @override
  String get testNotification => 'Test Notification';

  @override
  String get dailyReminderTitle => 'Mnemo PIM';

  @override
  String get dailyReminderBody => 'Don\'t forget to check your tasks today!';
}
