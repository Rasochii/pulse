import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pulse_auth_failure.dart';

/// Converte falhas da API/auth em texto legível em português.
abstract final class AuthErrorMessages {
  static String from(Object error) {
    if (error is PulseAuthFailure) {
      return error.message;
    }
    if (error is FunctionException) {
      return _fromFunctionException(error);
    }
    if (error is AuthWeakPasswordException) {
      if (error.reasons.isNotEmpty) {
        return 'Senha fraca: ${error.reasons.join('; ')}';
      }
      return _sanitizeMessage(error.message);
    }
    if (error is AuthInvalidJwtException) {
      return 'Chave de API ou token inválido. Verifique SUPABASE_ANON_KEY (publishable ou anon no app — nunca a chave sb_secret_) e a URL do projeto.';
    }
    if (error is AuthSessionMissingException) {
      return 'Sessão inválida ou expirada. Entre na conta de novo.';
    }
    if (error is AuthApiException) {
      return _fromAuthApi(error);
    }
    if (error is AuthRetryableFetchException) {
      return _networkMessage(error.message, error.statusCode);
    }
    if (error is AuthUnknownException) {
      final fromHttp = _messageFromOriginal(error.originalError);
      if (fromHttp != null) return fromHttp;
      return _sanitizeMessage(error.message);
    }
    return _sanitizeMessage(error.toString());
  }

  static String _fromFunctionException(FunctionException e) {
    final d = e.details;
    if (d is Map) {
      final err = d['error'];
      if (err is String && err.trim().isNotEmpty) {
        return _sanitizeMessage(err);
      }
      for (final key in ['msg', 'message', 'error_description']) {
        final v = d[key];
        if (v is String && v.trim().isNotEmpty) {
          return _sanitizeMessage(v);
        }
      }
    }
    if (d is String && d.trim().isNotEmpty) return _sanitizeMessage(d);
    if (e.status >= 500) {
      return 'Servidor indisponível ao excluir conta. Tente mais tarde.';
    }
    return 'Não foi possível excluir a conta.';
  }

  static String _fromAuthApi(AuthApiException e) {
    final msg = _sanitizeMessage(e.message);
    final code = e.code;

    switch (code) {
      case 'invalid_credentials':
      case 'invalid_grant':
      case 'user_not_found':
        return 'E-mail ou senha incorretos.';
      case 'email_not_confirmed':
        return 'Confirme o e-mail antes de entrar na conta — veja também na caixa de spam.';
      case 'bad_jwt':
      case 'no_authorization':
        return _badKeyOrJwt(msg);
      case 'over_request_rate_limit':
      case 'over_email_send_rate_limit':
        return 'Muitas tentativas. Aguarde um pouco e tente de novo.';
      case 'signup_disabled':
        return 'Novos cadastros estão desativados neste projeto.';
      case 'email_provider_disabled':
        return 'Login por e-mail está desabilitado nas configurações do Supabase.';
      case 'user_banned':
        return 'Esta conta foi desativada. Entre em contato com o suporte.';
      case 'weak_password':
        return msg.isEmpty ? 'Escolha uma senha mais forte.' : msg;
      case 'validation_failed':
        if (_looksLikeInvalidCredentials(msg.toLowerCase())) {
          return 'E-mail ou senha incorretos.';
        }
        return msg.isEmpty ? 'Dados inválidos. Verifique e-mail e senha.' : msg;
      default:
        break;
    }

    final lower = msg.toLowerCase();
    if (_looksLikeInvalidCredentials(lower)) {
      return 'E-mail ou senha incorretos.';
    }
    if (lower.contains('invalid login') ||
        lower.contains('invalid email or password')) {
      return 'E-mail ou senha incorretos.';
    }

    return msg.isEmpty
        ? 'Não foi possível concluir a operação. Tente novamente.'
        : msg;
  }

  static bool _looksLikeInvalidCredentials(String s) =>
      s.contains('invalid login') ||
      s.contains('invalid email or password') ||
      s.contains('email or password');

  static String _badKeyOrJwt(String sanitized) => sanitized.isEmpty
      ? 'Chave de API recusada. No app Flutter use apenas a anon/publishable — nunca sb_secret_. No dashboard: Publishable ou legado anon (eyJ...).'
      : '$sanitized\n\nSe aparecer erro 401/403, verifique SUPABASE_ANON_KEY (publishable ou JWT eyJ…) e SUPABASE_URL.';

  static String _networkMessage(String raw, String? statusCode) {
    final s = _sanitizeMessage(raw);
    if (statusCode == '500' ||
        raw.toLowerCase().contains('server') ||
        s.length > 280) {
      return 'Problema de conexão ou servidor. Tente de novo em instantes.';
    }
    return s.isEmpty ? 'Erro de rede. Verifique sua conexão.' : s;
  }

  static String? _messageFromOriginal(Object originalError) {
    if (originalError is http.Response) {
      return _sanitizeMessage(originalError.body);
    }
    return null;
  }

  /// Extrai texto útil quando a API devolve JSON (evita jogar JSON bruto na UI).
  static String _sanitizeMessage(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return '';
    if (t.startsWith('{')) {
      try {
        final decoded = jsonDecode(t);
        if (decoded is Map) {
          final out = decoded['msg'] ??
              decoded['message'] ??
              decoded['error_description'] ??
              decoded['error'];
          if (out is String && out.trim().isNotEmpty) return out.trim();
          if (out is Map) {
            final parts = out.values.whereType<String>();
            if (parts.isNotEmpty) return parts.join(' ');
          }
        }
      } catch (_) {
        // texto cru truncado abaixo
      }
    }
    if (t.length > 200) {
      return '${t.substring(0, 197)}…';
    }
    return t;
  }
}
