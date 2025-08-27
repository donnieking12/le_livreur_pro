import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:le_livreur_pro/core/models/delivery_order_simple.dart';
import 'package:le_livreur_pro/core/models/user.dart' as app_user;
import 'package:le_livreur_pro/core/services/auth_service.dart';
import 'package:le_livreur_pro/core/services/courier_service.dart';
import 'package:le_livreur_pro/core/providers/maps_providers.dart';
import 'package:le_livreur_pro/core/models/maps_models.dart';
import 'package:le_livreur_pro/shared/widgets/maps_widget.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';
import 'package:le_livreur_pro/features/courier/presentation/screens/courier_map_screen.dart';

class CourierDashboardScreen extends ConsumerStatefulWidget {
  const CourierDashboardScreen({super.key});

  @override
  ConsumerState<CourierDashboardScreen> createState() =>
      _CourierDashboardScreenState();
}

class _CourierDashboardScreenState
    extends ConsumerState<CourierDashboardScreen> {
  bool _isOnline = false;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current user profile
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return userProfileAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(
              child: Text('Utilisateur non connecté'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Tableau de Bord Coursier'.tr()),
            backgroundColor: AppTheme.primaryGreen,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(_isOnline ? Icons.location_on : Icons.location_off),
                onPressed: () => _toggleOnlineStatus(user.id),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => _refreshData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCourierStatus(user),
                  const SizedBox(height: 24),
                  if (_isOnline) ...[
                    _buildLocationOverview(),
                    const SizedBox(height: 24),
                  ],
                  _buildTodayStats(user.id),
                  const SizedBox(height: 24),
                  _buildAvailableDeliveries(),
                  const SizedBox(height: 24),
                  _buildActiveOrders(user.id),
                  const SizedBox(height: 24),
                  _buildRecentDeliveries(user.id),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showLocationPermissionDialog(context),
            backgroundColor: AppTheme.primaryGreen,
            icon: const Icon(Icons.gps_fixed),
            label: Text('Mettre à jour position'.tr()),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Erreur: $error'),
        ),
      ),
    );
  }

  Widget _buildCourierStatus(app_user.User user) {
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
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Coursier - ${user.vehicleType ?? "Moto"}'.tr(),
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
                          color: _isOnline
                              ? AppTheme.successGreen
                              : AppTheme.neutralGrey,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isOnline ? 'En ligne'.tr() : 'Hors ligne'.tr(),
                        style: TextStyle(
                          color: _isOnline
                              ? AppTheme.successGreen
                              : AppTheme.neutralGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Switch(
              value: _isOnline,
              onChanged: (value) => _toggleOnlineStatus(user.id),
              activeColor: AppTheme.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStats(String courierId) {
    final statsAsync = ref.watch(courierStatsProvider(courierId));

    return statsAsync.when(
      data: (stats) => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Livraisons'.tr(),
              value: '${stats.todayDeliveries}',
              color: AppTheme.primaryGreen,
              icon: Icons.local_shipping,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Gains'.tr(),
              value: stats.todayEarningsFormatted,
              color: AppTheme.accentOrange,
              icon: Icons.monetization_on,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Évaluation'.tr(),
              value: stats.ratingFormatted,
              color: AppTheme.infoBlue,
              icon: Icons.star,
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
      error: (error, stack) => Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Erreur'.tr(),
              value: '--',
              color: AppTheme.errorRed,
              icon: Icons.error,
            ),
          ),
        ],
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
                fontSize: 20,
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

  Widget _buildActiveOrders(String courierId) {
    final activeOrdersAsync = ref.watch(courierOrdersProvider(courierId));

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
        activeOrdersAsync.when(
          data: (orders) {
            if (orders.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'Aucune livraison active'.tr(),
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
              children:
                  orders.map((order) => _buildActiveOrderCard(order)).toList(),
            );
          },
          loading: () => Column(
            children: List.generate(1, (index) => _buildOrderCardLoading()),
          ),
          error: (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Erreur lors du chargement: $error'.tr(),
                style: const TextStyle(color: AppTheme.errorRed),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableDeliveries() {
    final availableOrdersAsync = ref.watch(availableOrdersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Livraisons disponibles'.tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => ref.refresh(availableOrdersProvider),
              child: Text('Actualiser'.tr()),
            ),
          ],
        ),
        const SizedBox(height: 16),
        availableOrdersAsync.when(
          data: (orders) {
            if (orders.isEmpty) {
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
                          'Aucune livraison disponible'.tr(),
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
              children: orders
                  .take(5)
                  .map((order) => _buildAvailableOrderCard(order))
                  .toList(),
            );
          },
          loading: () => Column(
            children: List.generate(2, (index) => _buildOrderCardLoading()),
          ),
          error: (error, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Erreur lors du chargement: $error'.tr(),
                style: const TextStyle(color: AppTheme.errorRed),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryCard({
    required String orderNumber,
    required String pickupAddress,
    required String deliveryAddress,
    required String amount,
    required String distance,
    required bool isUrgent,
  }) {
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
                  orderNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isUrgent)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.warningOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAddressRow(Icons.location_on, 'Ramassage: $pickupAddress'),
            const SizedBox(height: 8),
            _buildAddressRow(Icons.home, 'Livraison: $deliveryAddress'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Distance',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.neutralGrey,
                        ),
                      ),
                      Text(
                        distance,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Gains',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.neutralGrey,
                        ),
                      ),
                      Text(
                        amount,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryGreen,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                      side: const BorderSide(color: AppTheme.primaryGreen),
                    ),
                    child: Text('Voir détails'.tr()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                    child: Text('Accepter'.tr()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.neutralGrey,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.neutralGrey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentDeliveries(String courierId) {
    return FutureBuilder<List<DeliveryOrder>>(
      future: ref.read(courierServiceProvider).getCourierHistory(courierId),
      builder: (context, snapshot) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Livraisons récentes'.tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (snapshot.connectionState == ConnectionState.waiting)
              ...List.generate(3, (index) => _buildOrderCardLoading())
            else if (snapshot.hasError)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Erreur lors du chargement: ${snapshot.error}'.tr(),
                    style: const TextStyle(color: AppTheme.errorRed),
                  ),
                ),
              )
            else if (!snapshot.hasData || snapshot.data!.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'Aucune livraison récente'.tr(),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              )
            else
              ...snapshot.data!.map((order) => _buildRecentDeliveryItem(
                    orderNumber: order.orderNumber,
                    status: order.status.displayName,
                    amount: '${order.totalPriceXof} XOF',
                    time: DateFormat('HH:mm').format(order.updatedAt),
                  )),
          ],
        );
      },
    );
  }

  Widget _buildRecentDeliveryItem({
    required String orderNumber,
    required String status,
    required String amount,
    required String time,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          status == 'Livré' ? Icons.check_circle : Icons.pending,
          color: status == 'Livré'
              ? AppTheme.successGreen
              : const Color.fromARGB(255, 164, 102, 8),
        ),
        title: Text(orderNumber),
        subtitle: Text('$time - $amount'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(status),
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
      ),
    );
  }

  Color _getStatusColor(dynamic status) {
    if (status is DeliveryStatus) {
      switch (status) {
        case DeliveryStatus.pending:
          return AppTheme.neutralGrey;
        case DeliveryStatus.assigned:
          return AppTheme.infoBlue;
        case DeliveryStatus.courierEnRoute:
          return AppTheme.warningOrange;
        case DeliveryStatus.pickedUp:
        case DeliveryStatus.inTransit:
          return AppTheme.accentOrange;
        case DeliveryStatus.arrivedDestination:
          return AppTheme.warningOrange;
        case DeliveryStatus.delivered:
          return AppTheme.successGreen;
        case DeliveryStatus.cancelled:
          return AppTheme.errorRed;
        case DeliveryStatus.disputed:
          return AppTheme.errorRed;
      }
    }

    // Handle string status for backward compatibility
    switch (status.toString()) {
      case 'En cours':
        return AppTheme.warningOrange;
      case 'Livré':
        return AppTheme.successGreen;
      case 'Annulé':
        return AppTheme.errorRed;
      default:
        return AppTheme.neutralGrey;
    }
  }

  // ==================== EVENT HANDLERS ====================

  Future<void> _toggleOnlineStatus(String courierId) async {
    try {
      final newStatus = !_isOnline;
      final success = await ref
          .read(courierServiceProvider)
          .updateCourierStatus(courierId, newStatus);

      if (success) {
        setState(() {
          _isOnline = newStatus;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isOnline
                  ? 'Vous êtes maintenant en ligne'.tr()
                  : 'Vous êtes maintenant hors ligne'.tr(),
            ),
            backgroundColor:
                _isOnline ? AppTheme.successGreen : AppTheme.neutralGrey,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour du statut: $e'.tr()),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _acceptOrder(DeliveryOrder order) async {
    try {
      final userAsync = ref.read(currentUserProfileProvider);
      final user = userAsync.value;
      if (user == null) return;

      final success =
          await ref.read(courierServiceProvider).acceptOrder(order.id, user.id);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Commande acceptée avec succès'.tr()),
            backgroundColor: AppTheme.successGreen,
          ),
        );

        // Refresh the available orders
        ref.refresh(availableOrdersProvider);
        ref.refresh(courierOrdersProvider(user.id));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'acceptation: $e'.tr()),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  Future<void> _updateOrderStatus(DeliveryOrder order) async {
    try {
      final userAsync = ref.read(currentUserProfileProvider);
      final user = userAsync.value;
      if (user == null) return;

      DeliveryStatus nextStatus;
      switch (order.status) {
        case DeliveryStatus.assigned:
          nextStatus = DeliveryStatus.courierEnRoute;
          break;
        case DeliveryStatus.courierEnRoute:
          nextStatus = DeliveryStatus.pickedUp;
          break;
        case DeliveryStatus.pickedUp:
          nextStatus = DeliveryStatus.inTransit;
          break;
        case DeliveryStatus.inTransit:
          nextStatus = DeliveryStatus.arrivedDestination;
          break;
        case DeliveryStatus.arrivedDestination:
          nextStatus = DeliveryStatus.delivered;
          break;
        default:
          return;
      }

      final success = await ref.read(courierServiceProvider).updateOrderStatus(
            order.id,
            nextStatus,
            latitude: _currentPosition?.latitude,
            longitude: _currentPosition?.longitude,
          );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Statut mis à jour avec succès'.tr()),
            backgroundColor: AppTheme.successGreen,
          ),
        );

        // Refresh orders
        ref.refresh(courierOrdersProvider(user.id));
        ref.refresh(courierStatsProvider(user.id));
      }
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

  String _getNextActionText(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.assigned:
        return 'Démarrer'.tr();
      case DeliveryStatus.courierEnRoute:
        return 'Récupérer'.tr();
      case DeliveryStatus.pickedUp:
        return 'En transit'.tr();
      case DeliveryStatus.inTransit:
        return 'Arrivé'.tr();
      case DeliveryStatus.arrivedDestination:
        return 'Livrer'.tr();
      default:
        return 'Mettre à jour'.tr();
    }
  }

  Future<void> _refreshData() async {
    final userAsync = ref.read(currentUserProfileProvider);
    final user = userAsync.value;
    if (user != null) {
      ref.refresh(courierStatsProvider(user.id));
      ref.refresh(availableOrdersProvider);
      ref.refresh(courierOrdersProvider(user.id));
    }
  }

  void _showLocationPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Autorisation de localisation'.tr()),
        content: Text(
          'Cette application a besoin d\'accès à votre localisation pour suivre vos livraisons en temps réel.'
              .tr(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _requestLocationPermission();
            },
            child: Text('Autoriser'.tr()),
          ),
        ],
      ),
    );
  }

  Future<void> _requestLocationPermission() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        await _initializeLocation();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Localisation activée'.tr()),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Erreur lors de l\'activation de la localisation: $e'.tr()),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
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
              width: 40,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 60,
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

  Widget _buildAvailableOrderCard(DeliveryOrder order) {
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
                if (order.priorityLevel > 1)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: order.priorityLevel == 3
                          ? AppTheme.errorRed
                          : AppTheme.warningOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.priorityLevel == 3 ? 'EXPRESS' : 'URGENT',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAddressRow(Icons.location_on,
                'Ramassage: ${order.pickupAddress ?? "Adresse non disponible"}'),
            const SizedBox(height: 8),
            _buildAddressRow(Icons.home,
                'Livraison: ${order.deliveryAddress ?? "Adresse non disponible"}'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Distance'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.neutralGrey,
                        ),
                      ),
                      Text(
                        '${order.distanceKm.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Gains'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.neutralGrey,
                        ),
                      ),
                      Text(
                        '${order.totalPriceXof} XOF',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryGreen,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showOrderDetails(order),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                      side: const BorderSide(color: AppTheme.primaryGreen),
                    ),
                    child: Text('Voir détails'.tr()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _acceptOrder(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                    child: Text('Accepter'.tr()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveOrderCard(DeliveryOrder order) {
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
            const SizedBox(height: 12),
            _buildAddressRow(Icons.location_on,
                'Ramassage: ${order.pickupAddress ?? "Adresse non disponible"}'),
            const SizedBox(height: 8),
            _buildAddressRow(Icons.home,
                'Livraison: ${order.deliveryAddress ?? "Adresse non disponible"}'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updateOrderStatus(order),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                    child: Text(_getNextActionText(order.status)),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => _showOrderDetails(order),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryGreen,
                    side: const BorderSide(color: AppTheme.primaryGreen),
                  ),
                  child: Text('Détails'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCardLoading() {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 16,
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

  /// Build location overview map showing courier position and delivery zones
  Widget _buildLocationOverview() {
    final currentLocationAsync = ref.watch(currentLocationProvider);
    final deliveryZones = ref.watch(deliveryZonesProvider);

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
                  'Vue d\'ensemble'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => _showFullMapView(),
                  icon: const Icon(Icons.fullscreen),
                  color: AppTheme.primaryGreen,
                ),
              ],
            ),
            const SizedBox(height: 12),
            currentLocationAsync.when(
              data: (position) {
                final currentLocation = position != null
                    ? LatLng(position.latitude, position.longitude)
                    : const LatLng(5.3600, -4.0083); // Default Abidjan

                // Create markers for delivery zones
                final markers = <Marker>{
                  Marker(
                    markerId: const MarkerId('my_location'),
                    position: currentLocation,
                    infoWindow: InfoWindow(
                      title: 'Ma position'.tr(),
                      snippet: 'Position actuelle',
                    ),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue),
                  ),
                };

                // Add delivery zone markers
                for (final zone in deliveryZones) {
                  markers.add(zone.toMarker());
                }

                // Create circles for delivery zones
                final circles =
                    deliveryZones.map((zone) => zone.toCircle()).toSet();

                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.neutralGreyLight),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: MapsWidget(
                      initialCenter: currentLocation,
                      initialZoom: 12.0,
                      markers: markers,
                      circles: circles,
                      showMyLocation: false,
                      showMyLocationButton: false,
                      showZoomControls: false,
                      showCompass: false,
                      showDeliveryZones: true,
                    ),
                  ),
                );
              },
              loading: () => Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryGreen),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chargement de la position...'.tr(),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              error: (error, stack) => Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Position non disponible'.tr(),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _initializeLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                        ),
                        child: Text('Réessayer'.tr()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLocationStat(
                  icon: Icons.location_city,
                  label: 'Zones'.tr(),
                  value: '${deliveryZones.where((z) => z.isActive).length}',
                ),
                _buildLocationStat(
                  icon: Icons.access_time,
                  label: 'En ligne'.tr(),
                  value: _isOnline ? 'Oui'.tr() : 'Non'.tr(),
                ),
                _buildLocationStat(
                  icon: Icons.gps_fixed,
                  label: 'GPS'.tr(),
                  value: currentLocationAsync.hasValue ? 'Actif' : 'Inactif',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryGreen,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
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

  void _showFullMapView() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CourierMapScreen(),
      ),
    );
  }
}
