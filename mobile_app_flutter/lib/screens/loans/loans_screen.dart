import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../core/locale.dart';
import '../../widgets/language_toggle.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  final _api = ApiService();
  List<dynamic> _loans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  Future<void> _loadLoans() async {
    setState(() => _isLoading = true);
    try {
      final data = await _api.getLoans();
      if (data['success'] == true) setState(() => _loans = data['data']);
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.t(context, 'loan_guidance_title')),
        actions: [const LanguageToggle(), const SizedBox(width: 10)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loans.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_balance_wallet_outlined, size: 56, color: AppTheme.textHint),
                      const SizedBox(height: 12),
                      Text(AppLocale.t(context, 'no_loans')),
                      TextButton(onPressed: _loadLoans, child: Text(AppLocale.t(context, 'refresh'))),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLoans,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _loans.length,
                    itemBuilder: (_, i) => _LoanCard(loan: _loans[i]),
                  ),
                ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  final dynamic loan;

  const _LoanCard({required this.loan});

  @override
  Widget build(BuildContext context) {
    final hasSubsidy = loan['subsidyAvailable'] == true;
    final minRate = loan['interestRate']?['min'];
    final maxRate = loan['interestRate']?['max'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.loanOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: AppTheme.loanOrange, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loan['title'] ?? loan['loanType'] ?? AppLocale.t(context, 'loan_type'),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    Text(loan['bankName'] ?? '', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Rate + Subsidy badges
          Row(
            children: [
              if (minRate != null)
                _Badge(
                  label: '${AppLocale.t(context, 'interest_rate')}: $minRate–$maxRate%',
                  color: AppTheme.primaryGreen,
                  icon: Icons.percent_rounded,
                ),
              if (hasSubsidy) ...[
                const SizedBox(width: 8),
                _Badge(label: AppLocale.t(context, 'subsidy'), color: AppTheme.accent, icon: Icons.star_rounded),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Features
          if (loan['features'] != null)
            ...(loan['features'] as List).take(4).map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppTheme.success, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(f.toString(), style: const TextStyle(fontSize: 13, height: 1.4))),
                    ],
                  ),
                )),

          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.loanOrange,
                side: const BorderSide(color: AppTheme.loanOrange),
              ),
              child: Text(AppLocale.t(context, 'view_details_loans')),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _Badge({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
