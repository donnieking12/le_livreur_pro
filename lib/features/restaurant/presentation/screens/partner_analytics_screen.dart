import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:le_livreur_pro/core/models/analytics_data.dart';
import 'package:le_livreur_pro/core/services/analytics_service.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';

// Providers for analytics data
final partnerAnalyticsProvider = FutureProvider.family<PartnerAnalytics, AnalyticsRequest>((ref, request) async {
  return await AnalyticsService.getPartnerAnalytics(request.partnerId, request.period);
});

class AnalyticsRequest {
  final String partnerId;
  final String period;

  AnalyticsRequest(this.partnerId, this.period);
}

class PartnerAnalyticsScreen extends ConsumerStatefulWidget {
  final String partnerId;

  const PartnerAnalyticsScreen({
    super.key,
    required this.partnerId,
  });

  @override
  ConsumerState<PartnerAnalyticsScreen> createState() => _PartnerAnalyticsScreenState();
}

class _PartnerAnalyticsScreenState extends ConsumerState<PartnerAnalyticsScreen> {
  String _selectedPeriod = '7d'; // 7d, 30d, 90d, 1y
  
  final Map<String, String> _periodLabels = {
    '7d': '7 jours',
    '30d': '30 jours',
    '90d': '3 mois',
    '1y': '1 an',
  };

  @override
  Widget build(BuildContext context) {
    final analyticsRequest = AnalyticsRequest(widget.partnerId, _selectedPeriod);
    final analyticsAsync = ref.watch(partnerAnalyticsProvider(analyticsRequest));

    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics'.tr()),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.date_range),
            onSelected: (period) => setState(() => _selectedPeriod = period),
            itemBuilder: (context) => _periodLabels.entries
                .map((entry) => PopupMenuItem(
                      value: entry.key,
                      child: Text(entry.value.tr()),
                    ))
                .toList(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(),
          ),
        ],
      ),
      body: analyticsAsync.when(
        data: (analytics) => _buildAnalyticsContent(analytics),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildAnalyticsContent(PartnerAnalytics analytics) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: 20),
            _buildKPICards(analytics),
            const SizedBox(height: 24),
            _buildChartPlaceholder('Évolution des revenus'.tr()),
            const SizedBox(height: 24),
            _buildChartPlaceholder('Évolution des commandes'.tr()),
            const SizedBox(height: 24),
            _buildTopProducts(analytics),
            const SizedBox(height: 24),
            _buildCustomerInsights(analytics),
            const SizedBox(height: 24),
            _buildPerformanceMetrics(analytics),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Période d\'analyse'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _periodLabels.entries.map((entry) {
                final isSelected = _selectedPeriod == entry.key;
                return ChoiceChip(
                  label: Text(entry.value.tr()),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedPeriod = entry.key);
                    }
                  },
                  selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICards(PartnerAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Indicateurs clés'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                title: 'Revenus totaux'.tr(),
                value: '${analytics.totalRevenue} XOF',
                icon: Icons.monetization_on,
                color: AppTheme.primaryGreen,
                change: analytics.revenueChange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                title: 'Commandes'.tr(),
                value: '${analytics.totalOrders}',
                icon: Icons.shopping_bag,
                color: AppTheme.infoBlue,
                change: analytics.ordersChange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                title: 'Clients uniques'.tr(),
                value: '${analytics.uniqueCustomers}',
                icon: Icons.people,
                color: AppTheme.accentOrange,
                change: analytics.customersChange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                title: 'Panier moyen'.tr(),
                value: '${analytics.averageOrderValue} XOF',
                icon: Icons.shopping_cart,
                color: AppTheme.warningOrange,
                change: analytics.aovChange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    double? change,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                if (change != null) _buildChangeIndicator(change),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.neutralGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeIndicator(double change) {
    final isPositive = change >= 0;
    final color = isPositive ? AppTheme.successGreen : AppTheme.errorRed;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          '${change.abs().toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildChartPlaceholder(String title) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bar_chart,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Graphique sera ajouté\navec fl_chart',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProducts(PartnerAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produits les plus vendus'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...analytics.topProducts.take(5).map((product) => _buildTopProductItem(product)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductItem(TopProduct product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
            backgroundImage: product.imageUrl != null ? NetworkImage(product.imageUrl!) : null,
            child: product.imageUrl == null ? const Icon(Icons.restaurant, color: AppTheme.primaryGreen) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${product.quantity} vendus',
                  style: const TextStyle(
                    color: AppTheme.neutralGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${product.revenue} XOF',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInsights(PartnerAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insights clients'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInsightCard(
                    'Nouveaux clients'.tr(),
                    '${analytics.newCustomers}',
                    Icons.person_add,
                    AppTheme.successGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInsightCard(
                    'Clients fidèles'.tr(),
                    '${analytics.returningCustomers}',
                    Icons.favorite,
                    AppTheme.accentOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInsightCard(
                    'Commandes répétées'.tr(),
                    '${analytics.repeatOrderRate.toStringAsFixed(1)}%',
                    Icons.repeat,
                    AppTheme.infoBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInsightCard(
                    'Taux satisfaction'.tr(),
                    '${analytics.satisfactionRate.toStringAsFixed(1)}%',
                    Icons.star,
                    AppTheme.warningOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.neutralGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(PartnerAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Métriques de performance'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              'Temps de préparation moyen'.tr(),
              '${analytics.avgPreparationTime} min',
              Icons.timer,
            ),
            _buildMetricRow(
              'Taux d\'acceptation'.tr(),
              '${analytics.acceptanceRate.toStringAsFixed(1)}%',
              Icons.check_circle,
            ),
            _buildMetricRow(
              'Note moyenne'.tr(),
              '${analytics.averageRating.toStringAsFixed(1)}/5',
              Icons.star,
            ),
            _buildMetricRow(
              'Temps de livraison moyen'.tr(),
              '${analytics.avgDeliveryTime} min',
              Icons.delivery_dining,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur lors du chargement des analytics'.tr(),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _refreshData(),
              child: Text('Réessayer'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    ref.refresh(partnerAnalyticsProvider(AnalyticsRequest(widget.partnerId, _selectedPeriod)));
  }
}import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:le_livreur_pro/core/models/analytics_data.dart';
import 'package:le_livreur_pro/core/services/analytics_service.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';

// Providers for analytics data
final partnerAnalyticsProvider = FutureProvider.family<PartnerAnalytics, AnalyticsRequest>((ref, request) async {
  return await AnalyticsService.getPartnerAnalytics(request.partnerId, request.period);
});

class AnalyticsRequest {
  final String partnerId;
  final String period;

  AnalyticsRequest(this.partnerId, this.period);
}

class PartnerAnalyticsScreen extends ConsumerStatefulWidget {
  final String partnerId;

  const PartnerAnalyticsScreen({
    super.key,
    required this.partnerId,
  });

  @override
  ConsumerState<PartnerAnalyticsScreen> createState() => _PartnerAnalyticsScreenState();
}

class _PartnerAnalyticsScreenState extends ConsumerState<PartnerAnalyticsScreen> {
  String _selectedPeriod = '7d'; // 7d, 30d, 90d, 1y
  
  final Map<String, String> _periodLabels = {
    '7d': '7 jours',
    '30d': '30 jours',
    '90d': '3 mois',
    '1y': '1 an',
  };

  @override
  Widget build(BuildContext context) {
    final analyticsRequest = AnalyticsRequest(widget.partnerId, _selectedPeriod);
    final analyticsAsync = ref.watch(partnerAnalyticsProvider(analyticsRequest));

    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics'.tr()),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.date_range),
            onSelected: (period) => setState(() => _selectedPeriod = period),
            itemBuilder: (context) => _periodLabels.entries
                .map((entry) => PopupMenuItem(
                      value: entry.key,
                      child: Text(entry.value.tr()),
                    ))
                .toList(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(),
          ),
        ],
      ),
      body: analyticsAsync.when(
        data: (analytics) => _buildAnalyticsContent(analytics),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildAnalyticsContent(PartnerAnalytics analytics) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: 20),
            _buildKPICards(analytics),
            const SizedBox(height: 24),
            _buildChartPlaceholder('Évolution des revenus'.tr()),
            const SizedBox(height: 24),
            _buildChartPlaceholder('Évolution des commandes'.tr()),
            const SizedBox(height: 24),
            _buildTopProducts(analytics),
            const SizedBox(height: 24),
            _buildCustomerInsights(analytics),
            const SizedBox(height: 24),
            _buildPerformanceMetrics(analytics),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Période d\'analyse'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _periodLabels.entries.map((entry) {
                final isSelected = _selectedPeriod == entry.key;
                return ChoiceChip(
                  label: Text(entry.value.tr()),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedPeriod = entry.key);
                    }
                  },
                  selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICards(PartnerAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Indicateurs clés'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                title: 'Revenus totaux'.tr(),
                value: '${analytics.totalRevenue} XOF',
                icon: Icons.monetization_on,
                color: AppTheme.primaryGreen,
                change: analytics.revenueChange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                title: 'Commandes'.tr(),
                value: '${analytics.totalOrders}',
                icon: Icons.shopping_bag,
                color: AppTheme.infoBlue,
                change: analytics.ordersChange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                title: 'Clients uniques'.tr(),
                value: '${analytics.uniqueCustomers}',
                icon: Icons.people,
                color: AppTheme.accentOrange,
                change: analytics.customersChange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                title: 'Panier moyen'.tr(),
                value: '${analytics.averageOrderValue} XOF',
                icon: Icons.shopping_cart,
                color: AppTheme.warningOrange,
                change: analytics.aovChange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    double? change,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                if (change != null) _buildChangeIndicator(change),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.neutralGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeIndicator(double change) {
    final isPositive = change >= 0;
    final color = isPositive ? AppTheme.successGreen : AppTheme.errorRed;
    final icon = isPositive ? Icons.trending_up : Icons.trending_down;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Text(
          '${change.abs().toStringAsFixed(1)}%',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildChartPlaceholder(String title) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bar_chart,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Graphique sera ajouté\navec fl_chart',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProducts(PartnerAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produits les plus vendus'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...analytics.topProducts.take(5).map((product) => _buildTopProductItem(product)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductItem(TopProduct product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
            backgroundImage: product.imageUrl != null ? NetworkImage(product.imageUrl!) : null,
            child: product.imageUrl == null ? const Icon(Icons.restaurant, color: AppTheme.primaryGreen) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${product.quantity} vendus',
                  style: const TextStyle(
                    color: AppTheme.neutralGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${product.revenue} XOF',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInsights(PartnerAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Insights clients'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInsightCard(
                    'Nouveaux clients'.tr(),
                    '${analytics.newCustomers}',
                    Icons.person_add,
                    AppTheme.successGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInsightCard(
                    'Clients fidèles'.tr(),
                    '${analytics.returningCustomers}',
                    Icons.favorite,
                    AppTheme.accentOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInsightCard(
                    'Commandes répétées'.tr(),
                    '${analytics.repeatOrderRate.toStringAsFixed(1)}%',
                    Icons.repeat,
                    AppTheme.infoBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInsightCard(
                    'Taux satisfaction'.tr(),
                    '${analytics.satisfactionRate.toStringAsFixed(1)}%',
                    Icons.star,
                    AppTheme.warningOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.neutralGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(PartnerAnalytics analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Métriques de performance'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
              'Temps de préparation moyen'.tr(),
              '${analytics.avgPreparationTime} min',
              Icons.timer,
            ),
            _buildMetricRow(
              'Taux d\'acceptation'.tr(),
              '${analytics.acceptanceRate.toStringAsFixed(1)}%',
              Icons.check_circle,
            ),
            _buildMetricRow(
              'Note moyenne'.tr(),
              '${analytics.averageRating.toStringAsFixed(1)}/5',
              Icons.star,
            ),
            _buildMetricRow(
              'Temps de livraison moyen'.tr(),
              '${analytics.avgDeliveryTime} min',
              Icons.delivery_dining,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur lors du chargement des analytics'.tr(),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$error',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _refreshData(),
              child: Text('Réessayer'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    ref.refresh(partnerAnalyticsProvider(AnalyticsRequest(widget.partnerId, _selectedPeriod)));
  }
}