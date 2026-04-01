import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../core/locale.dart';
import '../../widgets/language_toggle.dart';

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  final _api = ApiService();
  List<dynamic> _schemes = [];
  bool _isLoading = true;
  String _selectedType = 'all';

  @override
  void initState() {
    super.initState();
    _loadSchemes();
  }

  Future<void> _loadSchemes() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getSchemes(type: _selectedType == 'all' ? null : _selectedType);
      if (data['success'] == true) setState(() => _schemes = data['data']);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.t(context, 'govt_schemes_title')),
        actions: const [LanguageToggle(), SizedBox(width: 10)],
      ),
      body: Column(
        children: [
          // ─── Filter Chips ──────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: ['all', 'central', 'state'].map((type) {
                final selected = _selectedType == type;
                final labelKey = type == 'state' ? 'state_schemes' : type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(AppLocale.t(context, labelKey)),
                    selected: selected,
                    selectedColor: AppTheme.schemePurple.withOpacity(0.15),
                    labelStyle: TextStyle(
                      color: selected ? AppTheme.schemePurple : AppTheme.textSecondary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    onSelected: (_) {
                      setState(() => _selectedType = type);
                      _loadSchemes();
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // ─── Scheme Cards ─────────────────────
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _schemes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded, size: 56, color: AppTheme.textHint),
                            const SizedBox(height: 12),
                            Text(AppLocale.t(context, 'no_schemes')),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadSchemes,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _schemes.length,
                          itemBuilder: (_, i) => _SchemeCard(scheme: _schemes[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _SchemeCard extends StatelessWidget {
  final dynamic scheme;

  const _SchemeCard({required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: (scheme['schemeType'] == 'central' ? AppTheme.schemePurple : AppTheme.calendarGreen).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.account_balance_rounded,
              color: scheme['schemeType'] == 'central' ? AppTheme.schemePurple : AppTheme.calendarGreen,
              size: 22,
            ),
          ),
          title: Text(scheme['schemeName'] ?? scheme['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          subtitle: Text(scheme['ministry'] ?? '', style: const TextStyle(fontSize: 12)),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(scheme['description'] ?? '', style: const TextStyle(fontSize: 13, height: 1.5, color: AppTheme.textSecondary)),
                   if (scheme['benefits'] != null) ...[
                    const SizedBox(height: 14),
                    Text('✅ ${AppLocale.t(context, 'benefits')}:', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.success)),
                    const SizedBox(height: 4),
                    ...(scheme['benefits'] as List).map((b) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text('  • $b', style: const TextStyle(fontSize: 13, height: 1.4)),
                        )),
                  ],
                  if (scheme['eligibility'] != null) ...[
                    const SizedBox(height: 10),
                    Text('📋 ${AppLocale.t(context, 'eligibility')}:', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.info)),
                    const SizedBox(height: 4),
                    ...(scheme['eligibility'] as List).map((e) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text('  • $e', style: const TextStyle(fontSize: 13, height: 1.4)),
                        )),
                  ],
                  if (scheme['applicationLink'] != null && (scheme['applicationLink'] as String).isNotEmpty) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final url = Uri.parse(scheme['applicationLink']);
                          if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
                        },
                        icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        label: Text(AppLocale.t(context, 'apply_now')),
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.schemePurple),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
