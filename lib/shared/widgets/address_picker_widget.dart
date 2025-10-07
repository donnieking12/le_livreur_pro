import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:le_livreur_pro/core/models/address.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';

class AddressPickerWidget extends ConsumerStatefulWidget {
  final String title;
  final bool allowAddNew;
  final Function(Address) onAddressSelected;

  const AddressPickerWidget({
    super.key,
    required this.title,
    this.allowAddNew = true,
    required this.onAddressSelected,
  });

  @override
  ConsumerState<AddressPickerWidget> createState() => _AddressPickerWidgetState();
}

class _AddressPickerWidgetState extends ConsumerState<AddressPickerWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        elevation: 0,
      ),
      body: Column(
        children: [
          if (widget.allowAddNew) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _addNewAddress,
                icon: const Icon(Icons.add),
                label: Text('Ajouter une nouvelle adresse'.tr()),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const Divider(),
          ],
          Expanded(
            child: _buildAddressList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList() {
    // For demo - return some sample addresses
    final demoAddresses = _getDemoAddresses();

    if (demoAddresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune adresse enregistrée',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.neutralGrey,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez votre première adresse pour commencer',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.neutralGrey,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addNewAddress,
              icon: const Icon(Icons.add),
              label: Text('Ajouter une adresse'.tr()),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: demoAddresses.length,
      itemBuilder: (context, index) {
        final address = demoAddresses[index];
        return _buildAddressCard(address);
      },
    );
  }

  Widget _buildAddressCard(Address address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          widget.onAddressSelected(address);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  _getAddressIcon(address.type),
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address.label,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Par défaut',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.fullAddress,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.neutralGrey,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (address.nearbyLandmark != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Près de: ${address.nearbyLandmark}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.neutralGrey,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.neutralGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getAddressIcon(AddressType type) {
    switch (type) {
      case AddressType.home:
        return Icons.home;
      case AddressType.work:
        return Icons.work;
      case AddressType.other:
        return Icons.location_on;
    }
  }

  void _addNewAddress() {
    // TODO: Navigate to add address screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter une adresse'),
        content: Text('Fonctionnalité d\'ajout d\'adresse à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer'),
          ),
        ],
      ),
    );
  }

  List<Address> _getDemoAddresses() {
    final now = DateTime.now();
    return [
      Address(
        id: 'addr_1',
        userId: 'user_1',
        label: 'Maison',
        fullAddress: 'Cocody, Angré 7ème Tranche, Abidjan',
        latitude: 5.3599517,
        longitude: -3.9715851,
        neighborhood: 'Angré',
        commune: 'Cocody',
        city: 'Abidjan',
        nearbyLandmark: 'Pharmacie Nouvelle',
        additionalInstructions: 'Maison blanche avec portail vert, 2ème étage',
        type: AddressType.home,
        isDefault: true,
        contactName: 'Jean Kouassi',
        contactPhone: '+225 07 12 34 56 78',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Address(
        id: 'addr_2',
        userId: 'user_1',
        label: 'Bureau',
        fullAddress: 'Plateau, Immeuble Alpha 2000, 5ème étage, Abidjan',
        latitude: 5.3196879,
        longitude: -4.0248565,
        neighborhood: 'Plateau',
        commune: 'Plateau',
        city: 'Abidjan',
        nearbyLandmark: 'Cathédrale Saint-Paul',
        additionalInstructions: 'Bureau 502, prendre ascenseur principal',
        type: AddressType.work,
        isDefault: false,
        contactName: 'Jean Kouassi',
        contactPhone: '+225 07 12 34 56 78',
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      Address(
        id: 'addr_3',
        userId: 'user_1',
        label: 'Chez Maman',
        fullAddress: 'Treichville, Rue 12, près du marché, Abidjan',
        latitude: 5.2918802,
        longitude: -4.0197926,
        neighborhood: 'Treichville',
        commune: 'Treichville',
        city: 'Abidjan',
        nearbyLandmark: 'Marché de Treichville',
        additionalInstructions: 'Cour commune, dernière porte à droite',
        type: AddressType.other,
        isDefault: false,
        contactName: 'Adjoua Kouassi',
        contactPhone: '+225 07 98 76 54 32',
        createdAt: now.subtract(const Duration(days: 90)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
    ];
  }
}