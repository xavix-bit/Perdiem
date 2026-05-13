import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/item.dart';
import '../providers/theme_provider.dart';

/// Playful Geometric 风格的删除确认弹窗
/// 对齐 stitch _6 设计
Future<bool?> showDeleteConfirmDialog({
  required BuildContext context,
  required Item item,
}) {
  return showDialog<bool>(
    context: context,
    barrierColor: Colors.transparent,
    builder: (ctx) => _DeleteConfirmDialog(item: item),
  );
}

class _DeleteConfirmDialog extends StatelessWidget {
  final Item item;

  const _DeleteConfirmDialog({required this.item});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop blur
        GestureDetector(
          onTap: () => Navigator.pop(context, false),
          child: Container(
            color: AppColors.background.withValues(alpha: 0.5),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(),
            ),
          ),
        ),

        // Modal
        Center(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(maxWidth: 420),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Main Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.onSurface, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.onSurface,
                          offset: const Offset(6, 6),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ===== Warning Illustration =====
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 112,
                              height: 112,
                              decoration: BoxDecoration(
                                color: AppColors.errorContainer,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.onSurface, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.onSurface,
                                    offset: const Offset(4, 4),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.delete_forever,
                                color: AppColors.error,
                                size: 56,
                              ),
                            ),
                            // Sticker close icon
                            Positioned(
                              top: -8,
                              right: -8,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.secondary,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.onSurface, width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.onSurface,
                                      offset: const Offset(2, 2),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                transform: Matrix4.rotationZ(12 * 3.14159 / 180),
                                child: Icon(Icons.close, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ===== Headline =====
                        Text(
                          '确定要删除吗？',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 280,
                          child: Text(
                            '此操作无法撤销，该物品的所有记录将永久删除。',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 10,
                              color: AppColors.onSurfaceVariant,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ===== Preview Card =====
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.onSurface, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.onSurface,
                                offset: const Offset(2, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Thumbnail
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.onSurface, width: 2),
                                ),
                                child: Icon(
                                  _iconForCategory(item.category),
                                  color: AppColors.primary,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '正在删除项目',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.05,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.name,
                                      style: TextStyle(
                                        fontFamily: 'Outfit',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurface,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '购买于 ${item.purchaseDate.year}年${item.purchaseDate.month}月',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ===== Action Buttons =====
                        Column(
                          children: [
                            // Confirm Delete Button (gradient)
                            SizedBox(
                              width: double.infinity,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.error, AppColors.secondary],
                                  ),
                                  borderRadius: BorderRadius.circular(9999),
                                  border: Border.all(color: AppColors.onSurface, width: 4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.onSurface,
                                      offset: const Offset(4, 4),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(9999),
                                    onTap: () {
                                      Navigator.pop(context, true);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '确认删除',
                                            style: TextStyle(
                                              fontFamily: 'Outfit',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(color: AppColors.onSurface, width: 2),
                                            ),
                                            child: Icon(Icons.delete, color: AppColors.error, size: 24),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Cancel Button
                            SizedBox(
                              width: double.infinity,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: BorderRadius.circular(9999),
                                  border: Border.all(color: AppColors.onSurface, width: 4),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(9999),
                                    onTap: () => Navigator.pop(context, false),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      child: Center(
                                        child: Text(
                                          '取消',
                                          style: TextStyle(
                                            fontFamily: 'Plus Jakarta Sans',
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.onSurface,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Decorative: Top-left circle
                  Positioned(
                    top: -24,
                    left: -24,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.tertiary,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.onSurface, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.onSurface,
                            offset: const Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Decorative: Bottom-right diamond
                  Positioned(
                    bottom: -16,
                    right: -16,
                    child: Transform.rotate(
                      angle: 45 * 3.14159 / 180,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.quaternary,
                          border: Border.all(color: AppColors.onSurface, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.onSurface,
                              offset: const Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Transform.rotate(
                            angle: -45 * 3.14159 / 180,
                            child: Icon(Icons.warning, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _iconForCategory(String? category) {
    switch (category) {
      case '数码':
        return Icons.laptop_mac;
      case '家居':
        return Icons.chair_outlined;
      case '服饰':
        return Icons.checkroom_outlined;
      case '运动':
        return Icons.directions_run;
      default:
        return Icons.inventory_2_outlined;
    }
  }
}
