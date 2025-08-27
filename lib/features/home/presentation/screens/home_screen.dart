import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:le_livreur_pro/core/models/user.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';
import 'package:le_livreur_pro/features/auth/presentation/screens/login_screen.dart';
import 'package:le_livreur_pro/features/orders/presentation/screens/create_order_screen.dart';
import 'package:le_livreur_pro/features/orders/presentation/screens/orders_screen.dart';
import 'package:le_livreur_pro/features/profile/presentation/screens/profile_screen.dart';
import 'package:le_livreur_pro/features/tracking/presentation/screens/tracking_screen.dart';
import 'package:le_livreur_pro/features/home/presentation/widgets/marketplace_tab.dart';
import 'package:le_livreur_pro/features/home/presentation/widgets/package_delivery_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  // Mock user for demonstration - in real app this would come from auth provider
  final User _currentUser = const User(
    id: '1',
    phone: '+2250700000000',
    fullName: 'John Doe',
    userType: UserType.customer,
    createdAt: null,
    updatedAt: null,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Le Livreur Pro'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => _navigateToProfile(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboard();
      case 1:
        return _buildOrders();
      case 2:
        return _buildTracking();
      case 3:
        return _buildProfile();
      default:
        return _buildDashboard();
    }
  }

  Widget _buildDashboard() {
    switch (_currentUser.userType) {
      case UserType.customer:
        return _buildCustomerMarketplace();
      case UserType.courier:
        return _buildCourierDashboard();
      case UserType.partner:
        return _buildPartnerDashboard();
      case UserType.admin:
        return _buildAdminDashboard();
    }
  }

  Widget _buildCustomerMarketplace() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: AppTheme.primaryGreen,
            child: TabBar(
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(
                  icon: const Icon(Icons.storefront),
                  text: 'Explorer les boutiques'.tr(),
                ),
                Tab(
                  icon: const Icon(Icons.local_shipping),
                  text: 'Envoyer un colis'.tr(),
                ),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                MarketplaceTab(),
                PackageDeliveryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
          const SizedBox(height: 20),
          _buildQuickActions(),
          const SizedBox(height: 20),
          _buildRecentOrders(),
          const SizedBox(height: 20),
          _buildDeliveryZones(),
        ],
      ),
    );
  }

  Widget _buildCourierDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCourierStatusCard(),
          const SizedBox(height: 20),
          _buildAvailableDeliveries(),
          const SizedBox(height: 20),
          _buildEarningsSummary(),
          const SizedBox(height: 20),
          _buildPerformanceStats(),
        ],
      ),
    );
  }

  Widget _buildPartnerDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPartnerStatusCard(),
          const SizedBox(height: 20),
          _buildOrderManagement(),
          const SizedBox(height: 20),
          _buildAnalytics(),
          const SizedBox(height: 20),
          _buildSettings(),
        ],
      ),
    );
  }

  Widget _buildAdminDashboard() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAdminOverviewCard(),
          const SizedBox(height: 20),
          _buildSystemStats(),
          const SizedBox(height: 20),
          _buildUserManagement(),
          const SizedBox(height: 20),
          _buildSystemSettings(),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryGreen,
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour, ${_currentUser.fullName}'.tr(),
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Text(
                        'Bienvenue sur Le Livreur Pro'.tr(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppTheme.neutralGrey,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actions Rapides'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.add_shopping_cart,
                label: 'Nouvelle Commande'.tr(),
                onTap: () => _createNewOrder(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.location_on,
                label: 'Suivre Livraison'.tr(),
                onTap: () => _trackDelivery(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Commandes Récentes'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildOrderItem(
                  orderNumber: 'CMD-2024-001',
                  status: 'En cours',
                  amount: '2,500 XOF',
                  date: 'Aujourd\'hui',
                ),
                const Divider(),
                _buildOrderItem(
                  orderNumber: 'CMD-2024-002',
                  status: 'Livré',
                  amount: '1,800 XOF',
                  date: 'Hier',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem({
    required String orderNumber,
    required String status,
    required String amount,
    required String date,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                orderNumber,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.neutralGrey,
                    ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              amount,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGreen,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: status == 'Livré'
                    ? AppTheme.successGreen
                    : AppTheme.warningOrange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryZones() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Zones de Livraison'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildZoneItem('Abidjan', '5km', '500 XOF'),
                const Divider(),
                _buildZoneItem('Bouaké', '3km', '400 XOF'),
                const Divider(),
                _buildZoneItem('Yamoussoukro', '4km', '450 XOF'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildZoneItem(String city, String radius, String basePrice) {
    return Row(
      children: [
        const Icon(
          Icons.location_city,
          color: AppTheme.primaryGreen,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                city,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                'Rayon: $radius',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.neutralGrey,
                    ),
              ),
            ],
          ),
        ),
        Text(
          'À partir de $basePrice',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  // Placeholder methods for other dashboard sections
  Widget _buildCourierStatusCard() => const Card(
      child:
          Padding(padding: EdgeInsets.all(20), child: Text('Courier Status')));
  Widget _buildAvailableDeliveries() => const Card(
      child: Padding(
          padding: EdgeInsets.all(20), child: Text('Available Deliveries')));
  Widget _buildEarningsSummary() => const Card(
      child: Padding(
          padding: EdgeInsets.all(20), child: Text('Earnings Summary')));
  Widget _buildPerformanceStats() => const Card(
      child: Padding(
          padding: EdgeInsets.all(20), child: Text('Performance Stats')));

  Widget _buildPartnerStatusCard() => const Card(
      child:
          Padding(padding: EdgeInsets.all(20), child: Text('Partner Status')));
  Widget _buildOrderManagement() => const Card(
      child: Padding(
          padding: EdgeInsets.all(20), child: Text('Order Management')));
  Widget _buildAnalytics() => const Card(
      child: Padding(padding: EdgeInsets.all(20), child: Text('Analytics')));
  Widget _buildSettings() => const Card(
      child: Padding(padding: EdgeInsets.all(20), child: Text('Settings')));

  Widget _buildAdminOverviewCard() => const Card(
      child:
          Padding(padding: EdgeInsets.all(20), child: Text('Admin Overview')));
  Widget _buildSystemStats() => const Card(
      child: Padding(padding: EdgeInsets.all(20), child: Text('System Stats')));
  Widget _buildUserManagement() => const Card(
      child:
          Padding(padding: EdgeInsets.all(20), child: Text('User Management')));
  Widget _buildSystemSettings() => const Card(
      child:
          Padding(padding: EdgeInsets.all(20), child: Text('System Settings')));

  Widget _buildOrders() {
    return const OrdersScreen();
  }

  Widget _buildTracking() {
    return const TrackingScreen();
  }

  Widget _buildProfile() {
    return const ProfileScreen();
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
          icon: const Icon(Icons.home),
          label: 'Accueil'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.shopping_bag),
          label: 'Commandes'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.location_on),
          label: 'Suivi'.tr(),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person),
          label: 'Profil'.tr(),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    if (_currentUser.userType == UserType.customer) {
      return FloatingActionButton.extended(
        onPressed: _createNewOrder,
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add),
        label: Text('Nouvelle Commande'.tr()),
      );
    }
    return const SizedBox.shrink();
  }

  // Navigation methods
  void _createNewOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateOrderScreen(),
      ),
    );
  }

  void _trackDelivery() {
    setState(() => _currentIndex = 2);
  }

  void _navigateToProfile() {
    setState(() => _currentIndex = 3);
  }

  void _logout() {
    // TODO: Implement logout logic
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }
}
