import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:le_livreur_pro/core/models/admin_analytics_data.dart';
import 'package:le_livreur_pro/core/services/admin_service.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';

// Provider for admin analytics
final adminAnalyticsProvider =
    FutureProvider.family<AdminAnalyticsData, String>((ref, period) async {
  return await AdminService.getAnalytics(period);
});

class AdminAnalyticsScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  ConsumerState<AdminAnalyticsScreen> createState() =>
      _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends ConsumerState<AdminAnalyticsScreen> {
  String _selectedPeriod = '7d'; // 7d, 30d, 90d, 1y

  final Map<String, String> _periodLabels = {
    '7d': '7 jours',
    '30d': '30 jours',
    '90d': '3 mois',
    '1y': '1 an',
  };

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(adminAnalyticsProvider(_selectedPeriod));

    return Scaffold(
      body: analyticsAsync.when(
        data: (analytics) => _buildAnalyticsContent(analytics),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showExportOptions(),
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.file_download),
      ),
    );
  }

  Widget _buildAnalyticsContent(AdminAnalyticsData analytics) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: 20),
            _buildPlatformOverview(analytics),
            const SizedBox(height: 24),
            _buildRevenueMetrics(analytics),
            const SizedBox(height: 24),
            _buildUserGrowth(analytics),
            const SizedBox(height: 24),
            _buildOrderMetrics(analytics),
            const SizedBox(height: 24),
            _buildPerformanceMetrics(analytics),
            const SizedBox(height: 24),
            _buildGeographicData(analytics),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Analytics de la plateforme'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case 'export':
                        _showExportOptions();
                        break;
                      case 'share':
                        _shareReport();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [
                          const Icon(Icons.file_download),
                          const SizedBox(width: 8),
                          Text('Exporter'.tr()),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          const Icon(Icons.share),
                          const SizedBox(width: 8),
                          Text('Partager'.tr()),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
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

  Widget _buildPlatformOverview(AdminAnalyticsData analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vue d\'ensemble'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildOverviewCard(
                  'Revenus totaux'.tr(),
                  '${analytics.totalRevenue} XOF',
                  Icons.monetization_on,
                  AppTheme.primaryGreen,
                  analytics.revenueGrowth,
                ),
                _buildOverviewCard(
                  'Commandes'.tr(),
                  '${analytics.totalOrders}',
                  Icons.shopping_bag,
                  AppTheme.accentOrange,
                  analytics.ordersGrowth,
                ),
                _buildOverviewCard(
                  'Utilisateurs actifs'.tr(),
                  '${analytics.activeUsers}',
                  Icons.people,
                  AppTheme.infoBlue,
                  analytics.userGrowth,
                ),
                _buildOverviewCard(
                  'Taux de réussite'.tr(),
                  '${analytics.successRate.toStringAsFixed(1)}%',
                  Icons.check_circle,
                  AppTheme.successGreen,
                  analytics.successRateChange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    IconData icon,
    Color color,
    double? change,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
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

  Widget _buildRevenueMetrics(AdminAnalyticsData analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Métriques de revenus'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildChartPlaceholder('Évolution des revenus'.tr()),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    'Commission moyenne'.tr(),
                    '${analytics.averageCommission}%',
                    AppTheme.primaryGreen,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    'Revenus par commande'.tr(),
                    '${analytics.revenuePerOrder} XOF',
                    AppTheme.accentOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserGrowth(AdminAnalyticsData analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Croissance des utilisateurs'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildChartPlaceholder('Nouveaux utilisateurs par jour'.tr()),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildUserTypeMetric('Clients'.tr(),
                    '${analytics.totalCustomers}', AppTheme.infoBlue),
                _buildUserTypeMetric('Livreurs'.tr(),
                    '${analytics.totalCouriers}', AppTheme.accentOrange),
                _buildUserTypeMetric('Partenaires'.tr(),
                    '${analytics.totalPartners}', AppTheme.warningOrange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserTypeMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderMetrics(AdminAnalyticsData analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Métriques des commandes'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildChartPlaceholder('Commandes par statut'.tr()),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildOrderMetricRow(
                  'Temps de livraison moyen'.tr(),
                  '${analytics.averageDeliveryTime} min',
                  Icons.timer,
                ),
                _buildOrderMetricRow(
                  'Taux d\'annulation'.tr(),
                  '${analytics.cancellationRate.toStringAsFixed(1)}%',
                  Icons.cancel,
                ),
                _buildOrderMetricRow(
                  'Note moyenne'.tr(),
                  '${analytics.averageRating.toStringAsFixed(1)}/5',
                  Icons.star,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderMetricRow(String label, String value, IconData icon) {
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

  Widget _buildPerformanceMetrics(AdminAnalyticsData analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance système'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildPerformanceCard(
                    'Uptime'.tr(),
                    '${analytics.systemUptime}%',
                    AppTheme.successGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildPerformanceCard(
                    'Temps de réponse'.tr(),
                    '${analytics.responseTime}ms',
                    AppTheme.infoBlue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
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
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeographicData(AdminAnalyticsData analytics) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Données géographiques'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildChartPlaceholder('Répartition par commune'.tr()),
            const SizedBox(height: 16),
            ...analytics.topCities.take(5).map((city) => _buildCityRow(
                city['name'], city['orderCount'], city['percentage'])),
          ],
        ),
      ),
    );
  }

  Widget _buildCityRow(String city, int orders, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              city,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '$orders commandes',
            style: const TextStyle(color: AppTheme.neutralGrey),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      children: [
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
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.neutralGrey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildChartPlaceholder(String title) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.bar_chart,
              size: 32,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Graphique bientôt disponible',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
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

  // ==================== EVENT HANDLERS ====================

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Options d\'export'.tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: Text('Exporter en PDF'.tr()),
              onTap: () {
                Navigator.pop(context);
                _exportToPDF();
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: Text('Exporter en CSV'.tr()),
              onTap: () {
                Navigator.pop(context);
                _exportToCSV();
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: Text('Exporter graphiques'.tr()),
              onTap: () {
                Navigator.pop(context);
                _exportCharts();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportToPDF() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export PDF bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _exportToCSV() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export CSV bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _exportCharts() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export graphiques bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _shareReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Partage de rapport bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  Future<void> _refreshData() async {
    ref.refresh(adminAnalyticsProvider(_selectedPeriod));
  }
}
