import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/item.dart';
import '../providers/item_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '设置',
                        style: TextStyle(
                          fontFamily: 'Outfit',
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          color: AppColors.onBackground,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '个性化您的记账与资产管理体验',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            // Settings Grid (3 columns on wide, stacked on mobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== Appearance Section =====
                _SectionHeader(
                  icon: Icons.palette,
                  iconColor: AppColors.primary,
                  title: '外观',
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.foreground, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        offset: const Offset(6, 6),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Theme Color Row
                      _SettingsRow(
                        icon: Icons.color_lens,
                        iconBgColor: AppColors.quaternary,
                        iconRotate: -3,
                        title: '主题颜色',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ColorDot(color: AppColors.primary),
                            const SizedBox(width: 4),
                            _ColorDot(color: AppColors.secondary),
                            const SizedBox(width: 4),
                            _ColorDot(color: AppColors.tertiary),
                          ],
                        ),
                        onTap: () => _showThemeColorPicker(context, ref),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ===== Data Section =====
                _SectionHeader(
                  icon: Icons.storage,
                  iconColor: AppColors.secondary,
                  title: '数据',
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.foreground, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.4),
                        offset: const Offset(6, 6),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _SettingsRow(
                        icon: Icons.upload,
                        iconBgColor: AppColors.primaryContainer,
                        iconRotate: 2,
                        title: '导出数据',
                        trailing: Icon(Icons.chevron_right, color: AppColors.foreground),
                        onTap: () => _exportData(context, ref),
                      ),
                      Divider(height: 2, thickness: 2, color: AppColors.border),
                      _SettingsRow(
                        icon: Icons.download,
                        iconBgColor: AppColors.quaternary,
                        iconRotate: -1,
                        title: '导入数据',
                        trailing: Icon(Icons.chevron_right, color: AppColors.foreground),
                        onTap: () => _importData(context, ref),
                      ),
                      Divider(height: 2, thickness: 2, color: AppColors.border),
                      _SettingsRow(
                        icon: Icons.delete_forever,
                        iconBgColor: AppColors.error,
                        iconRotate: -2,
                        title: '清除所有数据',
                        titleColor: AppColors.error,
                        trailing: Icon(Icons.warning, color: AppColors.error),
                        onTap: () => _confirmClearData(context, ref),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ===== About Section =====
                _SectionHeader(
                  icon: Icons.info,
                  iconColor: AppColors.quaternary,
                  title: '关于',
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.foreground, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.quaternary.withValues(alpha: 0.4),
                        offset: const Offset(6, 6),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _SettingsRow(
                        icon: Icons.terminal,
                        iconBgColor: AppColors.onSurfaceVariant,
                        iconRotate: 6,
                        title: '版本信息',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(9999),
                            border: Border.all(color: AppColors.foreground, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.foreground,
                                offset: const Offset(2, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            'V1.0.0',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.05,
                              color: AppColors.onBackground,
                            ),
                          ),
                        ),
                      ),
                      Divider(height: 2, thickness: 2, color: AppColors.border),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeColorPicker(BuildContext context, WidgetRef ref) {
    final themes = <Map<String, dynamic>>[
      {'name': '紫罗兰', 'primary': 0xFF6b38d4, 'secondary': 0xFFF472B6, 'tertiary': 0xFFFBBF24},
      {'name': '海洋蓝', 'primary': 0xFF2563EB, 'secondary': 0xFF06B6D4, 'tertiary': 0xFFF59E0B},
      {'name': '森林绿', 'primary': 0xFF059669, 'secondary': 0xFF34D399, 'tertiary': 0xFFFBBF24},
      {'name': '珊瑚红', 'primary': 0xFFDC2626, 'secondary': 0xFFF97316, 'tertiary': 0xFFFBBF24},
      {'name': '玫瑰金', 'primary': 0xFFDB2777, 'secondary': 0xFFF472B6, 'tertiary': 0xFFFCD34D},
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('选择主题颜色'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themes.map((theme) {
            return ListTile(
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 20, height: 20, decoration: BoxDecoration(color: Color(theme['primary'] as int), shape: BoxShape.circle, border: Border.all(color: AppColors.foreground))),
                  const SizedBox(width: 4),
                  Container(width: 20, height: 20, decoration: BoxDecoration(color: Color(theme['secondary'] as int), shape: BoxShape.circle, border: Border.all(color: AppColors.foreground))),
                  const SizedBox(width: 4),
                  Container(width: 20, height: 20, decoration: BoxDecoration(color: Color(theme['tertiary'] as int), shape: BoxShape.circle, border: Border.all(color: AppColors.foreground))),
                ],
              ),
              title: Text(theme['name'] as String),
              onTap: () {
                ref.read(themeColorProvider.notifier).setThemeColors(
                  primary: Color(theme['primary'] as int),
                  secondary: Color(theme['secondary'] as int),
                  tertiary: Color(theme['tertiary'] as int),
                );
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    try {
      final repo = ref.read(itemRepositoryProvider);
      final items = await repo.getAllItems();
      if (items.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('没有数据可导出')),
          );
        }
        return;
      }

      final jsonList = items.map((item) => item.toMap()).toList();
      final jsonStr = const JsonEncoder.withIndent('  ').convert(jsonList);

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final file = File('${dir.path}/dailycost_export_$timestamp.json');
      await file.writeAsString(jsonStr);

      if (context.mounted) {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: '日计数据导出 $timestamp',
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.isEmpty) return;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();
      final jsonList = jsonDecode(content) as List<dynamic>;

      final repo = ref.read(itemRepositoryProvider);
      int imported = 0;
      for (final map in jsonList) {
        final cleanMap = Map<String, dynamic>.from(map as Map)
          ..remove('id')
          ..['created_at'] ??= DateTime.now().toIso8601String()
          ..['updated_at'] = DateTime.now().toIso8601String();
        // Build Item without id so DB auto-generates one
        final item = Item(
          name: cleanMap['name'] as String? ?? '未命名',
          brand: cleanMap['brand'] as String?,
          category: cleanMap['category'] as String?,
          price: (cleanMap['price'] as num?)?.toDouble() ?? 0,
          purchaseDate: cleanMap['purchase_date'] != null
              ? DateTime.parse(cleanMap['purchase_date'] as String)
              : DateTime.now(),
          expectedLifespanMonths: (cleanMap['expected_lifespan_months'] as int?) ?? 365,
          imagePath: cleanMap['image_path'] as String?,
          source: (cleanMap['source'] as String?) ?? 'manual',
        );
        await repo.createItem(item);
        imported++;
      }
      ref.invalidate(itemListProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('成功导入 $imported 件物品')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导入失败: $e')),
        );
      }
    }
  }

  void _confirmClearData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('确定要删除所有物品记录吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(itemRepositoryProvider);
              await repo.deleteAllItems();
              ref.invalidate(itemListProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('所有数据已清除')),
                );
              }
            },
            child: Text('删除', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

// ==================== Section Header ====================

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;

  const _SectionHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.foreground, width: 2),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.05,
            color: AppColors.foreground,
          ),
        ),
      ],
    );
  }
}

// ==================== Settings Row ====================

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final double iconRotate;
  final String title;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.iconBgColor,
    this.iconRotate = 0,
    required this.title,
    this.titleColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Transform.rotate(
              angle: iconRotate * 3.14159 / 180,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.foreground, width: 2),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: titleColor ?? AppColors.onBackground,
                ),
              ),
            ),
            // ignore: use_null_aware_elements
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

// ==================== Color Dot ====================

class _ColorDot extends StatelessWidget {
  final Color color;

  const _ColorDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.foreground, width: 2),
      ),
    );
  }
}

