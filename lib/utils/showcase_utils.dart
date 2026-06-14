import 'package:showcaseview/showcaseview.dart';

void ensureShowcaseViewRegistered() {
  try {
    ShowcaseView.get();
  } catch (_) {
    ShowcaseView.register();
  }
}
