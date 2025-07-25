// lib/widgets/progress_indicators/progress_chart_widget.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // For charting library
import 'package:dhyana/core/constants/app_colors.dart';
import 'package:dhyana/core/constants/app_text_styles.dart';
import 'package:dhyana/core/constants/app_constants.dart';
import 'package:dhyana/core/utils/helpers.dart'; // For date formatting

/// A widget that displays a line chart representing user progress over time,
/// such as meditation minutes or mood trends. It uses `fl_chart` for rendering
/// and adheres to the Dhyana app's Glass Morphism theme.
class ProgressChartWidget extends StatelessWidget {
  final Map<String, int> data; // Data where key is date string (e.g., 'YYYY-MM-DD') and value is a metric (e.g., minutes)
  final String chartTitle;
  final String yAxisLabel; // Label for the Y-axis (e.g., 'Minutes', 'Mood Rating')

  /// Constructor for ProgressChartWidget.
  const ProgressChartWidget({
    super.key,
    required this.data,
    required this.chartTitle,
    required this.yAxisLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // Sort data by date to ensure the line chart is drawn correctly
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => DateTime.parse(a.key).compareTo(DateTime.parse(b.key)));

    // Convert data to FlSpot for the LineChart
    final List<FlSpot> spots = [];
    double maxX = 0;
    double maxY = 0;
    if (sortedEntries.isNotEmpty) {
      for (int i = 0; i < sortedEntries.length; i++) {
        final entry = sortedEntries[i];
        final double x = i.toDouble(); // X-axis represents index (time progression)
        final double y = entry.value.toDouble();
        spots.add(FlSpot(x, y));
        if (x > maxX) maxX = x;
        if (y > maxY) maxY = y;
      }
      // Add a small buffer to maxY for better visualization
      maxY = (maxY * 1.2).ceilToDouble();
      if (maxY < 10) maxY = 10; // Ensure a minimum Y-axis range
    } else {
      // Handle empty data case
      spots.add(FlSpot(0, 0));
      maxX = 0;
      maxY = 10;
    }

    return Card(
      // Card provides the GlassContainer effect via AppTheme
      margin: const EdgeInsets.all(AppConstants.marginMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chartTitle,
              style: AppTextStyles.titleLarge.copyWith(
                color: isDarkMode ? AppColors.textDark : AppColors.textLight,
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            if (spots.length <= 1)
              Center(
                child: Text(
                  'Not enough data to display chart.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.7),
                  ),
                ),
              )
            else
              SizedBox(
                height: 200, // Fixed height for the chart
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.1),
                          strokeWidth: 0.5,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return FlLine(
                          color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.1),
                          strokeWidth: 0.5,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            // Display date labels for bottom axis
                            if (value.toInt() < sortedEntries.length) {
                              final dateString = sortedEntries[value.toInt()].key;
                              final date = DateTime.parse(dateString);
                              // Format date to show only day and month for brevity
                              return SideTitleWidget(
                                axisSide: meta.axisSide,
                                space: 8.0,
                                child: Text(
                                  Helpers.formatDate(date, 'MMM dd'),
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.8),
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            // Display Y-axis labels
                            return Text(
                              value.toInt().toString(),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: (isDarkMode ? AppColors.textDark : AppColors.textLight).withOpacity(0.8),
                              ),
                              textAlign: TextAlign.left,
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(
                        color: (isDarkMode ? AppColors.glassBorderDark : AppColors.glassBorderLight),
                        width: 1,
                      ),
                    ),
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
                            isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue,
                            (isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue).withOpacity(0.3),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              (isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue).withOpacity(0.3),
                              (isDarkMode ? AppColors.primaryLightGreen : AppColors.primaryLightBlue).withOpacity(0),
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
          ],
        ),
      ),
    );
  }
}
