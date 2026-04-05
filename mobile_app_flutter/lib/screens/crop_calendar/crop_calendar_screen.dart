import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../providers/calendar_provider.dart';
import '../../models/farming_activity.dart';
import '../../config/theme.dart';
import '../../core/locale.dart';
import '../../widgets/language_toggle.dart';

// ─── Activity Type Colors & Icons ─────────────────────────────────────────────
Color _colorForType(ActivityType type) {
  switch (type) {
    case ActivityType.irrigation:    return const Color(0xFF1E88E5); // blue
    case ActivityType.fertilization: return const Color(0xFFFF8F00); // amber
    case ActivityType.pestControl:   return const Color(0xFFE53935); // red
    case ActivityType.sowing:        return const Color(0xFF43A047); // green
    case ActivityType.harvesting:    return const Color(0xFF8E24AA); // purple
    case ActivityType.landPrep:      return const Color(0xFF6D4C41); // brown
    case ActivityType.weeding:       return const Color(0xFF00897B); // teal
    case ActivityType.monitoring:    return const Color(0xFF546E7A); // blue-grey
  }
}

IconData _iconForType(ActivityType type) {
  switch (type) {
    case ActivityType.irrigation:    return Icons.water_drop_rounded;
    case ActivityType.fertilization: return Icons.science_rounded;
    case ActivityType.pestControl:   return Icons.bug_report_rounded;
    case ActivityType.sowing:        return Icons.agriculture_rounded;
    case ActivityType.harvesting:    return Icons.content_cut_rounded;
    case ActivityType.landPrep:      return Icons.landscape_rounded;
    case ActivityType.weeding:       return Icons.grass_rounded;
    case ActivityType.monitoring:    return Icons.visibility_rounded;
  }
}

String _labelForType(BuildContext context, ActivityType type) {
  switch (type) {
    case ActivityType.irrigation:    return AppLocale.t(context, 'act_irrigation');
    case ActivityType.fertilization: return AppLocale.t(context, 'act_fertilization');
    case ActivityType.pestControl:   return AppLocale.t(context, 'act_pest_control');
    case ActivityType.sowing:        return AppLocale.t(context, 'act_sowing');
    case ActivityType.harvesting:    return AppLocale.t(context, 'act_harvesting');
    case ActivityType.landPrep:      return AppLocale.t(context, 'act_land_prep');
    case ActivityType.weeding:       return AppLocale.t(context, 'act_weeding');
    case ActivityType.monitoring:    return AppLocale.t(context, 'act_monitoring');
  }
}

Color _colorForPriority(Priority priority) {
  switch (priority) {
    case Priority.high:   return const Color(0xFFE53935);
    case Priority.medium: return const Color(0xFFFFA000);
    case Priority.low:    return const Color(0xFF43A047);
  }
}

String _labelForPriority(BuildContext context, Priority priority) {
  switch (priority) {
    case Priority.high:   return AppLocale.t(context, 'priority_high');
    case Priority.medium: return AppLocale.t(context, 'priority_medium');
    case Priority.low:    return AppLocale.t(context, 'priority_low');
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

class CropCalendarScreen extends StatefulWidget {
  const CropCalendarScreen({super.key});

  @override
  State<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends State<CropCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalendarProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocale.t(context, 'crop_calendar_title')),
          actions: const [LanguageToggle(), SizedBox(width: 10)],
        ),
        body: Consumer<CalendarProvider>(
          builder: (context, cal, _) {
            final selectedActivities = cal.selectedDayActivities;

            return Column(
              children: [
                // ─── Calendar ──────────────────────────
                Container(
                  margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: TableCalendar<FarmingActivity>(
                    firstDay: DateTime(DateTime.now().year - 1),
                    lastDay: DateTime(DateTime.now().year + 1, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) => isSameDay(cal.selectedDate, day),
                    eventLoader: cal.getActivitiesForDay,
                    onDaySelected: (selected, focused) {
                      cal.selectDate(selected);
                      setState(() => _focusedDay = focused);
                    },
                    onFormatChanged: (format) => setState(() => _calendarFormat = format),
                    onPageChanged: (focused) => _focusedDay = focused,
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: AppTheme.primaryLight.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: const BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                      markerSize: 6,
                      markersMaxCount: 3,
                      markerMargin: const EdgeInsets.symmetric(horizontal: 0.8),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isEmpty) return null;
                        final types = events.map((e) => e.type).toSet().toList();
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: types.take(3).map((type) {
                            return Container(
                              width: 6, height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 0.8),
                              decoration: BoxDecoration(
                                color: _colorForType(type),
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: true,
                      titleCentered: true,
                      formatButtonDecoration: BoxDecoration(
                        border: Border.fromBorderSide(BorderSide(color: AppTheme.primaryGreen)),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      formatButtonTextStyle: TextStyle(color: AppTheme.primaryGreen, fontSize: 12),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ─── Filters Row ────────────────────────
                _FiltersRow(),

                // ─── Activity Legend ────────────────────
                _ActivityLegend(),

                // ─── Day Activities List ────────────────
                Expanded(
                  child: selectedActivities.isEmpty
                      ? _EmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                          itemCount: selectedActivities.length + 1, // +1 for header
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  '${AppLocale.t(context, 'tasks_for')} ${cal.selectedDate.day}/${cal.selectedDate.month}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              );
                            }
                            return _ActivityCard(activity: selectedActivities[index - 1]);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Filters Row ──────────────────────────────────────────────────────────────
class _FiltersRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cal = Provider.of<CalendarProvider>(context);
    final seasons = ['all', 'kharif', 'rabi', 'zaid'];
    final crops = ['all', ...cal.cropNames];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          // Season chips
          Expanded(
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: seasons.map((s) {
                  final selected = cal.selectedSeason == s;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(
                        s == 'all' ? AppLocale.t(context, 'all_seasons') : AppLocale.t(context, s),
                        style: TextStyle(
                          fontSize: 12,
                          color: selected ? Colors.white : AppTheme.textSecondary,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      selected: selected,
                      onSelected: (_) => cal.selectSeason(s),
                      backgroundColor: AppTheme.surfaceVariant,
                      selectedColor: AppTheme.primaryGreen,
                      checkmarkColor: Colors.white,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Crop dropdown
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.divider),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: cal.selectedCrop,
                icon: const Icon(Icons.eco_rounded, size: 16, color: AppTheme.calendarGreen),
                isDense: true,
                style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                items: crops.map((c) => DropdownMenuItem(
                  value: c,
                  child: Text(c == 'all' ? AppLocale.t(context, 'all_crops') : c, style: const TextStyle(fontSize: 12)),
                )).toList(),
                onChanged: (v) => cal.selectCrop(v!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Activity Legend ──────────────────────────────────────────────────────────
class _ActivityLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        children: ActivityType.values.map((type) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: _colorForType(type),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _labelForType(context, type),
                  style: TextStyle(fontSize: 10, color: AppTheme.textHint),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_available_rounded, size: 56, color: AppTheme.textHint.withOpacity(0.4)),
          const SizedBox(height: 12),
          Text(
            AppLocale.t(context, 'no_activities'),
            style: TextStyle(fontSize: 15, color: AppTheme.textHint, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocale.t(context, 'no_activities_hint'),
            style: TextStyle(fontSize: 12, color: AppTheme.textHint),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Activity Card ────────────────────────────────────────────────────────────
class _ActivityCard extends StatelessWidget {
  final FarmingActivity activity;
  const _ActivityCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    final typeColor = _colorForType(activity.type);
    final priorityColor = _colorForPriority(activity.priority);

    return GestureDetector(
      onTap: () => _showDetailSheet(context, activity),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppTheme.softShadow,
          border: Border(left: BorderSide(color: typeColor, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_iconForType(activity.type), color: typeColor, size: 22),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: title + priority
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            activity.title,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _labelForPriority(context, activity.priority),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: priorityColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Crop + type tags
                    Row(
                      children: [
                        _Tag(label: activity.cropName, color: AppTheme.calendarGreen),
                        const SizedBox(width: 6),
                        _Tag(label: _labelForType(context, activity.type), color: typeColor),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Description
                    Text(
                      activity.description,
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Tap hint
                    if (activity.tips.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.tips_and_updates_rounded, size: 14, color: AppTheme.accent),
                          const SizedBox(width: 4),
                          Text(
                            '${activity.tips.length} ${AppLocale.t(context, 'tips_available')}',
                            style: TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textHint),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Tag Widget ───────────────────────────────────────────────────────────────
class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Detail Bottom Sheet ──────────────────────────────────────────────────────
void _showDetailSheet(BuildContext context, FarmingActivity activity) {
  final typeColor = _colorForType(activity.type);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(_iconForType(activity.type), color: typeColor, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(activity.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _Tag(label: activity.cropName, color: AppTheme.calendarGreen),
                          const SizedBox(width: 6),
                          _Tag(label: _labelForType(context, activity.type), color: typeColor),
                          const SizedBox(width: 6),
                          _Tag(
                            label: _labelForPriority(context, activity.priority),
                            color: _colorForPriority(activity.priority),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Description
            Text(
              activity.description,
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
            ),

            // Tips
            if (activity.tips.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.tips_and_updates_rounded, color: AppTheme.accent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppLocale.t(context, 'expert_tips'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.accent),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...activity.tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(tip, style: const TextStyle(fontSize: 13, height: 1.5)),
                    ),
                  ],
                ),
              )),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}
