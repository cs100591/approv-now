import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../utils/app_logger.dart';

/// Supabase Service - Singleton for database operations
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  bool _isInitialized = false;

  /// Initialize Supabase
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await Supabase.initialize(
        url: SupabaseConfig.supabaseUrl,
        anonKey: SupabaseConfig.supabaseAnonKey,
        debug: false,
      );

      _isInitialized = true;

      AppLogger.info('✅ Supabase initialized successfully');
      AppLogger.info('🔗 URL: ${SupabaseConfig.supabaseUrl}');
    } catch (e) {
      AppLogger.error('❌ Failed to initialize Supabase', e);
      rethrow;
    }
  }

  /// Get Supabase client
  SupabaseClient get client {
    _checkInitialized();
    return Supabase.instance.client;
  }

  /// Get Auth client
  GoTrueClient get auth {
    _checkInitialized();
    return client.auth;
  }

  void _checkInitialized() {
    if (!_isInitialized) {
      throw StateError('Supabase not initialized. Call initialize() first.');
    }
  }

  /// Get current user
  User? get currentUser => auth.currentUser;

  /// Get current user ID
  String? get currentUserId => auth.currentUser?.id;

  /// Get current user email
  String? get currentUserEmail => auth.currentUser?.email;

  /// Check if user is logged in
  bool get isAuthenticated => auth.currentUser != null;

  /// Auth state changes stream
  Stream<AuthState> get authStateChanges => auth.onAuthStateChange;

  // ============================================
  // AUTH METHODS
  // ============================================

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final response = await auth.signUp(
        email: email,
        password: password,
        data: {
          if (displayName != null) 'display_name': displayName,
        },
      );
      AppLogger.info('User signed up: $email');
      return response;
    } catch (e) {
      AppLogger.error('Sign up failed', e);
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await auth.signInWithPassword(
        email: email,
        password: password,
      );
      AppLogger.info('User signed in: $email');
      return response;
    } catch (e) {
      AppLogger.error('Sign in failed', e);
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await auth.signOut();
      AppLogger.info('User signed out');
    } catch (e) {
      AppLogger.error('Sign out failed', e);
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await auth.resetPasswordForEmail(email);
      AppLogger.info('Password reset email sent: $email');
    } catch (e) {
      AppLogger.error('Password reset failed', e);
      rethrow;
    }
  }

  /// Update user profile
  Future<UserResponse> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final response = await auth.updateUser(
        UserAttributes(
          data: {
            if (displayName != null) 'display_name': displayName,
            if (photoUrl != null) 'photo_url': photoUrl,
          },
        ),
      );
      AppLogger.info('User profile updated');
      return response;
    } catch (e) {
      AppLogger.error('Profile update failed', e);
      rethrow;
    }
  }

  // ============================================
  // WORKSPACE METHODS
  // ============================================

  /// Get all workspaces for current user
  Future<List<Map<String, dynamic>>> getWorkspaces() async {
    final userId = currentUserId;
    if (userId == null) throw StateError('User not authenticated');

    try {
      final response = await client
          .from(SupabaseConfig.workspacesTable)
          .select()
          .or('owner_id.eq.$userId,member_ids.cs.{$userId}')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.error('Failed to get workspaces', e);
      rethrow;
    }
  }

  /// Create workspace
  Future<Map<String, dynamic>> createWorkspace({
    required String name,
    String? description,
    String? companyName,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw StateError('User not authenticated');

    try {
      final response = await client
          .from(SupabaseConfig.workspacesTable)
          .insert({
            'name': name,
            'description': description,
            'company_name': companyName,
            'owner_id': userId,
            'created_by': userId,
            'member_ids': [userId],
          })
          .select()
          .single();

      AppLogger.info('Created workspace: ${response['id']}');
      return response;
    } catch (e) {
      AppLogger.error('Failed to create workspace', e);
      rethrow;
    }
  }

  /// Update workspace
  Future<Map<String, dynamic>> updateWorkspace(
    String workspaceId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await client
          .from(SupabaseConfig.workspacesTable)
          .update(data)
          .eq('id', workspaceId)
          .select()
          .single();

      AppLogger.info('Updated workspace: $workspaceId');
      return response;
    } catch (e) {
      AppLogger.error('Failed to update workspace', e);
      rethrow;
    }
  }

  /// Delete workspace
  Future<void> deleteWorkspace(String workspaceId) async {
    try {
      await client
          .from(SupabaseConfig.workspacesTable)
          .delete()
          .eq('id', workspaceId);

      AppLogger.info('Deleted workspace: $workspaceId');
    } catch (e) {
      AppLogger.error('Failed to delete workspace', e);
      rethrow;
    }
  }

  // ============================================
  // TEMPLATE METHODS
  // ============================================

  /// Get templates for workspace
  Future<List<Map<String, dynamic>>> getTemplates(String workspaceId) async {
    try {
      final response = await client
          .from(SupabaseConfig.templatesTable)
          .select()
          .eq('workspace_id', workspaceId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.error('Failed to get templates', e);
      rethrow;
    }
  }

  /// Get single template
  Future<Map<String, dynamic>?> getTemplate(String templateId) async {
    try {
      final response = await client
          .from(SupabaseConfig.templatesTable)
          .select()
          .eq('id', templateId)
          .maybeSingle();

      return response;
    } catch (e) {
      AppLogger.error('Failed to get template', e);
      rethrow;
    }
  }

  /// Create template
  Future<Map<String, dynamic>> createTemplate({
    required String workspaceId,
    required String name,
    String? description,
    required List<Map<String, dynamic>> fields,
    required List<Map<String, dynamic>> approvalSteps,
  }) async {
    final userId = currentUserId;
    if (userId == null) throw StateError('User not authenticated');

    try {
      final response = await client
          .from(SupabaseConfig.templatesTable)
          .insert({
            'workspace_id': workspaceId,
            'name': name,
            'description': description,
            'fields': fields,
            'approval_steps': approvalSteps,
            'is_active': true,
            'created_by': userId,
          })
          .select()
          .single();

      AppLogger.info('Created template: ${response['id']}');
      return response;
    } catch (e) {
      AppLogger.error('Failed to create template', e);
      rethrow;
    }
  }

  /// Update template
  Future<Map<String, dynamic>> updateTemplate(
    String templateId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await client
          .from(SupabaseConfig.templatesTable)
          .update(data)
          .eq('id', templateId)
          .select()
          .single();

      AppLogger.info('Updated template: $templateId');
      return response;
    } catch (e) {
      AppLogger.error('Failed to update template', e);
      rethrow;
    }
  }

  /// Delete template
  Future<void> deleteTemplate(String templateId) async {
    try {
      await client
          .from(SupabaseConfig.templatesTable)
          .delete()
          .eq('id', templateId);

      AppLogger.info('Deleted template: $templateId');
    } catch (e) {
      AppLogger.error('Failed to delete template', e);
      rethrow;
    }
  }

  // ============================================
  // REQUEST METHODS
  // ============================================

  /// Get requests for workspace
  Future<List<Map<String, dynamic>>> getRequests(String workspaceId) async {
    try {
      final response = await client
          .from(SupabaseConfig.requestsTable)
          .select()
          .eq('workspace_id', workspaceId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.error('Failed to get requests', e);
      rethrow;
    }
  }

  /// Get pending requests for approver
  Future<List<Map<String, dynamic>>> getPendingRequests(
      String workspaceId) async {
    final userId = currentUserId;
    if (userId == null) throw StateError('User not authenticated');

    try {
      final response = await client
          .from(SupabaseConfig.requestsTable)
          .select()
          .eq('workspace_id', workspaceId)
          .eq('status', 'pending')
          .contains('current_approver_ids', [userId]).order('created_at',
              ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.error('Failed to get pending requests', e);
      rethrow;
    }
  }

  /// Get single request
  Future<Map<String, dynamic>?> getRequest(String requestId) async {
    try {
      final response = await client
          .from(SupabaseConfig.requestsTable)
          .select()
          .eq('id', requestId)
          .maybeSingle();

      return response;
    } catch (e) {
      AppLogger.error('Failed to get request', e);
      rethrow;
    }
  }

  /// Create request
  Future<Map<String, dynamic>> createRequest({
    required String workspaceId,
    required String templateId,
    required String templateName,
    required List<Map<String, dynamic>> fieldValues,
    required List<Map<String, dynamic>> approvalSteps,
  }) async {
    final userId = currentUserId;
    final userName = currentUserEmail ?? 'Unknown';
    if (userId == null) throw StateError('User not authenticated');

    // Extract approver IDs from first approval step
    final currentApproverIds = approvalSteps.isNotEmpty
        ? (approvalSteps[0]['approvers'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            <String>[]
        : <String>[];

    try {
      final response = await client
          .from(SupabaseConfig.requestsTable)
          .insert({
            'workspace_id': workspaceId,
            'template_id': templateId,
            'template_name': templateName,
            'submitted_by': userId,
            'submitted_by_name': userName,
            'status': 'pending',
            'current_level': 1,
            'field_values': fieldValues,
            'approval_actions': [],
            'current_approver_ids': currentApproverIds,
          })
          .select()
          .single();

      AppLogger.info('Created request: ${response['id']}');
      return response;
    } catch (e) {
      AppLogger.error('Failed to create request', e);
      rethrow;
    }
  }

  /// Update request
  Future<Map<String, dynamic>> updateRequest(
    String requestId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await client
          .from(SupabaseConfig.requestsTable)
          .update(data)
          .eq('id', requestId)
          .select()
          .single();

      AppLogger.info('Updated request: $requestId');
      return response;
    } catch (e) {
      AppLogger.error('Failed to update request', e);
      rethrow;
    }
  }

  /// Delete request
  Future<void> deleteRequest(String requestId) async {
    try {
      await client
          .from(SupabaseConfig.requestsTable)
          .delete()
          .eq('id', requestId);

      AppLogger.info('Deleted request: $requestId');
    } catch (e) {
      AppLogger.error('Failed to delete request', e);
      rethrow;
    }
  }
}
