import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:le_livreur_pro/core/models/restaurant.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Restaurant> _favoriteRestaurants = [];
  List<String> _favoriteAddresses = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadFavorites() {
    // Load demo favorites - in real app this would come from database
    _favoriteRestaurants = [
      Restaurant(
        id: 'rest-1',
        name: 'Restaurant Chez Mama',
        cuisine: 'Ivoirienne',
        address: 'Plateau, Abidjan',
        latitude: 5.3200,
        longitude: -4.0100,
        rating: 4.8,
        deliveryTime: '25-35 min',
        deliveryFee: 1000,
        imageUrl: 'https://example.com/restaurant1.jpg',
        isOpen: true,
        categories: ['Traditionnel', 'Grillades'],
      ),
      Restaurant(
        id: 'rest-2',
        name: 'Pizza Palace',
        cuisine: 'Italienne',
        address: 'Cocody, Abidjan',
        latitude: 5.3500,
        longitude: -3.9900,
        rating: 4.5,
        deliveryTime: '20-30 min',
        deliveryFee: 800,
        imageUrl: 'https://example.com/restaurant2.jpg',
        isOpen: true,
        categories: ['Pizza', 'Pâtes'],
      ),
    ];

    _favoriteAddresses = [
      'Plateau, Immeuble BCEAO, 2ème étage',
      'Cocody, Riviera 2, Villa 123',
      'Marcory, Zone 4, Résidence Les Palmiers',
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('favorites_title'.tr()),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'restaurants'.tr(), icon: const Icon(Icons.restaurant)),
            Tab(text: 'addresses'.tr(), icon: const Icon(Icons.location_on)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFavoriteRestaurants(),
          _buildFavoriteAddresses(),
        ],
      ),
    );
  }

  Widget _buildFavoriteRestaurants() {
    if (_favoriteRestaurants.isEmpty) {
      return _buildEmptyState(
        'no_favorite_restaurants'.tr(),
        Icons.restaurant_menu,
        'add_restaurants_to_favorites'.tr(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favoriteRestaurants.length,
      itemBuilder: (context, index) {
        final restaurant = _favoriteRestaurants[index];
        return _buildRestaurantCard(restaurant);
      },
    );
  }

  Widget _buildFavoriteAddresses() {
    if (_favoriteAddresses.isEmpty) {
      return _buildEmptyState(
        'no_favorite_addresses'.tr(),
        Icons.location_off,
        'add_addresses_to_favorites'.tr(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _favoriteAddresses.length,
      itemBuilder: (context, index) {
        final address = _favoriteAddresses[index];
        return _buildAddressCard(address, index);
      },
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.restaurant, size: 32),
          ),
        ),
        title: Text(
          restaurant.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${restaurant.cuisine} • ${restaurant.address}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                Text(' ${restaurant.rating}'),
                const SizedBox(width: 16),
                Icon(Icons.access_time, color: Colors.grey, size: 16),
                Text(' ${restaurant.deliveryTime}'),
                const SizedBox(width: 16),
                Text('${restaurant.deliveryFee} XOF'),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          onPressed: () => _removeFavoriteRestaurant(restaurant),
        ),
        onTap: () => _viewRestaurant(restaurant),
      ),
    );
  }

  Widget _buildAddressCard(String address, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.location_on, color: Colors.white),
        ),
        title: Text(
          _getAddressLabel(index),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(address),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'use':
                _useAddress(address);
                break;
              case 'edit':
                _editAddress(address, index);
                break;
              case 'remove':
                _removeFavoriteAddress(index);
                break;
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'use',
              child: Row(
                children: [
                  const Icon(Icons.send),
                  const SizedBox(width: 8),
                  Text('use_for_delivery'.tr()),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit),
                  const SizedBox(width: 8),
                  Text('edit_address'.tr()),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  const Icon(Icons.delete, color: Colors.red),
                  const SizedBox(width: 8),
                  Text('remove_from_favorites'.tr(), style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, IconData icon, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getAddressLabel(int index) {
    switch (index) {
      case 0:
        return 'work_address'.tr();
      case 1:
        return 'home_address'.tr();
      default:
        return 'saved_address_num'.tr(args: [(index + 1).toString()]);
    }
  }

  void _removeFavoriteRestaurant(Restaurant restaurant) {
    setState(() {
      _favoriteRestaurants.remove(restaurant);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('restaurant_removed_from_favorites'.tr()),
        action: SnackBarAction(
          label: 'undo'.tr(),
          onPressed: () {
            setState(() {
              _favoriteRestaurants.add(restaurant);
            });
          },
        ),
      ),
    );
  }

  void _removeFavoriteAddress(int index) {
    final address = _favoriteAddresses[index];
    setState(() {
      _favoriteAddresses.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('address_removed_from_favorites'.tr()),
        action: SnackBarAction(
          label: 'undo'.tr(),
          onPressed: () {
            setState(() {
              _favoriteAddresses.insert(index, address);
            });
          },
        ),
      ),
    );
  }

  void _viewRestaurant(Restaurant restaurant) {
    // Navigate to restaurant detail screen
    Navigator.pushNamed(
      context,
      '/restaurant-detail',
      arguments: restaurant,
    );
  }

  void _useAddress(String address) {
    // Use this address for a new delivery order
    Navigator.pushNamed(
      context,
      '/create-order',
      arguments: {'delivery_address': address},
    );
  }

  void _editAddress(String address, int index) {
    // Show dialog to edit address
    showDialog(
      context: context,
      builder: (context) => _buildEditAddressDialog(address, index),
    );
  }

  Widget _buildEditAddressDialog(String currentAddress, int index) {
    final controller = TextEditingController(text: currentAddress);
    
    return AlertDialog(
      title: Text('edit_address'.tr()),
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'address'.tr(),
          border: const OutlineInputBorder(),
        ),
        maxLines: 2,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _favoriteAddresses[index] = controller.text.trim();
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('address_updated'.tr())),
            );
          },
          child: Text('save'.tr()),
        ),
      ],
    );
  }
}