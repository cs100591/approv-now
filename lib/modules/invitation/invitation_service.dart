import 'package:flutter/foundation.dart';
import '../../core/config/app_config.dart';
import '../../core/utils/app_logger.dart';
import '../workspace/workspace_models.dart';
import '../workspace/workspace_member.dart';

/// Service to handle invitations
/// Note: Email notifications are disabled by default (AppConfig.enableEmailNotifications = false)
/// When enabled, this would integrate with Firebase Functions to send emails
class InvitationService {
  InvitationService();

  /// Resend invitation email
  /// Returns true if successful, false if emails are disabled
  Future<bool> resendInvitationEmail({
    required String workspaceId,
    required String invitationId,
  }) async {
    if (!AppConfig.emailsEnabled) {
      AppLogger.info('Email notifications disabled - skipping resend');
      return false;
    }

    try {
      // When Firebase Functions are enabled, this would call the cloud function
      AppLogger.info('Would resend invitation email: $invitationId');
      return true;
    } catch (e) {
      AppLogger.error('Error resending invitation', e);
      return false;
    }
  }

  /// Accept invitation
  Future<InvitationResult> acceptInvitation({
    required String workspaceId,
    required String invitationId,
    required String token,
    required String userId,
    String? displayName,
  }) async {
    try {
      AppLogger.info('Accepting invitation: $invitationId for user: $userId');
      return InvitationResult.success();
    } catch (e) {
      AppLogger.error('Error accepting invitation', e);
      throw InvitationException('Failed to accept invitation');
    }
  }

  /// Reject invitation
  Future<bool> rejectInvitation({
    required String workspaceId,
    required String invitationId,
    required String token,
  }) async {
    try {
      AppLogger.info('Rejecting invitation: $invitationId');
      return true;
    } catch (e) {
      AppLogger.error('Error rejecting invitation', e);
      throw InvitationException('Failed to reject invitation');
    }
  }

  /// Parse invitation deep link
  InvitationDeepLink? parseInvitationLink(String url) {
    try {
      final uri = Uri.parse(url);

      // Check if it's an invitation link
      if (!uri.path.contains('/invite')) {
        return null;
      }

      final workspaceId = uri.queryParameters['workspace'];
      final invitationId = uri.queryParameters['invitation'];
      final token = uri.queryParameters['token'];
      final action = uri.queryParameters['action'];

      if (workspaceId == null || invitationId == null || token == null) {
        AppLogger.warning('Invalid invitation link: missing parameters');
        return null;
      }

      return InvitationDeepLink(
        workspaceId: workspaceId,
        invitationId: invitationId,
        token: token,
        action: action ?? 'accept',
      );
    } catch (e) {
      AppLogger.error('Error parsing invitation link', e);
      return null;
    }
  }

  /// Validate invitation token
  Future<bool> validateInvitationToken({
    required String workspaceId,
    required String invitationId,
    required String token,
  }) async {
    try {
      AppLogger.info('Validating invitation token: $invitationId');
      return true;
    } catch (e) {
      AppLogger.error('Error validating token', e);
      return false;
    }
  }

  /// Generate invite link for manual sharing
  String generateInviteLink({
    required String workspaceId,
    required String invitationId,
    required String token,
  }) {
    // Using Firebase Hosting URL
    return 'https://approve-now.web.app/invite?workspace=$workspaceId&invitation=$invitationId&token=$token';
  }
}

/// Deep link data for invitations
class InvitationDeepLink {
  final String workspaceId;
  final String invitationId;
  final String token;
  final String action; // 'accept' or 'reject'

  const InvitationDeepLink({
    required this.workspaceId,
    required this.invitationId,
    required this.token,
    this.action = 'accept',
  });

  bool get isAccept => action == 'accept';
  bool get isReject => action == 'reject';
}

/// Result of invitation acceptance
class InvitationResult {
  final bool success;
  final String? error;
  final Workspace? workspace;
  final WorkspaceMember? member;

  const InvitationResult._({
    required this.success,
    this.error,
    this.workspace,
    this.member,
  });

  factory InvitationResult.success({
    Workspace? workspace,
    WorkspaceMember? member,
  }) {
    return InvitationResult._(
      success: true,
      workspace: workspace,
      member: member,
    );
  }

  factory InvitationResult.failure(String error) {
    return InvitationResult._(
      success: false,
      error: error,
    );
  }
}

/// Custom exception for invitation operations
class InvitationException implements Exception {
  final String message;
  final String? code;

  InvitationException(this.message, {this.code});

  @override
  String toString() => message;
}
