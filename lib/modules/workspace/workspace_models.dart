import 'package:equatable/equatable.dart';

/// Workspace model representing an approval workspace
class Workspace extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? companyName;
  final String? address;
  final String? footerText;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> members;
  final String plan; // free, starter, pro
  final Map<String, dynamic> settings;

  const Workspace({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.companyName,
    this.address,
    this.footerText,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.members = const [],
    this.plan = 'free',
    this.settings = const {},
  });

  Workspace copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    String? companyName,
    String? address,
    String? footerText,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? members,
    String? plan,
    Map<String, dynamic>? settings,
  }) {
    return Workspace(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      footerText: footerText ?? this.footerText,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      members: members ?? this.members,
      plan: plan ?? this.plan,
      settings: settings ?? this.settings,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'logoUrl': logoUrl,
        'companyName': companyName,
        'address': address,
        'footerText': footerText,
        'createdBy': createdBy,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'members': members,
        'plan': plan,
        'settings': settings,
      };

  factory Workspace.fromJson(Map<String, dynamic> json) => Workspace(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        logoUrl: json['logoUrl'] as String?,
        companyName: json['companyName'] as String?,
        address: json['address'] as String?,
        footerText: json['footerText'] as String?,
        createdBy: json['createdBy'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        members: List<String>.from(json['members'] ?? []),
        plan: json['plan'] as String? ?? 'free',
        settings: json['settings'] as Map<String, dynamic>? ?? {},
      );

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        logoUrl,
        companyName,
        address,
        footerText,
        createdBy,
        createdAt,
        updatedAt,
        members,
        plan,
        settings
      ];
}

/// Request model for creating/updating workspace
class CreateWorkspaceRequest {
  final String name;
  final String? description;
  final String? companyName;
  final String? address;

  const CreateWorkspaceRequest({
    required this.name,
    this.description,
    this.companyName,
    this.address,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'companyName': companyName,
        'address': address,
      };
}

/// Workspace state for provider
class WorkspaceState extends Equatable {
  final List<Workspace> workspaces;
  final Workspace? currentWorkspace;
  final bool isLoading;
  final String? error;

  const WorkspaceState({
    this.workspaces = const [],
    this.currentWorkspace,
    this.isLoading = false,
    this.error,
  });

  WorkspaceState copyWith({
    List<Workspace>? workspaces,
    Workspace? currentWorkspace,
    bool? isLoading,
    String? error,
  }) {
    return WorkspaceState(
      workspaces: workspaces ?? this.workspaces,
      currentWorkspace: currentWorkspace ?? this.currentWorkspace,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [workspaces, currentWorkspace, isLoading, error];
}
