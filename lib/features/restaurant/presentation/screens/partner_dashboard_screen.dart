import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:le_livreur_pro/core/models/delivery_order.dart';
import 'package:le_livreur_pro/core/models/restaurant.dart';
import 'package:le_livreur_pro/core/models/user.dart' as app_user;
import 'package:le_livreur_pro/core/services/auth_service.dart';
import 'package:le_livreur_pro/core/services/restaurant_service.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';
import 'package:le_livreur_pro/features/restaurant/presentation/screens/menu_management_screen.dart';
import 'package:le_livreur_pro/features/restaurant/presentation/screens/partner_orders_screen.dart';
import 'package:le_livreur_pro/features/restaurant/presentation/screens/partner_analytics_screen.dart';
import 'package:le_livreur_pro/features/restaurant/presentation/screens/restaurant_settings_screen.dart';

class PartnerDashboardScreen extends ConsumerStatefulWidget {
  const PartnerDashboardScreen({super.key});

  @override
  ConsumerState<PartnerDashboardScreen> createState() =>
      _PartnerDashboardScreenState();
}

class _PartnerDashboardScreenState
    extends ConsumerState<PartnerDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return userProfileAsync.when(
      data: (user) {
        if (user == null || user.userType != app_user.UserType.partner) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Tableau de Bord Partenaire'.tr()),
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Text('Accès non autorisé'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Tableau de Bord Partenaire'.tr()),
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => _showNotifications(),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _openSettings(user),
              ),
            ],
          ),
          body: _buildBody(user),
          bottomNavigationBar: _buildBottomNavigationBar(),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text('Tableau de Bord Partenaire'.tr()),
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: Text('Tableau de Bord Partenaire'.tr()),
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text('Erreur: $error'),
        ),
      ),
    );
  }

  Widget _buildBody(app_user.User user) {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardTab(user);
      case 1:
        return PartnerOrdersScreen(partnerId: user.id);
      case 2:
        return MenuManagementScreen(restaurantId: user.restaurantId!);
      case 3:
        return PartnerAnalyticsScreen(partnerId: user.id);
      default:
        return _buildDashboardTab(user);
    }
  }

  Widget _buildDashboardTab(app_user.User user) {
    if (user.restaurantId == null) {
      return _buildNoRestaurantView();
    }

    return RefreshIndicator(
      onRefresh: () => _refreshData(user.id, user.restaurantId!),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(user),
            const SizedBox(height: 24),
            _buildQuickStats(user.restaurantId!),
            const SizedBox(height: 24),
            _buildRestaurantStatus(user.restaurantId!),
            const SizedBox(height: 24),
            _buildRecentOrders(user.id),
            const SizedBox(height: 24),
            _buildQuickActions(user),
          ],
        ),
      ),
    );
  }

  Widget _buildNoRestaurantView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 120,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun restaurant configuré'.tr(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.neutralGrey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Vous devez créer votre restaurant pour commencer à utiliser le tableau de bord partenaire.'
                  .tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _createRestaurant,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              icon: const Icon(Icons.add_business),
              label: Text('Créer mon restaurant'.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(app_user.User user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.primaryGreen,
              backgroundImage: user.profileImageUrl != null
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
              child: user.profileImageUrl == null
                  ? const Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour, ${user.fullName}'.tr(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gérez votre restaurant et vos commandes'.tr(),
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
                          color: user.isVerified
                              ? AppTheme.successGreen
                              : AppTheme.warningOrange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user.isVerified
                            ? 'Vérifié'.tr()
                            : 'En attente de vérification'.tr(),
                        style: TextStyle(
                          color: user.isVerified
                              ? AppTheme.successGreen
                              : AppTheme.warningOrange,
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

  Widget _buildQuickStats(String restaurantId) {
    // Mock data - replace with real providers
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Commandes aujourd\'hui'.tr(),
            value: '12',
            icon: Icons.shopping_bag,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Revenus du jour'.tr(),
            value: '45,000',
            subtitle: 'XOF',
            icon: Icons.monetization_on,
            color: AppTheme.accentOrange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Évaluation'.tr(),
            value: '4.8',
            icon: Icons.star,
            color: AppTheme.warningOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    String? subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
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
      ),
    );
  }

  Widget _buildRestaurantStatus(String restaurantId) {
    return FutureBuilder<Restaurant?>(
      future: RestaurantService.getRestaurantById(restaurantId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final restaurant = snapshot.data!;
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
                      'Statut du restaurant'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: restaurant.acceptsOrders,
                      onChanged: (value) =>
                          _toggleRestaurantStatus(restaurantId, value),
                      activeThumbColor: AppTheme.primaryGreen,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      restaurant.acceptsOrders
                          ? Icons.check_circle
                          : Icons.pause_circle,
                      color: restaurant.acceptsOrders
                          ? AppTheme.successGreen
                          : AppTheme.warningOrange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      restaurant.acceptsOrders
                          ? 'Accepte les commandes'.tr()
                          : 'Commandes suspendues'.tr(),
                      style: TextStyle(
                        color: restaurant.acceptsOrders
                            ? AppTheme.successGreen
                            : AppTheme.warningOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.timer,
                      size: 16,
                      color: AppTheme.neutralGrey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Temps de préparation: ${restaurant.preparationTimeMinutes} min'
                          .tr(),
                      style: const TextStyle(
                        color: AppTheme.neutralGrey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentOrders(String partnerId) {
    // Mock data - replace with real provider
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
                  'Commandes récentes'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _currentIndex = 1),
                  child: Text('Voir toutes'.tr()),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...List.generate(
                3,
                (index) => _buildOrderItem(
                      orderNumber: 'CMD-2024-${100 + index}',
                      items: 'Attiéké poulet, Jus de gingembre',
                      amount: '${3500 + (index * 1000)} XOF',
                      status: index == 0
                          ? 'pending'
                          : index == 1
                              ? 'assigned'
                              : 'delivered',
                      time: '${10 + index}:30',
                    )),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem({
    required String orderNumber,
    required String items,
    required String amount,
    required String status,
    required String time,
  }) {
    Color statusColor;
    String statusText;

    switch (status) {
      case 'pending':
        statusColor = AppTheme.warningOrange;
        statusText = 'Nouveau'.tr();
        break;
      case 'assigned':
        statusColor = AppTheme.infoBlue;
        statusText = 'En préparation'.tr();
        break;
      case 'delivered':
        statusColor = AppTheme.successGreen;
        statusText = 'Livré'.tr();
        break;
      default:
        statusColor = AppTheme.neutralGrey;
        statusText = status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  orderNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  items,
                  style: const TextStyle(
                    color: AppTheme.neutralGrey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppTheme.neutralGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(app_user.User user) {
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
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildActionButton(
                  icon: Icons.restaurant_menu,
                  label: 'Gérer le menu'.tr(),
                  onTap: () => setState(() => _currentIndex = 2),
                ),
                _buildActionButton(
                  icon: Icons.analytics,
                  label: 'Voir analytics'.tr(),
                  onTap: () => setState(() => _currentIndex = 3),
                ),
                _buildActionButton(
                  icon: Icons.inventory_2,
                  label: 'Gérer stock'.tr(),
                  onTap: () => _manageStock(),
                ),
                _buildActionButton(
                  icon: Icons.campaign,
                  label: 'Promotions'.tr(),
                  onTap: () => _managePromotions(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppTheme.primaryGreen,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.primaryGreen,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppTheme.primaryGreen,
      unselectedItemColor: AppTheme.neutralGrey,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard),
          label: 'Tableau de bord'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.shopping_bag),
          label: 'Commandes'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.restaurant_menu),
          label: 'Menu'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.analytics),
          label: 'Analytics'.tr(),
        ),
      ],
    );
  }

  // ==================== EVENT HANDLERS ====================

  void _showNotifications() {
    // TODO: Implement notifications screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notifications bientôt disponibles'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _openSettings(app_user.User user) {
    if (user.restaurantId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              RestaurantSettingsScreen(restaurantId: user.restaurantId!),
        ),
      );
    }
  }

  void _createRestaurant() {
    // TODO: Implement restaurant creation flow
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Création de restaurant bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  Future<void> _toggleRestaurantStatus(
      String restaurantId, bool acceptsOrders) async {
    try {
      await RestaurantService.updateRestaurant(restaurantId, {
        'accepts_orders': acceptsOrders,
      });

      setState(() {}); // Refresh the UI

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            acceptsOrders
                ? 'Restaurant ouvert aux commandes'.tr()
                : 'Restaurant fermé aux commandes'.tr(),
          ),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour: $e'.tr()),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  void _manageStock() {
    // TODO: Implement stock management
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gestion du stock bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _managePromotions() {
    // TODO: Implement promotions management
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gestion des promotions bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  Future<void> _refreshData(String partnerId, String restaurantId) async {
    // TODO: Refresh all data providers
    setState(() {});
  }
}
