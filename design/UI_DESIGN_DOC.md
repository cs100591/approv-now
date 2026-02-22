# Approve Now - Web UI 设计文档

## 📁 设计文件

**文件位置**: `/Users/cssee/Dev/Approve Now/design/approve_now_ui.pen`

---

## 🎨 设计规范

### 色彩系统
- **主色**: `#1E3A8A` (蓝色)
- **背景**: `#F8FAFC` (浅灰蓝)
- **卡片**: `#FFFFFF` (白色)
- **边框**: `#E2E8F0` (浅灰)
- **文字**: `#0F172A` (深色), `#64748B` (灰色)
- **状态色**:
  - 成功: `#22C55E`
  - 警告: `#F59E0B`
  - 错误: `#EF4444`
  - 信息: `#1E3A8A`

### 字体
- **标题**: Space Grotesk
- **正文**: Inter

### 间距
- 页面内边距: 32px 40px
- 卡片内边距: 24px
- 组件间距: 12-24px

---

## 📱 页面列表

### 1. Dashboard (仪表板)
**ID**: `p25AO`

**功能**:
- 统计卡片展示 (Pending/Approved/Avg Time/Templates)
- 最近活动列表
- 快捷操作面板
- 左侧导航栏

**组件**:
- Sidebar (260px 固定宽度)
- Stats Cards (4列网格)
- Activity List (时间线)
- Quick Actions (4个快捷按钮)

---

### 2. Templates (模板管理)
**ID**: `M2SSa`

**功能**:
- 模板卡片网格展示
- 搜索功能
- 新建模板按钮
- 状态标签 (Active/Draft)

**组件**:
- Search Bar
- Template Cards (图标+标题+描述+状态)
- New Template Button

---

### 3. Requests (审批列表)
**ID**: `qMznr`

**功能**:
- Tab 切换 (Pending/Approved/Rejected)
- 搜索和筛选
- 表格列表展示
- 状态徽章

**组件**:
- Tabs
- Filter Bar
- Data Table (Request/Template/Status/Date)
- Status Badges

---

### 4. Request Detail (审批详情)
**ID**: `vx36v`

**功能**:
- 面包屑导航
- 请求信息展示
- 附件列表
- 审批时间线
- 提交人信息卡片
- 审批/拒绝按钮

**组件**:
- Breadcrumb
- Request Info Card
- Timeline
- Submitter Card
- Action Buttons

---

### 5. Mobile Dashboard (移动端)
**ID**: `570FO`

**功能**:
- 欢迎语
- 横向滚动的统计卡片
- 最近活动列表
- 快捷操作网格
- 底部导航栏

**组件**:
- Mobile Header
- Stats Scroll (横向滚动)
- Activity Cards
- Action Grid
- Bottom Navigation (4个Tab)

---

### 6. Workspaces (工作空间)
**ID**: `JfVfr`

**功能**:
- 工作空间卡片网格
- 成员/模板/请求统计
- 新建工作空间按钮
- 状态标签

**组件**:
- Workspace Cards
- Stats Display
- New Workspace Button

---

## 🔄 共享组件

### Sidebar (侧边栏)
**位置**: 所有页面左侧

**元素**:
- Logo (图标 + 文字)
- Navigation Items:
  - Dashboard (◆)
  - Templates (▢)
  - Requests (◈)
  - Workspaces (⊡)
  - Team (👥)
- User Section (头像 + 姓名 + 邮箱)

**样式**:
- 宽度: 260px
- 背景: #FFFFFF
- 右边框: 1px solid #E2E8F0
- 选中状态: #EFF6FF 背景 + #1E3A8A 文字

---

### Cards (卡片)

**统计卡片**:
- 图标 (40x40)
- 数值 (36px, 粗体)
- 标签 (13px, 灰色)
- 变化指示 (绿色/红色)

**模板卡片**:
- 图标 (48x48)
- 标题 (18px)
- 描述 (14px, 灰色)
- 状态徽章
- 请求数量

**工作空间卡片**:
- 图标 (48x48)
- 名称 (18px)
- 状态标签
- 统计 (Members/Templates/Requests)

---

### Buttons (按钮)

**Primary Button**:
- 背景: #1E3A8A
- 文字: #FFFFFF
- 圆角: 8px
- 内边距: 12px 20px

**Secondary Button**:
- 背景: #FFFFFF
- 边框: 1px solid #E2E8F0
- 文字: #0F172A
- 圆角: 8px

**Danger Button**:
- 背景: #FEF2F2
- 边框: 1px solid #FECACA
- 文字: #DC2626
- 圆角: 8px

---

### Badges (徽章)

**Active**: #DCFCE7 背景, #166534 文字
**Pending**: #FEF3C7 背景, #92400E 文字
**Draft**: #F1F5F9 背景, #475569 文字
**Rejected**: #FEF2F2 背景, #991B1B 文字

---

## 📐 响应式断点

- **Desktop**: > 1024px (1440px 标准)
- **Tablet**: 768px - 1024px
- **Mobile**: < 768px (375px 标准)

---

## 🎯 使用说明

### 在 Flutter Web 中实现

```dart
// 1. 复制颜色常量
const primaryColor = Color(0xFF1E3A8A);
const backgroundColor = Color(0xFFF8FAFC);
const cardColor = Colors.white;
const borderColor = Color(0xFFE2E8F0);

// 2. 使用相同的字体
// 在 pubspec.yaml 中添加:
// fonts:
//   - family: Space Grotesk
//     fonts:
//       - asset: assets/fonts/SpaceGrotesk.ttf
//   - family: Inter
//     fonts:
//       - asset: assets/fonts/Inter.ttf

// 3. 创建响应式布局
ResponsiveLayout(
  mobile: MobileDashboard(),
  tablet: Dashboard(),
  desktop: Dashboard(),
)
```

### 导出为 HTML/CSS

使用 Pencil CLI 导出:
```bash
pencil export approve_now_ui.pen --format html --output web/
```

---

## 🔗 与 Flutter App 联动

### 共享 Backend
- 所有页面使用相同的 Supabase Client
- 共享 Auth Provider
- 共享 Workspace/Template/Request 状态

### 路由对应
```
/              -> Dashboard
/templates     -> Templates
/requests      -> Requests
/requests/:id  -> Request Detail
/workspaces    -> Workspaces
/team          -> Team
```

### 状态管理
使用 Provider/Riverpod 在 Web 和 Mobile 间共享:
- AuthProvider (认证状态)
- WorkspaceProvider (当前工作空间)
- TemplateProvider (模板列表)
- RequestProvider (请求列表)

---

## 📸 截图预览

所有页面截图位于:
- `/Users/cssee/Dev/Approve Now/design/screenshots/`

页面截图:
1. `dashboard.png` - Dashboard
2. `templates.png` - Templates
3. `requests.png` - Requests
4. `request_detail.png` - Request Detail
5. `mobile_dashboard.png` - Mobile
6. `workspaces.png` - Workspaces

---

## ✨ 设计亮点

1. **一致的视觉语言**: 所有页面使用相同的配色、字体和间距
2. **清晰的层次**: 通过颜色深浅和字体大小建立视觉层次
3. **友好的交互**: 悬停状态、选中状态清晰可辨
4. **移动端优化**: 底部导航栏、卡片式布局适配小屏幕
5. **信息密度适中**: 既不过于拥挤，也不过于稀疏

---

## 📝 后续优化建议

1. 添加深色模式支持
2. 增加图表组件 (折线图、饼图等)
3. 添加拖拽排序功能
4. 实现实时通知推送
5. 添加多语言支持

---

**设计完成时间**: 2026-02-22
**设计工具**: Pencil MCP
**版本**: 1.0
