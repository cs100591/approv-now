import 'package:flutter/material.dart';

class MemberGroup {
  final String id;
  final String workspaceId;
  final String name;
  final String? description;
  final String color;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MemberGroup({
    required this.id,
    required this.workspaceId,
    required this.name,
    this.description,
    this.color = '#3B82F6',
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  Color get displayColor {
    try {
      return Color(int.parse(color.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF3B82F6);
    }
  }

  MemberGroup copyWith({
    String? id,
    String? workspaceId,
    String? name,
    String? description,
    String? color,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MemberGroup(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workspace_id': workspaceId,
      'name': name,
      'description': description,
      'color': color,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory MemberGroup.fromJson(Map<String, dynamic> json) {
    return MemberGroup(
      id: json['id'].toString(),
      workspaceId: json['workspace_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      color: json['color']?.toString() ?? '#3B82F6',
      createdBy: json['created_by']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MemberGroup && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class GroupMember {
  final String id;
  final String groupId;
  final String workspaceMemberId;
  final String? addedBy;
  final DateTime addedAt;

  const GroupMember({
    required this.id,
    required this.groupId,
    required this.workspaceMemberId,
    this.addedBy,
    required this.addedAt,
  });

  GroupMember copyWith({
    String? id,
    String? groupId,
    String? workspaceMemberId,
    String? addedBy,
    DateTime? addedAt,
  }) {
    return GroupMember(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      workspaceMemberId: workspaceMemberId ?? this.workspaceMemberId,
      addedBy: addedBy ?? this.addedBy,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'workspace_member_id': workspaceMemberId,
      'added_by': addedBy,
      'added_at': addedAt.toIso8601String(),
    };
  }

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'].toString(),
      groupId: json['group_id']?.toString() ?? '',
      workspaceMemberId: json['workspace_member_id']?.toString() ?? '',
      addedBy: json['added_by']?.toString(),
      addedAt: json['added_at'] != null
          ? DateTime.parse(json['added_at'].toString())
          : DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GroupMember && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class MemberGroupWithMembers {
  final MemberGroup group;
  final List<String> memberIds;

  const MemberGroupWithMembers({
    required this.group,
    required this.memberIds,
  });

  int get memberCount => memberIds.length;
}
