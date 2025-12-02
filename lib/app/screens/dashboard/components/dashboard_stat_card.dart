// lib/screens/owner/dashboard/components/stat_card.dart
import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String? subtitle;
  final String? previousValue;
  final double? changePercent;
  final bool isMobile; // ✅ ДОБАВЛЕНО для адаптивности

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    required this.color,
    this.subtitle,
    this.previousValue,
    this.changePercent,
    this.isMobile = false, // ✅ По умолчанию false (desktop)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isPositive = changePercent != null && changePercent! >= 0;

    // Responsive sizing
    final cardPadding = isMobile ? 16.0 : 24.0;
    final labelFontSize = isMobile ? 12.0 : 14.0;
    final subtitleFontSize = isMobile ? 10.0 : 11.0;
    final valueFontSize = isMobile ? 20.0 : 28.0;
    final dotSize = isMobile ? 6.0 : 8.0;
    final iconSize = isMobile ? 14.0 : 16.0;
    final percentFontSize = isMobile ? 12.0 : 14.0;
    final comparisonFontSize = isMobile ? 11.0 : 12.0;

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: const Color(0xFF6B7280),
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: isMobile ? 2 : 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: const Color(0xFF9CA3AF),
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 8 : 12),
          Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Change indicator
          if (changePercent != null) ...[
            SizedBox(height: isMobile ? 6 : 8),
            isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isPositive
                                ? Icons.trending_up
                                : Icons.trending_down,
                            size: iconSize,
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isPositive ? "+" : ""}${changePercent!.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: percentFontSize,
                              fontWeight: FontWeight.w600,
                              color: isPositive ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'vs предыдущий период',
                        style: TextStyle(
                          fontSize: comparisonFontSize,
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: iconSize,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${isPositive ? "+" : ""}${changePercent!.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: percentFontSize,
                          fontWeight: FontWeight.w600,
                          color: isPositive ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'vs предыдущий период',
                          style: TextStyle(
                            fontSize: comparisonFontSize,
                            color: const Color(0xFF9CA3AF),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ],
        ],
      ),
    );
  }
}
