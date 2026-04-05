/// Activity types for farming calendar
enum ActivityType {
  irrigation,
  fertilization,
  pestControl,
  sowing,
  harvesting,
  landPrep,
  weeding,
  monitoring,
}

/// Activity priority levels
enum Priority { high, medium, low }

/// A single farming activity on the calendar
class FarmingActivity {
  final DateTime date;
  final String cropName;
  final ActivityType type;
  final String title;
  final String description;
  final List<String> tips;
  final Priority priority;
  final String season; // kharif, rabi, zaid

  const FarmingActivity({
    required this.date,
    required this.cropName,
    required this.type,
    required this.title,
    required this.description,
    this.tips = const [],
    this.priority = Priority.medium,
    required this.season,
  });
}
