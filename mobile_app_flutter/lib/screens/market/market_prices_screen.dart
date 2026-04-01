import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/market_provider.dart';
import '../../config/theme.dart';
import '../../core/locale.dart';
import '../../widgets/language_toggle.dart';
import 'package:fl_chart/fl_chart.dart';

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<MarketProvider>(context, listen: false).fetchPrices());
  }

  Future<void> _onRefresh() async {
    await Provider.of<MarketProvider>(context, listen: false).fetchPrices(
      commodity: _searchController.text.isNotEmpty ? _searchController.text : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.t(context, 'market_prices')),
        actions: const [LanguageToggle(), SizedBox(width: 10)],
      ),
      body: Column(
        children: [
          // ─── Price Trend Chart ─────────────────
          Container(
            height: 140,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.marketBlue, AppTheme.marketBlue.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: AppTheme.marketBlue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(1, 4),
                      FlSpot(2, 3.5),
                      FlSpot(3, 5),
                      FlSpot(4, 4.5),
                      FlSpot(5, 6),
                    ],
                    isCurved: true,
                    color: Colors.white,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Search Bar ────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppLocale.t(context, 'search_crop'),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _onRefresh();
                        },
                      )
                    : null,
              ),
              onSubmitted: (v) => Provider.of<MarketProvider>(context, listen: false).fetchPrices(commodity: v),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // ─── Price List with Pull-to-Refresh ───
          Expanded(
            child: Consumer<MarketProvider>(
              builder: (_, market, __) {
                if (market.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (market.prices.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Icon(Icons.storefront_rounded, size: 64, color: AppTheme.textHint),
                        const SizedBox(height: 12),
                        Text(AppLocale.t(context, 'no_prices')),
                        const SizedBox(height: 8),
                        TextButton(onPressed: _onRefresh, child: Text(AppLocale.t(context, 'refresh'))),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: AppTheme.primaryGreen,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    itemCount: market.prices.length,
                    itemBuilder: (_, i) {
                      final price = market.prices[i];
                      return _PriceCard(
                        commodity: price.commodity,
                        market: price.market,
                        district: price.district,
                        state: price.state,
                        unit: price.unit,
                        minPrice: price.minPrice,
                        maxPrice: price.maxPrice,
                        modalPrice: price.modalPrice,
                        trend: price.trend,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final String commodity, market, district, state, unit;
  final double minPrice, maxPrice, modalPrice;
  final String? trend;

  const _PriceCard({
    required this.commodity, required this.market, required this.district,
    required this.state, required this.unit, required this.minPrice,
    required this.maxPrice, required this.modalPrice, this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final trendIcon = trend == 'rising' ? Icons.trending_up : trend == 'falling' ? Icons.trending_down : Icons.trending_flat;
    final trendColor = trend == 'rising' ? AppTheme.success : trend == 'falling' ? AppTheme.error : AppTheme.textHint;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(commodity, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('₹${modalPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primaryGreen, fontSize: 15)),
                    Text('/$unit', style: TextStyle(color: AppTheme.primaryGreen.withOpacity(0.7), fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.storefront_rounded, size: 14, color: AppTheme.textHint),
              const SizedBox(width: 4),
              Text('$market, $district', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _MiniChip(label: '${AppLocale.t(context, 'min_price')} ₹${minPrice.toStringAsFixed(0)}', color: AppTheme.info),
              const SizedBox(width: 8),
              _MiniChip(label: '${AppLocale.t(context, 'max_price')} ₹${maxPrice.toStringAsFixed(0)}', color: AppTheme.accent),
              const Spacer(),
              Icon(trendIcon, size: 18, color: trendColor),
              const SizedBox(width: 4),
              Text(AppLocale.t(context, trend ?? 'stable'), style: TextStyle(fontSize: 12, color: trendColor, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
