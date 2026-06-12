// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'PIM Personnel';

  @override
  String get settings => 'Paramètres';

  @override
  String get appMenu => 'Menu de l\'application';

  @override
  String get home => 'Accueil';

  @override
  String get calendar => 'Calendrier';

  @override
  String get calendarPlaceholder =>
      'Ici sera un calendrier avec dates, paramètres de rappel et un gestionnaire de tâches';

  @override
  String get language => 'Langue';

  @override
  String get english => 'Anglais';

  @override
  String get ukrainian => 'Ukrainien';

  @override
  String get german => 'Allemand';

  @override
  String get french => 'Français';

  @override
  String get spanish => 'Espagnol';

  @override
  String get polish => 'Polonais';

  @override
  String get myContacts => 'Mes contacts';

  @override
  String get addContact => 'Ajouter un contact';

  @override
  String get configureColumns => 'Configurer les colonnes';

  @override
  String get configureTable => 'Paramètres du tableau';

  @override
  String get columnReorderInstruction =>
      'Faites glisser pour réorganiser. Appuyez sur ❌ pour masquer une colonne.';

  @override
  String get availableFieldsToAdd => 'Champs disponibles à ajouter :';

  @override
  String get allFieldsAlreadyInTable =>
      'Tous les champs existants sont déjà dans le tableau';

  @override
  String get search => 'Rechercher';

  @override
  String get all => 'Tout';

  @override
  String get noName => 'Pas de nom';

  @override
  String get error => 'Erreur';

  @override
  String get loading => 'Chargement...';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get loginSubtitle => 'Please sign in to your account';

  @override
  String get login => 'Connexion';

  @override
  String get loginTitle => 'Connexion à l\'application';

  @override
  String get password => 'Mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get register => 'S\'inscrire';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get loginWithGoogle => 'Se connecter avec Google';

  @override
  String get pleaseEnterEmailAndPassword =>
      'Veuillez entrer l\'email et le mot de passe';

  @override
  String get fillAllFields => 'Veuillez remplir tous les champs';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get verificationEmailSent =>
      'E-mail de vérification envoyé à votre adresse !';

  @override
  String get verifyEmailTitle => 'Vérification de l\'e-mail';

  @override
  String verificationEmailSentTo(String email) {
    return 'Un e-mail de confirmation a été envoyé à :\n$email';
  }

  @override
  String get checkEmailInstructions =>
      'Veuillez vérifier votre boîte de réception et cliquer sur le lien dans l\'e-mail pour activer votre compte.\n\nS\'il n\'y a pas d\'e-mail dans les minutes qui suivent, n\'oubliez pas de vérifier votre dossier \'Spam\'.';

  @override
  String get emailResent => 'E-mail renvoyé avec succès !';

  @override
  String get resendEmail => 'Renvoyer l\'e-mail';

  @override
  String get cancelAndReturn => 'Annuler et revenir';

  @override
  String get enterEmailToResetPassword =>
      'Entrer l\'email pour réinitialiser le mot de passe';

  @override
  String get passwordResetEmailSent =>
      'Si le compte existe, l\'e-mail de réinitialisation a été envoyé !';

  @override
  String get logout => 'Déconnexion';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Téléphone';

  @override
  String get name => 'Nom';

  @override
  String get birthday => 'Anniversaire';

  @override
  String get groups => 'Groupes';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get edit => 'Modifier';

  @override
  String get delete => 'Supprimer';

  @override
  String get deleteContact => 'Supprimer le contact';

  @override
  String get deleteContactTitle => 'Supprimer le contact';

  @override
  String deleteContactConfirmation(Object name) {
    return 'Êtes-vous sûr de vouloir supprimer \"$name\" ?\nCette action est irréversible.';
  }

  @override
  String get contactDeleted => 'Contact supprimé';

  @override
  String get hideEmptyFields => 'Masquer les champs vides';

  @override
  String get showEmptyFields => 'Afficher les champs vides';

  @override
  String get addField => 'Ajouter un champ';

  @override
  String get intelligentInput => 'Saisie intelligente';

  @override
  String get listening => 'Écoute...';

  @override
  String get tapToSpeak => 'Appuyez sur le microphone pour parler';

  @override
  String get stop => 'Arrêter';

  @override
  String get aiInputHint => 'Écrivez/collez le texte copié ou dictez...';

  @override
  String get recognize => 'Reconnaître';

  @override
  String get newField => 'Nouveau champ';

  @override
  String get fieldNameHint => 'Nom (ex: Telegram)';

  @override
  String get dataType => 'Type de données :';

  @override
  String get textType => 'Texte';

  @override
  String get numberType => 'Numéro/Téléphone';

  @override
  String get dateType => 'Date';

  @override
  String get booleanType => 'Booléen (Oui/Non)';

  @override
  String get add => 'Ajouter';

  @override
  String get chooseFieldType => 'Choisir le type de champ';

  @override
  String get deleteFieldTitle => 'Supprimer le champ';

  @override
  String deleteFieldConfirmation(Object name) {
    return 'Êtes-vous sûr de vouloir supprimer le champ \"$name\" ?\nCette action est irréversible.';
  }

  @override
  String deleteFieldUsageWarning(int count) {
    return 'Ce champ contient des données dans $count contacts. Le supprimer pour tout le monde ?';
  }

  @override
  String get fieldDeleted => 'Champ supprimé';

  @override
  String get changeFieldType => 'Changer le type de champ';

  @override
  String get rename => 'Renommer';

  @override
  String get copyValue => 'Copier la valeur';

  @override
  String get valueCopied => 'Valeur copiée !';

  @override
  String get fieldName => 'Nom du champ';

  @override
  String get tapToSelect => 'Appuyez pour sélectionner...';

  @override
  String get selectDate => 'Sélectionner une date';

  @override
  String get enterName => 'Entrer un nom';

  @override
  String get groupSettings => 'Paramètres du groupe';

  @override
  String get manageGroups => 'Gérer les groupes';

  @override
  String get createNewGroup => 'Créer un nouveau groupe...';

  @override
  String get noGroupsYet => 'Pas encore de groupes';

  @override
  String get configure => 'Configurer';

  @override
  String get groupName => 'Nom du groupe';

  @override
  String get nameWithoutCommas => 'Nom sans virgules';

  @override
  String get deleteGroupFromSystem => 'Supprimer le groupe du système';

  @override
  String get groupDeleted => 'Groupe supprimé';

  @override
  String get groupNameNoCommas =>
      'Le nom du groupe ne peut pas contenir de virgules !';

  @override
  String get max10Groups => 'Maximum 10 groupes !';

  @override
  String get max10SelectedGroups =>
      'Maximum 10 groupes peuvent être sélectionnés';

  @override
  String get failedToRecognizeAi =>
      'Impossible de reconnaître les données de contact dans le texte.';

  @override
  String get recognitionError => 'Erreur de reconnaissance';

  @override
  String get geminiApiKeyNotFound => 'GEMINI_API_KEY non trouvé';

  @override
  String get serverOverloaded => 'Serveur surchargé. Réessayez plus tard.';

  @override
  String get aiReturnedEmptyResponse => 'L\'IA a renvoyé une réponse vide';

  @override
  String get contactListEmpty => 'La liste de contacts est vide';

  @override
  String get selectAtLeastOneColumn =>
      'Sélectionnez au moins une colonne dans les paramètres';

  @override
  String get noResultsFound => 'Aucun résultat trouvé pour votre requête';

  @override
  String get reorderingDisabledWhileFiltering =>
      'La réorganisation est désactivée pendant la recherche ou le filtrage';

  @override
  String get themeMode => 'Mode du thème';

  @override
  String get themeColor => 'Couleur du thème';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get dataManagement => 'Gestion des données';

  @override
  String get importData => 'Importer des données';

  @override
  String get exportData => 'Exporter des données';

  @override
  String get importSuccessful => 'Données importées avec succès';

  @override
  String get importFailed => 'Échec de l\'importation des données';

  @override
  String get exportSuccessful => 'Données exportées avec succès';

  @override
  String get exportFailed => 'Échec de l\'exportation des données';

  @override
  String get invalidFileFormat => 'Format de fichier invalide';

  @override
  String get noDataToExport => 'Aucune donnée à exporter';

  @override
  String get importFromPhone => 'Importer du répertoire';

  @override
  String get permissionDenied => 'Permission refusée';

  @override
  String get selectContacts => 'Sélectionner des contacts';

  @override
  String importNContacts(int count) {
    return 'Importer $count contacts';
  }

  @override
  String get eventsOnThisDay => 'Événements ce jour-là';

  @override
  String get noEventsOnThisDay => 'Il n\'y a pas d\'événements ce jour-là';

  @override
  String get birthdayEvent => 'Anniversaire';

  @override
  String get remindEveryYear => 'Rappeler chaque année';

  @override
  String get remindBefore => 'Rappeler à l\'avance :';

  @override
  String get halfYear => 'six mois';

  @override
  String get threeMonths => 'trois mois';

  @override
  String get month => 'mois';

  @override
  String get twoWeeks => 'deux semaines';

  @override
  String get week => 'semaine';

  @override
  String get threeDays => '3 jours';

  @override
  String get day => 'jour';

  @override
  String get today => 'le jour même';

  @override
  String get reminderTime => 'Heure de rappel';

  @override
  String get reminderSettings => 'Paramètres de rappel';

  @override
  String get todos => 'Tâches';

  @override
  String get addTodo => 'Ajouter une tâche';

  @override
  String get editTodo => 'Modifier une tâche';

  @override
  String get todoTitle => 'Titre';

  @override
  String get todoDescription => 'Description';

  @override
  String get dueDate => 'Date d\'échéance';

  @override
  String get priority => 'Priorité';

  @override
  String get low => 'Basse';

  @override
  String get medium => 'Moyenne';

  @override
  String get high => 'Haute';

  @override
  String get todoDeleted => 'Tâche supprimée';

  @override
  String get deleteTodoConfirmation =>
      'Êtes-vous sûr de vouloir supprimer cette tâche?';

  @override
  String get invalidEmail => 'Format d\'email invalide.';

  @override
  String get userNotFound => 'Utilisateur non trouvé.';

  @override
  String get wrongPassword => 'Mot de passe incorrect.';

  @override
  String get invalidCredential => 'Email ou mot de passe invalide.';

  @override
  String get emailAlreadyInUse => 'Cet email est déjà enregistré.';

  @override
  String get weakPassword =>
      'Le mot de passe est trop faible (minimum 6 caractères).';

  @override
  String get tooManyRequests => 'Trop de tentatives. Réessayez plus tard.';

  @override
  String get userDisabled => 'Ce compte est désactivé.';

  @override
  String get authError => 'Une erreur d\'authentification s\'est produite.';

  @override
  String get googleClientIdNotFound => 'GOOGLE_CLIENT_ID non trouvé.';

  @override
  String get authGoogleError => 'Erreur d\'authentification Google.';

  @override
  String get unknownLoginError => 'Erreur de connexion inconnue.';

  @override
  String get unknownRegistrationError => 'Erreur d\'inscription inconnue.';

  @override
  String get userNotAuthenticated => 'Utilisateur non authentifié.';

  @override
  String get unknownError => 'Erreur inconnue.';

  @override
  String waitCooldown(int seconds) {
    return 'Attendez $seconds sec. avant de renvoyer.';
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
  String get enterTextToRecognize => 'Entrez le texte à reconnaître';

  @override
  String get stopRecordingToRecognize => 'Arrêtez d\'abord l\'enregistrement';

  @override
  String get onboardingHomeTitle => 'Bienvenue sur Personal PIM !';

  @override
  String get onboardingHomeDesc =>
      'Gérez vos contacts ici. Vous pouvez glisser-déposer des lignes pour modifier leur ordre, et cliquer sur un en-tête de colonne triera la liste selon ce champ.';

  @override
  String get onboardingAddContactTitle => 'Ajouter des contacts';

  @override
  String get onboardingAddContactDesc =>
      'Appuyez ici pour ajouter un nouveau contact manuellement ou via l\'IA.';

  @override
  String get onboardingCalendarTitle => 'Calendrier & Tâches';

  @override
  String get onboardingCalendarDesc =>
      'Consultez ici les anniversaires et votre liste de tâches.';

  @override
  String get onboardingSettingsTitle => 'Paramètres de l\'application';

  @override
  String get onboardingSettingsDesc =>
      'Personnalisez l\'application, importez/exportez des données et trouvez des infos sur les widgets.';

  @override
  String get onboardingIntelligentInputTitle => 'Saisie intelligente';

  @override
  String get onboardingIntelligentInputDesc =>
      'Collez n\'importe quel texte sur un contact (par exemple, un message d\'une messagerie), et l\'IA essaiera de trouver les champs et de les remplir automatiquement.';

  @override
  String get onboardingWidgetTitle => 'Ajouter des widgets';

  @override
  String get onboardingWidgetDesc =>
      'N\'oubliez pas d\'ajouter notre widget à votre écran d\'accueil pour voir les anniversaires à venir !';

  @override
  String get onboardingContactMeTitle => 'Contacter le support';

  @override
  String get onboardingContactMeDesc =>
      'Vous avez des suggestions ? Contactez-moi à ladikovmax@gmail.com';
}
