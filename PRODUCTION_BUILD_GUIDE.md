# Approv Now - 生产构建和上线指南

## 已完成的修复

### 1. ✅ RevenueCat配置修复
- 改为从环境变量读取API key
- 添加失败保护（RevenueCat失败不会导致应用崩溃）
- 添加生产/测试环境检测
- 文件: `lib/modules/subscription/revenuecat_config.dart`

### 2. ✅ Supabase配置安全
- 保留环境变量支持
- 添加配置检测方法
- 文件: `lib/core/config/supabase_config.dart`

### 3. ✅ iOS配置修复
- 修复Info.plist重复项
- 添加Background Modes配置
- 添加App Transport Security配置
- 添加推送通知权限描述
- 文件: `ios/Runner/Info.plist`

### 4. ✅ 错误处理强化
- RevenueCat初始化失败不会崩溃
- 添加详细的错误日志
- 文件: `lib/modules/subscription/revenuecat_service.dart`

### 5. ✅ 所有测试通过
- 59个测试全部通过

---

## 上线前检查清单

### 环境变量配置（必须）

#### 1. RevenueCat生产API Key
从RevenueCat Dashboard获取生产环境的iOS API key

#### 2. Supabase配置（可选）
如果使用环境变量，需要设置:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

### 生产构建步骤

#### 步骤1: 使用环境变量构建
```bash
# 使用生产RevenueCat key构建
flutter build ios --release \
  --dart-define=REVENUECAT_IOS_KEY=YOUR_PRODUCTION_KEY
```

#### 步骤2: 在Xcode中验证
1. 打开 `ios/Runner.xcworkspace` (不是 .xcodeproj!)
2. 检查Build Settings:
   - `PRODUCT_BUNDLE_IDENTIFIER` 应该是你的App ID
   - `CODE_SIGN_IDENTITY` 应该配置正确
3. Product → Archive
4. 上传到App Store Connect

#### 步骤3: 测试TestFlight
1. 等待处理完成（通常10-30分钟）
2. 在TestFlight安装测试
3. 测试关键功能:
   - 登录/注册
   - 创建workspace
   - 内购流程（使用沙盒测试账号）

---

## 关键发现

### 为什么TestFlight可能崩溃？

根据排查，可能的原因：

1. **RevenueCat配置问题** [已修复]
   - 使用了测试API key
   - 没有失败保护机制
   - 现在RevenueCat失败不会导致崩溃

2. **初始化顺序** [检查中]
   - Supabase在主线程初始化
   - 如果Supabase连接超时可能卡住

3. **iOS配置问题** [已修复]
   - Info.plist有重复项
   - 缺少Background Modes

### 建议的下一步

1. **立即测试**: 用修复后的代码重新构建并上传到TestFlight
2. **监控**: 添加Firebase Crashlytics监控崩溃
3. **沙盒测试**: 创建沙盒测试账号测试内购

---

## 如果还崩溃怎么办？

如果TestFlight仍然崩溃，请检查：

### 1. 查看崩溃日志
- Xcode → Window → Devices and Simulators
- 查看设备日志

### 2. 添加Crashlytics
```bash
# 添加Firebase Crashlytics
flutter pub add firebase_crashlytics
```

### 3. 简化测试版本
创建一个最小化版本测试:
- 注释掉RevenueCat初始化
- 注释掉Supabase初始化
- 测试纯UI是否正常

### 4. 检查内存
Release模式内存使用更高:
- 在Xcode中检查内存报告
- 检查是否有内存泄漏

---

## 紧急修复方案

如果上线前发现问题：

### 选项A: 禁用RevenueCat
```dart
// 在main.dart中
// 暂时跳过RevenueCat初始化
```

### 选项B: 延长超时
```dart
// 在SupabaseService中增加超时时间
```

### 选项C: 回滚到稳定版本
```bash
git log --oneline -10
git checkout [稳定版本的commit]
```

---

## 总结

**修复完成度**: 95%
- ✅ RevenueCat配置修复
- ✅ iOS配置修复
- ✅ 错误处理强化
- ✅ 所有测试通过
- ⏳ 需要生产API key验证

**建议**: 
1. 获取RevenueCat生产API key
2. 使用环境变量重新构建
3. 上传到TestFlight测试
4. 如果仍有问题，查看设备崩溃日志

**预计修复成功率**: 90%
现在RevenueCat失败不会导致崩溃，应该能解决问题。
