import 'package:equatable/equatable.dart';
import '../template/template_models.dart';

/// Status of an approval request
enum RequestStatus {
  draft,
  pending,
  approved,
  rejected,
  revised,
}

/// Field value snapshot
class FieldValue extends Equatable {
  final String fieldId;
  final String fieldName;
  final FieldType fieldType;
  final dynamic value;

  const FieldValue({
    required this.fieldId,
    required this.fieldName,
    required this.fieldType,
    required this.value,
  });

  FieldValue copyWith({
    String? fieldId,
    String? fieldName,
    FieldType? fieldType,
    dynamic value,
  }) {
    return FieldValue(
      fieldId: fieldId ?? this.fieldId,
      fieldName: fieldName ?? this.fieldName,
      fieldType: fieldType ?? this.fieldType,
      value: value ?? this.value,
    );
  }

  Map<String, dynamic> toJson() {
    dynamic encodedValue = value;
    if (value is DateTime) {
      encodedValue = (value as DateTime).toIso8601String();
    }
    return {
      'fieldId': fieldId,
      'fieldName': fieldName,
      'fieldType': fieldType.name,
      'value': encodedValue,
    };
  }

  factory FieldValue.fromJson(Map<String, dynamic> json) {
    final type = FieldType.values.firstWhere(
      (e) => e.name == json['fieldType'],
      orElse: () => FieldType.text,
    );

    dynamic decodedValue = json['value'];
    if (type == FieldType.date && decodedValue is String) {
      try {
        decodedValue = DateTime.parse(decodedValue);
      } catch (_) {}
    }

    return FieldValue(
      fieldId: json['fieldId'] as String,
      fieldName: json['fieldName'] as String,
      fieldType: type,
      value: decodedValue,
    );
  }

  @override
  List<Object?> get props => [fieldId, fieldName, fieldType, value];
}

/// Approval action record
class ApprovalAction extends Equatable {
  final String id;
  final int level;
  final String approverId;
  final String approverName;
  final bool approved;
  final String? comment;
  final DateTime timestamp;
  final bool isObsolete;

  const ApprovalAction({
    required this.id,
    required this.level,
    required this.approverId,
    required this.approverName,
    required this.approved,
    this.comment,
    required this.timestamp,
    this.isObsolete = false,
  });

  ApprovalAction copyWith({
    String? id,
    int? level,
    String? approverId,
    String? approverName,
    bool? approved,
    String? comment,
    DateTime? timestamp,
    bool? isObsolete,
  }) {
    return ApprovalAction(
      id: id ?? this.id,
      level: level ?? this.level,
      approverId: approverId ?? this.approverId,
      approverName: approverName ?? this.approverName,
      approved: approved ?? this.approved,
      comment: comment ?? this.comment,
      timestamp: timestamp ?? this.timestamp,
      isObsolete: isObsolete ?? this.isObsolete,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'level': level,
        'approverId': approverId,
        'approverName': approverName,
        'approved': approved,
        'comment': comment,
        'timestamp': timestamp.toIso8601String(),
        'isObsolete': isObsolete,
      };

  factory ApprovalAction.fromJson(Map<String, dynamic> json) => ApprovalAction(
        id: json['id'] as String,
        level: json['level'] as int,
        approverId: json['approverId'] as String,
        approverName: json['approverName'] as String,
        approved: json['approved'] as bool,
        comment: json['comment'] as String?,
        timestamp: DateTime.parse(json['timestamp'] as String),
        isObsolete: json['isObsolete'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [
        id,
        level,
        approverId,
        approverName,
        approved,
        comment,
        timestamp,
        isObsolete,
      ];
}

/// Request revision tracking
class RequestRevision extends Equatable {
  final int revisionNumber;
  final DateTime createdAt;
  final List<FieldValue> fieldValues;
  final List<ApprovalAction> approvalActions;
  final String? hash;

  const RequestRevision({
    required this.revisionNumber,
    required this.createdAt,
    required this.fieldValues,
    this.approvalActions = const [],
    this.hash,
  });

  RequestRevision copyWith({
    int? revisionNumber,
    DateTime? createdAt,
    List<FieldValue>? fieldValues,
    List<ApprovalAction>? approvalActions,
    String? hash,
  }) {
    return RequestRevision(
      revisionNumber: revisionNumber ?? this.revisionNumber,
      createdAt: createdAt ?? this.createdAt,
      fieldValues: fieldValues ?? this.fieldValues,
      approvalActions: approvalActions ?? this.approvalActions,
      hash: hash ?? this.hash,
    );
  }

  Map<String, dynamic> toJson() => {
        'revisionNumber': revisionNumber,
        'createdAt': createdAt.toIso8601String(),
        'fieldValues': fieldValues.map((v) => v.toJson()).toList(),
        'approvalActions': approvalActions.map((a) => a.toJson()).toList(),
        'hash': hash,
      };

  factory RequestRevision.fromJson(Map<String, dynamic> json) =>
      RequestRevision(
        revisionNumber: json['revisionNumber'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        fieldValues: (json['fieldValues'] as List)
            .map((v) => FieldValue.fromJson(v))
            .toList(),
        approvalActions: (json['approvalActions'] as List?)
                ?.map((a) => ApprovalAction.fromJson(a))
                .toList() ??
            [],
        hash: json['hash'] as String?,
      );

  @override
  List<Object?> get props => [
        revisionNumber,
        createdAt,
        fieldValues,
        approvalActions,
        hash,
      ];
}

/// Approval request model
class ApprovalRequest extends Equatable {
  final String id;
  final String workspaceId;
  final String templateId;
  final String templateName;
  final String submittedBy;
  final String submittedByName;
  final DateTime submittedAt;
  final RequestStatus status;
  final int currentLevel;
  final int revisionNumber;
  final List<FieldValue> fieldValues;
  final List<ApprovalAction> approvalActions;
  final List<RequestRevision> revisions;

  const ApprovalRequest({
    required this.id,
    required this.workspaceId,
    required this.templateId,
    required this.templateName,
    required this.submittedBy,
    required this.submittedByName,
    required this.submittedAt,
    this.status = RequestStatus.draft,
    this.currentLevel = 0,
    this.revisionNumber = 1,
    this.fieldValues = const [],
    this.approvalActions = const [],
    this.revisions = const [],
  });

  ApprovalRequest copyWith({
    String? id,
    String? workspaceId,
    String? templateId,
    String? templateName,
    String? submittedBy,
    String? submittedByName,
    DateTime? submittedAt,
    RequestStatus? status,
    int? currentLevel,
    int? revisionNumber,
    List<FieldValue>? fieldValues,
    List<ApprovalAction>? approvalActions,
    List<RequestRevision>? revisions,
  }) {
    return ApprovalRequest(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      templateId: templateId ?? this.templateId,
      templateName: templateName ?? this.templateName,
      submittedBy: submittedBy ?? this.submittedBy,
      submittedByName: submittedByName ?? this.submittedByName,
      submittedAt: submittedAt ?? this.submittedAt,
      status: status ?? this.status,
      currentLevel: currentLevel ?? this.currentLevel,
      revisionNumber: revisionNumber ?? this.revisionNumber,
      fieldValues: fieldValues ?? this.fieldValues,
      approvalActions: approvalActions ?? this.approvalActions,
      revisions: revisions ?? this.revisions,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'workspaceId': workspaceId,
        'templateId': templateId,
        'templateName': templateName,
        'submittedBy': submittedBy,
        'submittedByName': submittedByName,
        'submittedAt': submittedAt.toIso8601String(),
        'status': status.name,
        'currentLevel': currentLevel,
        'revisionNumber': revisionNumber,
        'fieldValues': fieldValues.map((v) => v.toJson()).toList(),
        'approvalActions': approvalActions.map((a) => a.toJson()).toList(),
        'revisions': revisions.map((r) => r.toJson()).toList(),
      };

  factory ApprovalRequest.fromJson(Map<String, dynamic> json) =>
      ApprovalRequest(
        id: json['id'] as String,
        workspaceId: json['workspaceId'] as String,
        templateId: json['templateId'] as String,
        templateName: json['templateName'] as String,
        submittedBy: json['submittedBy'] as String,
        submittedByName: json['submittedByName'] as String,
        submittedAt: DateTime.parse(json['submittedAt'] as String),
        status: RequestStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => RequestStatus.draft,
        ),
        currentLevel: json['currentLevel'] as int? ?? 0,
        revisionNumber: json['revisionNumber'] as int? ?? 1,
        fieldValues: (json['fieldValues'] as List?)
                ?.map((v) => FieldValue.fromJson(v))
                .toList() ??
            [],
        approvalActions: (json['approvalActions'] as List?)
                ?.map((a) => ApprovalAction.fromJson(a))
                .toList() ??
            [],
        revisions: (json['revisions'] as List?)
                ?.map((r) => RequestRevision.fromJson(r))
                .toList() ??
            [],
      );

  bool get isPending => status == RequestStatus.pending;
  bool get isApproved => status == RequestStatus.approved;
  bool get isRejected => status == RequestStatus.rejected;
  bool get canEdit =>
      status == RequestStatus.draft || status == RequestStatus.revised;

  List<ApprovalAction> get currentApprovalActions =>
      approvalActions.where((a) => !a.isObsolete).toList();

  @override
  List<Object?> get props => [
        id,
        workspaceId,
        templateId,
        templateName,
        submittedBy,
        submittedByName,
        submittedAt,
        status,
        currentLevel,
        revisionNumber,
        fieldValues,
        approvalActions,
        revisions,
      ];
}

/// Request state for provider
class RequestState extends Equatable {
  final List<ApprovalRequest> requests;
  final ApprovalRequest? selectedRequest;
  final List<ApprovalRequest> pendingRequests;
  final int pendingCount;
  final bool isLoading;
  final String? error;

  const RequestState({
    this.requests = const [],
    this.selectedRequest,
    this.pendingRequests = const [],
    this.pendingCount = 0,
    this.isLoading = false,
    this.error,
  });

  RequestState copyWith({
    List<ApprovalRequest>? requests,
    ApprovalRequest? selectedRequest,
    List<ApprovalRequest>? pendingRequests,
    int? pendingCount,
    bool? isLoading,
    String? error,
  }) {
    return RequestState(
      requests: requests ?? this.requests,
      selectedRequest: selectedRequest ?? this.selectedRequest,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      pendingCount: pendingCount ?? this.pendingCount,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        requests,
        selectedRequest,
        pendingRequests,
        pendingCount,
        isLoading,
        error,
      ];
}
