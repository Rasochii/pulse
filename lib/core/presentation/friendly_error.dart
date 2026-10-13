import 'package:flutter/foundation.dart';

/// Texto de erro para o usuário: [message] em português; o detalhe técnico só em debug.
String friendlyError(
  Object error, [
  String message = 'Algo deu errado. Tente de novo.',
]) {
  if (kDebugMode) return '$message\n$error';
  return message;
}
