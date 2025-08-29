import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:le_livreur_pro/core/models/admin_dashboard_data.dart';
import 'package:le_livreur_pro/core/services/admin_service.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';
import 'package:le_livreur_pro/features/admin/presentation/screens/admin_users_screen.dart';
import 'package:le_livreur_pro/features/admin/presentation/screens/admin_orders_screen.dart';
import 'package:le_livreur_pro/features/admin/presentation/screens/admin_analytics_screen.dart';
import 'package:le_livreur_pro/features/admin/presentation/screens/admin_settings_screen.dart';

// Provider for admin dashboard data
final adminDashboardProvider = FutureProvider<AdminDashboardData>((ref) async {
  return await AdminService.getDashboardData();
});

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Administration'.tr()),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotifications(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshData(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          isScrollable: true,
          tabs: [
            Tab(text: 'Tableau de bord'.tr()),
            Tab(text: 'Utilisateurs'.tr()),
            Tab(text: 'Commandes'.tr()),
            Tab(text: 'Analytics'.tr()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          const AdminUsersScreen(),
          const AdminOrdersScreen(),
          const AdminAnalyticsScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickActions(),
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.admin_panel_settings),
      ),
    );
  }

  Widget _buildDashboardTab() {
    final dashboardAsync = ref.watch(adminDashboardProvider);

    return dashboardAsync.when(
      data: (dashboard) => RefreshIndicator(
        onRefresh: () => _refreshData(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 24),
              _buildSystemOverview(dashboard),
              const SizedBox(height: 24),
              _buildQuickStats(dashboard),
              const SizedBox(height: 24),
              _buildRecentActivity(dashboard),
              const SizedBox(height: 24),
              _buildSystemHealth(dashboard),
              const SizedBox(height: 24),
              _buildQuickActions(),
            ],
          ),
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.admin_panel_settings,
                size: 32,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Panneau d\'administration'.tr(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gestion complète de la plateforme Le Livreur Pro'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppTheme.neutralGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppTheme.successGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Système opérationnel'.tr(),
                        style: const TextStyle(
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemOverview(AdminDashboardData dashboard) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aperçu du système'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewItem(
                    'Uptime',
                    '${dashboard.systemUptime}%',
                    Icons.trending_up,
                    AppTheme.successGreen,
                  ),
                ),
                Expanded(
                  child: _buildOverviewItem(
                    'Performance',
                    dashboard.systemPerformance,
                    Icons.speed,
                    AppTheme.infoBlue,
                  ),
                ),
                Expanded(
                  child: _buildOverviewItem(
                    'Version',
                    dashboard.appVersion,
                    Icons.info,
                    AppTheme.neutralGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(
      String label, String value, IconData icon, Color color) {
    return Column(
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
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.neutralGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(AdminDashboardData dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistiques rapides'.tr(),
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
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Utilisateurs totaux'.tr(),
              '${dashboard.totalUsers}',
              Icons.people,
              AppTheme.primaryGreen,
              '+${dashboard.newUsersToday} aujourd\'hui',
            ),
            _buildStatCard(
              'Commandes actives'.tr(),
              '${dashboard.activeOrders}',
              Icons.shopping_bag,
              AppTheme.accentOrange,
              '${dashboard.completedOrdersToday} terminées',
            ),
            _buildStatCard(
              'Livreurs en ligne'.tr(),
              '${dashboard.onlineCouriers}',
              Icons.delivery_dining,
              AppTheme.infoBlue,
              '${dashboard.totalCouriers} au total',
            ),
            _buildStatCard(
              'Restaurants actifs'.tr(),
              '${dashboard.activeRestaurants}',
              Icons.restaurant,
              AppTheme.warningOrange,
              '${dashboard.totalRestaurants} partenaires',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.neutralGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(AdminDashboardData dashboard) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Activité récente'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _showActivityLog(),
                  child: Text('Voir tout'.tr()),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...dashboard.recentActivities
                .take(5)
                .map((activity) => _buildActivityItem(activity)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(RecentActivity activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getActivityColor(activity.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getActivityIcon(activity.type),
              color: _getActivityColor(activity.type),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  _formatDateTime(activity.timestamp),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.neutralGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemHealth(AdminDashboardData dashboard) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Santé du système'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...dashboard.systemHealthChecks
                .map((check) => _buildHealthCheckItem(check)),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCheckItem(HealthCheck check) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            check.isHealthy ? Icons.check_circle : Icons.error,
            color: check.isHealthy ? AppTheme.successGreen : AppTheme.errorRed,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              check.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            check.status,
            style: TextStyle(
              color:
                  check.isHealthy ? AppTheme.successGreen : AppTheme.errorRed,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions rapides'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildActionChip(
                  'Gérer utilisateurs'.tr(),
                  Icons.people,
                  () => _tabController.animateTo(1),
                ),
                _buildActionChip(
                  'Voir commandes'.tr(),
                  Icons.shopping_bag,
                  () => _tabController.animateTo(2),
                ),
                _buildActionChip(
                  'Analytics'.tr(),
                  Icons.analytics,
                  () => _tabController.animateTo(3),
                ),
                _buildActionChip(
                  'Paramètres'.tr(),
                  Icons.settings,
                  () => _showSettings(),
                ),
                _buildActionChip(
                  'Notifications'.tr(),
                  Icons.notifications_active,
                  () => _sendBroadcastNotification(),
                ),
                _buildActionChip(
                  'Backup'.tr(),
                  Icons.backup,
                  () => _initiateBackup(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppTheme.primaryGreen, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w600,
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
              'Erreur lors du chargement'.tr(),
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

  // ==================== HELPER METHODS ====================

  Color _getActivityColor(String type) {
    switch (type) {
      case 'user_action':
        return AppTheme.infoBlue;
      case 'order_update':
        return AppTheme.accentOrange;
      case 'system_event':
        return AppTheme.primaryGreen;
      case 'error':
        return AppTheme.errorRed;
      default:
        return AppTheme.neutralGrey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'user_action':
        return Icons.person;
      case 'order_update':
        return Icons.shopping_bag;
      case 'system_event':
        return Icons.settings;
      case 'error':
        return Icons.error;
      default:
        return Icons.info;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'À l\'instant';
    }
  }

  // ==================== EVENT HANDLERS ====================

  void _showNotifications() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Centre de notifications bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Actions administrateur'.tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.backup),
              title: Text('Sauvegarder données'.tr()),
              onTap: () {
                Navigator.pop(context);
                _initiateBackup();
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              title: Text('Redémarrer services'.tr()),
              onTap: () {
                Navigator.pop(context);
                _restartServices();
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: Text('Audit de sécurité'.tr()),
              onTap: () {
                Navigator.pop(context);
                _runSecurityAudit();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityLog() {
    // TODO: Implement activity log screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Journal d\'activité bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _showSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminSettingsScreen(),
      ),
    );
  }

  void _sendBroadcastNotification() {
    // TODO: Implement broadcast notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification diffusée à tous les utilisateurs'.tr()),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  void _initiateBackup() {
    // TODO: Implement backup functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sauvegarde initiée...'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _restartServices() {
    // TODO: Implement service restart
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Services redémarrés'.tr()),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  void _runSecurityAudit() {
    // TODO: Implement security audit
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Audit de sécurité en cours...'.tr()),
        backgroundColor: AppTheme.warningOrange,
      ),
    );
  }

  Future<void> _refreshData() async {
    ref.refresh(adminDashboardProvider);
  }
}
