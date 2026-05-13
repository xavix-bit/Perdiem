import '../models/item.dart';

class CostCalculator {
  CostCalculator._();

  /// 已使用天数
  static int daysUsed(Item item) {
    final now = DateTime.now();
    return now.difference(item.purchaseDate).inDays;
  }

  /// 预期总使用天数
  static int expectedTotalDays(Item item) {
    return item.expectedLifespanMonths * 30;
  }

  /// 当前日均成本
  static double dailyCost(Item item) {
    final days = daysUsed(item);
    if (days <= 0) return item.price;
    return item.price / days;
  }

  /// 目标日均成本（按预期寿命计算）
  static double targetDailyCost(Item item) {
    final totalDays = expectedTotalDays(item);
    return item.price / totalDays;
  }

  /// 使用进度（0.0 ~ 1.0+，可能超过1表示超期使用）
  static double usageProgress(Item item) {
    final days = daysUsed(item);
    final total = expectedTotalDays(item);
    return days / total;
  }

  /// 是否已超过预期寿命
  static bool isOverdue(Item item) {
    return usageProgress(item) >= 1.0;
  }

  /// 剩余天数（负数表示超期使用天数）
  static int remainingDays(Item item) {
    return expectedTotalDays(item) - daysUsed(item);
  }

  /// 超期使用天数
  static int overdueDays(Item item) {
    final remaining = remainingDays(item);
    return remaining < 0 ? -remaining : 0;
  }

  /// 日均成本历史数据（用于绘制折线图）
  /// 返回从购买日到今天的日均成本变化
  static List<DailyCostPoint> costHistory(Item item) {
    final days = daysUsed(item);
    if (days <= 0) return [];

    final result = <DailyCostPoint>[];
    for (int d = 1; d <= days; d++) {
      final date = item.purchaseDate.add(Duration(days: d));
      final cost = item.price / d;
      result.add(DailyCostPoint(date: date, day: d, dailyCost: cost));
    }
    return result;
  }

  /// 采样日均成本（数据点太多时按间隔采样）
  static List<DailyCostPoint> sampledCostHistory(Item item,
      {int maxPoints = 60}) {
    final history = costHistory(item);
    if (history.length <= maxPoints) return history;

    final step = (history.length / maxPoints).ceil();
    final sampled = <DailyCostPoint>[];
    for (int i = 0; i < history.length; i += step) {
      sampled.add(history[i]);
    }
    // 确保最后一个点被包含
    if (sampled.last != history.last) {
      sampled.add(history.last);
    }
    return sampled;
  }

  /// 汇总统计
  static CostSummary summary(Item item) {
    return CostSummary(
      daysUsed: daysUsed(item),
      expectedTotalDays: expectedTotalDays(item),
      dailyCost: dailyCost(item),
      targetDailyCost: targetDailyCost(item),
      usageProgress: usageProgress(item),
      isOverdue: isOverdue(item),
      remainingDays: remainingDays(item),
      overdueDays: overdueDays(item),
    );
  }
}

class DailyCostPoint {
  final DateTime date;
  final int day;
  final double dailyCost;

  const DailyCostPoint({
    required this.date,
    required this.day,
    required this.dailyCost,
  });
}

class CostSummary {
  final int daysUsed;
  final int expectedTotalDays;
  final double dailyCost;
  final double targetDailyCost;
  final double usageProgress;
  final bool isOverdue;
  final int remainingDays;
  final int overdueDays;

  const CostSummary({
    required this.daysUsed,
    required this.expectedTotalDays,
    required this.dailyCost,
    required this.targetDailyCost,
    required this.usageProgress,
    required this.isOverdue,
    required this.remainingDays,
    required this.overdueDays,
  });
}
