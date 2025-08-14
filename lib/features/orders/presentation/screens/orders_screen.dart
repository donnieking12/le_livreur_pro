import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Commandes'.tr()),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderStats(),
            const SizedBox(height: 24),
            _buildOrderFilters(),
            const SizedBox(height: 20),
            _buildOrdersList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total',
            value: '24',
            color: AppTheme.primaryGreen,
            icon: Icons.shopping_bag,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'En cours',
            value: '3',
            color: AppTheme.warningOrange,
            icon: Icons.pending,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Livrés',
            value: '21',
            color: AppTheme.successGreen,
            icon: Icons.check_circle,
          ),
        ),
      ],
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

  Widget _buildOrderFilters() {
    return Row(
      children: [
        Expanded(
          child: _buildFilterChip('Tous', true),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFilterChip('En cours', false),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFilterChip('Livrés', false),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFilterChip('Annulés', false),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {},
      selectedColor: AppTheme.primaryGreen,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.neutralGrey,
      ),
    );
  }

  Widget _buildOrdersList() {
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
        _buildOrderItem(
          orderNumber: 'CMD-2024-001',
          status: 'En cours',
          amount: '2,500 XOF',
          date: 'Aujourd\'hui',
          description: 'Livraison de documents',
          isActive: true,
        ),
        _buildOrderItem(
          orderNumber: 'CMD-2024-002',
          status: 'Livré',
          amount: '1,800 XOF',
          date: 'Hier',
          description: 'Colis fragile',
          isActive: false,
        ),
        _buildOrderItem(
          orderNumber: 'CMD-2024-003',
          status: 'En cours',
          amount: '3,200 XOF',
          date: 'Il y a 2 jours',
          description: 'Livraison express',
          isActive: true,
        ),
        _buildOrderItem(
          orderNumber: 'CMD-2024-004',
          status: 'Livré',
          amount: '950 XOF',
          date: 'Il y a 3 jours',
          description: 'Petit colis',
          isActive: false,
        ),
      ],
    );
  }

  Widget _buildOrderItem({
    required String orderNumber,
    required String status,
    required String amount,
    required String date,
    required String description,
    required bool isActive,
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(16),
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
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.neutralGrey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.neutralGrey,
                  ),
                ),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            if (isActive) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.location_on),
                      label: Text('Suivre'.tr()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryGreen,
                        side: const BorderSide(color: AppTheme.primaryGreen),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.support_agent),
                      label: Text('Support'.tr()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                      ),
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

  Color _getStatusColor(String status) {
    switch (status) {
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
}
