import '../l10n/app_localizations.dart';

class AppKeys {
  static const String name = "name";
  static const String phone = "phone";
  static const String email = "email";
  static const String birthday = "birthday";
  static const String groups = "groups";
  static const String orderIndex = "orderIndex";

  static String getLocalizedLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case name:
        return l10n.name;
      case phone:
        return l10n.phone;
      case email:
        return l10n.email;
      case birthday:
        return l10n.birthday;
      case groups:
        return l10n.groups;
      default:
        return key;
    }
  }
}
