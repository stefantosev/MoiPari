import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:mobile/models/category.dart';
import 'package:mobile/models/expense.dart';
import 'package:mobile/providers/state_providers.dart';
import 'package:mobile/utils/color_utils.dart';
import 'package:mobile/utils/icon_utils.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _AnalyticsPageState();
  }
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  String selectedPeriod = 'Week';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text("Analytics"),),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Week', label: Text('Week')),
                  ButtonSegment(value: 'Month', label: Text('Month')),
                  ButtonSegment(value: 'Year', label: Text('Year')),
                ],
                selected: {selectedPeriod},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    selectedPeriod = newSelection.first;
                  });
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SpendingSummaryCards(),
                    const SizedBox(height: 16),
        
                    const TopSpendingCategories(),
                    const Divider(),
        
                    if (selectedPeriod == 'Week') ...[
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Weekly Activity',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: WeeklyBarChart(
                          weeklyData: ref.watch(weeklySpendingProvider),
                        ),
                      ),
                    ] else if (selectedPeriod == 'Month') ...[
                      const MonthlyTrendChart(),
                    ] else ...[
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: Text('Year view coming soon')),
                      ),
                    ],
        
                    const SizedBox(height: 24),
        
                    const CategoryPieChart(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeeklyBarChart extends StatelessWidget {
  final Map<int, double> weeklyData;
  const WeeklyBarChart({super.key, required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 1.5,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _getMaxY(),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) =>
                    Theme.of(context).colorScheme.secondary,
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  String weekDay;
                  switch (group.x.toInt()) {
                    case 1:
                      weekDay = 'Monday';
                      break;
                    case 2:
                      weekDay = 'Tuesday';
                      break;
                    case 3:
                      weekDay = 'Wednesday';
                      break;
                    case 4:
                      weekDay = 'Thursday';
                      break;
                    case 5:
                      weekDay = 'Friday';
                      break;
                    case 6:
                      weekDay = 'Saturday';
                      break;
                    case 7:
                      weekDay = 'Sunday';
                      break;
                    default:
                      throw Error();
                  }

                  return BarTooltipItem(
                    '$weekDay\n',
                    TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: '\$${rod.toY.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                },
              ),
              touchCallback: (FlTouchEvent event, barTouchResponse) {
                if (event is FlPanDownEvent || event is FlTapDownEvent) {
                  if (barTouchResponse != null &&
                      barTouchResponse.spot != null) {
                    HapticFeedback.lightImpact();
                  }
                }
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: _getBottomTitles,
                ),
              ),
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barGroups: _chartGroups(context),
          ),
        ),
      ),
    );
  }

  // convert map into fl_chart bar groups
  List<BarChartGroupData> _chartGroups(BuildContext context) {
    return weeklyData.entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Theme.of(context).colorScheme.primaryContainer,
            width: 18,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _getMaxY(),
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      );
    }).toList();
  }

  // map integers 1-7 to day labels

  Widget _getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    Widget text;

    switch (value.toInt()) {
      case 1:
        text = const Text('M', style: style);
        break;
      case 2:
        text = const Text('T', style: style);
        break;
      case 3:
        text = const Text('W', style: style);
        break;
      case 4:
        text = const Text('T', style: style);
        break;
      case 5:
        text = const Text('F', style: style);
        break;
      case 6:
        text = const Text('S', style: style);
        break;
      case 7:
        text = const Text('S', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    return SideTitleWidget(meta: meta, child: text);
  }

  double _getMaxY() {
    double max = weeklyData.values.fold(
      0,
      (prev, element) => element > prev ? element : prev,
    );
    return max == 0 ? 100 : max * 1.2; //20 % padding to top
  }
}

class LegendItem extends StatelessWidget {
  final String name;
  final double amount;
  final Color color;

  const LegendItem({
    super.key,
    required this.name,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class CategoryPieChart extends ConsumerStatefulWidget {
  const CategoryPieChart({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _CategoryPieChartState();
  }
}

class _CategoryPieChartState extends ConsumerState<CategoryPieChart> {
  int touchedIndex = -1;
  OverlayEntry? _overlayEntry;
  Timer? _overlayTimer;

  @override
  Widget build(BuildContext context) {
    final categoryData = ref.watch(categorySpendingProvider);
    final categoriesAsync = ref.watch(categoryProvider);

    if (categoryData.isEmpty) {
      return const Center(child: Text('No expense data'));
    }

    return categoriesAsync.when(
      data: (categories) => Column(
        children: [
          AspectRatio(
            aspectRatio: 1.5,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    _overlayTimer?.cancel();
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _overlayTimer = Timer(
                          const Duration(milliseconds: 600),
                          () {
                            _removeOverlay();
                          },
                        );
                        touchedIndex = -1;
                        return;
                      }

                      final newIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;

                      if (touchedIndex != newIndex) {
                        HapticFeedback.lightImpact();
                      }

                      touchedIndex = newIndex;

                      if (newIndex >= 0 &&
                          (event is FlPanDownEvent ||
                              event is FlPanUpdateEvent)) {
                        final entry = categoryData.entries.toList()[newIndex];
                        final total = categoryData.values.fold(
                          0.0,
                          (sum, val) => sum + val,
                        );
                        final percentage = (entry.value / total * 100);

                        final localPosition = event.localPosition;
                        final renderBox =
                            context.findRenderObject() as RenderBox;
                        final globalPosition = renderBox.localToGlobal(
                          localPosition!,
                        );

                        _showCategoryOverlay(
                          context,
                          entry.key,
                          entry.value,
                          percentage,
                          globalPosition,
                        );
                      }
                    });
                  },
                ),
                sections: _createSections(categoryData, categories, context),
                sectionsSpace: 1,
                centerSpaceRadius: 50,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(categoryData, categories, context),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
    );
  }

  void _showCategoryOverlay(
    BuildContext context,
    String categoryName,
    double amount,
    double percentage,
    Offset position,
  ) {
    _removeOverlay();
    _overlayTimer?.cancel();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx - 100,
        top: position.dy - 80,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}% of total',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildLegend(
    Map<String, double> data,
    List<Category> categories,
    BuildContext context,
  ) {
    final total = data.values.fold(0.0, (sum, val) => sum + val);

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: data.entries.map((entry) {
        final category = categories.firstWhere(
          (c) => c.name == entry.key,
          orElse: () => Category(-1, "Unknown", "help_outline", "red", 0, [0]),
        );
        final percentage = (entry.value / total * 100);

        return Column(
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.inversePrimary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                IconUtils.getIconFromString(category.icon),
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${entry.key}: \$${entry.value.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        );
      }).toList(),
    );
  }

  List<PieChartSectionData> _createSections(
    Map<String, double> data,
    List<Category> categories,
    BuildContext context,
  ) {
    final total = data.values.fold(0.0, (sum, val) => sum + val);

    return data.entries.toList().asMap().entries.map((mapEntry) {
      final index = mapEntry.key;
      final entry = mapEntry.value;
      final percentage = (entry.value / total * 100);

      final category = categories.firstWhere(
        (c) => c.name == entry.key,
        orElse: () => Category(-1, "Unknown", "help_outline", "red", 0, [0]),
      );

      final isTouched = index == touchedIndex;
      final fontSize = isTouched ? 16.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;
      final badgeSize = isTouched ? 50.0 : 40.0;

      return PieChartSectionData(
        color: ColorUtils.fromString(category.color, context),
        badgeWidget: _Badge(
          IconUtils.getIconFromString(category.icon),
          size: badgeSize,
          borderColor: Theme.of(context).canvasColor,
        ),
        badgePositionPercentageOffset: 1.1,
        value: entry.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimary,
          shadows: isTouched
              ? [const Shadow(color: Colors.black, blurRadius: 2)]
              : null,
        ),
      );
    }).toList();
  }

  @override
  void dispose() {
    super.dispose();
    _removeOverlay();
    _overlayTimer?.cancel();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

Color _getCategoryColor(Category category, BuildContext context) {
  return ColorUtils.fromString(category.color, context);
}

class SpendingSummaryCards extends ConsumerWidget {
  const SpendingSummaryCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expenseProvider);

    return expensesAsync.when(
      data: (expenses) {
        final thisMonth = _calculateThisMonth(expenses);
        final lastMonth = _calculateLastMonth(expenses);
        final average = _calculateAverage(expenses);

        return Row(
          children: [
            _SummaryCard('This Month', '\$${thisMonth.toStringAsFixed(2)}'),
            _SummaryCard('Last Month', '\$${lastMonth.toStringAsFixed(2)}'),
            _SummaryCard('Avg/Month', '\$${average.toStringAsFixed(2)}'),
          ],
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, s) => Text('Error: $e'),
    );
  }

  double _calculateThisMonth(List<Expense> expenses) {
    final now = DateTime.now();
    return expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double _calculateLastMonth(List<Expense> expenses) {
    final lastMonth = DateTime.now().subtract(const Duration(days: 30));
    return expenses
        .where(
          (e) =>
              e.date.month == lastMonth.month && e.date.year == lastMonth.year,
        )
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  double _calculateAverage(List<Expense> expenses) {
    if (expenses.isEmpty) return 0;
    final total = expenses.fold(0.0, (sum, e) => sum + e.amount);
    final months = expenses
        .map((e) => '${e.date.year}-${e.date.month}')
        .toSet()
        .length;
    return months > 0 ? total / months : 0;
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryCard(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.icon, {required this.size, required this.borderColor});

  final IconData icon;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: .5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(child: Icon(icon)),
    );
  }
}

class TopSpendingCategories extends ConsumerWidget {
  const TopSpendingCategories({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryData = ref.watch(categorySpendingProvider);
    final categoriesAsync = ref.watch(categoryProvider);

    if (categoryData.isEmpty) return const SizedBox.shrink();

    final sorted = categoryData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top3 = sorted.take(3);

    return categoriesAsync.when(
      data: (categories) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Spending',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...top3.map((entry) {
              final category = categories.firstWhere(
                (c) => c.name == entry.key,
                orElse: () =>
                    Category(-1, "Unknown", "help_outline", "red", 0, [0]),
              );
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      IconUtils.getIconFromString(category.icon),
                      color: ColorUtils.fromString(category.color, context),
                    ),
                    const SizedBox(width: 12),
                    Text(entry.key, style: const TextStyle(fontSize: 16)),
                    const Spacer(),
                    Text(
                      '\$${entry.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}

class MonthlyTrendChart extends ConsumerWidget {
  const MonthlyTrendChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyData = ref.watch(monthlySpendingProvider);

    if (monthlyData.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Trend (Last 6 Months)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= monthlyData.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          monthlyData[index].month,
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (monthlyData.length - 1).toDouble(),
                lineBarsData: [
                  LineChartBarData(
                    spots: monthlyData.asMap().entries.map((entry) {
                      return FlSpot(entry.key.toDouble(), entry.value.amount);
                    }).toList(),
                    isCurved: true,
                    color: Theme.of(context).colorScheme.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
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
}
