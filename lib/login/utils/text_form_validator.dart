import 'package:flutter/material.dart';
import 'package:fudo_challenge/l10n/l10n.dart';

/// Returns a [String] if the [value] is empty, otherwise returns `null`.
String? textFormValidator(String? value, BuildContext context) {
  if (value == null || value.isEmpty) {
    return context.l10n.textFormFieldEmptyError;
  }
  return null;
}
