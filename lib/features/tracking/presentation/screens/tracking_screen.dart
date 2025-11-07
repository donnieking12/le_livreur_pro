import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:le_livreur_pro/core/models/delivery_order.dart';
import 'package:le_livreur_pro/core/services/auth_service.dart';
import 'package:le_livreur_pro/core/services/order_service.dart';
import 'package:le_livreur_pro/core/providers/maps_providers.dart';
import 'package:le_livreur_pro/core/models/maps_models.dart';
import 'package:le_livreur_pro/shared/widgets/maps_widget.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  final _trackingController = TextEditingController();
  DeliveryOrder? _trackedOrder;
  bool _isSearching = false;

  @override
  void dispose() {
    _trackingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return userProfileAsync.when(
      data: (user) {
        if (user == null) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Suivi de Livraison'.tr()),
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
            title: Text('Suivi de Livraison'.tr()),
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
          ),
          body: RefreshIndicator(
            onRefresh: () => _refreshData(user.id),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTrackingSearch(),
                  const SizedBox(height: 24),
                  if (_trackedOrder != null) ...[
                    _buildTrackedOrderDetails(),
                    const SizedBox(height: 24),
                  ],
                  _buildActiveDeliveries(user.id),
                  const SizedBox(height: 24),
                  _buildTrackingHistory(user.id),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: Text('Suivi de Livraison'.tr()),
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: Text('Suivi de Livraison'.tr()),
          backgroundColor: AppTheme.primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text('Erreur: $error'),
        ),
      ),
    );
  }

  Widget _buildTrackingSearch() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suivre une livraison'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _trackingController,
                    decoration: InputDecoration(
                      hintText: 'Numéro de commande (ex: CMD-2024-001)'.tr(),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (_) => _trackOrder(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isSearching ? null : _trackOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                  ),
                  child: _isSearching
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text('Suivre'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveDeliveries(String userId) {
    final userOrdersAsync = ref.watch(userOrdersProvider(userId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Livraisons actives'.tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        userOrdersAsync.when(
          data: (orders) {
            final activeOrders =
                orders.where((order) => order.status.isActive).toList();

            if (activeOrders.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Aucune livraison active'.tr(),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: activeOrders
                  .map((order) => _buildRealDeliveryCard(order))
                  .toList(),
            );
          },
          loading: () => Column(
            children: List.generate(2, (index) => _buildDeliveryCardLoading()),
          ),
          error: (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Erreur lors du chargement des livraisons: $error'.tr(),
                style: const TextStyle(color: AppTheme.errorRed),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRealDeliveryCard(DeliveryOrder order) {
    final timeAgo = _getTimeAgo(order.createdAt);
    final estimatedTime = _getEstimatedDeliveryTime(order);

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
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status),
                    borderRadius: BorderRadius.circular(16),
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
              order.packageDescription ?? 'Livraison de colis',
              style: const TextStyle(
                color: AppTheme.neutralGrey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            _buildTrackingSteps(order.status),
            const SizedBox(height: 16),
            Row(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryGreen,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.courierId != null
                            ? 'Coursier assigné'
                            : 'En attente d\'assignation',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        estimatedTime,
                        style: const TextStyle(
                          color: AppTheme.neutralGrey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                if (order.courierId != null)
                  IconButton(
                    onPressed: () => _contactCourier(order),
                    icon: const Icon(Icons.phone),
                    color: AppTheme.primaryGreen,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackedOrderDetails() {
    if (_trackedOrder == null) return const SizedBox.shrink();

    return Card(
      color: AppTheme.primaryGreen.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.track_changes,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Commande suivie'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Add real-time map for tracked order
            _buildOrderTrackingMap(_trackedOrder!),
            const SizedBox(height: 16),

            _buildRealDeliveryCard(_trackedOrder!),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _trackedOrder = null),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                    ),
                    child: Text('Fermer'.tr()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showOrderDetails(_trackedOrder!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                    child: Text('Détails complets'.tr()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingSteps(DeliveryStatus currentStatus) {
    final steps = [
      {
        'title': 'Commande confirmée',
        'status': DeliveryStatus.pending,
        'icon': Icons.check_circle
      },
      {
        'title': 'Coursier assigné',
        'status': DeliveryStatus.assigned,
        'icon': Icons.person_add
      },
      {
        'title': 'En route vers ramassage',
        'status': DeliveryStatus.courierEnRoute,
        'icon': Icons.directions_run
      },
      {
        'title': 'Colis récupéré',
        'status': DeliveryStatus.pickedUp,
        'icon': Icons.inventory
      },
      {
        'title': 'En transit',
        'status': DeliveryStatus.inTransit,
        'icon': Icons.local_shipping
      },
      {
        'title': 'Arrivé à destination',
        'status': DeliveryStatus.arrivedDestination,
        'icon': Icons.location_on
      },
      {
        'title': 'Livré',
        'status': DeliveryStatus.delivered,
        'icon': Icons.home
      },
    ];

    // Determine which steps are completed
    final currentIndex =
        steps.indexWhere((step) => step['status'] == currentStatus);

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;
        final isLast = index == steps.length - 1;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.successGreen
                      : isCurrent
                          ? AppTheme.warningOrange
                          : AppTheme.neutralGreyLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  step['icon'] as IconData,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step['title'] as String,
                  style: TextStyle(
                    color: isCompleted
                        ? AppTheme.neutralGreyDark
                        : isCurrent
                            ? AppTheme.warningOrange
                            : AppTheme.neutralGreyLight,
                    fontWeight: isCompleted || isCurrent
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrackingHistory(String userId) {
    final recentOrdersAsync = ref.watch(recentOrdersProvider(userId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historique des livraisons'.tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        recentOrdersAsync.when(
          data: (orders) {
            final completedOrders = orders
                .where((order) =>
                    order.status == DeliveryStatus.delivered ||
                    order.status == DeliveryStatus.cancelled)
                .take(5)
                .toList();

            if (completedOrders.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'Aucun historique de livraison'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: completedOrders
                  .map((order) => _buildHistoryItem(
                        orderNumber: order.orderNumber,
                        status: order.status.displayName,
                        date: _getTimeAgo(order.updatedAt),
                        time: DateFormat('HH:mm').format(order.updatedAt),
                        order: order,
                      ))
                  .toList(),
            );
          },
          loading: () => Column(
            children: List.generate(3, (index) => _buildDeliveryCardLoading()),
          ),
          error: (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Erreur lors du chargement de l\'historique: $error'.tr(),
                style: const TextStyle(color: AppTheme.errorRed),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem({
    required String orderNumber,
    required String status,
    required String date,
    required String time,
    DeliveryOrder? order,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          status == 'Livré' ? Icons.check_circle : Icons.cancel,
          color: status == 'Livré' ? AppTheme.successGreen : AppTheme.errorRed,
        ),
        title: Text(orderNumber),
        subtitle: Text('$date à $time'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color:
                status == 'Livré' ? AppTheme.successGreen : AppTheme.errorRed,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            status,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: order != null ? () => _showOrderDetails(order) : null,
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
        return AppTheme.primaryOrange;
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

  String _getEstimatedDeliveryTime(DeliveryOrder order) {
    if (order.estimatedDeliveryTime != null) {
      final estimatedTime = order.estimatedDeliveryTime!;
      final now = DateTime.now();
      final difference = estimatedTime.difference(now);

      if (difference.isNegative) {
        return 'En retard';
      } else if (difference.inMinutes < 60) {
        return 'Arrivée estimée: ${difference.inMinutes} min';
      } else {
        return 'Arrivée estimée: ${DateFormat('HH:mm').format(estimatedTime)}';
      }
    }

    // Default estimation based on status
    switch (order.status) {
      case DeliveryStatus.pending:
        return 'En attente d\'assignation';
      case DeliveryStatus.assigned:
      case DeliveryStatus.courierEnRoute:
        return 'Arrivée estimée: 30-45 min';
      case DeliveryStatus.pickedUp:
      case DeliveryStatus.inTransit:
        return 'Arrivée estimée: 15-30 min';
      case DeliveryStatus.arrivedDestination:
        return 'Le coursier est arrivé';
      case DeliveryStatus.delivered:
        return 'Livré';
      case DeliveryStatus.cancelled:
        return 'Annulé';
      case DeliveryStatus.disputed:
        return 'En litige';
    }
  }

  Widget _buildDeliveryCardLoading() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== EVENT HANDLERS ====================

  Future<void> _trackOrder() async {
    final orderNumber = _trackingController.text.trim();
    if (orderNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez saisir un numéro de commande'.tr()),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() => _isSearching = true);

    try {
      // Get all user orders and find the one with matching order number
      final userAsync = ref.read(currentUserProfileProvider);
      final user = userAsync.value;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final orders =
          await ref.read(orderServiceProvider).getUserOrders(user.id);
      final foundOrder = orders
          .where((order) =>
              order.orderNumber.toLowerCase() == orderNumber.toLowerCase())
          .firstOrNull;

      if (foundOrder != null) {
        setState(() {
          _trackedOrder = foundOrder;
          _isSearching = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Commande trouvée !'.tr()),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      } else {
        setState(() => _isSearching = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Commande non trouvée. Vérifiez le numéro.'.tr()),
            backgroundColor: AppTheme.warningOrange,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSearching = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la recherche: $e'.tr()),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _contactCourier(DeliveryOrder order) async {
    // TODO: Get courier phone number from database
    const courierPhone = '+2250700000000'; // Placeholder

    final Uri phoneUri = Uri(scheme: 'tel', path: courierPhone);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible d\'appeler le coursier'.tr()),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
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

  Future<void> _refreshData(String userId) async {
    ref.refresh(userOrdersProvider(userId));
    ref.refresh(recentOrdersProvider(userId));
  }

  /// Build real-time tracking map for the tracked order
  Widget _buildOrderTrackingMap(DeliveryOrder order) {
    // Use the actual coordinate fields from DeliveryOrder
    final pickupCoords = LatLng(order.pickupLatitude, order.pickupLongitude);
    final deliveryCoords =
        LatLng(order.deliveryLatitude, order.deliveryLongitude);

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('pickup'),
        position: pickupCoords,
        infoWindow: InfoWindow(
          title: 'Point de ramassage'.tr(),
          snippet: order.pickupAddress ?? '',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId('delivery'),
        position: deliveryCoords,
        infoWindow: InfoWindow(
          title: 'Point de livraison'.tr(),
          snippet: order.deliveryAddress ?? '',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    // Add courier location if available and order is active
    if (order.courierId != null && order.status.isActive) {
      final courierLocationAsync = ref.watch(courierLocationProvider);

      courierLocationAsync.when(
        data: (courierLocation) {
          markers.add(
            Marker(
              markerId: const MarkerId('courier'),
              position:
                  LatLng(courierLocation.latitude, courierLocation.longitude),
              infoWindow: InfoWindow(
                title: 'Coursier'.tr(),
                snippet: 'Position actuelle',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
            ),
          );
                },
        loading: () {
          // Handle loading state if needed
        },
        error: (error, stack) {
          // Handle error state if needed
        },
      );
    }

    // Get route if order is active
    final Set<Polyline> polylines = {};
    if (order.status.isActive) {
      final routeAsync = ref.watch(routeProvider(RouteRequest(
        origin: pickupCoords,
        destination: deliveryCoords,
      )));

      routeAsync.whenData((route) {
        polylines.add(route.toPolyline(
          color: AppTheme.primaryGreen,
          id: 'delivery_route',
        ));
      });
    }

    return Container(
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.neutralGreyLight),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: MapsWidget(
          initialCenter: pickupCoords,
          initialZoom: 13.0,
          markers: markers,
          polylines: polylines,
          showMyLocation: false,
          showMyLocationButton: false,
          showZoomControls: true,
          showCompass: true,
          onMapCreated: (controller) {
            // Auto-fit the map to show both pickup and delivery points
            Future.delayed(const Duration(milliseconds: 500), () {
              controller.animateCamera(
                CameraUpdate.newLatLngBounds(
                  LatLngBounds(
                    southwest: LatLng(
                      [pickupCoords.latitude, deliveryCoords.latitude]
                          .reduce((a, b) => a < b ? a : b),
                      [pickupCoords.longitude, deliveryCoords.longitude]
                          .reduce((a, b) => a < b ? a : b),
                    ),
                    northeast: LatLng(
                      [pickupCoords.latitude, deliveryCoords.latitude]
                          .reduce((a, b) => a > b ? a : b),
                      [pickupCoords.longitude, deliveryCoords.longitude]
                          .reduce((a, b) => a > b ? a : b),
                    ),
                  ),
                  100.0,
                ),
              );
            });
          },
        ),
      ),
    );
  }

  /// Parse coordinates from string format "lat,lng"
  LatLng? _parseCoordinates(String? coordinates) {
    if (coordinates == null || coordinates.isEmpty) return null;

    try {
      final parts = coordinates.split(',');
      if (parts.length == 2) {
        final lat = double.parse(parts[0].trim());
        final lng = double.parse(parts[1].trim());
        return LatLng(lat, lng);
      }
    } catch (e) {
      debugPrint('Error parsing coordinates: $e');
    }

    return null;
  }
}
