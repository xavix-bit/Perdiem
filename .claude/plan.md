# UI Redesign: Playful Geometric Design System 迁移计划

## 概述
将现有 Flutter 应用的 UI 从当前的简约风格迁移为 stitch 设计的 **Playful Geometric** 风格。核心变化：硬阴影(hard shadow)、圆角贴纸卡片、波点/条纹纹理背景、2px粗边框、弹性动画。

## 现状分析

**已完成的部分：**
- `theme_provider.dart` 已经包含了 Playful Geometric 的完整颜色 token（AppColors 类）
- `sticker_card.dart` 已有基本的硬阴影 + 2px 边框
- 字体系统已用 Outfit（标题）+ Plus Jakarta Sans（正文）
- 数据层（Model、Repository、Provider、CostCalculator）完善

**需要改进的部分：**
- 底部导航栏：缺少硬阴影、2px 顶边框、选中项 pill 形状背景
- Home 页：统计卡片缺少颜色区分（secondary-container 背景）、缺少波点背景纹理
- Home 页：物品卡片需要更丰富的进度条样式（带 2px 边框的圆角进度条）
- Home 页："添加物品"按钮需要 pill 形状 + 大硬阴影
- Item Detail：缺少圆形进度环、统计卡片缺少彩色背景、成本趋势图缺失
- Add Item：缺少波点背景、表单缺少硬阴影 inset 效果
- Settings：缺少分栏卡片样式、缺少彩色硬阴影、缺少装饰几何形状
- Statistics：缺少虚线边框容器、柱状图、条纹纹理进度条
- 删除确认弹窗：需要自定义 modal 替代 AlertDialog

## 实施计划

### 第 1 步：更新 StickerCard 组件
**文件：** `lib/widgets/sticker_card.dart`
- 增加彩色硬阴影选项（primary/pink/green shadow）
- 增加 hover 微旋转效果
- 调整默认边框为 `onBackground` (#1E293B) 而非 outlineVariant

### 第 2 步：重做底部导航栏
**文件：** `lib/screens/main_screen.dart`（_BottomNavBar）
- 2px 顶边框 + 顶部硬阴影 (`0 -4px 0 #1E293B`)
- 选中项：pill 形状背景（primary色 + 圆角 + 小硬阴影）
- 未选中项：无背景，onSurfaceVariant 色
- 背景：surfaceContainer 色

### 第 3 步：Home 页重设计
**文件：** `lib/screens/home_screen.dart`
- AppBar：2px 底边框 + 底部硬阴影 + 背景 blur
- 统计卡片：左侧用 secondaryContainer 背景，右侧用 tertiary 背景，各有彩色硬阴影
- 物品卡片：带 2px 边框的进度条、分类图标在方块容器中
- "添加物品"按钮：pill 形状、大硬阴影（8px）、内嵌圆形 + 号图标
- 背景增加微妙的点阵纹理

### 第 4 步：Item Detail 页重设计
**文件：** `lib/screens/item_detail_screen.dart`
- AppBar：sticky、2px 底边框 + 硬阴影、编辑/删除按钮圆形带硬阴影
- 主卡片：大号成本数字 + 圆形 SVG 进度环
- 统计列：三张彩色卡片（primary-container / surface-container-highest / secondary）
- 成本趋势：SVG 折线图区域
- 物品信息：表格化显示
- 图片区域：宝丽来风格相框

### 第 5 步：Add Item 页重设计
**文件：** `lib/screens/add_item_screen.dart`
- 波点背景纹理
- 照片上传区：camera 图标浮在左上角（-rotate + 圆形 + 硬阴影）
- 表单：2 列网格布局、硬阴影 inset 输入框
- 预期使用时长：自定义滑块（圆形拖拽手柄 + 硬阴影）
- 成本预览卡片：条纹背景 + 2px 边框 + 大硬阴影
- 保存按钮：pill 形状 + 硬阴影

### 第 6 步：Statistics 页重设计
**文件：** `lib/screens/statistics_screen.dart`
- 点阵背景纹理
- 标题下划线用 secondary 色条 + 微旋转
- 虚线边框容器包裹各 section
- 概览卡片：粉色硬阴影 + 迷你柱状图
- 支出趋势：带硬阴影的柱状图（彩色旋转）
- 分类分布：条纹纹理进度条 + 彩色圆形图标

### 第 7 步：Settings 页重设计
**文件：** `lib/screens/settings_screen.dart`
- 三栏网格布局（外观/数据/关于）
- 每栏标题：彩色圆形小图标 + uppercase label
- 卡片：2px 边框 + 彩色硬阴影（紫/粉/绿）
- 每行图标在彩色方块中，hover 微旋转
- 底部退出按钮：红色边框 + 硬阴影

### 第 8 步：删除确认弹窗重设计
**文件：** 新增 `lib/widgets/delete_confirm_dialog.dart`
- 全屏 backdrop blur
- 居中白卡片：大号红色圆形警告图标 + 装饰几何元素
- 预览卡片：物品缩略图 + 名称 + 购买日期
- 渐变确认按钮（红→粉）+ 2px 硬阴影
- 取消按钮：白底 + 2px 边框

### 第 9 步：Theme 微调
**文件：** `lib/providers/theme_provider.dart`
- 补充 ColorScheme 中缺少的 token（surfaceContainer, surfaceContainerHigh 等）
- 更新 CardTheme 的默认边框为 onBackground
- 更新 InputDecorationTheme 加入 inset shadow 效果
- 添加 BottomNavigationBarTheme 的硬阴影样式

## 执行顺序
按 1→2→3→4→5→6→7→8→9 顺序实施，每步完成后运行 `flutter analyze` 确保无错误。

## 风险评估
- 代码量较大但每步独立，可分步提交
- 不涉及数据层变更，纯 UI 层重构
- 现有功能（增删查改）不受影响
