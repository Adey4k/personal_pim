// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Персональний PIM';

  @override
  String get settings => 'Налаштування';

  @override
  String get appMenu => 'Меню застосунку';

  @override
  String get home => 'Головна';

  @override
  String get calendar => 'Календар';

  @override
  String get calendarPlaceholder =>
      'Тут буде календар з датами, налаштуваннями нагадувань та задачник';

  @override
  String get language => 'Мова';

  @override
  String get english => 'Англійська';

  @override
  String get ukrainian => 'Українська';

  @override
  String get german => 'Німецька';

  @override
  String get french => 'Французька';

  @override
  String get spanish => 'Іспанська';

  @override
  String get polish => 'Польська';

  @override
  String get myContacts => 'Мої контакти';

  @override
  String get addContact => 'Додати контакт';

  @override
  String get configureColumns => 'Налаштувати колонки';

  @override
  String get configureTable => 'Налаштування таблиці';

  @override
  String get columnReorderInstruction =>
      'Тягніть, щоб змінити порядок. Натисніть ❌, щоб сховати колонку.';

  @override
  String get availableFieldsToAdd => 'Доступні поля для додавання:';

  @override
  String get allFieldsAlreadyInTable => 'Всі існуючі поля вже в таблиці';

  @override
  String get search => 'Пошук';

  @override
  String get all => 'Всі';

  @override
  String get noName => 'Без імені';

  @override
  String get error => 'Помилка';

  @override
  String get loading => 'Завантаження';

  @override
  String get welcomeBack => 'З поверненням!';

  @override
  String get loginSubtitle => 'Будь ласка, увійдіть у свій акаунт';

  @override
  String get login => 'Увійти';

  @override
  String get loginTitle => 'Вхід у застосунок';

  @override
  String get password => 'Пароль';

  @override
  String get confirmPassword => 'Підтвердження пароля';

  @override
  String get register => 'Реєстрація';

  @override
  String get forgotPassword => 'Забули пароль?';

  @override
  String get loginWithGoogle => 'Увійти через Google';

  @override
  String get pleaseEnterEmailAndPassword =>
      'Будь ласка, введіть email та пароль';

  @override
  String get fillAllFields => 'Заповніть всі поля';

  @override
  String get passwordsDoNotMatch => 'Паролі не збігаються';

  @override
  String get verificationEmailSent =>
      'Лист для підтвердження надіслано на вашу пошту!';

  @override
  String get verifyEmailTitle => 'Підтвердження пошти';

  @override
  String verificationEmailSentTo(String email) {
    return 'Лист із підтвердженням надіслано на:\n$email';
  }

  @override
  String get checkEmailInstructions =>
      'Будь ласка, перевірте вашу скриньку та натисніть на посилання у листі для активації акаунту.\n\nЯкщо листа немає протягом кількох хвилин, обов\'язково перевірте папку \"Спам\".';

  @override
  String get emailResent => 'Лист надіслано повторно!';

  @override
  String get resendEmail => 'Надіслати листа ще раз';

  @override
  String get cancelAndReturn => 'Скасувати та повернутися';

  @override
  String get enterEmailToResetPassword => 'Введіть email для скидання пароля';

  @override
  String get passwordResetEmailSent =>
      'Якщо акаунт існує, лист для скидання надіслано!';

  @override
  String get logout => 'Вийти';

  @override
  String get email => 'Електронна пошта';

  @override
  String get phone => 'Телефон';

  @override
  String get name => 'Ім\'я';

  @override
  String get birthday => 'День народження';

  @override
  String get groups => 'Групи';

  @override
  String get save => 'Зберегти';

  @override
  String get cancel => 'Скасувати';

  @override
  String get edit => 'Редагувати';

  @override
  String get delete => 'Видалити';

  @override
  String get deleteContact => 'Видалити контакт';

  @override
  String get deleteContactTitle => 'Видалення контакту';

  @override
  String deleteContactConfirmation(Object name) {
    return 'Ви впевнені, що хочете видалити \"$name\"?\nЦю дію неможливо скасувати.';
  }

  @override
  String get contactDeleted => 'Контакт видалено';

  @override
  String get hideEmptyFields => 'Сховати пусті поля';

  @override
  String get showEmptyFields => 'Відобразити пусті поля';

  @override
  String get addField => 'Додати властивість';

  @override
  String get intelligentInput => 'Інтелектуальний ввід';

  @override
  String get listening => 'Слухаю...';

  @override
  String get tapToSpeak => 'Натисніть на мікрофон, щоб говорити';

  @override
  String get stop => 'Зупинити';

  @override
  String get aiInputHint =>
      'Пишіть/вставте скопійований текст або надиктуйте...';

  @override
  String get recognize => 'Розпізнати';

  @override
  String get newField => 'Нова властивість';

  @override
  String get fieldNameHint => 'Назва (напр. Telegram)';

  @override
  String get dataType => 'Тип даних:';

  @override
  String get textType => 'Текст';

  @override
  String get numberType => 'Число/Телефон';

  @override
  String get dateType => 'Дата';

  @override
  String get booleanType => 'Логічне (Так/Ні)';

  @override
  String get add => 'Додати';

  @override
  String get chooseFieldType => 'Оберіть тип властивості';

  @override
  String get deleteFieldTitle => 'Видалення поля';

  @override
  String deleteFieldConfirmation(Object name) {
    return 'Ви впевнені, що хочете видалити поле \"$name\"?\nЦю дію неможливо скасувати.';
  }

  @override
  String deleteFieldUsageWarning(int count) {
    return 'Це поле заповнене у $count контактів. Видалити його для всіх?';
  }

  @override
  String get fieldDeleted => 'Поле видалено';

  @override
  String get changeFieldType => 'Змінити тип поля';

  @override
  String get rename => 'Перейменувати';

  @override
  String get copyValue => 'Скопіювати значення';

  @override
  String get valueCopied => 'Значення скопійовано!';

  @override
  String get fieldName => 'Назва властивості';

  @override
  String get tapToSelect => 'Натисніть, щоб обрати...';

  @override
  String get selectDate => 'Обрати дату';

  @override
  String get enterName => 'Введіть назву';

  @override
  String get groupSettings => 'Налаштування групи';

  @override
  String get manageGroups => 'Керування групами';

  @override
  String get createNewGroup => 'Створити нову групу...';

  @override
  String get noGroupsYet => 'Поки що немає жодної групи';

  @override
  String get configure => 'Налаштувати';

  @override
  String get groupName => 'Назва групи';

  @override
  String get nameWithoutCommas => 'Назва без ком';

  @override
  String get deleteGroupFromSystem => 'Видалити групу із системи';

  @override
  String get groupDeleted => 'Групу видалено';

  @override
  String get groupNameNoCommas => 'Назва групи не може містити кому!';

  @override
  String get maxGroups => 'Максимум 15 груп!';

  @override
  String get maxSelectedGroups => 'Можна обрати не більше 15 груп';

  @override
  String get failedToRecognizeAi =>
      'Не вдалося розпізнати контактні дані у тексті.';

  @override
  String get recognitionError => 'Помилка розпізнавання';

  @override
  String get geminiApiKeyNotFound => 'GEMINI_API_KEY не знайдено';

  @override
  String get serverOverloaded => 'Сервер перевантажений. Спробуйте пізніше.';

  @override
  String get aiReturnedEmptyResponse => 'ІІ повернув порожню відповідь';

  @override
  String get contactListEmpty => 'Список контактів порожній';

  @override
  String get selectAtLeastOneColumn =>
      'Виберіть хоча б одну колонку в налаштуваннях';

  @override
  String get noResultsFound => 'За вашим запитом нічого не знайдено';

  @override
  String get reorderingDisabledWhileFiltering =>
      'Сортування вимкнено під час пошуку або фільтрації';

  @override
  String get themeMode => 'Режим теми';

  @override
  String get themeColor => 'Колір теми';

  @override
  String get light => 'Світла';

  @override
  String get dark => 'Темна';

  @override
  String get dataManagement => 'Керування даними';

  @override
  String get importData => 'Імпорт даних';

  @override
  String get exportData => 'Експорт даних';

  @override
  String get importSuccessful => 'Дані успішно імпортовано';

  @override
  String get importFailed => 'Помилка імпорту даних';

  @override
  String get exportSuccessful => 'Дані успішно експортовано';

  @override
  String get exportFailed => 'Помилка експорту даних';

  @override
  String get invalidFileFormat => 'Невірний формат файлу';

  @override
  String get noDataToExport => 'Немає даних для експорту';

  @override
  String get importFromPhone => 'Імпорт з телефонної книги';

  @override
  String get permissionDenied => 'Доступ заборонено';

  @override
  String get selectContacts => 'Оберіть контакти';

  @override
  String importNContacts(int count) {
    return 'Імпортувати $count контактів';
  }

  @override
  String get eventsOnThisDay => 'Події на цей день';

  @override
  String get noEventsOnThisDay => 'На цей день подій немає';

  @override
  String get birthdayEvent => 'День народження';

  @override
  String get remindEveryYear => 'Нагадувати щороку';

  @override
  String get remindBefore => 'Нагадувати за:';

  @override
  String get halfYear => 'пів року';

  @override
  String get threeMonths => 'три місяці';

  @override
  String get month => 'місяць';

  @override
  String get twoWeeks => 'два тижні';

  @override
  String get week => 'тиждень';

  @override
  String get threeDays => '3 дні';

  @override
  String get day => 'день';

  @override
  String get today => 'день у день';

  @override
  String get reminderTime => 'Час нагадувань';

  @override
  String get reminderSettings => 'Налаштування нагадувань';

  @override
  String get todos => 'Завдання';

  @override
  String get addTodo => 'Додати завдання';

  @override
  String get editTodo => 'Редагувати завдання';

  @override
  String get todoTitle => 'Заголовок';

  @override
  String get todoDescription => 'Опис';

  @override
  String get dueDate => 'Дата виконання';

  @override
  String get priority => 'Пріоритет';

  @override
  String get low => 'Низький';

  @override
  String get medium => 'Середній';

  @override
  String get high => 'Високий';

  @override
  String get todoDeleted => 'Завдання видалено';

  @override
  String get deleteTodoConfirmation =>
      'Ви впевнені, що хочете видалити це завдання?';

  @override
  String get invalidEmail => 'Некоректний формат email.';

  @override
  String get userNotFound => 'Користувача не знайдено.';

  @override
  String get wrongPassword => 'Неправильний пароль.';

  @override
  String get invalidCredential => 'Неправильний email або пароль.';

  @override
  String get emailAlreadyInUse => 'Цей email вже зареєстровано.';

  @override
  String get weakPassword => 'Пароль занадто простий (мінімум 6 символів).';

  @override
  String get tooManyRequests => 'Занадто багато спроб. Спробуйте пізніше.';

  @override
  String get userDisabled => 'Цей акаунт заблоковано.';

  @override
  String get authError => 'Сталася помилка авторизації.';

  @override
  String get googleClientIdNotFound => 'GOOGLE_CLIENT_ID не знайдено.';

  @override
  String get authGoogleError => 'Помилка авторизації Google.';

  @override
  String get unknownLoginError => 'Невідома помилка входу.';

  @override
  String get unknownRegistrationError => 'Невідома помилка реєстрації.';

  @override
  String get userNotAuthenticated => 'Користувач не авторизований.';

  @override
  String get unknownError => 'Невідома помилка.';

  @override
  String waitCooldown(int seconds) {
    return 'Зачекайте $seconds сек. перед повторною відправкою.';
  }

  @override
  String get createAccount => 'Створити акаунт';

  @override
  String get registerSubtitle => 'Будь ласка, заповніть дані для реєстрації';

  @override
  String get firstName => 'Ім\'я';

  @override
  String get lastName => 'Прізвище';

  @override
  String get dontHaveAccount => 'Немає акаунта? Зареєструватися';

  @override
  String get alreadyHaveAccount => 'Вже є акаунт? Увійти';

  @override
  String get enterTextToRecognize => 'Введіть текст для розпізнавання';

  @override
  String get stopRecordingToRecognize => 'Спершу зупиніть запис';

  @override
  String get onboardingHomeTitle => 'Ласкаво просимо до Personal PIM!';

  @override
  String get onboardingHomeDesc =>
      'Тут ви можете керувати контактами. Рядки можна перетягувати для зміни порядку, а натискання на заголовок колонки відсортує список за цим полем.';

  @override
  String get onboardingAddContactTitle => 'Додавання контактів';

  @override
  String get onboardingAddContactDesc =>
      'Натисніть тут, щоб додати новий контакт вручну або за допомогою ШІ.';

  @override
  String get onboardingCalendarTitle => 'Календар та завдання';

  @override
  String get onboardingCalendarDesc =>
      'Тут ви знайдете дні народження та список ваших справ.';

  @override
  String get onboardingSettingsTitle => 'Налаштування';

  @override
  String get onboardingSettingsDesc =>
      'Змінюйте тему, імпортуйте дані. Не забувайте, що можете додати віджети на робочий стіл вашого телефону!';

  @override
  String get onboardingIntelligentInputTitle => 'Інтелектуальний ввід';

  @override
  String get onboardingIntelligentInputDesc =>
      'Вставте будь-який текст про контакт (наприклад, повідомлення з месенджера), а ШІ спробує знайти поля та заповнити їх автоматично.';

  @override
  String get onboardingWidgetTitle => 'Додайте віджети';

  @override
  String get onboardingWidgetDesc =>
      'Не забудьте додати віджет на головний екран телефону, щоб бачити наближення свят!';

  @override
  String get onboardingContactMeTitle => 'Зв\'язок зі мною';

  @override
  String get onboardingContactMeDesc => 'ladikovmax@gmail.com';

  @override
  String get withoutYear => 'Без року';

  @override
  String get orText => 'АБО';

  @override
  String get testNotification => 'Тестове повідомлення';

  @override
  String get dailyReminderTitle => 'Mnemo PIM';

  @override
  String get dailyReminderBody =>
      'Не забудьте перевірити свої завдання сьогодні!';
}
