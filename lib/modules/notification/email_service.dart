import '../../core/services/supabase_service.dart';
import '../../core/utils/app_logger.dart';

/// EmailService - Handles sending email notifications via Supabase Edge Function
class EmailService {
  final SupabaseService _supabase;

  EmailService({SupabaseService? supabase})
      : _supabase = supabase ?? SupabaseService();

  /// Send invitation email
  Future<bool> sendInvitationEmail({
    required String email,
    required String workspaceName,
    required String inviterName,
    required String inviteToken,
    required String workspaceId,
  }) async {
    return await _sendEmail(
      type: 'invitation',
      data: {
        'email': email,
        'workspaceName': workspaceName,
        'inviterName': inviterName,
        'inviteToken': inviteToken,
        'workspaceId': workspaceId,
      },
    );
  }

  /// Send approval request email
  Future<bool> sendApprovalRequestEmail({
    required String email,
    required String requestorName,
    required String templateName,
    required String workspaceName,
    required String workspaceId,
  }) async {
    return await _sendEmail(
      type: 'approval_request',
      data: {
        'email': email,
        'requestorName': requestorName,
        'templateName': templateName,
        'workspaceName': workspaceName,
        'workspaceId': workspaceId,
      },
    );
  }

  /// Send approval completed email
  Future<bool> sendApprovalCompletedEmail({
    required String email,
    required String templateName,
    required String workspaceName,
    required String workspaceId,
  }) async {
    return await _sendEmail(
      type: 'approval_completed',
      data: {
        'email': email,
        'templateName': templateName,
        'workspaceName': workspaceName,
        'workspaceId': workspaceId,
      },
    );
  }

  /// Send rejection email
  Future<bool> sendRejectionEmail({
    required String email,
    required String templateName,
    required String workspaceName,
    required String workspaceId,
    String? reason,
  }) async {
    return await _sendEmail(
      type: 'request_rejected',
      data: {
        'email': email,
        'templateName': templateName,
        'workspaceName': workspaceName,
        'workspaceId': workspaceId,
        'reason': reason,
      },
    );
  }

  /// Generic method to send email via Supabase Edge Function
  Future<bool> _sendEmail({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    try {
      AppLogger.info(
          '📧 [EmailService] Sending email: $type to ${data['email']}');
      AppLogger.info(
          '📧 [EmailService] Request data: workspaceId=${data['workspaceId']}, workspaceName=${data['workspaceName']}');

      final response = await _supabase.client.functions.invoke(
        'email-notifications',
        body: {
          'type': type,
          'data': data,
        },
      );

      AppLogger.info('📧 [EmailService] Response received: ${response.data}');

      final responseData = response.data as Map<String, dynamic>;

      if (responseData['success'] == true) {
        AppLogger.info('✅ [EmailService] Email sent successfully: $type');
        return true;
      } else {
        AppLogger.warning(
            '❌ [EmailService] Email sending failed: ${responseData['message'] ?? 'Unknown error'}');
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error(
          '❌ [EmailService] Failed to send email: $type', e, stackTrace);
      return false;
    }
  }
}
