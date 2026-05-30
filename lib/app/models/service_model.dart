class ServiceModel {
  final String id;
  final String arenaId;
  final String name;
  final String description;
  final String type;
  final List<String> photos;
  final String icon;
  final int pricePerHour;
  final Map<String, dynamic> prices;
  final int minDuration;
  final int maxDuration;
  final int durationStep;
  final Map<String, dynamic> schedule;
  final int capacity;
  final bool requiresPrepayment;
  final int prepaymentPercent;
  final bool isActive;

  ServiceModel({
    required this.id,
    required this.arenaId,
    required this.name,
    required this.description,
    required this.type,
    required this.photos,
    required this.icon,
    required this.pricePerHour,
    required this.prices,
    required this.minDuration,
    required this.maxDuration,
    required this.durationStep,
    required this.schedule,
    required this.capacity,
    required this.requiresPrepayment,
    required this.prepaymentPercent,
    required this.isActive,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['_id'] ?? '',
      arenaId: json['arena'] is Map ? json['arena']['_id'] : (json['arena'] ?? ''),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'other',
      photos: List<String>.from(json['photos'] ?? []),
      icon: json['icon'] ?? 'spa',
      pricePerHour: json['pricePerHour'] ?? 0,
      prices: json['prices'] ?? {},
      minDuration: json['minDuration'] ?? 60,
      maxDuration: json['maxDuration'] ?? 300,
      durationStep: json['durationStep'] ?? 30,
      schedule: json['schedule'] ?? {},
      capacity: json['capacity'] ?? 1,
      requiresPrepayment: json['requiresPrepayment'] ?? true,
      prepaymentPercent: json['prepaymentPercent'] ?? 100,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arenaId': arenaId,
      'name': name,
      'description': description,
      'type': type,
      'photos': photos,
      'icon': icon,
      'pricePerHour': pricePerHour,
      'prices': prices,
      'minDuration': minDuration,
      'maxDuration': maxDuration,
      'durationStep': durationStep,
      'schedule': schedule,
      'capacity': capacity,
      'requiresPrepayment': requiresPrepayment,
      'prepaymentPercent': prepaymentPercent,
      'isActive': isActive,
    };
  }
}
