import 'package:dio/dio.dart';

/// Uma exceção customizada para a aplicação que estende [DioException].
/// Ela unifica os erros do Dio e adiciona mensagens amigáveis em português
/// e o código de status HTTP de forma direta.
class AppException extends DioException {
  /// Mensagem customizada e tratada para exibir ao usuário final.
  final String customMessage;

  /// Código de status HTTP (ex: 400, 401, 500). Retorna -1 se não houver status.
  final int statusCode;

  AppException({
    required this.customMessage,
    required this.statusCode,
    required super.requestOptions,
    super.response,
    super.type = DioExceptionType.unknown,
    super.error,
  });

  /// Sobrescreve a mensagem padrão do Dio para retornar a nossa mensagem tratada.
  @override
  String get message => customMessage;

  @override
  String toString() {
    return 'AppException: [$statusCode] $customMessage';
  }

  /// Fábrica (Factory) utilitária para converter um [DioException] comum
  /// em um [AppException] estruturado. Ele analisa o tipo de erro e o status HTTP.
  factory AppException.fromDioException(DioException dioException) {
    String message = 'Ocorreu um erro inesperado. Tente novamente.';
    int status = dioException.response?.statusCode ?? -1;

    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Tempo limite de conexão esgotado. Verifique sua internet.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Tempo limite de envio esgotado. Tente novamente.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'O servidor demorou para responder. Tente novamente.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Certificado de segurança inválido.';
        break;
      case DioExceptionType.connectionError:
        message =
            'Falha na conexão com o servidor. Verifique se está conectado à internet.';
        break;
      case DioExceptionType.cancel:
        message = 'A requisição foi cancelada.';
        break;
      case DioExceptionType.badResponse:
        // Quando o servidor responde com erro (Ex: 400, 401, 404, 500)
        message = _handleStatusCode(status, dioException.response?.data);
        break;
      case DioExceptionType.unknown:
      default:
        if (dioException.message != null &&
            dioException.message!.contains('SocketException')) {
          message = 'Sem conexão com a internet.';
        } else {
          message = dioException.message ?? message;
        }
        break;
    }

    return AppException(
      customMessage: message,
      statusCode: status,
      requestOptions: dioException.requestOptions,
      response: dioException.response,
      type: dioException.type,
      error: dioException.error,
    );
  }

  /// Método auxiliar privado para mapear os status HTTP do servidor
  static String _handleStatusCode(int status, dynamic responseData) {
    // Tenta buscar uma mensagem de erro vinda do seu backend (ex: { "message": "Senha incorreta" })
    String? backendMessage;
    if (responseData is Map && responseData.containsKey('message')) {
      backendMessage = responseData['message']?.toString();
    }

    switch (status) {
      case 400:
        return backendMessage ?? 'Requisição inválida.';
      case 401:
        return backendMessage ??
            'Não autorizado. Por favor, faça login novamente.';
      case 403:
        return backendMessage ?? 'Acesso negado. Você não tem permissão.';
      case 404:
        return backendMessage ?? 'Recurso não encontrado no servidor.';
      case 409:
        return backendMessage ?? 'Conflito de dados no servidor.';
      case 500:
        return 'Erro interno do servidor. Tente novamente mais tarde.';
      default:
        return backendMessage ??
            'Erro de comunicação com o servidor ($status).';
    }
  }
}
