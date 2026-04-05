import 'package:flutter/material.dart';
import '../models/farming_activity.dart';
import '../data/karnataka_calendar_data.dart';

/// Provider for the farmer calendar feature.
/// Manages date selection, season/crop filters, and activity lookups.
class CalendarProvider extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  String _selectedSeason = 'all';
  String _selectedCrop = 'all';

  // Cache activities for current & adjacent years
  late List<FarmingActivity> _allActivities;

  CalendarProvider() {
    _loadActivities();
  }

  void _loadActivities() {
    final now = DateTime.now();
    _allActivities = [
      ...KarnatakaCalendarData.getActivities(now.year - 1),
      ...KarnatakaCalendarData.getActivities(now.year),
      ...KarnatakaCalendarData.getActivities(now.year + 1),
    ];
  }

  // ─── Getters ──────────────────────────────────────
  DateTime get selectedDate => _selectedDate;
  String get selectedSeason => _selectedSeason;
  String get selectedCrop => _selectedCrop;
  List<String> get cropNames => KarnatakaCalendarData.cropNames;

  // ─── Setters ──────────────────────────────────────
  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void selectSeason(String season) {
    _selectedSeason = season;
    notifyListeners();
  }

  void selectCrop(String crop) {
    _selectedCrop = crop;
    notifyListeners();
  }

  // ─── Activity Queries ─────────────────────────────

  /// Get filtered activities list
  List<FarmingActivity> get _filteredActivities {
    return _allActivities.where((a) {
      if (_selectedSeason != 'all' && a.season != _selectedSeason) return false;
      if (_selectedCrop != 'all' && a.cropName != _selectedCrop) return false;
      return true;
    }).toList();
  }

  /// Activities for a specific day (used by calendar event loader)
  List<FarmingActivity> getActivitiesForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _filteredActivities.where((a) {
      final aDate = DateTime(a.date.year, a.date.month, a.date.day);
      return aDate == date;
    }).toList();
  }

  /// Activities for the selected day
  List<FarmingActivity> get selectedDayActivities =>
      getActivitiesForDay(_selectedDate);

  /// Upcoming activities from today (next 7 days)
  List<FarmingActivity> get upcomingActivities {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekLater = today.add(const Duration(days: 7));
    return _filteredActivities.where((a) {
      final aDate = DateTime(a.date.year, a.date.month, a.date.day);
      return !aDate.isBefore(today) && aDate.isBefore(weekLater);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Get activity types present on a day (for multi-color dots)
  Set<ActivityType> getActivityTypesForDay(DateTime day) {
    return getActivitiesForDay(day).map((a) => a.type).toSet();
  }
}
