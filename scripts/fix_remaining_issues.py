#!/usr/bin/env python3
"""修复剩余的所有国际化相关错误"""

import re

files_to_fix = {
    "/Users/cssee/Dev/Approve Now/lib/modules/workspace/workspace_ui/workspace_detail_screen.dart": [
        # 修复 const InputDecoration
        (
            r"const InputDecoration\(labelText: AppLocalizations\.of\(context\)!(\.[\w]+)\)",
            r"InputDecoration(labelText: AppLocalizations.of(context)!\1)",
        ),
        (
            r"const InputDecoration\(labelText: AppLocalizations\.of\(context\)!(\.[\w]+)\)",
            r"InputDecoration(labelText: AppLocalizations.of(context)!\1)",
        ),
    ],
    "/Users/cssee/Dev/Approve Now/lib/modules/workspace/workspace_member.dart": [
        # 移除 AppLocalizations 导入和使用，在 enum 中不能使用
        (r"import '../../l10n/app_localizations.dart';\n", ""),
        (r"AppLocalizations\.of\(context\)!\.", ""),
    ],
    "/Users/cssee/Dev/Approve Now/lib/modules/workspace/workspace_ui/widgets/activity_list.dart": [
        # 移除 AppLocalizations 导入和使用，这些是工具方法
        (r"import '../../../../l10n/app_localizations.dart';\n", ""),
        (
            r"AppLocalizations\.of\(context\)!\.(\w+)",
            lambda m: f"'{get_hardcoded_value(m.group(1))}'",
        ),
    ],
    "/Users/cssee/Dev/Approve Now/lib/modules/template/ai/smart_template_generator.dart": [
        # 移除 AppLocalizations 导入和使用
        (r"import '../../../l10n/app_localizations.dart';\n", ""),
        (r"AppLocalizations\.of\(context\)!\.", ""),
    ],
}


def get_hardcoded_value(key):
    """返回硬编码的英文值"""
    values = {
        "pending": "Pending",
        "approved": "Approved",
        "rejected": "Rejected",
        "draft": "Draft",
    }
    return values.get(key, key)


def fix_file(file_path, replacements):
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()

        original = content
        for pattern, replacement in replacements:
            if callable(replacement):
                content = re.sub(pattern, replacement, content)
            else:
                content = re.sub(pattern, replacement, content)

        if content != original:
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(content)
            print(f"✅ Fixed: {file_path}")
            return True
    except Exception as e:
        print(f"❌ Error: {file_path} - {e}")
    return False


# 修复所有文件
for file_path, replacements in files_to_fix.items():
    fix_file(file_path, replacements)

print("\nDone!")
