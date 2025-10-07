import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:le_livreur_pro/core/models/menu_item.dart';
import 'package:le_livreur_pro/core/models/restaurant.dart';
import 'package:le_livreur_pro/core/services/restaurant_service.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
  });

  @override
  ConsumerState<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends ConsumerState<RestaurantDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildRestaurantInfo(),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryGreen,
                unselectedLabelColor: AppTheme.neutralGrey,
                indicatorColor: AppTheme.primaryGreen,
                tabs: [
                  Tab(text: 'Menu'.tr()),
                  const Tab(text: 'Informations'),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMenuTab(),
                _buildInfoTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCartSummary(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryGreen,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.restaurant.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: widget.restaurant.bannerUrl != null
            ? CachedNetworkImage(
                imageUrl: widget.restaurant.bannerUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.primaryGreen,
                  child: const Icon(
                    Icons.restaurant,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              )
            : Container(
                color: AppTheme.primaryGreen,
                child: const Icon(
                  Icons.restaurant,
                  size: 64,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildRestaurantInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.restaurant.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.neutralGrey,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.restaurant.acceptsOrders
                      ? AppTheme.successGreen.withOpacity(0.1)
                      : AppTheme.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.restaurant.acceptsOrders
                      ? 'Ouvert'.tr()
                      : 'Fermé'.tr(),
                  style: TextStyle(
                    color: widget.restaurant.acceptsOrders
                        ? AppTheme.successGreen
                        : AppTheme.errorRed,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.star,
                size: 20,
                color: Colors.amber[600],
              ),
              const SizedBox(width: 4),
              Text(
                widget.restaurant.rating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${widget.restaurant.totalReviews} avis)',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.neutralGrey,
                    ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.access_time,
                size: 16,
                color: AppTheme.neutralGrey,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.restaurant.preparationTimeMinutes} min',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.neutralGrey,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.delivery_dining,
                size: 16,
                color: AppTheme.neutralGrey,
              ),
              const SizedBox(width: 4),
              Text(
                widget.restaurant.deliveryFeeXof > 0
                    ? 'Livraison: ${widget.restaurant.deliveryFeeXof} CFA'
                    : 'Livraison gratuite'.tr(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.neutralGrey,
                    ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.shopping_cart,
                size: 16,
                color: AppTheme.neutralGrey,
              ),
              const SizedBox(width: 4),
              Text(
                'Min: ${widget.restaurant.minimumOrderXof} CFA',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.neutralGrey,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTab() {
    final menuItemsAsync = ref.watch(menuItemsProvider(widget.restaurant.id));
    final categoriesAsync =
        ref.watch(menuCategoriesProvider(widget.restaurant.id));

    return menuItemsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement du menu',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.refresh(menuItemsProvider(widget.restaurant.id));
                ref.refresh(menuCategoriesProvider(widget.restaurant.id));
              },
              child: Text('Réessayer'.tr()),
            ),
          ],
        ),
      ),
      data: (menuItems) {
        if (menuItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Menu non disponible',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.neutralGrey,
                      ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: menuItems.length,
          itemBuilder: (context, index) {
            final item = menuItems[index];
            return _buildMenuItemCard(item);
          },
        );
      },
    );
  }

  Widget _buildMenuItemCard(MenuItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: item.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.restaurant,
                        size: 40,
                        color: AppTheme.neutralGrey,
                      ),
                    )
                  : const Icon(
                      Icons.restaurant,
                      size: 40,
                      color: AppTheme.neutralGrey,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      if (item.isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Populaire'.tr(),
                            style: const TextStyle(
                              color: AppTheme.accentOrange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.neutralGrey,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (item.isSpicy) ...[
                        const Icon(
                          Icons.local_fire_department,
                          size: 16,
                          color: AppTheme.errorRed,
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (item.isVegetarian) ...[
                        const Icon(
                          Icons.eco,
                          size: 16,
                          color: AppTheme.successGreen,
                        ),
                        const SizedBox(width: 4),
                      ],
                      if (item.isHalal) ...[
                        const Text(
                          'Halal',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.successGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item.priceXof} CFA',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                      ),
                      ElevatedButton(
                        onPressed:
                            item.isAvailable ? () => _addToCart(item) : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        child: Text(
                          item.isAvailable
                              ? 'Ajouter au panier'.tr()
                              : 'Non disponible',
                          style: const TextStyle(fontSize: 12),
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

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            'Informations générales',
            [
              _buildInfoRow('Adresse', widget.restaurant.businessAddress),
              if (widget.restaurant.businessPhone != null)
                _buildInfoRow('Téléphone', widget.restaurant.businessPhone!),
              if (widget.restaurant.businessEmail != null)
                _buildInfoRow('Email', widget.restaurant.businessEmail!),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoSection(
            'Horaires d\'ouverture',
            [
              _buildInfoRow('Lundi - Vendredi', '08:00 - 22:00'),
              _buildInfoRow('Samedi', '08:00 - 23:00'),
              _buildInfoRow('Dimanche', '10:00 - 21:00'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.neutralGrey,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartSummary() {
    // TODO: Implement cart state management
    // For now, return empty container
    return const SizedBox.shrink();
  }

  void _addToCart(MenuItem item) {
    // TODO: Implement add to cart functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} ajouté au panier'),
        backgroundColor: AppTheme.primaryGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
