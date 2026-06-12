// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'PIM Personal';

  @override
  String get settings => 'Ajustes';

  @override
  String get appMenu => 'Menú de la aplicación';

  @override
  String get home => 'Inicio';

  @override
  String get calendar => 'Calendario';

  @override
  String get calendarPlaceholder =>
      'Aquí habrá un calendario con fechas, ajustes de recordatorio y un gestor de tareas';

  @override
  String get language => 'Idioma';

  @override
  String get english => 'Inglés';

  @override
  String get ukrainian => 'Ucraniano';

  @override
  String get german => 'Alemán';

  @override
  String get french => 'Francés';

  @override
  String get spanish => 'Español';

  @override
  String get polish => 'Polaco';

  @override
  String get myContacts => 'Mis contactos';

  @override
  String get addContact => 'Añadir contacto';

  @override
  String get configureColumns => 'Configurar columnas';

  @override
  String get configureTable => 'Ajustes de tabla';

  @override
  String get columnReorderInstruction =>
      'Arrastra para reordenar. Toca ❌ para ocultar una columna.';

  @override
  String get availableFieldsToAdd => 'Campos disponibles para añadir:';

  @override
  String get allFieldsAlreadyInTable =>
      'Todos los campos existentes ya están en la tabla';

  @override
  String get search => 'Buscar';

  @override
  String get all => 'Todo';

  @override
  String get noName => 'Sin nombre';

  @override
  String get error => 'Error';

  @override
  String get loading => 'Cargando...';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get loginSubtitle => 'Please sign in to your account';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get loginTitle => 'Iniciar sesión en la aplicación';

  @override
  String get password => 'Contraseña';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get register => 'Registrarse';

  @override
  String get forgotPassword => '¿Has olvidado tu contraseña?';

  @override
  String get loginWithGoogle => 'Iniciar sesión con Google';

  @override
  String get pleaseEnterEmailAndPassword =>
      'Por favor, introduce email y contraseña';

  @override
  String get fillAllFields => 'Por favor, rellena todos los campos';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String get verificationEmailSent =>
      '¡Correo de verificación enviado a tu cuenta!';

  @override
  String get verifyEmailTitle => 'Verificación de email';

  @override
  String verificationEmailSentTo(String email) {
    return 'Se ha enviado un correo de confirmación a:\n$email';
  }

  @override
  String get checkEmailInstructions =>
      'Por favor, comprueba tu bandeja de entrada y haz clic en el enlace del correo para activar tu cuenta.\n\nSi no recibes el correo en unos minutos, asegúrate de comprobar tu carpeta de \'Spam\'.';

  @override
  String get emailResent => '¡Correo reenviado con éxito!';

  @override
  String get resendEmail => 'Reenviar correo';

  @override
  String get cancelAndReturn => 'Cancelar y volver';

  @override
  String get enterEmailToResetPassword =>
      'Introduce email para restablecer contraseña';

  @override
  String get passwordResetEmailSent =>
      'Si la cuenta existe, ¡se ha enviado el correo de restablecimiento!';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Teléfono';

  @override
  String get name => 'Nombre';

  @override
  String get birthday => 'Cumpleaños';

  @override
  String get groups => 'Grupos';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Eliminar';

  @override
  String get deleteContact => 'Eliminar contacto';

  @override
  String get deleteContactTitle => 'Eliminar contacto';

  @override
  String deleteContactConfirmation(Object name) {
    return '¿Estás seguro de que quieres eliminar a \"$name\"?\nEsta acción no se puede deshacer.';
  }

  @override
  String get contactDeleted => 'Contacto eliminado';

  @override
  String get hideEmptyFields => 'Ocultar campos vacíos';

  @override
  String get showEmptyFields => 'Mostrar campos vacíos';

  @override
  String get addField => 'Añadir campo';

  @override
  String get intelligentInput => 'Entrada inteligente';

  @override
  String get listening => 'Escuchando...';

  @override
  String get tapToSpeak => 'Toca el micrófono para hablar';

  @override
  String get stop => 'Detener';

  @override
  String get aiInputHint => 'Escribe/pega el texto copiado o dicta...';

  @override
  String get recognize => 'Reconocer';

  @override
  String get newField => 'Nuevo campo';

  @override
  String get fieldNameHint => 'Nombre (ej. Telegram)';

  @override
  String get dataType => 'Tipo de dato:';

  @override
  String get textType => 'Texto';

  @override
  String get numberType => 'Número/Teléfono';

  @override
  String get dateType => 'Fecha';

  @override
  String get booleanType => 'Booleano (Sí/No)';

  @override
  String get add => 'Añadir';

  @override
  String get chooseFieldType => 'Elegir tipo de campo';

  @override
  String get deleteFieldTitle => 'Eliminar campo';

  @override
  String deleteFieldConfirmation(Object name) {
    return '¿Estás seguro de que quieres eliminar el campo \"$name\"?\nEsta acción no se puede deshacer.';
  }

  @override
  String deleteFieldUsageWarning(int count) {
    return 'Este campo tiene datos en $count contactos. ¿Eliminarlo para todos?';
  }

  @override
  String get fieldDeleted => 'Campo eliminado';

  @override
  String get changeFieldType => 'Cambiar tipo de campo';

  @override
  String get rename => 'Renombrar';

  @override
  String get copyValue => 'Copiar valor';

  @override
  String get valueCopied => '¡Valor copiado!';

  @override
  String get fieldName => 'Nombre del campo';

  @override
  String get tapToSelect => 'Toca para seleccionar...';

  @override
  String get selectDate => 'Seleccionar fecha';

  @override
  String get enterName => 'Introducir nombre';

  @override
  String get groupSettings => 'Ajustes de grupo';

  @override
  String get manageGroups => 'Gestionar grupos';

  @override
  String get createNewGroup => 'Crear nuevo grupo...';

  @override
  String get noGroupsYet => 'Aún no hay grupos';

  @override
  String get configure => 'Configurar';

  @override
  String get groupName => 'Nombre del grupo';

  @override
  String get nameWithoutCommas => 'Nombre sin comas';

  @override
  String get deleteGroupFromSystem => 'Eliminar grupo del sistema';

  @override
  String get groupDeleted => 'Grupo eliminado';

  @override
  String get groupNameNoCommas =>
      '¡El nombre del grupo no puede contener comas!';

  @override
  String get max10Groups => '¡Máximo 10 grupos!';

  @override
  String get max10SelectedGroups =>
      'Se pueden seleccionar como máximo 10 grupos';

  @override
  String get failedToRecognizeAi =>
      'No se pudieron reconocer los datos de contacto en el texto.';

  @override
  String get recognitionError => 'Error de reconocimiento';

  @override
  String get geminiApiKeyNotFound => 'GEMINI_API_KEY no encontrado';

  @override
  String get serverOverloaded =>
      'Servidor sobrecargado. Inténtalo de nuevo más tarde.';

  @override
  String get aiReturnedEmptyResponse => 'La IA devolvió una respuesta vacía';

  @override
  String get contactListEmpty => 'La lista de contactos está vacía';

  @override
  String get selectAtLeastOneColumn =>
      'Selecciona al menos una columna en ajustes';

  @override
  String get noResultsFound =>
      'No se han encontrado resultados para tu consulta';

  @override
  String get reorderingDisabledWhileFiltering =>
      'La reordenación está desactivada durante la búsqueda o el filtrado';

  @override
  String get themeMode => 'Modo del tema';

  @override
  String get themeColor => 'Color del tema';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get dataManagement => 'Gestión de datos';

  @override
  String get importData => 'Importar datos';

  @override
  String get exportData => 'Exportar datos';

  @override
  String get importSuccessful => 'Datos importados con éxito';

  @override
  String get importFailed => 'Error al importar datos';

  @override
  String get exportSuccessful => 'Datos exportados con éxito';

  @override
  String get exportFailed => 'Error al exportar datos';

  @override
  String get invalidFileFormat => 'Formato de archivo no válido';

  @override
  String get noDataToExport => 'No hay datos para exportar';

  @override
  String get importFromPhone => 'Importar de la agenda';

  @override
  String get permissionDenied => 'Permiso denegado';

  @override
  String get selectContacts => 'Seleccionar contactos';

  @override
  String importNContacts(int count) {
    return 'Importar $count contactos';
  }

  @override
  String get eventsOnThisDay => 'Eventos en este día';

  @override
  String get noEventsOnThisDay => 'No hay eventos en este día';

  @override
  String get birthdayEvent => 'Cumpleaños';

  @override
  String get remindEveryYear => 'Recordar cada año';

  @override
  String get remindBefore => 'Recordar con antelación:';

  @override
  String get halfYear => 'medio año';

  @override
  String get threeMonths => 'tres meses';

  @override
  String get month => 'mes';

  @override
  String get twoWeeks => 'dos semanas';

  @override
  String get week => 'semana';

  @override
  String get threeDays => '3 días';

  @override
  String get day => 'día';

  @override
  String get today => 'el mismo día';

  @override
  String get reminderTime => 'Hora de recordatorio';

  @override
  String get reminderSettings => 'Ajustes de recordatorio';

  @override
  String get todos => 'Tareas';

  @override
  String get addTodo => 'Añadir tarea';

  @override
  String get editTodo => 'Editar tarea';

  @override
  String get todoTitle => 'Título';

  @override
  String get todoDescription => 'Descripción';

  @override
  String get dueDate => 'Fecha de vencimiento';

  @override
  String get priority => 'Prioridad';

  @override
  String get low => 'Baja';

  @override
  String get medium => 'Media';

  @override
  String get high => 'Alta';

  @override
  String get todoDeleted => 'Tarea eliminada';

  @override
  String get deleteTodoConfirmation =>
      '¿Estás seguro de que quieres eliminar esta tarea?';

  @override
  String get invalidEmail => 'Formato de email no válido.';

  @override
  String get userNotFound => 'Usuario no encontrado.';

  @override
  String get wrongPassword => 'Contraseña incorrecta.';

  @override
  String get invalidCredential => 'Email o contraseña no válidos.';

  @override
  String get emailAlreadyInUse => 'Este email ya está registrado.';

  @override
  String get weakPassword =>
      'La contraseña es demasiado débil (mínimo 6 caracteres).';

  @override
  String get tooManyRequests =>
      'Demasiados intentos. Inténtalo de nuevo más tarde.';

  @override
  String get userDisabled => 'Esta cuenta está desactivada.';

  @override
  String get authError => 'Se ha producido un error de autenticación.';

  @override
  String get googleClientIdNotFound => 'GOOGLE_CLIENT_ID no encontrado.';

  @override
  String get authGoogleError => 'Error de autenticación de Google.';

  @override
  String get unknownLoginError => 'Error de inicio de sesión desconocido.';

  @override
  String get unknownRegistrationError => 'Error de registro desconocido.';

  @override
  String get userNotAuthenticated => 'Usuario no auténticado.';

  @override
  String get unknownError => 'Error desconocido.';

  @override
  String waitCooldown(int seconds) {
    return 'Espera $seconds seg. antes de volver a enviar.';
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
  String get enterTextToRecognize => 'Introduzca texto para reconocer';

  @override
  String get stopRecordingToRecognize => 'Detenga la grabación primero';

  @override
  String get onboardingHomeTitle => '¡Bienvenido a Personal PIM!';

  @override
  String get onboardingHomeDesc =>
      'Administre sus contactos aquí. Puede arrastrar y soltar filas para cambiar su orden, y hacer clic en el encabezado de una columna ordenará la lista por ese campo.';

  @override
  String get onboardingAddContactTitle => 'Añadir contactos';

  @override
  String get onboardingAddContactDesc =>
      'Toca aquí para añadir un nuevo contacto manualmente o usando IA.';

  @override
  String get onboardingCalendarTitle => 'Calendario y tareas';

  @override
  String get onboardingCalendarDesc =>
      'Consulta aquí los cumpleaños y tu lista de tareas.';

  @override
  String get onboardingSettingsTitle => 'Ajustes de la aplicación';

  @override
  String get onboardingSettingsDesc =>
      'Personaliza la aplicación, importa/exporta datos y encuentra información sobre widgets.';

  @override
  String get onboardingIntelligentInputTitle => 'Entrada inteligente';

  @override
  String get onboardingIntelligentInputDesc =>
      'Pegue cualquier texto sobre un contacto (por ejemplo, un mensaje de un mensajero) y la IA intentará encontrar campos y completarlos automáticamente.';

  @override
  String get onboardingWidgetTitle => 'Añadir widgets';

  @override
  String get onboardingWidgetDesc =>
      'No olvides añadir nuestro widget a tu pantalla de inicio para ver los próximos cumpleaños.';

  @override
  String get onboardingContactMeTitle => 'Contactar con el soporte';

  @override
  String get onboardingContactMeDesc =>
      '¿Tienes sugerencias? Contáctame en ladikovmax@gmail.com';
}
