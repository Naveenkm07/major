import 'package:flutter/material.dart';
import '../../config/theme.dart';

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> {
  final List<String> _filters = ['All', 'Subsidies', 'Loans', 'Equipment'];
  int _selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ─── Header ────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            color: AppTheme.primaryGreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Schemes & Loans', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        const Icon(Icons.more_horiz, color: Colors.white),
                        const SizedBox(width: 16),
                        Container(width: 8, height: 16, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Search Bar
                Container(
                  height: 48,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search schemes...',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── Filters ────────────────────
          Container(
            height: 60,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedFilter == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedFilter = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryGreen : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade300),
                      ),
                      child: Text(
                        _filters[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ─── Scrollbar Indicator Placeholder ─────────
          Container(
            height: 20,
            color: Colors.grey.shade800,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.arrow_left, color: Colors.grey, size: 20),
                Expanded(
                  child: Container(
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(color: Colors.grey.shade600, borderRadius: BorderRadius.circular(4)),
                    alignment: Alignment.centerLeft,
                    child: Container(width: 60, decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(4))),
                  ),
                ),
                const Icon(Icons.arrow_right, color: Colors.grey, size: 20),
              ],
            ),
          ),

          // ─── List ────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSchemeCard(
                  origin: 'Karnataka Govt.',
                  title: 'Krishi Bhagya',
                  desc: 'Rainwater harvesting subsidy',
                  benefitTitle: 'Benefit',
                  benefitValue: '₹50,000',
                  badge: 'Eligible',
                ),
                const SizedBox(height: 16),
                _buildSchemeCard(
                  origin: 'Central Govt.',
                  title: 'PM-KISAN',
                  desc: 'Direct income support for farmers',
                  benefitTitle: 'Benefit',
                  benefitValue: '₹6,000 /yr',
                  badge: 'Eligible',
                ),
                const SizedBox(height: 16),
                _buildSchemeCard(
                  origin: 'DCC Bank',
                  title: 'Kisan Credit Card',
                  desc: 'Short-term crop loan @ 4% p.a.',
                  benefitTitle: 'Benefit',
                  benefitValue: 'Up to ₹3 L',
                  badge: 'Check eligibility',
                  isBadgeGrey: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeCard({
    required String origin,
    required String title,
    required String desc,
    required String benefitTitle,
    required String benefitValue,
    required String badge,
    bool isBadgeGrey = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(origin, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isBadgeGrey ? Colors.grey.shade100 : AppTheme.primaryGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    if (!isBadgeGrey) const Icon(Icons.check_circle_outline, color: Colors.white, size: 14),
                    if (!isBadgeGrey) const SizedBox(width: 4),
                    Text(
                      badge,
                      style: TextStyle(
                        color: isBadgeGrey ? Colors.grey.shade600 : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(benefitTitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                  Text(benefitValue, style: const TextStyle(color: AppTheme.accent, fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: const Row(
                  children: [
                    Text('How to Apply', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
