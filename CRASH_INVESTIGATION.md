# TestFlight 崩溃排查检查清单

## 已发现的问题和修复状态

### 1. RevenueCat 配置问题 [已修复]
**问题**: 硬编码测试API key，没有区分Sandbox/Production环境
**风险**: 高 - 可能导致TestFlight内购验证失败或崩溃
**修复**: 
- 改为从环境变量读取API key
- 添加`--dart-define=REVENUECAT_IOS_KEY=xxx`支持
- 添加失败保护（RevenueCat失败不会导致应用崩溃）

### 2. Supabase 配置问题 [待修复]
**问题**: Anon key硬编码在代码中
**风险**: 中 - 安全风险，但不会导致崩溃
**修复**: 
- 需要改为从环境变量读取
- 已支持`--dart-define=SUPABASE_ANON_KEY=xxx`

### 3. iOS 原生配置检查 [待检查]
需要检查:
- [ ] App Transport Security 设置
- [ ] Background Modes 配置
- [ ] 推送通知配置
- [ ] 应用图标和启动屏
- [ ] 构建设置（Architecture, Code Signing）

### 4. 错误处理强化 [已部分修复]
**已修复**:
- RevenueCat初始化失败不会导致崩溃
- 添加了详细的错误日志

**需要检查**:
- Supabase连接超时的处理
- 网络请求超时设置

### 5. 构建配置检查 [待检查]
需要确认:
- [ ] Release模式编译优化
- [ ] 代码混淆/压缩设置
- [ ] 架构设置（arm64 only for production）
- [ ] Bitcode设置（iOS 16+不需要）

## 下一步行动

### 立即执行:
1. 修复Supabase配置
2. 检查并修复iOS Background Modes
3. 添加App Transport Security配置
4. 测试Release构建

### 构建命令（生产环境）:
```bash
# 生产构建（带环境变量）
flutter build ios --release \
  --dart-define=REVENUECAT_IOS_KEY=YOUR_PRODUCTION_KEY \
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_KEY

# 或者直接编辑Xcode配置
```

## TestFlight崩溃常见原因

1. **RevenueCat配置错误** - 使用测试key而不是生产key
2. **Supabase连接失败** - 网络超时或配置错误
3. **内存限制** - Release模式下内存使用过高
4. **代码签名问题** - 证书或provisioning profile错误
5. **缺少权限描述** - 某些权限描述缺失
6. **架构不匹配** - 包含模拟器架构
