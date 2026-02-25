# App Store Connect 订阅产品提交指南

## 当前状态
- ✅ Subscription Group 已创建: "Appro Now Plan"
- ✅ 4 个订阅产品已配置
- ❌ 状态: "Missing Metadata"（缺少 Review Screenshot）
- ❌ 尚未提交审核

---

## 第一步：完善产品信息（30 分钟）

### 1.1 上传 Review Screenshot

对于每个订阅产品（共 4 个）：

**操作路径**：
```
App Store Connect → My Apps → Appro Now → Subscriptions → [产品名称]
```

**必填内容**：
- **Review Screenshot**: 点击 "Choose File"
  - 尺寸要求：1024x768 像素或更高
  - 格式：JPG 或 PNG
  - 内容：可以是应用的截图，或简单的占位图
  - 提示：苹果只用它来做审核参考，不影响功能

**保存**：
- 点击右上角 **"Save"** 按钮
- 状态应该变成 **"Ready to Submit"**

**批量操作建议**：
- 用同一个截图上传给所有 4 个产品
- 或者创建 4 个不同的截图（更好）

---

## 第二步：创建 App 版本（20 分钟）

### 2.1 创建新版本

**操作路径**：
```
App Store Connect → My Apps → Appro Now → App Store → iOS App → [+] 按钮
```

**填写信息**：
- **Version Number**: `1.0.0`（或你的版本号）
- **What's New in This Version**: 
  ```
  Initial release with subscription support.
  - Free plan with basic features
  - Starter plan with workspace branding
  - Pro plan with custom branding and email notifications
  ```

### 2.2 关联订阅产品

**关键步骤**：

1. 在版本页面找到 **"In-App Purchases and Subscriptions"** 部分
2. 点击 **"Edit"**
3. 勾选所有 4 个订阅产品：
   - ✅ Starter Monthly
   - ✅ Starter Yearly  
   - ✅ Pro Monthly
   - ✅ Pro Yearly
4. 点击 **"Done"**

### 2.3 填写其他信息

**App Store 信息**：
- **Promotional Text**: （可选）
- **Description**: 
  ```
  Appro Now is an intelligent approval management system designed to streamline your team's approval workflows.
  
  Key Features:
  - Create custom approval templates
  - Multi-level approval workflows
  - PDF export with verification hash
  - Real-time notifications
  - Workspace collaboration
  
  Subscription Plans:
  • Free: 1 workspace, 1 template, basic features
  • Starter: 3 workspaces, 5 templates, Excel export, workspace branding
  • Pro: Unlimited workspaces and templates, custom branding, email notifications
  ```

- **Keywords**: `approval, workflow, business, team, document, pdf, signature`
- **Support URL**: 你的支持网站（可以用 landing page）
- **Marketing URL**: （可选）

---

## 第三步：上传构建版本（30 分钟）

### 3.1 在 Xcode 中构建

```bash
# 确保代码已提交
git add -A
git commit -m "Prepare for App Store submission"
git push origin master

# 构建 Release 版本
flutter build ios --release
```

### 3.2 使用 Xcode Archive

1. 打开 `ios/Runner.xcworkspace`
2. 选择 **Generic iOS Device** 或 **Any iOS Device**
3. 点击 **Product** → **Archive**
4. 等待构建完成

### 3.3 上传到 App Store Connect

1. 在 Organizer 窗口中，选择刚创建的 Archive
2. 点击 **"Distribute App"**
3. 选择 **"App Store Connect"** → **"Upload"**
4. 选择签名方式（通常是 Automatic）
5. 等待上传完成（5-10 分钟）

**上传完成后**：
- 等待 10-30 分钟，构建版本会出现在 App Store Connect
- 状态会从 "Processing" 变成 "Ready"

---

## 第四步：提交审核（10 分钟）

### 4.1 选择构建版本

**操作路径**：
```
App Store Connect → My Apps → Appro Now → App Store → iOS App → 1.0.0
```

**操作**：
1. 在 **"Build"** 部分，点击 **"Select a build before you submit your app"**
2. 选择刚上传的构建版本
3. 点击 **"Done"**

### 4.2 填写审核信息

**App Review Information**：
- **Sign-in Information**: 
  - 提供测试账号（如果应用需要登录）
  - 邮箱：`test@example.com`
  - 密码：`Test123!`
  
- **Contact Information**: 你的联系信息
- **Notes**: （可选）给审核员的备注

**Export Compliance**: 
- 通常选择 **"No"**（除非使用加密）

### 4.3 提交审核

1. 点击右上角 **"Submit for Review"**
2. 回答出口合规问题
3. 确认内容评级
4. 点击 **"Submit"**

---

## 第五步：等待审核（24-48 小时）

### 审核状态跟踪

**操作路径**：
```
App Store Connect → My Apps → Appro Now → App Store → iOS App
```

**可能的状态**：
- **Waiting for Review**: 等待审核
- **In Review**: 正在审核
- **Pending Contract**: 需要签署合同（如果是首次提交）
- **Ready for Sale**: 审核通过！
- **Rejected**: 被拒绝（查看原因并修复）

### 如果被拒绝

**常见原因**：
1. **Guideline 3.1.1 - Business**: 订阅信息不清晰
   - 修复：确保 App 内清晰展示订阅价格和条款
   
2. **Guideline 2.3.10 - Performance**: 准确的元数据
   - 修复：确保截图和描述准确反映应用功能

3. **Guideline 4.2 - Design**: 最低功能要求
   - 修复：确保应用有足够功能，不只是网站包装

---

## 第六步：RevenueCat 同步（审核通过后）

### 6.1 等待 RevenueCat 同步

审核通过后：
1. RevenueCat 会在 5-10 分钟内自动同步
2. 在 RevenueCat Dashboard → Products
3. 状态应该变成 **"Available"**

### 6.2 测试订阅功能

**使用 Xcode 运行到真机**：
1. 确保使用的是 **Sandbox 测试账号**
2. 登录：设置 → App Store → 登录沙盒账号
3. 测试购买流程

**验证**：
- 能正常显示订阅选项
- 能完成购买
- RevenueCat Dashboard 显示交易记录

---

## 快速检查清单

### 提交流入前检查：
- [ ] 4 个订阅产品都上传了 Review Screenshot
- [ ] 所有产品状态变成 "Ready to Submit"
- [ ] 创建了 App 版本并关联了订阅
- [ ] 上传了构建版本并等待处理完成
- [ ] 填写了所有必填信息（描述、关键词、支持 URL）
- [ ] 提供了测试账号（如果需要）

### 提交后检查：
- [ ] 状态变成 "Waiting for Review"
- [ ] 收到确认邮件
- [ ] 24-48 小时内审核完成
- [ ] RevenueCat 产品状态变成 "Available"
- [ ] 测试订阅功能正常

---

## 故障排除

### Q: 上传构建版本后看不到
**A**: 等待 10-30 分钟，刷新页面

### Q: RevenueCat 显示 "Could not check"
**A**: 
1. 确认 App Store Connect 产品已提交审核
2. 等待 5-10 分钟后刷新
3. 检查 RevenueCat 使用的是正确的 App Store App ID

### Q: 审核被拒绝
**A**: 
1. 仔细阅读拒绝原因
2. 按照指南修复问题
3. 重新提交

### Q: 测试购买时显示 "Cannot connect to iTunes Store"
**A**: 
1. 确认使用沙盒测试账号（不是真实 Apple ID）
2. 在设置 → App Store → 登录沙盒账号
3. 重新运行应用

---

## 重要提示

1. **首次提交**: 审核可能需要 48 小时，耐心等待
2. **订阅产品**: 必须随 App 版本一起提交
3. **价格显示**: 确保 App 内清晰展示价格和条款
4. **隐私政策**: 确保提供隐私政策 URL
5. **测试账号**: 准备好测试账号给审核员使用

---

## 下一步

完成以上步骤后，告诉我：
1. 你是否成功提交了审核？
2. 审核状态是什么？
3. RevenueCat 产品状态是否变成 "Available"？

我来帮你检查 RevenueCat 配置是否正确！
