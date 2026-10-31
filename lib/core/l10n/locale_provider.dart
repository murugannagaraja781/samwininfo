import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/app_state_providers.dart';
import 'app_strings.dart';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final storage = ref.watch(localStorageServiceProvider);
    final savedCode = storage.getLocale();
    return Locale(savedCode);
  }

  void setLocale(String languageCode) {
    if (state.languageCode == languageCode) return;
    state = Locale(languageCode);
    final storage = ref.read(localStorageServiceProvider);
    storage.saveLocale(languageCode);
  }

  void toggleLocale() {
    final next = state.languageCode == 'ta' ? 'en' : 'ta';
    setLocale(next);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);

extension LocalizationExt on WidgetRef {
  String tr(String key) {
    final locale = watch(localeProvider);
    return AppStrings.get(key, locale.languageCode);
  }

  bool get isTamil {
    final locale = watch(localeProvider);
    return locale.languageCode == 'ta';
  }
}

extension BuildContextLocExt on BuildContext {
  String tr(WidgetRef ref, String key) {
    return ref.tr(key);
  }
}
