import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:le_livreur_pro/core/models/delivery_order.dart';
import 'package:le_livreur_pro/core/services/order_service.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';

// Provider for partner orders
final partnerOrdersProvider =
    FutureProvider.family<List<DeliveryOrder>, String>((ref, partnerId) async {
  // TODO: Create proper service method for partner orders
  // For now, use getUserOrders as placeholder
  return await ref.read(orderServiceProvider).getUserOrders(partnerId);
});

class PartnerOrdersScreen extends ConsumerStatefulWidget {
  final String partnerId;

  const PartnerOrdersScreen({
    super.key,
    required this.partnerId,
  });

  @override
  ConsumerState<PartnerOrdersScreen> createState() =>
      _PartnerOrdersScreenState();
}

class _PartnerOrdersScreenState extends ConsumerState<PartnerOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DeliveryStatus? _selectedFilter;

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
        title: Text('Gestion des Commandes'.tr()),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshOrders(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Nouvelles'.tr()),
            Tab(text: 'En cours'.tr()),
            Tab(text: 'Prêtes'.tr()),
            Tab(text: 'Historique'.tr()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrdersList(DeliveryStatus.pending),
          _buildOrdersList(DeliveryStatus.assigned),
          _buildOrdersList(DeliveryStatus.pickedUp),
          _buildOrdersList(null), // All orders for history
        ],
      ),
    );
  }

  Widget _buildOrdersList(DeliveryStatus? statusFilter) {
    final ordersAsync = ref.watch(partnerOrdersProvider(widget.partnerId));

    return RefreshIndicator(
      onRefresh: _refreshOrders,
      child: ordersAsync.when(
        data: (orders) {
          List<DeliveryOrder> filteredOrders;

          if (statusFilter != null) {
            filteredOrders =
                orders.where((order) => order.status == statusFilter).toList();
          } else {
            // History - show completed and cancelled orders
            filteredOrders = orders
                .where((order) =>
                    order.status == DeliveryStatus.delivered ||
                    order.status == DeliveryStatus.cancelled)
                .toList();
          }

          if (filteredOrders.isEmpty) {
            return _buildEmptyState(statusFilter);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredOrders.length,
            itemBuilder: (context, index) {
              final order = filteredOrders[index];
              return _buildOrderCard(order, statusFilter);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
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
                'Erreur lors du chargement: $error'.tr(),
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshOrders,
                child: Text('Réessayer'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(DeliveryStatus? statusFilter) {
    String message;
    IconData icon;

    switch (statusFilter) {
      case DeliveryStatus.pending:
        message = 'Aucune nouvelle commande';
        icon = Icons.inbox;
        break;
      case DeliveryStatus.assigned:
        message = 'Aucune commande en cours';
        icon = Icons.kitchen;
        break;
      case DeliveryStatus.pickedUp:
        message = 'Aucune commande prête';
        icon = Icons.check_circle_outline;
        break;
      default:
        message = 'Aucun historique';
        icon = Icons.history;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              message.tr(),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(DeliveryOrder order, DeliveryStatus? statusFilter) {
    final timeAgo = _getTimeAgo(order.createdAt);
    final canAccept = order.status == DeliveryStatus.pending;
    final canPrepare = order.status == DeliveryStatus.assigned;
    final canMarkReady =
        order.status == DeliveryStatus.assigned; // When preparation is done

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Header
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

            // Order Details
            if (order.orderType == OrderType.marketplace) ...[
              Text(
                'Commande restaurant'.tr(),
                style: const TextStyle(
                  color: AppTheme.neutralGrey,
                  fontSize: 14,
                ),
              ),
            ] else ...[
              Text(
                order.packageDescription ?? 'Livraison de colis',
                style: const TextStyle(
                  color: AppTheme.neutralGrey,
                  fontSize: 14,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Customer Info
            Row(
              children: [
                const Icon(
                  Icons.person,
                  size: 16,
                  color: AppTheme.neutralGrey,
                ),
                const SizedBox(width: 8),
                Text(
                  order.recipientName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppTheme.neutralGrey,
                ),
                const SizedBox(width: 4),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    color: AppTheme.neutralGrey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Delivery Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppTheme.neutralGrey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.deliveryAddress ?? 'Adresse non disponible',
                    style: const TextStyle(
                      color: AppTheme.neutralGrey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Price and Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.totalPriceXof} XOF',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                Row(
                  children: [
                    if (canAccept) ...[
                      OutlinedButton(
                        onPressed: () => _rejectOrder(order),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.errorRed,
                          side: const BorderSide(color: AppTheme.errorRed),
                        ),
                        child: Text('Refuser'.tr()),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _acceptOrder(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                        ),
                        child: Text('Accepter'.tr()),
                      ),
                    ] else if (canPrepare) ...[
                      ElevatedButton(
                        onPressed: () => _markOrderReady(order),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentOrange,
                        ),
                        child: Text('Marquer prêt'.tr()),
                      ),
                    ] else ...[
                      OutlinedButton(
                        onPressed: () => _showOrderDetails(order),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryGreen,
                        ),
                        child: Text('Détails'.tr()),
                      ),
                    ],
                  ],
                ),
              ],
            ),

            // Special Instructions
            if (order.specialInstructions != null &&
                order.specialInstructions!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppTheme.warningOrange.withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppTheme.warningOrange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.specialInstructions!,
                        style: const TextStyle(
                          color: AppTheme.warningOrange,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
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
        return AppTheme.warningOrange;
      case DeliveryStatus.assigned:
        return AppTheme.infoBlue;
      case DeliveryStatus.courierEnRoute:
      case DeliveryStatus.pickedUp:
        return AppTheme.accentOrange;
      case DeliveryStatus.inTransit:
        return AppTheme.primaryGreen;
      case DeliveryStatus.delivered:
        return AppTheme.successGreen;
      case DeliveryStatus.cancelled:
        return AppTheme.errorRed;
      default:
        return AppTheme.neutralGrey;
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

  // ==================== EVENT HANDLERS ====================

  Future<void> _acceptOrder(DeliveryOrder order) async {
    try {
      // TODO: Implement partner order acceptance
      // This would update the order status and notify the customer

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Commande ${order.orderNumber} acceptée'.tr()),
          backgroundColor: AppTheme.successGreen,
        ),
      );

      _refreshOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'acceptation: $e'.tr()),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _rejectOrder(DeliveryOrder order) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Refuser la commande'.tr()),
        content: Text('Voulez-vous vraiment refuser cette commande?'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: Text('Refuser'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // TODO: Implement partner order rejection
        await ref.read(orderServiceProvider).cancelOrder(
              order.id,
              'Refusé par le partenaire',
            );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Commande ${order.orderNumber} refusée'.tr()),
            backgroundColor: AppTheme.warningOrange,
          ),
        );

        _refreshOrders();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du refus: $e'.tr()),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _markOrderReady(DeliveryOrder order) async {
    try {
      // TODO: Implement marking order as ready for pickup
      // This would change status to indicate the order is ready for courier pickup

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Commande ${order.orderNumber} marquée comme prête'.tr()),
          backgroundColor: AppTheme.successGreen,
        ),
      );

      _refreshOrders();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour: $e'.tr()),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
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
                    _buildDetailRow('Client'.tr(), order.recipientName),
                    _buildDetailRow('Téléphone'.tr(), order.recipientPhone),
                    _buildDetailRow('Adresse de livraison'.tr(),
                        order.deliveryAddress ?? 'Non spécifié'),
                    if (order.specialInstructions != null)
                      _buildDetailRow(
                          'Instructions'.tr(), order.specialInstructions!),
                    _buildDetailRow(
                        'Créé le'.tr(),
                        DateFormat('dd/MM/yyyy à HH:mm')
                            .format(order.createdAt)),
                    if (order.estimatedDeliveryTime != null)
                      _buildDetailRow(
                          'Livraison estimée'.tr(),
                          DateFormat('dd/MM/yyyy à HH:mm')
                              .format(order.estimatedDeliveryTime!)),
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
            width: 120,
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

  Future<void> _refreshOrders() async {
    ref.refresh(partnerOrdersProvider(widget.partnerId));
  }
}
