import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../shared/theme/app_theme.dart';

class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suivi de Livraison'.tr()),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTrackingSearch(),
            const SizedBox(height: 24),
            _buildActiveDeliveries(),
            const SizedBox(height: 24),
            _buildTrackingHistory(),
          ],
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
                    decoration: InputDecoration(
                      hintText: 'Numéro de commande'.tr(),
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                  child: Text('Suivre'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveDeliveries() {
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
        _buildDeliveryCard(
          orderNumber: 'CMD-2024-001',
          status: 'En route',
          estimatedTime: '15 min',
          courierName: 'Kouassi Jean',
          courierPhone: '+2250700000001',
        ),
        _buildDeliveryCard(
          orderNumber: 'CMD-2024-003',
          status: 'En préparation',
          estimatedTime: '45 min',
          courierName: 'Diallo Mariam',
          courierPhone: '+2250700000002',
        ),
      ],
    );
  }

  Widget _buildDeliveryCard({
    required String orderNumber,
    required String status,
    required String estimatedTime,
    required String courierName,
    required String courierPhone,
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            const SizedBox(height: 16),
            _buildTrackingSteps(status),
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
                        courierName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Arrivée estimée: $estimatedTime',
                        style: const TextStyle(
                          color: AppTheme.neutralGrey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
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

  Widget _buildTrackingSteps(String currentStatus) {
    final steps = [
      {'title': 'Commande confirmée', 'icon': Icons.check_circle, 'completed': true},
      {'title': 'En préparation', 'icon': Icons.inventory, 'completed': currentStatus != 'En route'},
      {'title': 'En route', 'icon': Icons.local_shipping, 'completed': currentStatus == 'En route'},
      {'title': 'Livré', 'icon': Icons.home, 'completed': false},
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = step['completed'] as bool;
        final isLast = index == steps.length - 1;

        return Row(
          children: [
            Icon(
              step['icon'] as IconData,
              color: isCompleted ? AppTheme.successGreen : AppTheme.neutralGreyLight,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                step['title'] as String,
                style: TextStyle(
                  color: isCompleted ? AppTheme.neutralGreyDark : AppTheme.neutralGreyLight,
                  fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTrackingHistory() {
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
        _buildHistoryItem(
          orderNumber: 'CMD-2024-002',
          status: 'Livré',
          date: 'Hier',
          time: '14:30',
        ),
        _buildHistoryItem(
          orderNumber: 'CMD-2024-004',
          status: 'Livré',
          date: 'Il y a 3 jours',
          time: '10:15',
        ),
      ],
    );
  }

  Widget _buildHistoryItem({
    required String orderNumber,
    required String status,
    required String date,
    required String time,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(
          Icons.check_circle,
          color: AppTheme.successGreen,
        ),
        title: Text(orderNumber),
        subtitle: Text('$date à $time'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.successGreen,
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'En route':
        return AppTheme.warningOrange;
      case 'En préparation':
        return AppTheme.infoBlue;
      case 'Livré':
        return AppTheme.successGreen;
      default:
        return AppTheme.neutralGrey;
    }
  }
}
