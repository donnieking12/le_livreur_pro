import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:le_livreur_pro/core/models/user.dart' as app_user;
import 'package:le_livreur_pro/core/services/admin_service.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';

// Providers for user management
final allUsersProvider = FutureProvider<List<app_user.User>>((ref) async {
  return await AdminService.getAllUsers();
});

final usersByTypeProvider =
    FutureProvider.family<List<app_user.User>, app_user.UserType>(
        (ref, userType) async {
  return await AdminService.getUsersByType(userType);
});

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
                _buildAllUsersTab(),
                _buildUserTypeTab(app_user.UserType.customer),
                _buildUserTypeTab(app_user.UserType.courier),
                _buildUserTypeTab(app_user.UserType.partner),
                _buildUserTypeTab(app_user.UserType.admin),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateUserDialog(),
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.person_add),
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
                    hintText: 'Rechercher par nom, email ou téléphone...'.tr(),
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
          _buildUserStats(),
        ],
      ),
    );
  }

  Widget _buildUserStats() {
    final allUsersAsync = ref.watch(allUsersProvider);

    return allUsersAsync.when(
      data: (users) {
        final stats = _calculateUserStats(users);
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatChip(
                'Total'.tr(), '${stats['total']}', AppTheme.primaryGreen),
            _buildStatChip(
                'Actifs'.tr(), '${stats['active']}', AppTheme.successGreen),
            _buildStatChip(
                'Vérifiés'.tr(), '${stats['verified']}', AppTheme.infoBlue),
            _buildStatChip(
                'Bloqués'.tr(), '${stats['blocked']}', AppTheme.errorRed),
          ],
        );
      },
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
          Tab(text: 'Tous'.tr()),
          Tab(text: 'Clients'.tr()),
          Tab(text: 'Livreurs'.tr()),
          Tab(text: 'Partenaires'.tr()),
          Tab(text: 'Admins'.tr()),
        ],
      ),
    );
  }

  Widget _buildAllUsersTab() {
    final usersAsync = ref.watch(allUsersProvider);

    return usersAsync.when(
      data: (users) => _buildUsersList(users),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildUserTypeTab(app_user.UserType userType) {
    final usersAsync = ref.watch(usersByTypeProvider(userType));

    return usersAsync.when(
      data: (users) => _buildUsersList(users),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildUsersList(List<app_user.User> users) {
    List<app_user.User> filteredUsers = users;

    if (_searchQuery.isNotEmpty) {
      filteredUsers = users.where((user) {
        return user.fullName
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            user.phone.contains(_searchQuery) ||
            (user.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false);
      }).toList();
    }

    if (filteredUsers.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _refreshData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final user = filteredUsers[index];
          return _buildUserCard(user);
        },
      ),
    );
  }

  Widget _buildUserCard(app_user.User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getUserTypeColor(user.userType).withOpacity(0.1),
          backgroundImage: user.profileImageUrl != null
              ? NetworkImage(user.profileImageUrl!)
              : null,
          child: user.profileImageUrl == null
              ? Icon(
                  _getUserTypeIcon(user.userType),
                  color: _getUserTypeColor(user.userType),
                )
              : null,
        ),
        title: Text(
          user.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.phone,
              style: const TextStyle(color: AppTheme.neutralGrey),
            ),
            if (user.email != null)
              Text(
                user.email!,
                style: const TextStyle(
                  color: AppTheme.neutralGrey,
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(user.isActive ? 'Actif'.tr() : 'Inactif'.tr(),
                    user.isActive ? AppTheme.successGreen : AppTheme.errorRed),
                const SizedBox(width: 8),
                if (user.isVerified)
                  _buildStatusChip('Vérifié'.tr(), AppTheme.infoBlue),
                const SizedBox(width: 8),
                _buildStatusChip(
                  _getUserTypeLabel(user.userType),
                  _getUserTypeColor(user.userType),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  const Icon(Icons.visibility),
                  const SizedBox(width: 8),
                  Text('Voir détails'.tr()),
                ],
              ),
            ),
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
              value: user.isActive ? 'deactivate' : 'activate',
              child: Row(
                children: [
                  Icon(user.isActive ? Icons.block : Icons.check_circle),
                  const SizedBox(width: 8),
                  Text(user.isActive ? 'Désactiver'.tr() : 'Activer'.tr()),
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
          onSelected: (value) => _handleUserAction(user, value),
        ),
        isThreeLine: true,
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun utilisateur trouvé'.tr(),
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Essayez de modifier votre recherche'.tr(),
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

  Map<String, int> _calculateUserStats(List<app_user.User> users) {
    return {
      'total': users.length,
      'active': users.where((u) => u.isActive).length,
      'verified': users.where((u) => u.isVerified).length,
      'blocked': users.where((u) => !u.isActive).length,
    };
  }

  Color _getUserTypeColor(app_user.UserType userType) {
    switch (userType) {
      case app_user.UserType.customer:
        return AppTheme.infoBlue;
      case app_user.UserType.courier:
        return AppTheme.accentOrange;
      case app_user.UserType.partner:
        return AppTheme.warningOrange;
      case app_user.UserType.admin:
        return AppTheme.errorRed;
    }
  }

  IconData _getUserTypeIcon(app_user.UserType userType) {
    switch (userType) {
      case app_user.UserType.customer:
        return Icons.person;
      case app_user.UserType.courier:
        return Icons.delivery_dining;
      case app_user.UserType.partner:
        return Icons.restaurant;
      case app_user.UserType.admin:
        return Icons.admin_panel_settings;
    }
  }

  String _getUserTypeLabel(app_user.UserType userType) {
    switch (userType) {
      case app_user.UserType.customer:
        return 'Client';
      case app_user.UserType.courier:
        return 'Livreur';
      case app_user.UserType.partner:
        return 'Partenaire';
      case app_user.UserType.admin:
        return 'Admin';
    }
  }

  // ==================== EVENT HANDLERS ====================

  void _showCreateUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Créer un utilisateur'.tr()),
        content: Text(
            'Interface de création d\'utilisateur bientôt disponible'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'.tr()),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filtres'.tr()),
        content: Text('Options de filtrage bientôt disponibles'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'.tr()),
          ),
        ],
      ),
    );
  }

  void _handleUserAction(app_user.User user, String action) {
    switch (action) {
      case 'view':
        _viewUserDetails(user);
        break;
      case 'edit':
        _editUser(user);
        break;
      case 'activate':
      case 'deactivate':
        _toggleUserStatus(user);
        break;
      case 'delete':
        _deleteUser(user);
        break;
    }
  }

  void _viewUserDetails(app_user.User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Détails de ${user.fullName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', user.id),
              _buildDetailRow('Nom complet', user.fullName),
              _buildDetailRow('Téléphone', user.phone),
              if (user.email != null) _buildDetailRow('Email', user.email!),
              _buildDetailRow('Type', _getUserTypeLabel(user.userType)),
              _buildDetailRow('Actif', user.isActive ? 'Oui' : 'Non'),
              _buildDetailRow('Vérifié', user.isVerified ? 'Oui' : 'Non'),
              if (user.createdAt != null)
                _buildDetailRow('Créé le',
                    DateFormat('dd/MM/yyyy').format(user.createdAt!)),
            ],
          ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _editUser(app_user.User user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('Modification de ${user.fullName} bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  void _toggleUserStatus(app_user.User user) async {
    final action = user.isActive ? 'désactiver' : 'activer';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action.capitalize()} ${user.fullName}'),
        content: Text('Voulez-vous vraiment $action cet utilisateur?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  user.isActive ? AppTheme.errorRed : AppTheme.successGreen,
            ),
            child: Text(action.capitalize()),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AdminService.toggleUserStatus(user.id, !user.isActive);
        _refreshData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Utilisateur ${user.isActive ? "désactivé" : "activé"} avec succès'
                      .tr()),
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

  void _deleteUser(app_user.User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer ${user.fullName}'),
        content: const Text(
            'Cette action est irréversible. Voulez-vous vraiment supprimer cet utilisateur?'),
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
        await AdminService.deleteUser(user.id);
        _refreshData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Utilisateur supprimé avec succès'.tr()),
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

  Future<void> _refreshData() async {
    ref.refresh(allUsersProvider);
    ref.refresh(usersByTypeProvider(app_user.UserType.customer));
    ref.refresh(usersByTypeProvider(app_user.UserType.courier));
    ref.refresh(usersByTypeProvider(app_user.UserType.partner));
    ref.refresh(usersByTypeProvider(app_user.UserType.admin));
  }
}

extension StringCapitalization on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
