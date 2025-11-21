part of 'my_arena_bloc.dart';

@immutable
sealed class MyArenaEvent {}

// Загрузить арены владельца
final class MyArenaLoad extends MyArenaEvent {}

// Загрузить удобства
final class MyArenaLoadAmenities extends MyArenaEvent {}

// Создать арену (новая структура)
final class MyArenaCreate extends MyArenaEvent {
  final String name;
  final String address;
  final String description;
  final String? gisLink;
  final String city;
  // Параметры поля
  final double? length;
  final double? width;
  final double? height;
  final int? playersCount;
  final String typeGrass;
  final bool isCovered;

  // Удобства (массив ID)
  final List<String> amenityIds;

  // Фото и цены
  final List<String> photoUrls;
  final Map<String, Map<String, double?>> prices;

  MyArenaCreate({
    required this.name,
    required this.address,
    required this.description,
    this.gisLink,
    this.length,
    this.width,
    this.height,
    this.playersCount,
    required this.typeGrass,
    required this.city,
    required this.isCovered,
    required this.amenityIds,
    required this.photoUrls,
    required this.prices,
  });
}

// Обновить арену
final class MyArenaUpdate extends MyArenaEvent {
  final String arenaId;
  final String name;
  final String address;
  final String description;
  final String? gisLink;
  final String city;
  // Параметры поля
  final double? length;
  final double? width;
  final double? height;
  final int? playersCount;
  final String typeGrass;
  final bool isCovered;

  // Удобства (массив ID)
  final List<String> amenityIds;

  // Фото и цены
  final List<String> photoUrls;
  final Map<String, Map<String, double?>> prices;

  MyArenaUpdate({
    required this.arenaId,
    required this.name,
    required this.city,
    required this.address,
    required this.description,
    this.gisLink,
    this.length,
    this.width,
    this.height,
    this.playersCount,
    required this.typeGrass,
    required this.isCovered,
    required this.amenityIds,
    required this.photoUrls,
    required this.prices,
  });
}

// Удалить арену
final class MyArenaDelete extends MyArenaEvent {
  final String arenaId;
  MyArenaDelete({required this.arenaId});
}
