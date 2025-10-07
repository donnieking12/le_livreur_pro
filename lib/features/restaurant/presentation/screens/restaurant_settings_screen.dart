import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:le_livreur_pro/core/models/restaurant.dart';
import 'package:le_livreur_pro/core/services/restaurant_service.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';

// Provider for restaurant data
final restaurantProvider =
    FutureProvider.family<Restaurant?, String>((ref, restaurantId) async {
  return await RestaurantService.getRestaurantById(restaurantId);
});

class RestaurantSettingsScreen extends ConsumerStatefulWidget {
  final String restaurantId;

  const RestaurantSettingsScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  ConsumerState<RestaurantSettingsScreen> createState() =>
      _RestaurantSettingsScreenState();
}

class _RestaurantSettingsScreenState
    extends ConsumerState<RestaurantSettingsScreen>
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
    final restaurantAsync = ref.watch(restaurantProvider(widget.restaurantId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Paramètres du Restaurant'.tr()),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
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
            Tab(text: 'Informations'.tr()),
            Tab(text: 'Horaires'.tr()),
            Tab(text: 'Livraison'.tr()),
            Tab(text: 'Préférences'.tr()),
          ],
        ),
      ),
      body: restaurantAsync.when(
        data: (restaurant) => restaurant != null
            ? TabBarView(
                controller: _tabController,
                children: [
                  _buildRestaurantInfoTab(restaurant),
                  _buildOperatingHoursTab(restaurant),
                  _buildDeliverySettingsTab(restaurant),
                  _buildPreferencesTab(restaurant),
                ],
              )
            : _buildNotFoundState(),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildRestaurantInfoTab(Restaurant restaurant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBasicInfoSection(restaurant),
          const SizedBox(height: 24),
          _buildContactInfoSection(restaurant),
          const SizedBox(height: 24),
          _buildLocationSection(restaurant),
          const SizedBox(height: 24),
          _buildBrandingSection(restaurant),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(Restaurant restaurant) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations de base'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoTile(
              'Nom du restaurant'.tr(),
              restaurant.name,
              Icons.restaurant,
              onEdit: () =>
                  _editField('name', restaurant.name, 'Nom du restaurant'),
            ),
            _buildInfoTile(
              'Description'.tr(),
              restaurant.description,
              Icons.description,
              onEdit: () => _editField(
                  'description', restaurant.description, 'Description'),
            ),
            _buildInfoTile(
              'Types de cuisine'.tr(),
              restaurant.cuisineTypes.join(', '),
              Icons.local_dining,
              onEdit: () => _editCuisineTypes(restaurant.cuisineTypes),
            ),
            _buildInfoTile(
              'Catégories'.tr(),
              restaurant.categories.join(', '),
              Icons.category,
              onEdit: () => _editCategories(restaurant.categories),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoSection(Restaurant restaurant) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations de contact'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoTile(
              'Téléphone professionnel'.tr(),
              restaurant.businessPhone ?? 'Non renseigné'.tr(),
              Icons.phone,
              onEdit: () => _editField('business_phone',
                  restaurant.businessPhone, 'Téléphone professionnel'),
            ),
            _buildInfoTile(
              'Email professionnel'.tr(),
              restaurant.businessEmail ?? 'Non renseigné'.tr(),
              Icons.email,
              onEdit: () => _editField('business_email',
                  restaurant.businessEmail, 'Email professionnel'),
            ),
            _buildInfoTile(
              'Adresse'.tr(),
              restaurant.businessAddress,
              Icons.location_on,
              onEdit: () => _editField(
                  'business_address', restaurant.businessAddress, 'Adresse'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection(Restaurant restaurant) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Localisation'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoTile(
              'Latitude'.tr(),
              restaurant.latitude.toString(),
              Icons.gps_fixed,
              onEdit: () =>
                  _editLocation(restaurant.latitude, restaurant.longitude),
            ),
            _buildInfoTile(
              'Longitude'.tr(),
              restaurant.longitude.toString(),
              Icons.gps_fixed,
              onEdit: () =>
                  _editLocation(restaurant.latitude, restaurant.longitude),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _updateLocation(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.infoBlue,
                ),
                icon: const Icon(Icons.my_location),
                label: Text('Mettre à jour la localisation'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandingSection(Restaurant restaurant) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Image de marque'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildImageSection(
                    'Logo'.tr(),
                    restaurant.logoUrl,
                    Icons.image,
                    () {}, // Empty callback for now
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildImageSection(
                    'Bannière'.tr(),
                    restaurant.bannerUrl,
                    Icons.panorama,
                    () {}, // Empty callback for now
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(
      String title, String? imageUrl, IconData icon, VoidCallback onUpload) {
    return Column(
      children: [
        Container(
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) =>
                        Icon(icon, size: 40, color: Colors.grey[400]),
                  ),
                )
              : Icon(icon, size: 40, color: Colors.grey[400]),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        TextButton(
          onPressed: onUpload,
          child: Text('Modifier'.tr()),
        ),
      ],
    );
  }

  Widget _buildOperatingHoursTab(Restaurant restaurant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Horaires d\'ouverture'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // TODO: Implement operating hours management
                  Text(
                    'Configuration des horaires bientôt disponible'.tr(),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverySettingsTab(Restaurant restaurant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDeliveryConfigSection(restaurant),
          const SizedBox(height: 24),
          _buildPricingSection(restaurant),
        ],
      ),
    );
  }

  Widget _buildDeliveryConfigSection(Restaurant restaurant) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration de livraison'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text('Accepter les commandes'.tr()),
              subtitle: Text('Activer/désactiver les commandes'.tr()),
              value: restaurant.acceptsOrders,
              onChanged: (value) =>
                  _updateRestaurantField('accepts_orders', value),
              activeThumbColor: AppTheme.primaryGreen,
            ),
            _buildInfoTile(
              'Temps de préparation'.tr(),
              '${restaurant.preparationTimeMinutes} minutes',
              Icons.timer,
              onEdit: () => _editField(
                'preparation_time_minutes',
                restaurant.preparationTimeMinutes.toString(),
                'Temps de préparation (minutes)',
                isNumeric: true,
              ),
            ),
            _buildInfoTile(
              'Commande minimum'.tr(),
              '${restaurant.minimumOrderXof} XOF',
              Icons.shopping_cart,
              onEdit: () => _editField(
                'minimum_order_xof',
                restaurant.minimumOrderXof.toString(),
                'Commande minimum (XOF)',
                isNumeric: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingSection(Restaurant restaurant) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tarification'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoTile(
              'Frais de livraison'.tr(),
              '${restaurant.deliveryFeeXof} XOF',
              Icons.delivery_dining,
              onEdit: () => _editField(
                'delivery_fee_xof',
                restaurant.deliveryFeeXof.toString(),
                'Frais de livraison (XOF)',
                isNumeric: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesTab(Restaurant restaurant) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Préférences'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: Text('Restaurant actif'.tr()),
                    subtitle: Text('Visible dans l\'application'.tr()),
                    value: restaurant.isActive,
                    onChanged: (value) =>
                        _updateRestaurantField('is_active', value),
                    activeThumbColor: AppTheme.primaryGreen,
                  ),
                  ListTile(
                    title: Text('Statut de vérification'.tr()),
                    subtitle: Text(
                      restaurant.isVerified
                          ? 'Vérifié'.tr()
                          : 'En attente de vérification'.tr(),
                    ),
                    leading: Icon(
                      restaurant.isVerified ? Icons.verified : Icons.pending,
                      color: restaurant.isVerified
                          ? AppTheme.successGreen
                          : AppTheme.warningOrange,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value, IconData icon,
      {VoidCallback? onEdit}) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGreen),
      title: Text(title),
      subtitle: Text(value),
      trailing: onEdit != null
          ? IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            )
          : null,
    );
  }

  Widget _buildNotFoundState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Restaurant non trouvé'.tr(),
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

  // ==================== EVENT HANDLERS ====================

  void _editField(String field, String? currentValue, String label,
      {bool isNumeric = false}) {
    final controller = TextEditingController(text: currentValue ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier $label'.tr()),
        content: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          maxLines: field == 'description' ? 3 : 1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                final updateValue = isNumeric ? int.tryParse(value) : value;
                if (updateValue != null) {
                  _updateRestaurantField(field, updateValue);
                  Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen),
            child: Text('Enregistrer'.tr()),
          ),
        ],
      ),
    );
  }

  void _editCuisineTypes(List<String> currentTypes) {
    // TODO: Implement cuisine types editor
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Éditeur de types de cuisine bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _editCategories(List<String> currentCategories) {
    // TODO: Implement categories editor
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Éditeur de catégories bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _editLocation(double latitude, double longitude) {
    // TODO: Implement location picker
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sélecteur de localisation bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _updateLocation() {
    // TODO: Implement GPS location update
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mise à jour GPS bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _uploadImage(String type) {
    // TODO: Implement image upload
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Upload d\'image bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _updateRestaurantField(String field, dynamic value) async {
    try {
      await RestaurantService.updateRestaurant(
          widget.restaurantId, {field: value});
      _refreshData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mise à jour effectuée avec succès'.tr()),
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

  void _refreshData() {
    ref.refresh(restaurantProvider(widget.restaurantId));
  }
}
