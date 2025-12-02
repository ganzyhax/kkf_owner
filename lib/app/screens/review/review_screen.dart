// lib/screens/owner/review_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:kff_owner_admin/app/screens/review/bloc/review_bloc.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({Key? key}) : super(key: key);

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocProvider(
        create: (context) => ReviewBloc()..add(ReviewLoad()),
        child: BlocBuilder<ReviewBloc, ReviewState>(
          builder: (context, state) {
            if (state is ReviewLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ReviewError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(fontSize: 16, color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ReviewBloc>().add(ReviewLoad());
                      },
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              );
            }

            if (state is ReviewLoaded) {
              return _buildContent(state.data);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    final totalReviews = data['totalReviews'] ?? 0;
    final avgRating =
        double.tryParse(data['avgRating']?.toString() ?? '0') ?? 0.0;
    final arenaReviews = (data['data'] as List?) ?? [];

    // Подсчет положительных и отрицательных отзывов
    int positiveReviews = 0;
    int negativeReviews = 0;
    int neutralReviews = 0;

    for (var arenaData in arenaReviews) {
      final reviews = (arenaData['reviews'] as List?) ?? [];
      for (var review in reviews) {
        final rating = review['rating'] ?? 0;
        if (rating >= 4) {
          positiveReviews++;
        } else if (rating <= 2) {
          negativeReviews++;
        } else {
          neutralReviews++;
        }
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Отзывы и Рейтинг',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 32),

          // Statistics Cards
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 1024) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: _buildRatingCard(avgRating, totalReviews),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 2,
                      child: _buildStatisticsCard(
                        positiveReviews,
                        negativeReviews,
                        neutralReviews,
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildRatingCard(avgRating, totalReviews),
                    const SizedBox(height: 24),
                    _buildStatisticsCard(
                      positiveReviews,
                      negativeReviews,
                      neutralReviews,
                    ),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 40),

          // Reviews by Arena
          _buildReviewsList(arenaReviews),
        ],
      ),
    );
  }

  // Rating Card
  Widget _buildRatingCard(double avgRating, int totalReviews) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Общий Рейтинг',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                avgRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.star, size: 40, color: Color(0xFFFBBF24)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'На основе $totalReviews отзыв${_getReviewsEnding(totalReviews)}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // Statistics Card
  Widget _buildStatisticsCard(
    int positiveReviews,
    int negativeReviews,
    int neutralReviews,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Статистика отзывов',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      '$positiveReviews',
                      'Положительных',
                      Colors.green,
                      Icons.thumb_up,
                    ),
                    _buildStatItem(
                      '$neutralReviews',
                      'Нейтральных',
                      Colors.orange,
                      Icons.remove_circle_outline,
                    ),
                    _buildStatItem(
                      '$negativeReviews',
                      'Отрицательных',
                      Colors.red,
                      Icons.thumb_down,
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildStatItem(
                      '$positiveReviews',
                      'Положительных',
                      Colors.green,
                      Icons.thumb_up,
                    ),
                    const SizedBox(height: 16),
                    _buildStatItem(
                      '$neutralReviews',
                      'Нейтральных',
                      Colors.orange,
                      Icons.remove_circle_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildStatItem(
                      '$negativeReviews',
                      'Отрицательных',
                      Colors.red,
                      Icons.thumb_down,
                    ),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  // Reviews List
  Widget _buildReviewsList(List<dynamic> arenaReviews) {
    if (arenaReviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.rate_review_outlined,
                size: 64,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              Text(
                'Отзывов пока нет',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Последние Комментарии',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 24),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: arenaReviews.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final arenaData = arenaReviews[index] as Map<String, dynamic>;
              return _buildArenaReviewsSection(arenaData);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildArenaReviewsSection(Map<String, dynamic> arenaData) {
    final arenaName = arenaData['arenaName'] ?? '';
    final avgRating =
        double.tryParse(arenaData['avgRating']?.toString() ?? '0') ?? 0.0;
    final count = arenaData['count'] ?? 0;
    final reviews = (arenaData['reviews'] as List?) ?? [];

    // Подсчет положительных и отрицательных отзывов для арены
    int arenaPositive = 0;
    int arenaNegative = 0;

    for (var review in reviews) {
      final rating = review['rating'] ?? 0;
      if (rating >= 4) {
        arenaPositive++;
      } else if (rating <= 2) {
        arenaNegative++;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Arena Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.sports_soccer,
                    color: Color(0xFF667EEA),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          arenaName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$count отзыв${_getReviewsEnding(count)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        avgRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFBBF24),
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Статистика по отзывам арены
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.thumb_up, color: Colors.green, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$arenaPositive',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'положительных',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.thumb_down, color: Colors.red, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '$arenaNegative',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'отрицательных',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Reviews
        ...reviews
            .map((review) => _buildReviewItem(review as Map<String, dynamic>))
            .toList(),
      ],
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    final user = review['user'] as Map<String, dynamic>?;
    final userName = user?['name'] ?? 'Пользователь';
    final rating = review['rating'] ?? 0;
    final comment = review['comment'] ?? '';
    final createdAt =
        DateTime.tryParse(review['createdAt'] ?? '') ?? DateTime.now();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User Info
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF667EEA),
                      child: Text(
                        userName[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: List.generate(
                              5,
                              (index) => Icon(
                                index < rating ? Icons.star : Icons.star_border,
                                size: 16,
                                color: const Color(0xFFFBBF24),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Time
              Text(
                _formatDate(createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} минут назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} час${_getHoursEnding(difference.inHours)} назад';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${_getDaysEnding(difference.inDays)} назад';
    } else {
      return DateFormat('dd.MM.yyyy').format(date);
    }
  }

  String _getReviewsEnding(int count) {
    if (count % 10 == 1 && count % 100 != 11) return '';
    if (count % 10 >= 2 &&
        count % 10 <= 4 &&
        (count % 100 < 10 || count % 100 >= 20))
      return 'а';
    return 'ов';
  }

  String _getHoursEnding(int hours) {
    if (hours % 10 == 1 && hours % 100 != 11) return '';
    if (hours % 10 >= 2 &&
        hours % 10 <= 4 &&
        (hours % 100 < 10 || hours % 100 >= 20))
      return 'а';
    return 'ов';
  }

  String _getDaysEnding(int days) {
    if (days % 10 == 1 && days % 100 != 11) return 'день';
    if (days % 10 >= 2 &&
        days % 10 <= 4 &&
        (days % 100 < 10 || days % 100 >= 20))
      return 'дня';
    return 'дней';
  }
}
