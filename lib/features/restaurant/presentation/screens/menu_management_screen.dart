import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:le_livreur_pro/core/models/menu_item.dart';
import 'package:le_livreur_pro/core/models/menu_category.dart';
import 'package:le_livreur_pro/core/services/menu_service.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';

// Providers for menu data
final menuCategoriesProvider =
    FutureProvider.family<List<MenuCategory>, String>(
        (ref, restaurantId) async {
  return await MenuService.getMenuCategories(restaurantId);
});

final menuItemsProvider =
    FutureProvider.family<List<MenuItem>, String>((ref, restaurantId) async {
  return await MenuService.getMenuItems(restaurantId);
});

class MenuManagementScreen extends ConsumerStatefulWidget {
  final String restaurantId;

  const MenuManagementScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  ConsumerState<MenuManagementScreen> createState() =>
      _MenuManagementScreenState();
}

class _MenuManagementScreenState extends ConsumerState<MenuManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        title: Text('Gestion du Menu'.tr()),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(text: 'Articles'.tr()),
            Tab(text: 'Catégories'.tr()),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMenuItemsTab(),
          _buildCategoriesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMenuItemsTab() {
    final categoriesAsync =
        ref.watch(menuCategoriesProvider(widget.restaurantId));
    final itemsAsync = ref.watch(menuItemsProvider(widget.restaurantId));

    return Column(
      children: [
        // Category Filter
        categoriesAsync.when(
          data: (categories) => _buildCategoryFilter(categories),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        // Menu Items List
        Expanded(
          child: itemsAsync.when(
            data: (items) => _buildMenuItemsList(items),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorState(error),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter(List<MenuCategory> categories) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Tous'.tr(), null),
          const SizedBox(width: 8),
          ...categories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildFilterChip(category.name, category.id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? categoryId) {
    final isSelected = _selectedCategoryId == categoryId;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategoryId = selected ? categoryId : null;
        });
      },
      selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
      checkmarkColor: AppTheme.primaryGreen,
    );
  }

  Widget _buildMenuItemsList(List<MenuItem> items) {
    List<MenuItem> filteredItems = items;

    if (_selectedCategoryId != null) {
      filteredItems = items
          .where((item) => item.categoryId == _selectedCategoryId)
          .toList();
    }

    if (filteredItems.isEmpty) {
      return _buildEmptyState(
          'Aucun article trouvé'.tr(), Icons.restaurant_menu);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredItems.length,
      itemBuilder: (context, index) {
        final item = filteredItems[index];
        return _buildMenuItemCard(item);
      },
    );
  }

  Widget _buildMenuItemCard(MenuItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryGreen.withOpacity(0.1),
          backgroundImage:
              item.imageUrl != null ? NetworkImage(item.imageUrl!) : null,
          child: item.imageUrl == null
              ? const Icon(Icons.restaurant, color: AppTheme.primaryGreen)
              : null,
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppTheme.neutralGrey),
            ),
            const SizedBox(height: 4),
            Text(
              '${item.priceXof} XOF',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: item.isAvailable,
              onChanged: (value) => _toggleItemAvailability(item, value),
              activeThumbColor: AppTheme.primaryGreen,
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit),
                      const SizedBox(width: 8),
                      Text('Modifier'.tr()),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: AppTheme.errorRed),
                      const SizedBox(width: 8),
                      Text('Supprimer'.tr(),
                          style: const TextStyle(color: AppTheme.errorRed)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _editMenuItem(item);
                    break;
                  case 'delete':
                    _deleteMenuItem(item);
                    break;
                }
              },
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildCategoriesTab() {
    final categoriesAsync =
        ref.watch(menuCategoriesProvider(widget.restaurantId));

    return categoriesAsync.when(
      data: (categories) => categories.isEmpty
          ? _buildEmptyState('Aucune catégorie trouvée'.tr(), Icons.category)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return _buildCategoryCard(category);
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildCategoryCard(MenuCategory category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.accentOrange.withOpacity(0.1),
          backgroundImage:
              category.iconUrl != null ? NetworkImage(category.iconUrl!) : null,
          child: category.iconUrl == null
              ? const Icon(Icons.category, color: AppTheme.accentOrange)
              : null,
        ),
        title: Text(
          category.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          category.description ?? 'Aucune description'.tr(),
          style: const TextStyle(color: AppTheme.neutralGrey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: category.isActive,
              onChanged: (value) => _toggleCategoryStatus(category, value),
              activeThumbColor: AppTheme.primaryGreen,
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit),
                      const SizedBox(width: 8),
                      Text('Modifier'.tr()),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: AppTheme.errorRed),
                      const SizedBox(width: 8),
                      Text('Supprimer'.tr(),
                          style: const TextStyle(color: AppTheme.errorRed)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _editCategory(category);
                    break;
                  case 'delete':
                    _deleteCategory(category);
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
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
              message,
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
            'Erreur: $error'.tr(),
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            child: Text('Réessayer'.tr()),
          ),
        ],
      ),
    );
  }

  // ==================== EVENT HANDLERS ====================

  void _showAddDialog() {
    if (_tabController.index == 0) {
      _addMenuItem();
    } else {
      _addCategory();
    }
  }

  void _addMenuItem() {
    showDialog(
      context: context,
      builder: (context) => _MenuItemDialog(
        restaurantId: widget.restaurantId,
        onSaved: _refreshData,
      ),
    );
  }

  void _editMenuItem(MenuItem item) {
    showDialog(
      context: context,
      builder: (context) => _MenuItemDialog(
        restaurantId: widget.restaurantId,
        item: item,
        onSaved: _refreshData,
      ),
    );
  }

  void _deleteMenuItem(MenuItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer l\'article'.tr()),
        content: Text('Voulez-vous vraiment supprimer "${item.name}"?'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: Text('Supprimer'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await MenuService.deleteMenuItem(item.id);
        _refreshData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Article supprimé avec succès'.tr()),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: $e'.tr()),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  void _toggleItemAvailability(MenuItem item, bool isAvailable) async {
    try {
      await MenuService.updateMenuItem(item.id, {'is_available': isAvailable});
      _refreshData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la mise à jour: $e'.tr()),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  void _addCategory() {
    showDialog(
      context: context,
      builder: (context) => _CategoryDialog(
        restaurantId: widget.restaurantId,
        onSaved: _refreshData,
      ),
    );
  }

  void _editCategory(MenuCategory category) {
    showDialog(
      context: context,
      builder: (context) => _CategoryDialog(
        restaurantId: widget.restaurantId,
        category: category,
        onSaved: _refreshData,
      ),
    );
  }

  void _deleteCategory(MenuCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer la catégorie'.tr()),
        content:
            Text('Voulez-vous vraiment supprimer "${category.name}"?'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            child: Text('Supprimer'.tr()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await MenuService.deleteMenuCategory(category.id);
        _refreshData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Catégorie supprimée avec succès'.tr()),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: $e'.tr()),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  void _toggleCategoryStatus(MenuCategory category, bool isActive) async {
    try {
      await MenuService.updateMenuCategory(
          category.id, {'is_active': isActive});
      _refreshData();
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
    ref.refresh(menuCategoriesProvider(widget.restaurantId));
    ref.refresh(menuItemsProvider(widget.restaurantId));
  }
}

// ==================== DIALOG WIDGETS ====================

class _MenuItemDialog extends StatefulWidget {
  final String restaurantId;
  final MenuItem? item;
  final VoidCallback onSaved;

  const _MenuItemDialog({
    required this.restaurantId,
    this.item,
    required this.onSaved,
  });

  @override
  State<_MenuItemDialog> createState() => _MenuItemDialogState();
}

class _MenuItemDialogState extends State<_MenuItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  String? _selectedCategoryId;
  bool _isAvailable = true;
  bool _isPopular = false;
  bool _isSpicy = false;
  bool _isVegetarian = false;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _descriptionController.text = widget.item!.description;
      _priceController.text = widget.item!.priceXof.toString();
      _selectedCategoryId = widget.item!.categoryId;
      _isAvailable = widget.item!.isAvailable;
      _isPopular = widget.item!.isPopular;
      _isSpicy = widget.item!.isSpicy;
      _isVegetarian = widget.item!.isVegetarian;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item == null
          ? 'Ajouter un article'.tr()
          : 'Modifier l\'article'.tr()),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration:
                    InputDecoration(labelText: 'Nom de l\'article'.tr()),
                validator: (value) =>
                    value?.isEmpty == true ? 'Champ requis'.tr() : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'.tr()),
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty == true ? 'Champ requis'.tr() : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Prix (XOF)'.tr(),
                  suffixText: 'XOF',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Champ requis'.tr();
                  if (int.tryParse(value!) == null) return 'Prix invalide'.tr();
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: Text('Disponible'.tr()),
                value: _isAvailable,
                onChanged: (value) =>
                    setState(() => _isAvailable = value ?? true),
              ),
              CheckboxListTile(
                title: Text('Populaire'.tr()),
                value: _isPopular,
                onChanged: (value) =>
                    setState(() => _isPopular = value ?? false),
              ),
              CheckboxListTile(
                title: Text('Épicé'.tr()),
                value: _isSpicy,
                onChanged: (value) => setState(() => _isSpicy = value ?? false),
              ),
              CheckboxListTile(
                title: Text('Végétarien'.tr()),
                value: _isVegetarian,
                onChanged: (value) =>
                    setState(() => _isVegetarian = value ?? false),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler'.tr()),
        ),
        ElevatedButton(
          onPressed: _saveItem,
          style:
              ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
          child: Text('Enregistrer'.tr()),
        ),
      ],
    );
  }

  void _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final data = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price_xof': int.parse(_priceController.text),
        'category_id': _selectedCategoryId,
        'is_available': _isAvailable,
        'is_popular': _isPopular,
        'is_spicy': _isSpicy,
        'is_vegetarian': _isVegetarian,
      };

      if (widget.item == null) {
        await MenuService.createMenuItem(widget.restaurantId, data);
      } else {
        await MenuService.updateMenuItem(widget.item!.id, data);
      }

      widget.onSaved();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'.tr()),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }
}

class _CategoryDialog extends StatefulWidget {
  final String restaurantId;
  final MenuCategory? category;
  final VoidCallback onSaved;

  const _CategoryDialog({
    required this.restaurantId,
    this.category,
    required this.onSaved,
  });

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      _nameController.text = widget.category!.name;
      _descriptionController.text = widget.category!.description ?? '';
      _isActive = widget.category!.isActive;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null
          ? 'Ajouter une catégorie'.tr()
          : 'Modifier la catégorie'.tr()),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration:
                  InputDecoration(labelText: 'Nom de la catégorie'.tr()),
              validator: (value) =>
                  value?.isEmpty == true ? 'Champ requis'.tr() : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration:
                  InputDecoration(labelText: 'Description (optionnel)'.tr()),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: Text('Active'.tr()),
              value: _isActive,
              onChanged: (value) => setState(() => _isActive = value ?? true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler'.tr()),
        ),
        ElevatedButton(
          onPressed: _saveCategory,
          style:
              ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
          child: Text('Enregistrer'.tr()),
        ),
      ],
    );
  }

  void _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final data = {
        'name': _nameController.text,
        'description': _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : null,
        'is_active': _isActive,
      };

      if (widget.category == null) {
        await MenuService.createMenuCategory(widget.restaurantId, data);
      } else {
        await MenuService.updateMenuCategory(widget.category!.id, data);
      }

      widget.onSaved();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'.tr()),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }
}
