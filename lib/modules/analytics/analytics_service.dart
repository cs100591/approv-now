/// Analytics event types
enum AnalyticsEvent {
  workspaceCreated,
  templateCreated,
  requestSubmitted,
  requestApproved,
  requestRejected,
  requestRestarted,
  userLogin,
  userLogout,
  pdfExported,
  subscriptionUpgraded,
}

/// AnalyticsService - Handles analytics logging
class AnalyticsService {
  final List<Map<String, dynamic>> _events = [];
  bool _isEnabled = true;

  /// Initialize analytics
  void initialize({bool enabled = true}) {
    _isEnabled = enabled;
  }

  /// Check if analytics is enabled
  bool get isEnabled => _isEnabled;

  /// Enable/disable analytics
  set isEnabled(bool value) {
    _isEnabled = value;
  }

  /// Log event
  void logEvent(
    AnalyticsEvent event, {
    String? userId,
    String? workspaceId,
    String? requestId,
    Map<String, dynamic>? parameters,
  }) {
    if (!_isEnabled) return;

    final eventData = {
      'event': event.name,
      'timestamp': DateTime.now().toIso8601String(),
      'userId': userId,
      'workspaceId': workspaceId,
      'requestId': requestId,
      'parameters': parameters ?? {},
    };

    _events.add(eventData);

    // In real implementation, this would send to Firebase Analytics
    _sendToAnalytics(eventData);
  }

  /// Log workspace created
  void logWorkspaceCreated({
    required String userId,
    required String workspaceId,
    String? plan,
  }) {
    logEvent(
      AnalyticsEvent.workspaceCreated,
      userId: userId,
      workspaceId: workspaceId,
      parameters: {'plan': plan ?? 'free'},
    );
  }

  /// Log template created
  void logTemplateCreated({
    required String userId,
    required String workspaceId,
    required String templateId,
    required int fieldCount,
    required int approvalLevelCount,
  }) {
    logEvent(
      AnalyticsEvent.templateCreated,
      userId: userId,
      workspaceId: workspaceId,
      parameters: {
        'templateId': templateId,
        'fieldCount': fieldCount,
        'approvalLevelCount': approvalLevelCount,
      },
    );
  }

  /// Log request submitted
  void logRequestSubmitted({
    required String userId,
    required String workspaceId,
    required String requestId,
    required String templateId,
  }) {
    logEvent(
      AnalyticsEvent.requestSubmitted,
      userId: userId,
      workspaceId: workspaceId,
      requestId: requestId,
      parameters: {'templateId': templateId},
    );
  }

  /// Log request approved
  void logRequestApproved({
    required String userId,
    required String workspaceId,
    required String requestId,
    required int level,
  }) {
    logEvent(
      AnalyticsEvent.requestApproved,
      userId: userId,
      workspaceId: workspaceId,
      requestId: requestId,
      parameters: {'level': level},
    );
  }

  /// Log request rejected
  void logRequestRejected({
    required String userId,
    required String workspaceId,
    required String requestId,
    required int level,
  }) {
    logEvent(
      AnalyticsEvent.requestRejected,
      userId: userId,
      workspaceId: workspaceId,
      requestId: requestId,
      parameters: {'level': level},
    );
  }

  /// Log request restarted
  void logRequestRestarted({
    required String userId,
    required String workspaceId,
    required String requestId,
    required int revisionNumber,
  }) {
    logEvent(
      AnalyticsEvent.requestRestarted,
      userId: userId,
      workspaceId: workspaceId,
      requestId: requestId,
      parameters: {'revisionNumber': revisionNumber},
    );
  }

  /// Log user login
  void logUserLogin(String userId) {
    logEvent(
      AnalyticsEvent.userLogin,
      userId: userId,
    );
  }

  /// Log user logout
  void logUserLogout(String userId) {
    logEvent(
      AnalyticsEvent.userLogout,
      userId: userId,
    );
  }

  /// Log PDF exported
  void logPdfExported({
    required String userId,
    required String workspaceId,
    required String requestId,
    required String plan,
  }) {
    logEvent(
      AnalyticsEvent.pdfExported,
      userId: userId,
      workspaceId: workspaceId,
      requestId: requestId,
      parameters: {'plan': plan},
    );
  }

  /// Log subscription upgraded
  void logSubscriptionUpgraded({
    required String userId,
    required String oldPlan,
    required String newPlan,
  }) {
    logEvent(
      AnalyticsEvent.subscriptionUpgraded,
      userId: userId,
      parameters: {
        'oldPlan': oldPlan,
        'newPlan': newPlan,
      },
    );
  }

  /// Send to analytics backend (mock)
  void _sendToAnalytics(Map<String, dynamic> eventData) {
    // In real implementation, this would send to Firebase Analytics
    print('Analytics: ${eventData['event']}');
  }

  /// Get all logged events (for debugging)
  List<Map<String, dynamic>> getEvents() {
    return List.unmodifiable(_events);
  }

  /// Clear all events
  void clearEvents() {
    _events.clear();
  }
}
