import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/item.dart';
import '../providers/ai_provider.dart';
import '../providers/item_provider.dart';
import '../providers/theme_provider.dart';
import '../services/ai_service.dart';

class AddItemScreen extends ConsumerStatefulWidget {
  final Item? item;

  const AddItemScreen({super.key, this.item});

  @override
  ConsumerState<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends ConsumerState<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _priceController;
  late final TextEditingController _lifespanController;
  String? _category;
  late DateTime _purchaseDate;
  String? _imagePath;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item?.name ?? '');
    _brandController = TextEditingController(text: item?.brand ?? '');
    _priceController = TextEditingController(text: item != null ? item.price.toStringAsFixed(2) : '');
    _lifespanController = TextEditingController(text: item != null ? (item.expectedLifespanMonths * 30).toString() : '365');
    _category = item?.category;
    _purchaseDate = item?.purchaseDate ?? DateTime.now();
    _imagePath = item?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _lifespanController.dispose();
    super.dispose();
  }

  double get _targetDailyCost {
    final price = double.tryParse(_priceController.text) ?? 0;
    final days = int.tryParse(_lifespanController.text) ?? 365;
    if (days <= 0) return 0;
    return price / days;
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1024, imageQuality: 85);
    if (picked == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'item_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path)}';
    final newPath = p.join(dir.path, fileName);
    await File(picked.path).copy(newPath);

    setState(() => _imagePath = newPath);

    // Try AI recognition
    _tryAiRecognition(newPath);
  }

  Future<void> _tryAiRecognition(String imagePath) async {
    final config = ref.read(aiConfigProvider);
    if (!config.isConfigured) return;

    try {
      final info = await AiService.extractItemInfo(
        File(imagePath),
        apiKey: config.apiKey!,
        baseUrl: config.baseUrl,
        model: config.model,
      );
      if (mounted && info.name != null && _nameController.text.isEmpty) {
        setState(() {
          _nameController.text = info.name ?? '';
          if (info.brand != null && _brandController.text.isEmpty) {
            _brandController.text = info.brand!;
          }
          if (info.price != null && _priceController.text.isEmpty) {
            _priceController.text = info.price!.toStringAsFixed(2);
          }
          if (info.category != null && _category == null) {
            _category = info.category;
          }
        });
      }
    } catch (_) {
      // Silently ignore AI failures — user can still fill manually
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final item = Item(
      id: widget.item?.id,
      name: _nameController.text.trim(),
      brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
      category: _category,
      price: double.parse(_priceController.text),
      purchaseDate: _purchaseDate,
      expectedLifespanMonths: (int.parse(_lifespanController.text) / 30).ceil(),
      source: widget.item?.source ?? 'manual',
      imagePath: _imagePath,
      createdAt: widget.item?.createdAt,
    );

    if (_isEditing) {
      await ref.read(itemListProvider.notifier).updateItem(item);
    } else {
      await ref.read(itemListProvider.notifier).addItem(item);
    }
    if (mounted) {
      Navigator.pop(context, item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Polka dot background
          CustomPaint(
            painter: _PolkaDotPainter(),
            size: Size.infinite,
          ),
          // Decorative confetti
          _ConfettiDecoration(),
          SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.only(bottom: 120),
                children: [
                  // Top AppBar
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      border: Border(
                        bottom: BorderSide(color: AppColors.foreground, width: 2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.foreground,
                          offset: const Offset(4, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.arrow_back, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          _isEditing ? '编辑物品' : '添加物品',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                    child: Column(
                      children: [
                        // ===== Photo Upload =====
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Camera icon floating top-left
                            Positioned(
                              top: -12,
                              left: -12,
                              child: Transform.rotate(
                                angle: -12 * 3.14159 / 180,
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: AppColors.tertiary,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppColors.foreground, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.foreground,
                                        offset: const Offset(4, 4),
                                        blurRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Icon(Icons.photo_camera, color: AppColors.onBackground, size: 28),
                                ),
                              ),
                            ),
                            // Upload area
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: double.infinity,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 4,
                                    style: BorderStyle.solid,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.foreground,
                                      offset: const Offset(4, 4),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                                child: _imagePath != null
                                    ? Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.file(
                                              File(_imagePath!),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          // Remove button
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: GestureDetector(
                                              onTap: () => setState(() => _imagePath = null),
                                              child: Container(
                                                width: 32,
                                                height: 32,
                                                decoration: BoxDecoration(
                                                  color: AppColors.error,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.white, width: 2),
                                                ),
                                                child: const Icon(Icons.close, color: Colors.white, size: 18),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          CustomPaint(
                                            painter: _DashedBorderPainter(
                                              color: AppColors.primary.withValues(alpha: 0.5),
                                              borderRadius: 8,
                                            ),
                                            child: SizedBox(
                                              width: double.infinity,
                                              height: 200,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '添加照片',
                                                    style: TextStyle(
                                                      fontFamily: 'Plus Jakarta Sans',
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w700,
                                                      letterSpacing: 0.05,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '支持 JPG, PNG 格式',
                                                    style: TextStyle(
                                                      fontFamily: 'Plus Jakarta Sans',
                                                      fontSize: 10,
                                                      color: AppColors.mutedForeground,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),

                        // ===== Form Fields Grid (2 columns) =====
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column
                            Expanded(
                              child: Column(
                                children: [
                                  _buildTextField(
                                    controller: _nameController,
                                    label: '物品名称',
                                    hint: '例如：新款降噪耳机',
                                    validator: (v) => v == null || v.trim().isEmpty ? '请输入物品名称' : null,
                                  ),
                                  const SizedBox(height: 24),
                                  _buildTextField(
                                    controller: _brandController,
                                    label: '品牌',
                                    hint: '品牌名称',
                                  ),
                                  const SizedBox(height: 24),
                                  // Category Dropdown
                                  _buildLabel('分类'),
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.foreground,
                                          offset: const Offset(4, 4),
                                          blurRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _category,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: AppColors.surfaceContainerLowest,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: AppColors.foreground, width: 2),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: AppColors.foreground, width: 2),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                                        ),
                                      ),
                                      items: ['电子产品', '服饰配饰', '家居用品', '户外运动'].map((cat) {
                                        return DropdownMenuItem(value: cat, child: Text(cat));
                                      }).toList(),
                                      onChanged: (v) => setState(() => _category = v),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),
                            // Right Column
                            Expanded(
                              child: Column(
                                children: [
                                  _buildTextField(
                                    controller: _priceController,
                                    label: '价格 (¥)',
                                    hint: '0.00',
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) return '请输入价格';
                                      if (double.tryParse(v) == null) return '请输入有效数字';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  // Date Picker
                                  _buildLabel('购入日期'),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: _purchaseDate,
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime.now(),
                                      );
                                      if (date != null) {
                                        setState(() => _purchaseDate = date);
                                      }
                                    },
                                    child: Container(
                                      height: 56,
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerLowest,
                                        border: Border.all(color: AppColors.foreground, width: 2),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.foreground,
                                            offset: const Offset(4, 4),
                                            blurRadius: 0,
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            DateFormat('yyyy-MM-dd').format(_purchaseDate),
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 10,
                                              color: AppColors.onSurface,
                                            ),
                                          ),
                                          Icon(Icons.calendar_today, color: AppColors.onSurfaceVariant, size: 20),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Expected Lifespan Slider
                                  _buildLabel('预期使用时长'),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${_lifespanController.text} 天',
                                        style: TextStyle(
                                          fontFamily: 'Plus Jakarta Sans',
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Custom slider
                                  _LifespanSlider(
                                    value: (int.tryParse(_lifespanController.text) ?? 365).toDouble(),
                                    min: 30,
                                    max: 3650,
                                    onChanged: (v) {
                                      setState(() {
                                        _lifespanController.text = v.toInt().toString();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // ===== Cost Preview Card (striped bg) =====
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [0, 0.25, 0.5, 0.75, 1],
                              colors: [
                                Colors.white,
                                AppColors.primary.withValues(alpha: 0.03),
                                Colors.white,
                                AppColors.primary.withValues(alpha: 0.03),
                                Colors.white,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.foreground, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.foreground,
                                offset: const Offset(6, 6),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppColors.foreground.withValues(alpha: 0.2)),
                                ),
                                child: Text(
                                  '目标日均成本',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.05,
                                    color: AppColors.onBackground.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '¥ ${_targetDailyCost.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF1E1B4B),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(9999),
                                      border: Border.all(color: AppColors.foreground.withValues(alpha: 0.1)),
                                    ),
                                    child: Text(
                                      '/ 每天',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: _CostPreviewBox(
                                      label: '每周',
                                      amount: '¥${(_targetDailyCost * 7).toStringAsFixed(0)}',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _CostPreviewBox(
                                      label: '每月',
                                      amount: '¥${(_targetDailyCost * 30).toStringAsFixed(0)}',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // ===== Save Button =====
                        Center(
                          child: GestureDetector(
                            onTap: _save,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(48, 16, 32, 16),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(9999),
                                border: Border.all(color: AppColors.foreground, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.foreground,
                                    offset: const Offset(4, 4),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _isEditing ? '更新' : '保存',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppColors.foreground.withValues(alpha: 0.2)),
                                    ),
                                    child: Icon(Icons.arrow_forward, color: AppColors.primary, size: 16),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.05,
        color: AppColors.onBackground,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.foreground,
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.foreground, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.foreground, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== Cost Preview Box ====================

class _CostPreviewBox extends StatelessWidget {
  final String label;
  final String amount;

  const _CostPreviewBox({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.foreground, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.foreground,
            offset: const Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.05,
              color: AppColors.onBackground.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontFamily: 'Outfit',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.onBackground,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Lifespan Slider ====================

class _LifespanSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const _LifespanSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final progress = ((value - min) / (max - min)).clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final localX = details.localPosition.dx;
        final newProgress = (localX / box.size.width).clamp(0.0, 1.0);
        final newValue = min + newProgress * (max - min);
        onChanged(newValue);
      },
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Track
            Container(
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: AppColors.foreground, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        border: Border(
                          right: BorderSide(color: AppColors.foreground, width: 2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Thumb
            Positioned(
              left: progress * (MediaQuery.of(context).size.width / 2 - 80 - 48),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.tertiary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.foreground, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.foreground,
                      offset: const Offset(4, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== Polka Dot Background ====================

class _PolkaDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = AppColors.background;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final dotPaint = Paint()
      ..color = AppColors.outlineVariant
      ..style = PaintingStyle.fill;

    const spacing = 24.0;
    const dotSize = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==================== Dashed Border Painter ====================

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  _DashedBorderPainter({required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    // Not painting the actual dashed border here, the outer container has the border
    // This is just a placeholder for the CustomPaint wrapper
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==================== Confetti Decoration ====================

class _ConfettiDecoration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Pink circle
          Positioned(
            top: 100,
            left: 32,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.foreground, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.foreground,
                    offset: const Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
            ),
          ),
          // Yellow triangle
          Positioned(
            top: 180,
            right: 48,
            child: Transform.rotate(
              angle: 12 * 3.14159 / 180,
              child: CustomPaint(
                size: const Size(20, 20),
                painter: _TrianglePainter(color: AppColors.tertiary),
              ),
            ),
          ),
          // Purple triangle
          Positioned(
            bottom: 200,
            left: 64,
            child: Transform.rotate(
              angle: -12 * 3.14159 / 180,
              child: CustomPaint(
                size: const Size(24, 24),
                painter: _TrianglePainter(color: AppColors.primary),
              ),
            ),
          ),
          // Green diamond
          Positioned(
            bottom: 280,
            right: 40,
            child: Transform.rotate(
              angle: 45 * 3.14159 / 180,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.quaternary,
                  border: Border.all(color: AppColors.foreground, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.foreground,
                      offset: const Offset(2, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
