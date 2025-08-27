import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:le_livreur_pro/core/models/delivery_order_simple.dart';
import 'package:le_livreur_pro/core/services/admin_service.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';

// Providers for order management
final allOrdersProvider = FutureProvider<List<DeliveryOrder>>((ref) async {
  return await AdminService.getAllOrders();
});

final ordersByStatusProvider = FutureProvider.family<List<DeliveryOrder>, DeliveryStatus>((ref, status) async {
  return await AdminService.getOrdersByStatus(status);
});

final orderStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await AdminService.getOrderStatistics();
});

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllOrdersTab(),
                _buildStatusOrdersTab(DeliveryStatus.pending),
                _buildStatusOrdersTab(DeliveryStatus.assigned),
                _buildStatusOrdersTab(DeliveryStatus.inTransit),
                _buildStatusOrdersTab(DeliveryStatus.delivered),
                _buildProblemOrdersTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showOrderActions(),
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.admin_panel_settings),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher par numéro de commande...'.tr(),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _selectDateRange(),
                icon: const Icon(Icons.date_range),
                style: IconButton.styleFrom(
                  backgroundColor: _dateRange != null ? AppTheme.primaryGreen : Colors.grey[300],
                  foregroundColor: _dateRange != null ? Colors.white : Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _showFilterDialog(),
                icon: const Icon(Icons.filter_list),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildOrderStats(),
        ],
      ),
    );
  }

  Widget _buildOrderStats() {
    final statsAsync = ref.watch(orderStatsProvider);
    
    return statsAsync.when(
      data: (stats) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatChip('Total'.tr(), '${stats['total']}', AppTheme.primaryGreen),
          _buildStatChip('En cours'.tr(), '${stats['active']}', AppTheme.accentOrange),
          _buildStatChip('Livrées'.tr(), '${stats['delivered']}', AppTheme.successGreen),
          _buildStatChip('Problèmes'.tr(), '${stats['problems']}', AppTheme.errorRed),
        ],
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
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
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.primaryGreen,
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        isScrollable: true,
        tabs: [
          Tab(text: 'Toutes'.tr()),
          Tab(text: 'En attente'.tr()),
          Tab(text: 'Assignées'.tr()),
          Tab(text: 'En transit'.tr()),
          Tab(text: 'Livrées'.tr()),
          Tab(text: 'Problèmes'.tr()),
        ],
      ),
    );
  }

  Widget _buildAllOrdersTab() {
    final ordersAsync = ref.watch(allOrdersProvider);
    
    return ordersAsync.when(
      data: (orders) => _buildOrdersList(orders),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildStatusOrdersTab(DeliveryStatus status) {
    final ordersAsync = ref.watch(ordersByStatusProvider(status));
    
    return ordersAsync.when(
      data: (orders) => _buildOrdersList(orders),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildProblemOrdersTab() {
    final ordersAsync = ref.watch(allOrdersProvider);
    
    return ordersAsync.when(
      data: (orders) {
        final problemOrders = orders.where((order) => 
          order.status == DeliveryStatus.cancelled || 
          order.status == DeliveryStatus.disputed ||
          _isDelayedOrder(order)
        ).toList();
        return _buildOrdersList(problemOrders);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildOrdersList(List<DeliveryOrder> orders) {
    List<DeliveryOrder> filteredOrders = orders;
    
    if (_searchQuery.isNotEmpty) {
      filteredOrders = orders.where((order) {
        return order.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               order.recipientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               order.recipientPhone.contains(_searchQuery);
      }).toList();
    }

    if (_dateRange != null) {
      filteredOrders = filteredOrders.where((order) {
        return order.createdAt.isAfter(_dateRange!.start) &&
               order.createdAt.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    if (filteredOrders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _refreshData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(DeliveryOrder order) {
    final isDelayed = _isDelayedOrder(order);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(order.status).withOpacity(0.1),
          child: Icon(
            _getOrderTypeIcon(order.orderType),
            color: _getStatusColor(order.status),
          ),
        ),
        title: Text(
          order.orderNumber,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.recipientName,
              style: const TextStyle(color: AppTheme.neutralGrey),
            ),
            Text(
              DateFormat('dd/MM/yyyy à HH:mm').format(order.createdAt),
              style: const TextStyle(
                color: AppTheme.neutralGrey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(order.status.displayName, _getStatusColor(order.status)),
                const SizedBox(width: 8),
                if (isDelayed)
                  _buildStatusChip('Retard'.tr(), AppTheme.errorRed),
                const SizedBox(width: 8),
                Text(
                  '${order.totalPriceXof} XOF',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'track',
              child: Row(
                children: [
                  const Icon(Icons.track_changes),
                  const SizedBox(width: 8),
                  Text('Suivre'.tr()),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'assign',
              child: Row(
                children: [
                  const Icon(Icons.person_add),
                  const SizedBox(width: 8),
                  Text('Assigner'.tr()),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'cancel',
              child: Row(
                children: [
                  const Icon(Icons.cancel, color: AppTheme.errorRed),
                  const SizedBox(width: 8),
                  Text('Annuler'.tr(), style: const TextStyle(color: AppTheme.errorRed)),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleOrderAction(order, value),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Type', _getOrderTypeLabel(order.orderType)),
                if (order.packageDescription != null)
                  _buildDetailRow('Description', order.packageDescription!),
                _buildDetailRow('Client', '${order.recipientName} (${order.recipientPhone})'),
                if (order.courierAssigned != null)
                  _buildDetailRow('Livreur', order.courierAssigned!),
                _buildDetailRow('Adresse de livraison', order.deliveryAddress ?? 'Non spécifiée'),
                if (order.specialInstructions != null)
                  _buildDetailRow('Instructions', order.specialInstructions!),
                if (order.estimatedDeliveryTime != null)
                  _buildDetailRow(
                    'Livraison estimée',
                    DateFormat('dd/MM/yyyy à HH:mm').format(order.estimatedDeliveryTime!),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _viewOrderDetails(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.infoBlue,
                        ),
                        icon: const Icon(Icons.visibility),
                        label: Text('Voir détails'.tr()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _trackOrder(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                        ),
                        icon: const Icon(Icons.location_on),
                        label: Text('Localiser'.tr()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.neutralGrey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune commande trouvée'.tr(),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            if (_searchQuery.isNotEmpty || _dateRange != null) ...[
              const SizedBox(height: 8),
              Text(
                'Essayez de modifier vos filtres'.tr(),
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
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

  Color _getStatusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return AppTheme.warningOrange;
      case DeliveryStatus.assigned:
      case DeliveryStatus.courierEnRoute:
        return AppTheme.infoBlue;
      case DeliveryStatus.pickedUp:
      case DeliveryStatus.inTransit:
        return AppTheme.accentOrange;
      case DeliveryStatus.delivered:
        return AppTheme.successGreen;
      case DeliveryStatus.cancelled:
      case DeliveryStatus.disputed:
        return AppTheme.errorRed;
      default:
        return AppTheme.neutralGrey;
    }
  }

  IconData _getOrderTypeIcon(OrderType orderType) {
    switch (orderType) {
      case OrderType.package:
        return Icons.inventory_2;
      case OrderType.marketplace:
        return Icons.restaurant;
    }
  }

  String _getOrderTypeLabel(OrderType orderType) {
    switch (orderType) {
      case OrderType.package:
        return 'Colis';
      case OrderType.marketplace:
        return 'Restaurant';
    }
  }

  bool _isDelayedOrder(DeliveryOrder order) {
    if (order.estimatedDeliveryTime == null) return false;
    return DateTime.now().isAfter(order.estimatedDeliveryTime!) && 
           order.status != DeliveryStatus.delivered;
  }

  // ==================== EVENT HANDLERS ====================

  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filtres avancés'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_dateRange != null) ...[
              ListTile(
                leading: const Icon(Icons.date_range),
                title: Text('Période sélectionnée'.tr()),
                subtitle: Text(
                  '${DateFormat('dd/MM/yyyy').format(_dateRange!.start)} - '
                  '${DateFormat('dd/MM/yyyy').format(_dateRange!.end)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() => _dateRange = null);
                    Navigator.pop(context);
                  },
                ),
              ),
            ] else ...[
              Text('Aucun filtre actif'.tr()),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'.tr()),
          ),
        ],
      ),
    );
  }

  void _showOrderActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Actions sur les commandes'.tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: Text('Assigner automatiquement'.tr()),
              subtitle: Text('Assigner les commandes en attente'.tr()),
              onTap: () {
                Navigator.pop(context);
                _autoAssignOrders();
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: Text('Signaler problèmes'.tr()),
              subtitle: Text('Identifier les commandes en retard'.tr()),
              onTap: () {
                Navigator.pop(context);
                _flagProblematicOrders();
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: Text('Exporter données'.tr()),
              subtitle: Text('Exporter les commandes en CSV'.tr()),
              onTap: () {
                Navigator.pop(context);
                _exportOrders();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleOrderAction(DeliveryOrder order, String action) {
    switch (action) {
      case 'track':
        _trackOrder(order);
        break;
      case 'assign':
        _assignOrder(order);
        break;
      case 'cancel':
        _cancelOrder(order);
        break;
    }
  }

  void _viewOrderDetails(DeliveryOrder order) {
    // TODO: Navigate to detailed order view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Détails de ${order.orderNumber} bientôt disponibles'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _trackOrder(DeliveryOrder order) {
    // TODO: Show order tracking interface
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Suivi de ${order.orderNumber} bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _assignOrder(DeliveryOrder order) {
    // TODO: Show courier assignment interface
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attribution de ${order.orderNumber} bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _cancelOrder(DeliveryOrder order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Annuler ${order.orderNumber}'),
        content: const Text('Voulez-vous vraiment annuler cette commande?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Non'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: Text('Annuler'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AdminService.cancelOrder(order.id, 'Annulé par admin');
        _refreshData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Commande ${order.orderNumber} annulée'.tr()),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'.tr()),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  void _autoAssignOrders() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attribution automatique bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _flagProblematicOrders() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Signalement automatique bientôt disponible'.tr()),
        backgroundColor: AppTheme.warningOrange,
      ),
    );
  }

  void _exportOrders() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export CSV bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  Future<void> _refreshData() async {
    ref.refresh(allOrdersProvider);
    ref.refresh(orderStatsProvider);
    // Refresh all status-specific providers
    for (final status in DeliveryStatus.values) {
      ref.refresh(ordersByStatusProvider(status));
    }
  }
}import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:le_livreur_pro/core/models/delivery_order_simple.dart';
import 'package:le_livreur_pro/core/services/admin_service.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';

// Providers for order management
final allOrdersProvider = FutureProvider<List<DeliveryOrder>>((ref) async {
  return await AdminService.getAllOrders();
});

final ordersByStatusProvider = FutureProvider.family<List<DeliveryOrder>, DeliveryStatus>((ref, status) async {
  return await AdminService.getOrdersByStatus(status);
});

final orderStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await AdminService.getOrderStatistics();
});

class AdminOrdersScreen extends ConsumerStatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  ConsumerState<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends ConsumerState<AdminOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final _searchController = TextEditingController();
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSearchHeader(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllOrdersTab(),
                _buildStatusOrdersTab(DeliveryStatus.pending),
                _buildStatusOrdersTab(DeliveryStatus.assigned),
                _buildStatusOrdersTab(DeliveryStatus.inTransit),
                _buildStatusOrdersTab(DeliveryStatus.delivered),
                _buildProblemOrdersTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showOrderActions(),
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.admin_panel_settings),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Rechercher par numéro de commande...'.tr(),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _selectDateRange(),
                icon: const Icon(Icons.date_range),
                style: IconButton.styleFrom(
                  backgroundColor: _dateRange != null ? AppTheme.primaryGreen : Colors.grey[300],
                  foregroundColor: _dateRange != null ? Colors.white : Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _showFilterDialog(),
                icon: const Icon(Icons.filter_list),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildOrderStats(),
        ],
      ),
    );
  }

  Widget _buildOrderStats() {
    final statsAsync = ref.watch(orderStatsProvider);
    
    return statsAsync.when(
      data: (stats) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatChip('Total'.tr(), '${stats['total']}', AppTheme.primaryGreen),
          _buildStatChip('En cours'.tr(), '${stats['active']}', AppTheme.accentOrange),
          _buildStatChip('Livrées'.tr(), '${stats['delivered']}', AppTheme.successGreen),
          _buildStatChip('Problèmes'.tr(), '${stats['problems']}', AppTheme.errorRed),
        ],
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
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
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.primaryGreen,
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        isScrollable: true,
        tabs: [
          Tab(text: 'Toutes'.tr()),
          Tab(text: 'En attente'.tr()),
          Tab(text: 'Assignées'.tr()),
          Tab(text: 'En transit'.tr()),
          Tab(text: 'Livrées'.tr()),
          Tab(text: 'Problèmes'.tr()),
        ],
      ),
    );
  }

  Widget _buildAllOrdersTab() {
    final ordersAsync = ref.watch(allOrdersProvider);
    
    return ordersAsync.when(
      data: (orders) => _buildOrdersList(orders),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildStatusOrdersTab(DeliveryStatus status) {
    final ordersAsync = ref.watch(ordersByStatusProvider(status));
    
    return ordersAsync.when(
      data: (orders) => _buildOrdersList(orders),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildProblemOrdersTab() {
    final ordersAsync = ref.watch(allOrdersProvider);
    
    return ordersAsync.when(
      data: (orders) {
        final problemOrders = orders.where((order) => 
          order.status == DeliveryStatus.cancelled || 
          order.status == DeliveryStatus.disputed ||
          _isDelayedOrder(order)
        ).toList();
        return _buildOrdersList(problemOrders);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildOrdersList(List<DeliveryOrder> orders) {
    List<DeliveryOrder> filteredOrders = orders;
    
    if (_searchQuery.isNotEmpty) {
      filteredOrders = orders.where((order) {
        return order.orderNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               order.recipientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               order.recipientPhone.contains(_searchQuery);
      }).toList();
    }

    if (_dateRange != null) {
      filteredOrders = filteredOrders.where((order) {
        return order.createdAt.isAfter(_dateRange!.start) &&
               order.createdAt.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    if (filteredOrders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _refreshData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(DeliveryOrder order) {
    final isDelayed = _isDelayedOrder(order);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(order.status).withOpacity(0.1),
          child: Icon(
            _getOrderTypeIcon(order.orderType),
            color: _getStatusColor(order.status),
          ),
        ),
        title: Text(
          order.orderNumber,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              order.recipientName,
              style: const TextStyle(color: AppTheme.neutralGrey),
            ),
            Text(
              DateFormat('dd/MM/yyyy à HH:mm').format(order.createdAt),
              style: const TextStyle(
                color: AppTheme.neutralGrey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(order.status.displayName, _getStatusColor(order.status)),
                const SizedBox(width: 8),
                if (isDelayed)
                  _buildStatusChip('Retard'.tr(), AppTheme.errorRed),
                const SizedBox(width: 8),
                Text(
                  '${order.totalPriceXof} XOF',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'track',
              child: Row(
                children: [
                  const Icon(Icons.track_changes),
                  const SizedBox(width: 8),
                  Text('Suivre'.tr()),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'assign',
              child: Row(
                children: [
                  const Icon(Icons.person_add),
                  const SizedBox(width: 8),
                  Text('Assigner'.tr()),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'cancel',
              child: Row(
                children: [
                  const Icon(Icons.cancel, color: AppTheme.errorRed),
                  const SizedBox(width: 8),
                  Text('Annuler'.tr(), style: const TextStyle(color: AppTheme.errorRed)),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleOrderAction(order, value),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Type', _getOrderTypeLabel(order.orderType)),
                if (order.packageDescription != null)
                  _buildDetailRow('Description', order.packageDescription!),
                _buildDetailRow('Client', '${order.recipientName} (${order.recipientPhone})'),
                if (order.courierAssigned != null)
                  _buildDetailRow('Livreur', order.courierAssigned!),
                _buildDetailRow('Adresse de livraison', order.deliveryAddress ?? 'Non spécifiée'),
                if (order.specialInstructions != null)
                  _buildDetailRow('Instructions', order.specialInstructions!),
                if (order.estimatedDeliveryTime != null)
                  _buildDetailRow(
                    'Livraison estimée',
                    DateFormat('dd/MM/yyyy à HH:mm').format(order.estimatedDeliveryTime!),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _viewOrderDetails(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.infoBlue,
                        ),
                        icon: const Icon(Icons.visibility),
                        label: Text('Voir détails'.tr()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _trackOrder(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                        ),
                        icon: const Icon(Icons.location_on),
                        label: Text('Localiser'.tr()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.neutralGrey,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune commande trouvée'.tr(),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            if (_searchQuery.isNotEmpty || _dateRange != null) ...[
              const SizedBox(height: 8),
              Text(
                'Essayez de modifier vos filtres'.tr(),
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
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

  Color _getStatusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return AppTheme.warningOrange;
      case DeliveryStatus.assigned:
      case DeliveryStatus.courierEnRoute:
        return AppTheme.infoBlue;
      case DeliveryStatus.pickedUp:
      case DeliveryStatus.inTransit:
        return AppTheme.accentOrange;
      case DeliveryStatus.delivered:
        return AppTheme.successGreen;
      case DeliveryStatus.cancelled:
      case DeliveryStatus.disputed:
        return AppTheme.errorRed;
      default:
        return AppTheme.neutralGrey;
    }
  }

  IconData _getOrderTypeIcon(OrderType orderType) {
    switch (orderType) {
      case OrderType.package:
        return Icons.inventory_2;
      case OrderType.marketplace:
        return Icons.restaurant;
    }
  }

  String _getOrderTypeLabel(OrderType orderType) {
    switch (orderType) {
      case OrderType.package:
        return 'Colis';
      case OrderType.marketplace:
        return 'Restaurant';
    }
  }

  bool _isDelayedOrder(DeliveryOrder order) {
    if (order.estimatedDeliveryTime == null) return false;
    return DateTime.now().isAfter(order.estimatedDeliveryTime!) && 
           order.status != DeliveryStatus.delivered;
  }

  // ==================== EVENT HANDLERS ====================

  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    
    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filtres avancés'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_dateRange != null) ...[
              ListTile(
                leading: const Icon(Icons.date_range),
                title: Text('Période sélectionnée'.tr()),
                subtitle: Text(
                  '${DateFormat('dd/MM/yyyy').format(_dateRange!.start)} - '
                  '${DateFormat('dd/MM/yyyy').format(_dateRange!.end)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() => _dateRange = null);
                    Navigator.pop(context);
                  },
                ),
              ),
            ] else ...[
              Text('Aucun filtre actif'.tr()),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'.tr()),
          ),
        ],
      ),
    );
  }

  void _showOrderActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Actions sur les commandes'.tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: Text('Assigner automatiquement'.tr()),
              subtitle: Text('Assigner les commandes en attente'.tr()),
              onTap: () {
                Navigator.pop(context);
                _autoAssignOrders();
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning),
              title: Text('Signaler problèmes'.tr()),
              subtitle: Text('Identifier les commandes en retard'.tr()),
              onTap: () {
                Navigator.pop(context);
                _flagProblematicOrders();
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download),
              title: Text('Exporter données'.tr()),
              subtitle: Text('Exporter les commandes en CSV'.tr()),
              onTap: () {
                Navigator.pop(context);
                _exportOrders();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleOrderAction(DeliveryOrder order, String action) {
    switch (action) {
      case 'track':
        _trackOrder(order);
        break;
      case 'assign':
        _assignOrder(order);
        break;
      case 'cancel':
        _cancelOrder(order);
        break;
    }
  }

  void _viewOrderDetails(DeliveryOrder order) {
    // TODO: Navigate to detailed order view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Détails de ${order.orderNumber} bientôt disponibles'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _trackOrder(DeliveryOrder order) {
    // TODO: Show order tracking interface
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Suivi de ${order.orderNumber} bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _assignOrder(DeliveryOrder order) {
    // TODO: Show courier assignment interface
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attribution de ${order.orderNumber} bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _cancelOrder(DeliveryOrder order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Annuler ${order.orderNumber}'),
        content: const Text('Voulez-vous vraiment annuler cette commande?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Non'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: Text('Annuler'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AdminService.cancelOrder(order.id, 'Annulé par admin');
        _refreshData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Commande ${order.orderNumber} annulée'.tr()),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'.tr()),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  void _autoAssignOrders() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attribution automatique bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _flagProblematicOrders() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Signalement automatique bientôt disponible'.tr()),
        backgroundColor: AppTheme.warningOrange,
      ),
    );
  }

  void _exportOrders() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export CSV bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  Future<void> _refreshData() async {
    ref.refresh(allOrdersProvider);
    ref.refresh(orderStatsProvider);
    // Refresh all status-specific providers
    for (final status in DeliveryStatus.values) {
      ref.refresh(ordersByStatusProvider(status));
    }
  }
}