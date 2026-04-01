import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../providers/crop_provider.dart';
import '../../config/theme.dart';
import '../../core/locale.dart';
import '../../widgets/language_toggle.dart';

class CropCalendarScreen extends StatefulWidget {
  const CropCalendarScreen({super.key});

  @override
  State<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends State<CropCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String _selectedSeason = 'kharif';

  // Sample events for calendar dates
  final Map<DateTime, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    _generateSampleEvents();
    Future.microtask(() => Provider.of<CropProvider>(context, listen: false).fetchCrops(season: _selectedSeason));
  }

  void _generateSampleEvents() {
    final now = DateTime.now();
    _events[DateTime(now.year, now.month, 5)] = ['irrigation_wheat'];
    _events[DateTime(now.year, now.month, 10)] = ['apply_urea'];
    _events[DateTime(now.year, now.month, 15)] = ['pest_monitoring'];
    _events[DateTime(now.year, now.month, 20)] = ['foliar_spray'];
    _events[DateTime(now.year, now.month, 25)] = ['market_survey'];
  }

  List<String> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final events = _getEventsForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.t(context, 'crop_calendar_title')),
        actions: const [LanguageToggle(), SizedBox(width: 10)],
      ),
      body: Column(
        children: [
          // ─── Calendar Widget ──────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.softShadow,
            ),
            child: TableCalendar(
              firstDay: DateTime(2024),
              lastDay: DateTime(2030),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              onFormatChanged: (format) => setState(() => _calendarFormat = format),
              onPageChanged: (focused) => _focusedDay = focused,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(color: AppTheme.primaryLight.withOpacity(0.5), shape: BoxShape.circle),
                selectedDecoration: const BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle),
                markerDecoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
                markerSize: 6,
                markersMaxCount: 1,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
                formatButtonDecoration: BoxDecoration(
                  border: Border.fromBorderSide(BorderSide(color: AppTheme.primaryGreen)),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                formatButtonTextStyle: TextStyle(color: AppTheme.primaryGreen, fontSize: 13),
              ),
            ),
          ),

          // ─── Season Tabs ──────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: ['kharif', 'rabi', 'zaid'].map((season) {
                final selected = _selectedSeason == season;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedSeason = season);
                      Provider.of<CropProvider>(context, listen: false).fetchCrops(season: season);
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: selected ? AppTheme.primaryGreen : AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppLocale.t(context, season),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: selected ? Colors.white : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ─── Events / Tasks for Selected Day ─
          if (events.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('${AppLocale.t(context, 'tasks_for')} ${_selectedDay.day}/${_selectedDay.month}', style: Theme.of(context).textTheme.titleMedium),
              ),
            ),
            const SizedBox(height: 8),
            ...events.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.calendarGreen.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.calendarGreen.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.task_alt_rounded, color: AppTheme.calendarGreen, size: 20),
                        const SizedBox(width: 10),
                        Expanded(child: Text(AppLocale.t(context, e), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                      ],
                    ),
                  ),
                )),
          ],

          // ─── Crop List ────────────────────────
          Expanded(
            child: Consumer<CropProvider>(
              builder: (_, cropProvider, __) {
                if (cropProvider.isLoading) return const Center(child: CircularProgressIndicator());
                if (cropProvider.crops.isEmpty) return Center(child: Text(AppLocale.t(context, 'no_prices')));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cropProvider.crops.length,
                  itemBuilder: (_, i) {
                    final crop = cropProvider.crops[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: ExpansionTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        leading: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(color: AppTheme.calendarGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.eco_rounded, color: AppTheme.calendarGreen, size: 22),
                        ),
                        title: Text(crop.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: Text('${AppLocale.t(context, crop.category.toLowerCase())} • ${crop.growthDuration ?? '?'} ${AppLocale.t(context, 'days')}', style: const TextStyle(fontSize: 12)),
                        children: [
                          if (crop.calendar != null)
                            ...crop.calendar!.map((stage) => ListTile(
                                  dense: true,
                                  leading: const Icon(Icons.schedule_rounded, size: 18, color: AppTheme.accent),
                                  title: Text(AppLocale.t(context, stage.stage.toLowerCase().replaceAll(' ', '_')), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  subtitle: Text('${AppLocale.t(context, 'week')} ${stage.startWeek}–${stage.endWeek} • ${stage.activities.map((a) => AppLocale.t(context, a.toLowerCase().replaceAll(' ', '_'))).join(", ")}', style: const TextStyle(fontSize: 12)),
                                )),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
