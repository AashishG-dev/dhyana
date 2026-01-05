// lib/widgets/progress_indicators/progress_chart_widget.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/core/utils/helpers.dart';

class ProgressChartWidget extends StatelessWidget {
  final Map<String, int> data;
  final String chartTitle;
  final String yAxisLabel;

  const ProgressChartWidget({
    super.key,
    required this.data,
    required this.chartTitle,
    required this.yAxisLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final sortedEntries = data.entries.toList()
      ..sort((a, b) => DateTime.parse(a.key).compareTo(DateTime.parse(b.key)));

    final List<FlSpot> spots = [];
    double maxX = 0;
    double maxY = 0;

    if (sortedEntries.isNotEmpty) {
      for (int i = 0; i < sortedEntries.length; i++) {
        final entry = sortedEntries[i];
        final double x = i.toDouble();
        final double y = entry.value.toDouble();
        spots.add(FlSpot(x, y));
        if (x > maxX) maxX = x;
        if (y > maxY) maxY = y;
      }
      maxY = (maxY * 1.2).ceilToDouble();
      if (maxY < 10) maxY = 10;
    } else {
      spots.add(const FlSpot(0, 0));
      maxY = 10;
    }

    // Determine the interval to prevent label overlapping
    final double labelInterval = max((sortedEntries.length / 5).floorToDouble(), 1.0);

    return Card(
      margin: const EdgeInsets.all(AppConstants.marginMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chartTitle,
              style: AppTextStyles.titleLarge.copyWith(
                color: isDark ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            if (spots.length <= 1)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48.0),
                  child: Text(
                    'Not enough data to display chart.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: (isDark ? AppColors.textDark : AppColors.textLight)
                          .withOpacity(0.7),
                    ),
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  height: 200,
                  width: max(MediaQuery.of(context).size.width - 80, sortedEntries.length * 50.0),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text(
                              value.toInt().toString(),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: (isDark
                                    ? AppColors.textDark
                                    : AppColors.textLight)
                                    .withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: labelInterval,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() < sortedEntries.length) {
                                final date =
                                DateTime.parse(sortedEntries[value.toInt()].key);
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    Helpers.formatDate(date, 'MMM dd'),
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: (isDark
                                          ? AppColors.textDark
                                          : AppColors.textLight)
                                          .withOpacity(0.8),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: maxX,
                      minY: 0,
                      maxY: maxY,
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [
                              isDark
                                  ? AppColors.primaryLightGreen
                                  : AppColors.primaryLightBlue,
                              (isDark
                                  ? AppColors.primaryLightGreen
                                  : AppColors.primaryLightBlue)
                                  .withOpacity(0.3),
                            ],
                          ),
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                (isDark
                                    ? AppColors.primaryLightGreen
                                    : AppColors.primaryLightBlue)
                                    .withOpacity(0.3),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                      ],
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