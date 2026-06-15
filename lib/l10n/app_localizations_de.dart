// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Persönlicher PIM';

  @override
  String get settings => 'Einstellungen';

  @override
  String get appMenu => 'App-Menü';

  @override
  String get home => 'Startseite';

  @override
  String get calendar => 'Kalender';

  @override
  String get calendarPlaceholder =>
      'Hier wird ein Kalender mit Terminen, Erinnerungseinstellungen und einem Aufgabenmanager sein';

  @override
  String get language => 'Sprache';

  @override
  String get english => 'Englisch';

  @override
  String get ukrainian => 'Ukrainisch';

  @override
  String get german => 'Deutsch';

  @override
  String get french => 'Französisch';

  @override
  String get spanish => 'Spanisch';

  @override
  String get polish => 'Polnisch';

  @override
  String get myContacts => 'Meine Kontakte';

  @override
  String get addContact => 'Kontakt hinzufügen';

  @override
  String get configureColumns => 'Spalten konfigurieren';

  @override
  String get configureTable => 'Tabelleneinstellungen';

  @override
  String get columnReorderInstruction =>
      'Ziehen zum Umordnen. Tippen Sie auf ❌, um eine Spalte auszublenden.';

  @override
  String get availableFieldsToAdd => 'Verfügbare Felder zum Hinzufügen:';

  @override
  String get allFieldsAlreadyInTable =>
      'Alle vorhandenen Felder sind bereits in der Tabelle';

  @override
  String get search => 'Suchen';

  @override
  String get all => 'Alle';

  @override
  String get noName => 'Kein Name';

  @override
  String get error => 'Fehler';

  @override
  String get loading => 'Laden...';

  @override
  String get welcomeBack => 'Willkommen zurück!';

  @override
  String get loginSubtitle => 'Bitte melden Sie sich an, um fortzufahren';

  @override
  String get login => 'Anmelden';

  @override
  String get loginTitle => 'Anmeldung bei der App';

  @override
  String get password => 'Passwort';

  @override
  String get confirmPassword => 'Passwort bestätigen';

  @override
  String get register => 'Registrieren';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get loginWithGoogle => 'Mit Google anmelden';

  @override
  String get pleaseEnterEmailAndPassword =>
      'Bitte E-Mail und Passwort eingeben';

  @override
  String get fillAllFields => 'Bitte alle Felder ausfüllen';

  @override
  String get passwordsDoNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get verificationEmailSent =>
      'Bestätigungs-E-Mail an Ihre Post gesendet!';

  @override
  String get verifyEmailTitle => 'E-Mail-Verifizierung';

  @override
  String verificationEmailSentTo(String email) {
    return 'Eine Bestätigungs-E-Mail wurde gesendet an:\n$email';
  }

  @override
  String get checkEmailInstructions =>
      'Bitte überprüfen Sie Ihren Posteingang und klicken Sie auf den Link in der E-Mail, um Ihr Konto zu aktivieren.\n\nWenn innerhalb weniger Minuten keine E-Mail eintrifft, überprüfen Sie unbedingt Ihren \'Spam\'-Ordner.';

  @override
  String get emailResent => 'E-Mail erfolgreich erneut gesendet!';

  @override
  String get resendEmail => 'E-Mail erneut senden';

  @override
  String get cancelAndReturn => 'Abbrechen und zurück';

  @override
  String get enterEmailToResetPassword =>
      'E-Mail zum Zurücksetzen des Passworts eingeben';

  @override
  String get passwordResetEmailSent =>
      'Falls das Konto existiert, wurde eine E-Mail zum Zurücksetzen gesendet!';

  @override
  String get logout => 'Abmelden';

  @override
  String get email => 'E-Mail';

  @override
  String get phone => 'Telefon';

  @override
  String get name => 'Name';

  @override
  String get birthday => 'Geburtstag';

  @override
  String get groups => 'Gruppen';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get delete => 'Löschen';

  @override
  String get deleteContact => 'Kontakt löschen';

  @override
  String get deleteContactTitle => 'Kontakt löschen';

  @override
  String deleteContactConfirmation(Object name) {
    return 'Sind Sie sicher, dass Sie \"$name\" löschen möchten?\nDiese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String get contactDeleted => 'Kontakt gelöscht';

  @override
  String get hideEmptyFields => 'Leere Felder ausblenden';

  @override
  String get showEmptyFields => 'Leere Felder anzeigen';

  @override
  String get addField => 'Feld hinzufügen';

  @override
  String get intelligentInput => 'Intelligente Eingabe';

  @override
  String get listening => 'Zuhören...';

  @override
  String get tapToSpeak => 'Tippen Sie auf das Mikrofon, um zu sprechen';

  @override
  String get stop => 'Stopp';

  @override
  String get aiInputHint =>
      'Kopierten Text schreiben/einfügen oder diktieren...';

  @override
  String get recognize => 'Erkennen';

  @override
  String get newField => 'Neues Feld';

  @override
  String get fieldNameHint => 'Name (z.B. Telegram)';

  @override
  String get dataType => 'Datentyp:';

  @override
  String get textType => 'Text';

  @override
  String get numberType => 'Nummer/Telefon';

  @override
  String get dateType => 'Datum';

  @override
  String get booleanType => 'Boolean (Ja/Nein)';

  @override
  String get add => 'Hinzufügen';

  @override
  String get chooseFieldType => 'Feldtyp wählen';

  @override
  String get deleteFieldTitle => 'Feld löschen';

  @override
  String deleteFieldConfirmation(Object name) {
    return 'Sind Sie sicher, dass Sie das Feld \"$name\" löschen möchten?\nDiese Aktion kann nicht rückgängig gemacht werden.';
  }

  @override
  String deleteFieldUsageWarning(int count) {
    return 'Dieses Feld enthält Daten in $count Kontakten. Für alle löschen?';
  }

  @override
  String get fieldDeleted => 'Feld gelöscht';

  @override
  String get changeFieldType => 'Feldtyp ändern';

  @override
  String get rename => 'Umbenennen';

  @override
  String get copyValue => 'Wert kopieren';

  @override
  String get valueCopied => 'Wert kopiert!';

  @override
  String get fieldName => 'Feldname';

  @override
  String get tapToSelect => 'Tippen zum Auswählen...';

  @override
  String get selectDate => 'Datum auswählen';

  @override
  String get enterName => 'Name eingeben';

  @override
  String get groupSettings => 'Gruppeneinstellungen';

  @override
  String get manageGroups => 'Gruppen verwalten';

  @override
  String get createNewGroup => 'Neue Gruppe erstellen...';

  @override
  String get noGroupsYet => 'Noch keine Gruppen';

  @override
  String get configure => 'Konfigurieren';

  @override
  String get groupName => 'Gruppenname';

  @override
  String get nameWithoutCommas => 'Name ohne Kommas';

  @override
  String get deleteGroupFromSystem => 'Gruppe aus dem System löschen';

  @override
  String get groupDeleted => 'Gruppe gelöscht';

  @override
  String get groupNameNoCommas => 'Gruppenname darf keine Kommas enthalten!';

  @override
  String get maxGroups => 'Maximal 15 Gruppen!';

  @override
  String get maxSelectedGroups => 'Maximal 15 Gruppen können ausgewählt werden';

  @override
  String get failedToRecognizeAi =>
      'Kontaktdaten im Text konnten nicht erkannt werden.';

  @override
  String get recognitionError => 'Erkennungsfehler';

  @override
  String get geminiApiKeyNotFound => 'GEMINI_API_KEY nicht gefunden';

  @override
  String get serverOverloaded =>
      'Server überlastet. Versuchen Sie es später erneut.';

  @override
  String get aiReturnedEmptyResponse => 'KI gab eine leere Antwort zurück';

  @override
  String get contactListEmpty => 'Kontaktliste ist leer';

  @override
  String get selectAtLeastOneColumn =>
      'Wählen Sie mindestens eine Spalte in den Einstellungen aus';

  @override
  String get noResultsFound => 'Keine Ergebnisse für Ihre Anfrage gefunden';

  @override
  String get reorderingDisabledWhileFiltering =>
      'Das Umordnen ist während der Suche oder Filterung deaktiviert';

  @override
  String get themeMode => 'Themenmodus';

  @override
  String get themeColor => 'Themenfarbe';

  @override
  String get light => 'Hell';

  @override
  String get dark => 'Dunkel';

  @override
  String get dataManagement => 'Datenmanagement';

  @override
  String get importData => 'Daten importieren';

  @override
  String get exportData => 'Daten exportieren';

  @override
  String get importSuccessful => 'Daten erfolgreich importiert';

  @override
  String get importFailed => 'Datenimport fehlgeschlagen';

  @override
  String get exportSuccessful => 'Daten erfolgreich exportiert';

  @override
  String get exportFailed => 'Datenexport fehlgeschlagen';

  @override
  String get invalidFileFormat => 'Ungültiges Dateiformat';

  @override
  String get noDataToExport => 'Keine Daten zum Exportieren';

  @override
  String get importFromPhone => 'Vom Telefonbuch importieren';

  @override
  String get permissionDenied => 'Berechtigung verweigert';

  @override
  String get selectContacts => 'Kontakte auswählen';

  @override
  String importNContacts(int count) {
    return '$count Kontakte importieren';
  }

  @override
  String get eventsOnThisDay => 'Ereignisse an diesem Tag';

  @override
  String get noEventsOnThisDay => 'An diesem Tag gibt es keine Ereignisse';

  @override
  String get birthdayEvent => 'Geburtstag';

  @override
  String get remindEveryYear => 'Jedes Jahr erinnern';

  @override
  String get remindBefore => 'Im Voraus erinnern:';

  @override
  String get halfYear => 'ein halbes Jahr';

  @override
  String get threeMonths => 'drei Monate';

  @override
  String get month => 'Monat';

  @override
  String get twoWeeks => 'zwei Wochen';

  @override
  String get week => 'Woche';

  @override
  String get threeDays => '3 Tage';

  @override
  String get day => 'Tag';

  @override
  String get today => 'am Tag selbst';

  @override
  String get reminderTime => 'Erinnerungszeit';

  @override
  String get reminderSettings => 'Erinnerungseinstellungen';

  @override
  String get todos => 'Aufgaben';

  @override
  String get addTodo => 'Aufgabe hinzufügen';

  @override
  String get editTodo => 'Aufgabe bearbeiten';

  @override
  String get todoTitle => 'Titel';

  @override
  String get todoDescription => 'Beschreibung';

  @override
  String get dueDate => 'Fälligkeitsdatum';

  @override
  String get priority => 'Priorität';

  @override
  String get low => 'Niedrig';

  @override
  String get medium => 'Mittel';

  @override
  String get high => 'Hoch';

  @override
  String get todoDeleted => 'Aufgabe gelöscht';

  @override
  String get deleteTodoConfirmation =>
      'Sind Sie sicher, dass Sie diese Aufgabe löschen möchten?';

  @override
  String get invalidEmail => 'Ungültiges E-Mail-Format.';

  @override
  String get userNotFound => 'Benutzer nicht gefunden.';

  @override
  String get wrongPassword => 'Falsches Passwort.';

  @override
  String get invalidCredential => 'Ungültige E-Mail oder Passwort.';

  @override
  String get emailAlreadyInUse => 'Diese E-Mail ist bereits registriert.';

  @override
  String get weakPassword => 'Passwort ist zu schwach (mindestens 6 Zeichen).';

  @override
  String get tooManyRequests =>
      'Zu viele Versuche. Versuchen Sie es später erneut.';

  @override
  String get userDisabled => 'Dieses Konto ist deaktiviert.';

  @override
  String get authError => 'Authentifizierungsfehler aufgetreten.';

  @override
  String get googleClientIdNotFound => 'GOOGLE_CLIENT_ID nicht gefunden.';

  @override
  String get authGoogleError => 'Google-Authentifizierungsfehler.';

  @override
  String get unknownLoginError => 'Unbekannter Anmeldefehler.';

  @override
  String get unknownRegistrationError => 'Unbekannter Registrierungsfehler.';

  @override
  String get userNotAuthenticated => 'Benutzer nicht authentifiziert.';

  @override
  String get unknownError => 'Unbekannter Fehler.';

  @override
  String waitCooldown(int seconds) {
    return 'Warten Sie $seconds Sek. vor dem erneuten Senden.';
  }

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get registerSubtitle =>
      'Bitte füllen Sie die Details zur Registrierung aus';

  @override
  String get firstName => 'Vorname';

  @override
  String get lastName => 'Nachname';

  @override
  String get dontHaveAccount => 'Sie haben kein Konto? Registrieren';

  @override
  String get alreadyHaveAccount => 'Haben Sie bereits ein Konto? Anmelden';

  @override
  String get enterTextToRecognize => 'Geben Sie Text zum Erkennen ein';

  @override
  String get stopRecordingToRecognize => 'Stoppen Sie zuerst die Aufnahme';

  @override
  String get onboardingHomeTitle => 'Willkommen bei Personal PIM!';

  @override
  String get onboardingHomeDesc =>
      'Verwalten Sie hier Ihre Kontakte. Sie können Zeilen ziehen und ablegen, um ihre Reihenfolge zu ändern, und ein Klick auf einen Spaltenkopf sortiert die Liste nach diesem Feld.';

  @override
  String get onboardingAddContactTitle => 'Kontakte hinzufügen';

  @override
  String get onboardingAddContactDesc =>
      'Tippen Sie hier, um einen neuen Kontakt manuell oder mit KI hinzuzufügen.';

  @override
  String get onboardingCalendarTitle => 'Kalender & Aufgaben';

  @override
  String get onboardingCalendarDesc =>
      'Sehen Sie hier Geburtstage und Ihre Aufgabenliste.';

  @override
  String get onboardingSettingsTitle => 'App-Einstellungen';

  @override
  String get onboardingSettingsDesc =>
      'Passen Sie die App an, importieren/exportieren Sie Daten und finden Sie Widget-Infos.';

  @override
  String get onboardingIntelligentInputTitle => 'Intelligente Eingabe';

  @override
  String get onboardingIntelligentInputDesc =>
      'Fügen Sie einen beliebigen Text über einen Kontakt ein (z. B. eine Nachricht aus einem Messenger), und die KI wird versuchen, Felder zu finden und automatisch auszufüllen.';

  @override
  String get onboardingWidgetTitle => 'Widgets hinzufügen';

  @override
  String get onboardingWidgetDesc =>
      'Vergessen Sie nicht, unser Widget zu Ihrem Startbildschirm hinzuzufügen, um anstehende Geburtstage zu sehen!';

  @override
  String get onboardingContactMeTitle => 'Support kontaktieren';

  @override
  String get onboardingContactMeDesc =>
      'Haben Sie Vorschläge? Kontaktieren Sie mich unter ladikovmax@gmail.com';

  @override
  String get withoutYear => 'Ohne Jahr';

  @override
  String get orText => 'ODER';

  @override
  String get testNotification => 'Testbenachrichtigung';

  @override
  String get dailyReminderTitle => 'Mnemo PIM';

  @override
  String get dailyReminderBody =>
      'Vergessen Sie nicht, heute Ihre Aufgaben zu überprüfen!';
}
