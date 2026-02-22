#!/usr/bin/env python3
"""
自动化脚本：将 Dart 文件中的硬编码字符串替换为 AppLocalizations
"""

import re
import os
from pathlib import Path

# 定义字符串映射（硬编码 -> 本地化键）
STRING_MAPPINGS = {
    # 通用按钮和标签
    r"'Cancel'": "cancel",
    r'"Cancel"': "cancel",
    r"'Save'": "save",
    r'"Save"': "save",
    r"'Delete'": "delete",
    r'"Delete"': "delete",
    r"'Create'": "create",
    r'"Create"': "create",
    r"'Submit'": "submit",
    r'"Submit"': "submit",
    r"'Edit'": "edit",
    r'"Edit"': "edit",
    r"'Add'": "add",
    r'"Add"': "add",
    r"'Remove'": "remove",
    r'"Remove"': "remove",
    r"'Confirm'": "confirm",
    r'"Confirm"': "confirm",
    r"'Back'": "back",
    r'"Back"': "back",
    r"'Next'": "next",
    r'"Next"': "next",
    r"'Done'": "done",
    r'"Done"': "done",
    r"'Close'": "close",
    r'"Close"': "close",
    r"'Retry'": "retry",
    r'"Retry"': "retry",
    r"'Loading\.\.\.'": "loading",
    r'"Loading\.\.\."': "loading",
    # 认证相关
    r"'Email'": "email",
    r'"Email"': "email",
    r"'Password'": "password",
    r'"Password"': "password",
    r"'Full Name'": "fullName",
    r'"Full Name"': "fullName",
    r"'Display Name'": "displayName",
    r'"Display Name"': "displayName",
    r"'Name'": "name",
    r'"Name"': "name",
    r"'Login'": "login",
    r'"Login"': "login",
    r"'Sign In'": "signIn",
    r'"Sign In"': "signIn",
    r"'Sign Out'": "signOut",
    r'"Sign Out"': "signOut",
    r"'Log Out'": "logout",
    r'"Log Out"': "logout",
    r"'Logout'": "logout",
    r'"Logout"': "logout",
    r"'Create Account'": "createAccount",
    r'"Create Account"': "createAccount",
    r"'Register'": "register",
    r'"Register"': "register",
    r"'Forgot Password\?'": "forgotPassword",
    r'"Forgot Password\?"': "forgotPassword",
    r"'Change Password'": "changePassword",
    r'"Change Password"': "changePassword",
    r"'Current Password'": "currentPassword",
    r'"Current Password"': "currentPassword",
    r"'New Password'": "newPassword",
    r'"New Password"': "newPassword",
    r"'Confirm Password'": "confirmPassword",
    r'"Confirm Password"': "confirmPassword",
    r"'Settings'": "settings",
    r'"Settings"': "settings",
    r"'Notifications'": "notifications",
    r'"Notifications"': "notifications",
    r"'Profile'": "profile",
    r'"Profile"': "profile",
    r"'Account'": "account",
    r'"Account"': "account",
    # 工作区相关
    r"'Workspace'": "workspace",
    r'"Workspace"': "workspace",
    r"'Workspaces'": "workspaces",
    r'"Workspaces"': "workspaces",
    r"'Dashboard'": "dashboard",
    r'"Dashboard"': "dashboard",
    r"'Create Workspace'": "createWorkspace",
    r'"Create Workspace"': "createWorkspace",
    r"'Switch Workspace'": "switchWorkspace",
    r'"Switch Workspace"': "switchWorkspace",
    r"'Manage Workspaces'": "manageWorkspaces",
    r'"Manage Workspaces"': "manageWorkspaces",
    r"'Join Workspace'": "joinWorkspace",
    r'"Join Workspace"': "joinWorkspace",
    r"'Team Members'": "teamMembers",
    r'"Team Members"': "teamMembers",
    r"'Invite New Member'": "inviteNewMember",
    r'"Invite New Member"': "inviteNewMember",
    # 模板相关
    r"'Template'": "template",
    r'"Template"': "template",
    r"'Templates'": "templates",
    r'"Templates"': "templates",
    r"'New Template'": "newTemplate",
    r'"New Template"': "newTemplate",
    r"'Create Template'": "createTemplate",
    r'"Create Template"': "createTemplate",
    r"'Use Template'": "useTemplate",
    r'"Use Template"': "useTemplate",
    r"'Delete Template'": "deleteTemplate",
    r'"Delete Template"': "deleteTemplate",
    # 请求相关
    r"'Request'": "request",
    r'"Request"': "request",
    r"'Requests'": "requests",
    r'"Requests"': "requests",
    r"'New Request'": "newRequest",
    r'"New Request"': "newRequest",
    r"'Submit Request'": "submitRequest",
    r'"Submit Request"': "submitRequest",
    r"'Request Details'": "requestDetails",
    r'"Request Details"': "requestDetails",
    r"'Approve'": "approve",
    r'"Approve"': "approve",
    r"'Reject'": "reject",
    r'"Reject"': "reject",
    r"'Approve Request'": "approveRequest",
    r'"Approve Request"': "approveRequest",
    r"'Reject Request'": "rejectRequest",
    r'"Reject Request"': "rejectRequest",
    r"'Draft'": "draft",
    r'"Draft"': "draft",
    r"'Pending'": "pending",
    r'"Pending"': "pending",
    r"'Approved'": "approved",
    r'"Approved"': "approved",
    r"'Rejected'": "rejected",
    r'"Rejected"': "rejected",
    r"'Revised'": "revised",
    r'"Revised"': "revised",
    # 其他常见字符串
    r"'Description'": "description",
    r'"Description"': "description",
    r"'Active'": "active",
    r'"Active"': "active",
    r"'Yes'": "yes",
    r'"Yes"': "yes",
    r"'No'": "no",
    r'"No"': "no",
    r"'OR'": "or",
    r'"OR"': "or",
    r"'All'": "all",
    r'"All"': "all",
    r"'Upgrade'": "upgrade",
    r'"Upgrade"': "upgrade",
    r"'Coming Soon'": "comingSoon",
    r'"Coming Soon"': "comingSoon",
}


def process_file(file_path):
    """处理单个 Dart 文件"""
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    original_content = content
    has_import = "app_localizations.dart" in content

    # 检查是否有需要替换的内容
    needs_update = False
    for pattern in STRING_MAPPINGS.keys():
        if re.search(pattern, content):
            needs_update = True
            break

    if not needs_update:
        return False, "No strings to replace"

    # 添加导入语句
    if not has_import:
        # 找到最后一个 import 语句的位置
        import_match = re.search(r"^(import .+;)$", content, re.MULTILINE)
        if import_match:
            last_import = import_match.group(0)
            # 在最后一个 import 后面添加新的 import
            import_line = "import '../../../l10n/app_localizations.dart';"
            content = content.replace(last_import, f"{last_import}\n{import_line}", 1)

    # 替换字符串
    for pattern, key in STRING_MAPPINGS.items():
        # 创建替换模式
        # 匹配 Text('string') 或 Text("string") 或 label: 'string' 等
        replacement = f"AppLocalizations.of(context)!.{key}"
        content = re.sub(pattern, replacement, content)

    # 保存文件
    if content != original_content:
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(content)
        return True, "Updated"

    return False, "No changes"


def main():
    base_path = Path("/Users/cssee/Dev/Approve Now/lib")
    dart_files = list(base_path.rglob("*.dart"))

    updated_count = 0
    skipped_count = 0
    error_count = 0

    for file_path in dart_files:
        # 跳过生成的文件和测试文件
        if "generated" in str(file_path) or "test" in str(file_path):
            continue

        try:
            updated, message = process_file(file_path)
            if updated:
                updated_count += 1
                print(f"✅ Updated: {file_path.relative_to(base_path)}")
            else:
                skipped_count += 1
        except Exception as e:
            error_count += 1
            print(f"❌ Error in {file_path.relative_to(base_path)}: {e}")

    print(f"\n{'=' * 60}")
    print(f"Summary:")
    print(f"  Updated: {updated_count} files")
    print(f"  Skipped: {skipped_count} files")
    print(f"  Errors: {error_count} files")
    print(f"{'=' * 60}")


if __name__ == "__main__":
    main()
