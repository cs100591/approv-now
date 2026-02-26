# 🔍 Push Notification 诊断清单

## 用户反馈
- ✅ Debug Test 全部通过（FCM Token 获取成功、保存成功、权限已授权）
- ❌ 实际收不到推送通知

## 可能原因

### 1. Firebase Console APNs 配置问题 ⭐ MOST LIKELY
**检查步骤：**
1. 打开 https://console.firebase.google.com/
2. 选择 approve-now 项目
3. 点击 ⚙️ → Project settings → Cloud Messaging
4. 查看 "Apple app configuration" 部分

**应该看到：**
- ✅ APNs Authentication Key 已上传
- ✅ Key ID 显示（10个字符）
- ✅ Team ID: 23ABYAMJ3V

**如果没有，请上传：**
1. 去 Apple Developer → Certificates, Identifiers & Profiles → Keys
2. 创建新 Key，勾选 "Apple Push Notifications service (APNs)"
3. 下载 .p8 文件
4. 上传到 Firebase Console

---

### 2. Edge Function 发送失败
**测试方法：**

```bash
# 1. 查询你的 User ID
SELECT id, email, fcm_token FROM profiles WHERE fcm_token IS NOT NULL;

# 2. 记录 User ID，然后测试发送
```

**手动测试 Edge Function：**
```bash
curl -X POST "https://poaontiyougqfzmzxerf.supabase.co/functions/v1/send-push-notification" \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "YOUR_USER_ID",
    "title": "Test",
    "body": "Hello"
  }'
```

---

### 3. Provisioning Profile 问题
**现象：** TestFlight 版本收不到，但开发版本可以

**解决：**
1. Xcode → Signing & Capabilities
2. 确保 "Push Notifications" capability 已添加
3. 点击 "Automatically manage signing" 重新生成 profile

---

### 4. 网络/防火墙问题
**检查：** FCM 需要访问以下域名：
- fcm.googleapis.com
- firebaseinstallations.googleapis.com

---

## 🛠️ 立即执行的诊断步骤

### 步骤 1: 检查 Firebase Console
请截图或告诉我：
- Firebase Console → Project Settings → Cloud Messaging
- Apple app configuration 部分是否有 APNs Key？

### 步骤 2: 检查 Edge Function 日志
```sql
-- 在 Supabase Dashboard SQL Editor 中执行：
-- 查看最近的 Edge Function 调用日志
SELECT 
  timestamp,
  level,
  message
FROM edge_function_logs 
WHERE function_name = 'send-push-notification'
ORDER BY timestamp DESC
LIMIT 20;
```

### 步骤 3: 手动测试发送
在 App 中：
1. 创建一个审批请求
2. 查看 Xcode 控制台是否有 `sendPushNotification` 调用日志
3. 检查 Supabase Edge Function Logs

---

## 🎯 最可能的解决方案

### 方案 A: Firebase APNs 未配置（90% 可能）
**症状：** Token 能获取，但发送失败
**解决：** 上传 APNs .p8 文件到 Firebase Console

### 方案 B: Provisioning Profile 过期
**症状：** TestFlight 收不到，开发版可以
**解决：** Xcode 中重新生成 Provisioning Profile

### 方案 C: Edge Function 权限问题
**症状：** 调用返回 500 错误
**解决：** 检查 FCM_SERVICE_ACCOUNT 密钥

---

## 请告诉我检查结果：

1. **Firebase Console 有没有 APNs Key？**
2. **Supabase Edge Function 日志显示什么错误？**
3. **在 Xcode 控制台搜索 "sendPushNotification" 看到了什么？**
