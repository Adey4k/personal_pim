// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Osobisty PIM';

  @override
  String get settings => 'Ustawienia';

  @override
  String get appMenu => 'Menu aplikacji';

  @override
  String get home => 'Główna';

  @override
  String get calendar => 'Kalendarz';

  @override
  String get calendarPlaceholder =>
      'Tutaj znajdzie się kalendarz z datami, ustawieniami przypomnień i menedżerem zadań';

  @override
  String get language => 'Język';

  @override
  String get english => 'Angielski';

  @override
  String get ukrainian => 'Ukraiński';

  @override
  String get german => 'Niemiecki';

  @override
  String get french => 'Francuski';

  @override
  String get spanish => 'Hiszpański';

  @override
  String get polish => 'Polski';

  @override
  String get myContacts => 'Moje kontakty';

  @override
  String get addContact => 'Dodaj kontakt';

  @override
  String get configureColumns => 'Konfiguruj kolumny';

  @override
  String get configureTable => 'Ustawienia tabeli';

  @override
  String get columnReorderInstruction =>
      'Przeciągnij, aby zmienić kolejność. Dotknij ❌, aby ukryć kolumnę.';

  @override
  String get availableFieldsToAdd => 'Dostępne pola do dodania:';

  @override
  String get allFieldsAlreadyInTable =>
      'Wszystkie istniejące pola są już w tabeli';

  @override
  String get search => 'Szukaj';

  @override
  String get all => 'Wszystkie';

  @override
  String get noName => 'Brak nazwy';

  @override
  String get error => 'Błąd';

  @override
  String get loading => 'Ładowanie...';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get loginSubtitle => 'Please sign in to your account';

  @override
  String get login => 'Zaloguj się';

  @override
  String get loginTitle => 'Logowanie do aplikacji';

  @override
  String get password => 'Hasło';

  @override
  String get confirmPassword => 'Potwierdź hasło';

  @override
  String get register => 'Zarejestruj się';

  @override
  String get forgotPassword => 'Zapomniałeś hasła?';

  @override
  String get loginWithGoogle => 'Zaloguj się przez Google';

  @override
  String get pleaseEnterEmailAndPassword => 'Proszę wprowadzić e-mail i hasło';

  @override
  String get fillAllFields => 'Proszę wypełnić wszystkie pola';

  @override
  String get passwordsDoNotMatch => 'Hasła nie zgadzają się';

  @override
  String get verificationEmailSent =>
      'E-mail weryfikacyjny został wysłany na Twoją pocztę!';

  @override
  String get verifyEmailTitle => 'Weryfikacja e-mail';

  @override
  String verificationEmailSentTo(String email) {
    return 'E-mail potwierdzający został wysłany na adres:\n$email';
  }

  @override
  String get checkEmailInstructions =>
      'Proszę sprawdzić skrzynkę odbiorczą i kliknąć w link w e-mailu, aby aktywować konto.\n\nJeśli e-mail nie dotrze w ciągu kilku minut, sprawdź folder \'Spam\'.';

  @override
  String get emailResent => 'E-mail został wysłany ponownie!';

  @override
  String get resendEmail => 'Wyślij e-mail ponownie';

  @override
  String get cancelAndReturn => 'Anuluj i wróć';

  @override
  String get enterEmailToResetPassword =>
      'Wprowadź e-mail, aby zresetować hasło';

  @override
  String get passwordResetEmailSent =>
      'Jeśli konto istnieje, e-mail z resetem został wysłany!';

  @override
  String get logout => 'Wyloguj się';

  @override
  String get email => 'E-mail';

  @override
  String get phone => 'Telefon';

  @override
  String get name => 'Imię';

  @override
  String get birthday => 'Urodziny';

  @override
  String get groups => 'Grupy';

  @override
  String get save => 'Zapisz';

  @override
  String get cancel => 'Anuluj';

  @override
  String get edit => 'Edytuj';

  @override
  String get delete => 'Usuń';

  @override
  String get deleteContact => 'Usuń kontakt';

  @override
  String get deleteContactTitle => 'Usuń kontakt';

  @override
  String deleteContactConfirmation(Object name) {
    return 'Czy na pewno chcesz usunąć \"$name\"?\nTej operacji nie można cofnąć.';
  }

  @override
  String get contactDeleted => 'Kontakt usunięty';

  @override
  String get hideEmptyFields => 'Ukryj puste pola';

  @override
  String get showEmptyFields => 'Pokaż puste pola';

  @override
  String get addField => 'Dodaj pole';

  @override
  String get intelligentInput => 'Inteligentne wprowadzanie';

  @override
  String get listening => 'Słuchanie...';

  @override
  String get tapToSpeak => 'Dotknij mikrofonu, aby mówić';

  @override
  String get stop => 'Zatrzymaj';

  @override
  String get aiInputHint => 'Wpisz/wklej skopiowany tekst lub podyktuj...';

  @override
  String get recognize => 'Rozpoznaj';

  @override
  String get newField => 'Nowe pole';

  @override
  String get fieldNameHint => 'Nazwa (np. Telegram)';

  @override
  String get dataType => 'Typ danych:';

  @override
  String get textType => 'Tekst';

  @override
  String get numberType => 'Numer/Telefon';

  @override
  String get dateType => 'Data';

  @override
  String get booleanType => 'Logiczny (Tak/Nie)';

  @override
  String get add => 'Dodaj';

  @override
  String get chooseFieldType => 'Wybierz typ pola';

  @override
  String get deleteFieldTitle => 'Usuń pole';

  @override
  String deleteFieldConfirmation(Object name) {
    return 'Czy na pewno chcesz usunąć pole \"$name\"?\nTej operacji nie można cofnąć.';
  }

  @override
  String deleteFieldUsageWarning(int count) {
    return 'To pole zawiera dane u $count kontaktów. Usunąć je dla wszystkich?';
  }

  @override
  String get fieldDeleted => 'Pole usunięte';

  @override
  String get changeFieldType => 'Zmień typ pola';

  @override
  String get rename => 'Zmień nazwę';

  @override
  String get copyValue => 'Kopiuj wartość';

  @override
  String get valueCopied => 'Wartość skopiowana!';

  @override
  String get fieldName => 'Nazwa pola';

  @override
  String get tapToSelect => 'Dotknij, aby wybrać...';

  @override
  String get selectDate => 'Wybierz datę';

  @override
  String get enterName => 'Wprowadź nazwę';

  @override
  String get groupSettings => 'Ustawienia grupy';

  @override
  String get manageGroups => 'Zarządzaj grupami';

  @override
  String get createNewGroup => 'Utwórz nową grupę...';

  @override
  String get noGroupsYet => 'Brak grup';

  @override
  String get configure => 'Konfiguruj';

  @override
  String get groupName => 'Nazwa grupy';

  @override
  String get nameWithoutCommas => 'Nazwa bez przecinków';

  @override
  String get deleteGroupFromSystem => 'Usuń grupę z systemu';

  @override
  String get groupDeleted => 'Grupa usunięta';

  @override
  String get groupNameNoCommas => 'Nazwa grupy nie może zawierać przecinków!';

  @override
  String get max10Groups => 'Maksymalnie 10 grup!';

  @override
  String get max10SelectedGroups => 'Można wybrać maksymalnie 10 grup';

  @override
  String get failedToRecognizeAi =>
      'Nie udało się rozpoznać danych kontaktowych w tekście.';

  @override
  String get recognitionError => 'Błąd rozpoznawania';

  @override
  String get geminiApiKeyNotFound => 'Nie znaleziono GEMINI_API_KEY';

  @override
  String get serverOverloaded =>
      'Serwer przeciążony. Spróbuj ponownie później.';

  @override
  String get aiReturnedEmptyResponse => 'AI zwróciło pustą odpowiedź';

  @override
  String get contactListEmpty => 'Lista kontaktów jest pusta';

  @override
  String get selectAtLeastOneColumn =>
      'Wybierz co najmniej jedną kolumnę w ustawieniach';

  @override
  String get noResultsFound => 'Nie znaleziono wyników dla Twojego zapytania';

  @override
  String get reorderingDisabledWhileFiltering =>
      'Zmiana kolejności jest wyłączona podczas wyszukiwania lub filtrowania';

  @override
  String get themeMode => 'Tryb motywu';

  @override
  String get themeColor => 'Kolor motywu';

  @override
  String get light => 'Jasny';

  @override
  String get dark => 'Ciemny';

  @override
  String get dataManagement => 'Zarządzanie danymi';

  @override
  String get importData => 'Importuj dane';

  @override
  String get exportData => 'Eksportuj dane';

  @override
  String get importSuccessful => 'Dane zaimportowane pomyślnie';

  @override
  String get importFailed => 'Nie udało się zaimportować danych';

  @override
  String get exportSuccessful => 'Dane wyeksportowane pomyślnie';

  @override
  String get exportFailed => 'Nie udało się wyeksportować danych';

  @override
  String get invalidFileFormat => 'Nieprawidłowy format pliku';

  @override
  String get noDataToExport => 'Brak danych do eksportu';

  @override
  String get importFromPhone => 'Importuj z książki telefonicznej';

  @override
  String get permissionDenied => 'Odmowa dostępu';

  @override
  String get selectContacts => 'Wybierz kontakty';

  @override
  String importNContacts(int count) {
    return 'Importuj $count kontaktów';
  }

  @override
  String get eventsOnThisDay => 'Wydarzenia tego dnia';

  @override
  String get noEventsOnThisDay => 'Brak wydarzeń tego dnia';

  @override
  String get birthdayEvent => 'Urodziny';

  @override
  String get remindEveryYear => 'Przypominaj co roku';

  @override
  String get remindBefore => 'Przypomnij z wyprzedzeniem:';

  @override
  String get halfYear => 'pół roku';

  @override
  String get threeMonths => 'trzy miesiące';

  @override
  String get month => 'miesiąc';

  @override
  String get twoWeeks => 'dwa tygodnie';

  @override
  String get week => 'tydzień';

  @override
  String get threeDays => '3 dni';

  @override
  String get day => 'dzień';

  @override
  String get today => 'w dniu wydarzenia';

  @override
  String get reminderTime => 'Czas przypomnienia';

  @override
  String get reminderSettings => 'Ustawienia przypomnień';

  @override
  String get todos => 'Zadania';

  @override
  String get addTodo => 'Dodaj zadanie';

  @override
  String get editTodo => 'Edytuj zadanie';

  @override
  String get todoTitle => 'Tytuł';

  @override
  String get todoDescription => 'Opis';

  @override
  String get dueDate => 'Termin wykonania';

  @override
  String get priority => 'Priorytet';

  @override
  String get low => 'Niski';

  @override
  String get medium => 'Średni';

  @override
  String get high => 'Wysoki';

  @override
  String get todoDeleted => 'Zadanie usunięte';

  @override
  String get deleteTodoConfirmation => 'Czy na pewno chcesz usunąć to zadanie?';

  @override
  String get invalidEmail => 'Nieprawidłowy format e-mail.';

  @override
  String get userNotFound => 'Użytkownik nie został znaleziony.';

  @override
  String get wrongPassword => 'Błędne hasło.';

  @override
  String get invalidCredential => 'Nieprawidłowy e-mail lub hasło.';

  @override
  String get emailAlreadyInUse => 'Ten e-mail jest вже zarejestrowany.';

  @override
  String get weakPassword => 'Hasło jest za słabe (minimum 6 znaków).';

  @override
  String get tooManyRequests => 'Zbyt wiele prób. Spróbuj ponownie później.';

  @override
  String get userDisabled => 'To konto zostało zablokowane.';

  @override
  String get authError => 'Wystąpił błąd autoryzacji.';

  @override
  String get googleClientIdNotFound => 'Nie znaleziono GOOGLE_CLIENT_ID.';

  @override
  String get authGoogleError => 'Błąd autoryzacji Google.';

  @override
  String get unknownLoginError => 'Nieznany błąd logowania.';

  @override
  String get unknownRegistrationError => 'Nieznany błąd rejestracji.';

  @override
  String get userNotAuthenticated => 'Użytkownik nie jest zalogowany.';

  @override
  String get unknownError => 'Nieznany błąd.';

  @override
  String waitCooldown(int seconds) {
    return 'Odczekaj $seconds sek. przed ponownym wysłaniem.';
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
  String get enterTextToRecognize => 'Wprowadź tekst do rozpoznania';

  @override
  String get stopRecordingToRecognize => 'Najpierw zatrzymaj nagrywanie';
}
