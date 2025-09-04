import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:le_livreur_pro/core/models/delivery_order.dart';
import 'package:le_livreur_pro/core/services/auth_service.dart';
import 'package:le_livreur_pro/core/services/order_service.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  DeliveryStatus? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return userProfileAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Mes Commandes'.tr()),
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Text('Utilisateur non connecté'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Mes Commandes'.tr()),
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _refreshOrders(user.id),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => _refreshOrders(user.id),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderStats(user.id),
                  const SizedBox(height: 24),
                  _buildOrderFilters(),
                  const SizedBox(height: 20),
                  _buildOrdersList(user.id),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text('Mes Commandes'.tr()),
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: Text('Mes Commandes'.tr()),
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text('Erreur: $error'),
        ),
      ),
    );
  }

  Widget _buildOrderStats(String userId) {
    final orderStatsAsync = ref.watch(orderStatsProvider(userId));

    return orderStatsAsync.when(
      data: (stats) => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Total'.tr(),
              value: '${stats.totalOrders}',
              color: AppTheme.primaryGreen,
              icon: Icons.shopping_bag,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'En cours'.tr(),
              value: '${stats.activeOrders}',
              color: AppTheme.warningOrange,
              icon: Icons.pending,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Livrés'.tr(),
              value: '${stats.completedOrders}',
              color: AppTheme.successGreen,
              icon: Icons.check_circle,
            ),
          ),
        ],
      ),
      loading: () => Row(
        children: [
          Expanded(child: _buildStatCardLoading()),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCardLoading()),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCardLoading()),
        ],
      ),
      error: (error, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Erreur lors du chargement des statistiques: $error'.tr(),
            style: const TextStyle(color: AppTheme.errorRed),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.neutralGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCardLoading() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 60,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 80,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderFilters() {
    return Row(
      children: [
        Expanded(
          child: _buildFilterChip('Tous'.tr(), _selectedFilter == null),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFilterChip(
              'En cours'.tr(), _selectedFilter?.isActive == true),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFilterChip(
              'Livrés'.tr(), _selectedFilter == DeliveryStatus.delivered),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFilterChip(
              'Annulés'.tr(), _selectedFilter == DeliveryStatus.cancelled),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (label == 'Tous'.tr()) {
            _selectedFilter = null;
          } else if (label == 'En cours'.tr()) {
            _selectedFilter =
                DeliveryStatus.pending; // Represents active orders
          } else if (label == 'Livrés'.tr()) {
            _selectedFilter = DeliveryStatus.delivered;
          } else if (label == 'Annulés'.tr()) {
            _selectedFilter = DeliveryStatus.cancelled;
          }
        });
      },
      selectedColor: AppTheme.primaryGreen,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.neutralGrey,
      ),
    );
  }

  Widget _buildOrdersList(String userId) {
    final userOrdersAsync = ref.watch(userOrdersProvider(userId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Commandes récentes'.tr(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        userOrdersAsync.when(
          data: (orders) {
            if (orders.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune commande'.tr(),
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vous n\'avez pas encore passé de commande'.tr(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Filter orders based on selected filter
            List<DeliveryOrder> filteredOrders = orders;
            if (_selectedFilter != null) {
              if (_selectedFilter!.isActive) {
                filteredOrders =
                    orders.where((order) => order.status.isActive).toList();
              } else {
                filteredOrders = orders
                    .where((order) => order.status == _selectedFilter)
                    .toList();
              }
            }

            return Column(
              children: filteredOrders
                  .map((order) => _buildOrderItem(order))
                  .toList(),
            );
          },
          loading: () => Column(
            children: List.generate(3, (index) => _buildOrderItemLoading()),
          ),
          error: (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Erreur lors du chargement des commandes: $error'.tr(),
                style: const TextStyle(color: AppTheme.errorRed),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItemLoading() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 120,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                Container(
                  width: 60,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Container(
                  width: 80,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(DeliveryOrder order) {
    final isActive = order.status.isActive;
    final timeAgo = _getTimeAgo(order.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.status.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              order.orderType == OrderType.package
                  ? order.packageDescription ?? 'Livraison de colis'
                  : 'Commande restaurant',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.neutralGrey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Montant'.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.neutralGrey,
                      ),
                    ),
                    Text(
                      '${order.totalPriceXof} XOF',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Date'.tr(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.neutralGrey,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (isActive) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showOrderDetails(order),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryGreen,
                        side: const BorderSide(color: AppTheme.primaryGreen),
                      ),
                      child: Text('Suivre'.tr()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _cancelOrder(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.errorRed,
                      ),
                      child: Text('Annuler'.tr()),
                    ),
                  ),
                ],
              ),
            ] else if (order.status == DeliveryStatus.delivered) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showOrderDetails(order),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryGreen,
                        side: const BorderSide(color: AppTheme.primaryGreen),
                      ),
                      child: Text('Détails'.tr()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _rateOrder(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentOrange,
                      ),
                      child: Text('Évaluer'.tr()),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return AppTheme.neutralGrey;
      case DeliveryStatus.assigned:
        return AppTheme.infoBlue;
      case DeliveryStatus.courierEnRoute:
      case DeliveryStatus.pickedUp:
      case DeliveryStatus.inTransit:
        return AppTheme.warningOrange;
      case DeliveryStatus.arrivedDestination:
        return AppTheme.accentOrange;
      case DeliveryStatus.delivered:
        return AppTheme.successGreen;
      case DeliveryStatus.cancelled:
        return AppTheme.errorRed;
      case DeliveryStatus.disputed:
        return AppTheme.errorRed;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? "s" : ""}';
    } else if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? "s" : ""}';
    } else if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? "s" : ""}';
    } else {
      return 'Il y a quelques instants';
    }
  }

  Future<void> _refreshOrders(String userId) async {
    ref.refresh(userOrdersProvider(userId));
    ref.refresh(orderStatsProvider(userId));
  }

  void _showOrderDetails(DeliveryOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Détails de la commande'.tr(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildDetailRow('Numéro'.tr(), order.orderNumber),
                    _buildDetailRow(
                        'Type'.tr(),
                        order.orderType == OrderType.package
                            ? 'Colis'
                            : 'Restaurant'),
                    _buildDetailRow('Statut'.tr(), order.status.displayName),
                    _buildDetailRow(
                        'Montant'.tr(), '${order.totalPriceXof} XOF'),
                    _buildDetailRow('Distance'.tr(),
                        '${order.distanceKm.toStringAsFixed(1)} km'),
                    _buildDetailRow('Ramassage'.tr(),
                        order.pickupAddress ?? 'Non spécifié'),
                    _buildDetailRow('Livraison'.tr(),
                        order.deliveryAddress ?? 'Non spécifié'),
                    _buildDetailRow('Destinataire'.tr(), order.recipientName),
                    _buildDetailRow('Téléphone'.tr(), order.recipientPhone),
                    if (order.specialInstructions != null)
                      _buildDetailRow(
                          'Instructions'.tr(), order.specialInstructions!),
                    _buildDetailRow(
                        'Créé le'.tr(),
                        DateFormat('dd/MM/yyyy à HH:mm')
                            .format(order.createdAt)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.neutralGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _cancelOrder(DeliveryOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Annuler la commande'.tr()),
        content: Text('Voulez-vous vraiment annuler cette commande?'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Non'.tr()),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref.read(orderServiceProvider).cancelOrder(
                    order.id,
                    'Annulé par le client',
                  );

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Commande annulée avec succès'.tr()),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );

                // Refresh orders
                final userAsync = ref.read(currentUserProfileProvider);
                final user = userAsync.value;
                if (user != null) {
                  _refreshOrders(user.id);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur lors de l\'annulation'.tr()),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: Text('Oui, annuler'.tr()),
          ),
        ],
      ),
    );
  }

  void _rateOrder(DeliveryOrder order) {
    // TODO: Implement rating dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Évaluation bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }
}
