import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../shared/theme/app_theme.dart';

class CourierDashboardScreen extends StatelessWidget {
  const CourierDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de Bord Coursier'.tr()),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCourierStatus(),
            const SizedBox(height: 24),
            _buildTodayStats(),
            const SizedBox(height: 24),
            _buildAvailableDeliveries(),
            const SizedBox(height: 24),
            _buildRecentDeliveries(),
          ],
        ),
      ),
    );
  }

  Widget _buildCourierStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: AppTheme.primaryGreen,
              child: Icon(
                Icons.person,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kouassi Jean',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Coursier - Abidjan',
                    style: TextStyle(
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
                          color: AppTheme.successGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'En ligne',
                        style: TextStyle(
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Switch(
              value: true,
              onChanged: (value) {},
              activeColor: AppTheme.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Livraisons',
            value: '8',
            color: AppTheme.primaryGreen,
            icon: Icons.local_shipping,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Gains',
            value: '12,500 XOF',
            color: AppTheme.accentOrange,
            icon: Icons.monetization_on,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Évaluation',
            value: '4.8',
            color: AppTheme.infoBlue,
            icon: Icons.star,
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

  Widget _buildAvailableDeliveries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Livraisons disponibles'.tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildDeliveryCard(
          orderNumber: 'CMD-2024-005',
          pickupAddress: 'Cocody, Abidjan',
          deliveryAddress: 'Plateau, Abidjan',
          amount: '2,800 XOF',
          distance: '3.2 km',
          isUrgent: true,
        ),
        _buildDeliveryCard(
          orderNumber: 'CMD-2024-006',
          pickupAddress: 'Yopougon, Abidjan',
          deliveryAddress: 'Marcory, Abidjan',
          amount: '2,100 XOF',
          distance: '4.1 km',
          isUrgent: false,
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

  Widget _buildRecentDeliveries() {
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
        _buildRecentDeliveryItem(
          orderNumber: 'CMD-2024-001',
          status: 'Livré',
          amount: '2,500 XOF',
          time: '14:30',
        ),
        _buildRecentDeliveryItem(
          orderNumber: 'CMD-2024-002',
          status: 'Livré',
          amount: '1,800 XOF',
          time: '11:15',
        ),
        _buildRecentDeliveryItem(
          orderNumber: 'CMD-2024-003',
          status: 'En cours',
          amount: '3,200 XOF',
          time: '09:45',
        ),
      ],
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'En cours':
        return AppTheme.warningOrange;
      case 'Livré':
        return AppTheme.successGreen;
      default:
        return AppTheme.neutralGrey;
    }
  }
}
