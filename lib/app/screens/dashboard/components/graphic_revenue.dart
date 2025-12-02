import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class RevenueChart extends StatefulWidget {
  final List<Map<String, dynamic>> graphic;
  final List<Map<String, dynamic>>? previousMonthGraphic;
  final double? targetRevenue;
  final bool showAverage;

  const RevenueChart({
    Key? key,
    required this.graphic,
    this.previousMonthGraphic,
    this.targetRevenue,
    this.showAverage = true,
  }) : super(key: key);

  @override
  State<RevenueChart> createState() => _RevenueChartState();
}

class _RevenueChartState extends State<RevenueChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _calculateInterval(double maxRevenue) {
      final value = maxRevenue / 1000;
      if (value <= 20) return 5;
      if (value <= 100) return 20;
      return 50;
    }

    double _calculateMaxY(double maxRevenue) {
      if (maxRevenue == 0) return 10;

      final value = maxRevenue / 1000;
      double buffer = value * 0.15;
      double target = value + buffer;

      if (target <= 50) {
        return (target / 10).ceil() * 10;
      } else {
        return (target / 50).ceil() * 50;
      }
    }

    final filteredGraphic = _filterFutureZeroDays(widget.graphic);
    final filteredPreviousGraphic = widget.previousMonthGraphic ?? [];

    final double maxCurrentRevenue = filteredGraphic.isEmpty
        ? 0
        : (filteredGraphic
                  .map((g) => g['revenue'] as num)
                  .reduce((a, b) => a > b ? a : b))
              .toDouble();

    final double maxPreviousRevenue = filteredPreviousGraphic.isEmpty
        ? 0
        : (filteredPreviousGraphic
                  .map((g) => g['revenue'] as num)
                  .reduce((a, b) => a > b ? a : b))
              .toDouble();

    final double maxRevenue = maxCurrentRevenue > maxPreviousRevenue
        ? maxCurrentRevenue
        : maxPreviousRevenue;

    // ✅ РАСЧЕТ ОБЩЕГО ДОХОДА
    final double totalCurrentRevenue = filteredGraphic
        .map((g) => (g['revenue'] as num).toDouble())
        .fold(0, (a, b) => a + b);

    final double totalPreviousRevenue = filteredPreviousGraphic
        .map((g) => (g['revenue'] as num).toDouble())
        .fold(0, (a, b) => a + b);

    // ✅ РАЗНИЦА В СУММАХ И ПРОЦЕНТАХ
    final double revenueDifference = totalCurrentRevenue - totalPreviousRevenue;
    final double revenuePercentChange = totalPreviousRevenue > 0
        ? ((totalCurrentRevenue - totalPreviousRevenue) /
                  totalPreviousRevenue) *
              100
        : 0;

    // ✅ РАСЧЕТ СРЕДНЕГО ДОХОДА
    final double currentAverage = filteredGraphic.isEmpty
        ? 0
        : totalCurrentRevenue / filteredGraphic.length;

    final double previousAverage = filteredPreviousGraphic.isEmpty
        ? 0
        : totalPreviousRevenue / filteredPreviousGraphic.length;

    // ✅ РАСЧЕТ ПРОЦЕНТА ИЗМЕНЕНИЯ СРЕДНЕГО
    final double growthPercent = previousAverage > 0
        ? ((currentAverage - previousAverage) / previousAverage) * 100
        : 0;

    final spots = filteredGraphic
        .map(
          (g) => FlSpot(
            (g['day'] as int).toDouble(),
            (g['revenue'] as num).toDouble() / 1000,
          ),
        )
        .toList();

    final previousSpots = filteredPreviousGraphic
        .map(
          (g) => FlSpot(
            (g['day'] as int).toDouble(),
            (g['revenue'] as num).toDouble() / 1000,
          ),
        )
        .toList();

    final List<Color> gradientColors = [Color(0xFF667eea), Color(0xFF764ba2)];

    final List<Color> areaGradientColors = [
      Color(0xFF667eea).withOpacity(0.3),
      Color(0xFF764ba2).withOpacity(0.1),
    ];

    final List<Color> previousGradientColors = [
      Colors.grey.shade400,
      Colors.grey.shade500,
    ];

    final List<Color> previousAreaGradientColors = [
      Colors.grey.shade300.withOpacity(0.15),
      Colors.grey.shade400.withOpacity(0.05),
    ];

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.black.withOpacity(0.2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.blue.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ ЗАГОЛОВОК С ИНФОРМАЦИОННЫМИ КАРТОЧКАМИ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ЛЕВАЯ ЧАСТЬ - ЗАГОЛОВОК
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Color(0xFF667eea).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.trending_up_rounded,
                              color: Color(0xFF667eea),
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Динамика дохода',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ежедневный доход за текущий месяц',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),

                  // ПРАВАЯ ЧАСТЬ - КОМПАКТНЫЕ КАРТОЧКИ
                  if (filteredPreviousGraphic.isNotEmpty)
                    Row(
                      children: [
                        // КАРТОЧКА 2: РАЗНИЦА
                        _buildCompactCard(
                          icon: revenueDifference >= 0
                              ? Icons.add_circle_outline_rounded
                              : Icons.remove_circle_outline_rounded,
                          iconColor: revenueDifference >= 0
                              ? Colors.blue.shade600
                              : Colors.orange.shade600,
                          backgroundColor: revenueDifference >= 0
                              ? Colors.blue.shade50
                              : Colors.orange.shade50,
                          borderColor: revenueDifference >= 0
                              ? Colors.blue.shade200
                              : Colors.orange.shade200,
                          value:
                              '${revenueDifference >= 0 ? '+' : ''}${(revenueDifference / 1000).toStringAsFixed(0)}k',
                          label: 'Разница',
                          valueColor: revenueDifference >= 0
                              ? Colors.blue.shade700
                              : Colors.orange.shade700,
                        ),

                        SizedBox(width: 8),

                        // КАРТОЧКА 3: ОБЩИЙ РОСТ
                        _buildCompactCard(
                          icon: revenuePercentChange >= 0
                              ? Icons.show_chart_rounded
                              : Icons.trending_down_rounded,
                          iconColor: revenuePercentChange >= 0
                              ? Colors.purple.shade600
                              : Colors.deepOrange.shade600,
                          backgroundColor: revenuePercentChange >= 0
                              ? Colors.purple.shade50
                              : Colors.deepOrange.shade50,
                          borderColor: revenuePercentChange >= 0
                              ? Colors.purple.shade200
                              : Colors.deepOrange.shade200,
                          value:
                              '${revenuePercentChange >= 0 ? '+' : ''}${revenuePercentChange.toStringAsFixed(1)}%',
                          label: 'Общий',
                          valueColor: revenuePercentChange >= 0
                              ? Colors.purple.shade700
                              : Colors.deepOrange.shade700,
                        ),

                        if (widget.targetRevenue != null) ...[
                          SizedBox(width: 8),
                          // КАРТОЧКА 4: ЦЕЛЬ
                          _buildCompactCard(
                            icon: Icons.flag_rounded,
                            iconColor: Colors.green.shade600,
                            backgroundColor: Colors.green.shade50,
                            borderColor: Colors.green.shade200,
                            value:
                                '${(widget.targetRevenue! / 1000).toStringAsFixed(0)}k',
                            label: 'Цель',
                            valueColor: Colors.green.shade700,
                          ),
                        ],
                      ],
                    ),
                ],
              ),

              SizedBox(height: 24),

              // ✅ ГРАФИК С АНИМАЦИЕЙ
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        backgroundColor: Colors.transparent,
                        borderData: FlBorderData(show: false),

                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: _calculateInterval(maxRevenue),
                          getDrawingHorizontalLine: (value) {
                            // ✅ ЛИНИИ СРЕДНЕГО
                            if (widget.showAverage &&
                                currentAverage > 0 &&
                                ((value * 1000 - currentAverage).abs() < 500)) {
                              return FlLine(
                                color: Color(0xFF667eea).withOpacity(0.6),
                                strokeWidth: 2,
                                dashArray: [8, 4],
                              );
                            }
                            if (widget.showAverage &&
                                previousAverage > 0 &&
                                ((value * 1000 - previousAverage).abs() <
                                    500)) {
                              return FlLine(
                                color: Colors.grey.shade500.withOpacity(0.6),
                                strokeWidth: 2,
                                dashArray: [8, 4],
                              );
                            }
                            // ✅ ЛИНИЯ ЦЕЛИ
                            if (widget.targetRevenue != null &&
                                ((value * 1000 - widget.targetRevenue!).abs() <
                                    500)) {
                              return FlLine(
                                color: Colors.green.shade600,
                                strokeWidth: 2,
                                dashArray: [12, 6],
                              );
                            }

                            return FlLine(
                              color: Colors.grey.shade300,
                              strokeWidth: 0.8,
                              dashArray: value == 0 ? null : [4, 4],
                            );
                          },
                        ),

                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),

                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 28,
                              interval: _calculateDayInterval(
                                filteredGraphic.length,
                              ),
                              getTitlesWidget: (value, meta) {
                                final day = value.toInt();
                                final dataPoint = filteredGraphic.firstWhere(
                                  (g) => g['day'] == day,
                                  orElse: () => {'date': ''},
                                );

                                final dateString = dataPoint['date'] as String;
                                final isToday = _isToday(day);

                                return Container(
                                  margin: EdgeInsets.only(top: 6),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isToday
                                        ? Color(0xFF667eea)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _formatDayLabel(dateString, day),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isToday
                                          ? Colors.white
                                          : Colors.grey.shade600,
                                      fontWeight: isToday
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 42,
                              interval: _calculateInterval(maxRevenue),
                              getTitlesWidget: (value, meta) {
                                if (value == 0) return SizedBox();

                                return Text(
                                  '${value.toInt()}K ₸',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                              return touchedBarSpots.map((barSpot) {
                                final flSpot = barSpot;

                                final isCurrentMonth =
                                    barSpot.barIndex == 1 ||
                                    (previousSpots.isEmpty &&
                                        barSpot.barIndex == 0);

                                return LineTooltipItem(
                                  '${flSpot.y.toStringAsFixed(0)}k ₸\n${isCurrentMonth ? '(тек. месяц)' : '(пред. месяц)'}',
                                  TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),

                        lineBarsData: [
                          // ЛИНИЯ ПРЕДЫДУЩЕГО МЕСЯЦА
                          if (previousSpots.isNotEmpty)
                            LineChartBarData(
                              spots: previousSpots
                                  .map(
                                    (spot) => FlSpot(
                                      spot.x,
                                      spot.y * _animation.value,
                                    ),
                                  )
                                  .toList(),
                              isCurved: true,
                              curveSmoothness: 0.3,
                              barWidth: 2.5,
                              gradient: LinearGradient(
                                colors: previousGradientColors,
                                stops: [0.1, 0.9],
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: previousAreaGradientColors,
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: [0.1, 0.9],
                                ),
                                cutOffY: 0,
                                applyCutOffY: true,
                              ),
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 2,
                                    color: Colors.white,
                                    strokeWidth: 1.5,
                                    strokeColor: Colors.grey.shade400,
                                  );
                                },
                              ),
                              shadow: Shadow(
                                color: Colors.grey.shade400.withOpacity(0.2),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ),

                          // ЛИНИЯ ТЕКУЩЕГО МЕСЯЦА
                          LineChartBarData(
                            spots: spots
                                .map(
                                  (spot) =>
                                      FlSpot(spot.x, spot.y * _animation.value),
                                )
                                .toList(),
                            isCurved: true,
                            curveSmoothness: 0.3,
                            barWidth: 4,
                            gradient: LinearGradient(
                              colors: gradientColors,
                              stops: [0.1, 0.9],
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: areaGradientColors,
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: [0.1, 0.9],
                              ),
                              cutOffY: 0,
                              applyCutOffY: true,
                            ),
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                final isLastPoint = index == spots.length - 1;
                                final isHighPoint =
                                    spot.y == (maxCurrentRevenue / 1000);

                                return FlDotCirclePainter(
                                  radius: isLastPoint || isHighPoint ? 4 : 3,
                                  color: Colors.white,
                                  strokeWidth: isLastPoint || isHighPoint
                                      ? 3
                                      : 2,
                                  strokeColor: isLastPoint
                                      ? Color(0xFF764ba2)
                                      : isHighPoint
                                      ? Color(0xFF667eea)
                                      : gradientColors[0],
                                );
                              },
                            ),
                            shadow: Shadow(
                              color: gradientColors[0].withOpacity(0.3),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ),
                        ],

                        minX: 1,
                        maxX: filteredPreviousGraphic.isNotEmpty
                            ? (filteredPreviousGraphic.last['day'] as int)
                                  .toDouble()
                            : (filteredGraphic.isNotEmpty
                                  ? filteredGraphic.last['day'].toDouble()
                                  : 30),
                        minY: 0,
                        maxY: _calculateMaxY(maxRevenue),
                        clipData: FlClipData.all(),
                      ),
                    ),
                  );
                },
              ),

              // ✅ ЛЕГЕНДА
              if (filteredGraphic.isNotEmpty) ...[
                SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildLegendItem('Текущий месяц', Color(0xFF667eea)),
                    if (previousSpots.isNotEmpty)
                      _buildLegendItem(
                        'Предыдущий месяц',
                        Colors.grey.shade500,
                      ),
                    if (widget.showAverage && currentAverage > 0)
                      _buildLegendItem(
                        'Среднее',
                        Color(0xFF667eea),
                        isDashed: true,
                      ),
                    if (widget.targetRevenue != null)
                      _buildLegendItem(
                        'Цель',
                        Colors.green.shade600,
                        isDashed: true,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ✅ МЕТОД ДЛЯ СОЗДАНИЯ КОМПАКТНОЙ КАРТОЧКИ
  Widget _buildCompactCard({
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required Color borderColor,
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filterFutureZeroDays(
    List<Map<String, dynamic>> data,
  ) {
    final now = DateTime.now();
    final currentDay = now.day;

    int lastNonZeroDay = currentDay;
    for (int i = data.length - 1; i >= 0; i--) {
      final day = data[i]['day'] as int;
      final revenue = (data[i]['revenue'] as num).toDouble();

      if (revenue > 0 || day <= currentDay) {
        lastNonZeroDay = day;
        break;
      }
    }

    return data.where((point) {
      final day = point['day'] as int;
      return day <= lastNonZeroDay;
    }).toList();
  }

  bool _isToday(int day) {
    return day == DateTime.now().day;
  }

  String _formatDayLabel(String dateString, int day) {
    if (dateString.isEmpty) return day.toString();

    try {
      final parts = dateString.split(' ');
      if (parts.length >= 2) {
        final dayNum = parts[0];
        final month = parts[1].substring(0, 3);
        return '${_isToday(day) ? 'Сегодня' : '$dayNum $month'}';
      }
    } catch (e) {}

    return day.toString();
  }

  double _calculateDayInterval(int dataLength) {
    if (dataLength <= 10) return 1;
    if (dataLength <= 20) return 2;
    if (dataLength <= 30) return 3;
    return 5;
  }

  double _calculateInterval(double maxRevenue) {
    final value = maxRevenue / 1000;
    if (value <= 10) return 2;
    if (value <= 50) return 10;
    if (value <= 100) return 20;
    if (value <= 500) return 50;
    return 100;
  }

  Widget _buildLegendItem(String text, Color color, {bool isDashed = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: isDashed ? Colors.transparent : color,
            border: isDashed ? Border.all(color: color, width: 2) : null,
            borderRadius: BorderRadius.circular(3),
          ),
          child: isDashed
              ? CustomPaint(painter: DashedLinePainter(color))
              : null,
        ),
        SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
