import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:le_livreur_pro/core/models/address.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';
import 'package:le_livreur_pro/shared/widgets/address_picker_widget.dart';
import 'package:le_livreur_pro/features/orders/presentation/screens/create_order_screen.dart';

class PackageDeliveryTab extends ConsumerStatefulWidget {
  const PackageDeliveryTab({super.key});

  @override
  ConsumerState<PackageDeliveryTab> createState() => _PackageDeliveryTabState();
}

class _PackageDeliveryTabState extends ConsumerState<PackageDeliveryTab> {
  final _formKey = GlobalKey<FormState>();
  final _packageDescriptionController = TextEditingController();
  final _packageValueController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  final _specialInstructionsController = TextEditingController();

  String? _selectedPickupAddress;
  String? _selectedDeliveryAddress;
  Address? _pickupAddress;
  Address? _deliveryAddress;
  String _selectedPaymentMethod = 'cash_on_delivery';
  bool _isFragile = false;
  bool _requiresSignature = false;

  @override
  void dispose() {
    _packageDescriptionController.dispose();
    _packageValueController.dispose();
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPackageDetailsSection(),
            const SizedBox(height: 24),
            _buildLocationSection(),
            const SizedBox(height: 24),
            _buildRecipientSection(),
            const SizedBox(height: 24),
            _buildPaymentSection(),
            const SizedBox(height: 24),
            _buildPricingEstimate(),
            const SizedBox(height: 32),
            _buildCreateOrderButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageDetailsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.inventory_2,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Détails du colis',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _packageDescriptionController,
              decoration: InputDecoration(
                labelText: 'Description du colis'.tr(),
                hintText: 'Ex: Documents, vêtements, électronique...',
                prefixIcon: const Icon(Icons.description),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez décrire le contenu du colis';
                }
                return null;
              },
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _packageValueController,
              decoration: InputDecoration(
                labelText: 'Valeur du colis (CFA)'.tr(),
                hintText: 'Ex: 25000',
                prefixIcon: const Icon(Icons.attach_money),
                suffixText: 'CFA',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final amount = int.tryParse(value);
                  if (amount == null || amount < 0) {
                    return 'Veuillez entrer un montant valide';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    value: _isFragile,
                    onChanged: (value) {
                      setState(() {
                        _isFragile = value ?? false;
                      });
                    },
                    title: Text('Fragile'.tr()),
                    subtitle: const Text('Manipulation délicate requise'),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            CheckboxListTile(
              value: _requiresSignature,
              onChanged: (value) {
                setState(() {
                  _requiresSignature = value ?? false;
                });
              },
              title: Text('Signature requise'.tr()),
              subtitle: const Text('Remise en main propre uniquement'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Adresses',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAddressSelector(
              title: 'Adresse de récupération'.tr(),
              value: _pickupAddress?.label,
              subtitle: _pickupAddress?.fullAddress,
              onTap: () => _selectAddress(isPickup: true),
              icon: Icons.my_location,
            ),
            const SizedBox(height: 16),
            _buildAddressSelector(
              title: 'Adresse de livraison'.tr(),
              value: _deliveryAddress?.label,
              subtitle: _deliveryAddress?.fullAddress,
              onTap: () => _selectAddress(isPickup: false),
              icon: Icons.place,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSelector({
    required String title,
    required String? value,
    String? subtitle,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.neutralGrey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.neutralGrey,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value ?? 'Choisir une adresse'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: value != null
                              ? Colors.black
                              : AppTheme.neutralGrey,
                          fontWeight: value != null ? FontWeight.w500 : FontWeight.normal,
                        ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.neutralGrey,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipientSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.person,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Destinataire',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _recipientNameController,
              decoration: InputDecoration(
                labelText: 'Nom du destinataire'.tr(),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le nom du destinataire';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _recipientPhoneController,
              decoration: InputDecoration(
                labelText: 'Téléphone du destinataire'.tr(),
                prefixIcon: const Icon(Icons.phone),
                hintText: '+225 07 00 00 00 00',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer le numéro de téléphone';
                }
                // Basic phone validation for Côte d'Ivoire
                if (!RegExp(r'^\+225\d{10}$')
                    .hasMatch(value.replaceAll(' ', ''))) {
                  return 'Numéro de téléphone invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _specialInstructionsController,
              decoration: InputDecoration(
                labelText: 'Instructions spéciales'.tr(),
                hintText: 'Informations additionnelles pour la livraison...',
                prefixIcon: const Icon(Icons.note),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSection() {
    final paymentMethods = [
      {
        'key': 'cash_on_delivery',
        'label': 'Paiement à la livraison'.tr(),
        'icon': Icons.money
      },
      {
        'key': 'orange_money',
        'label': 'Orange Money',
        'icon': Icons.phone_android
      },
      {'key': 'mtn_money', 'label': 'MTN Money', 'icon': Icons.phone_android},
      {'key': 'wave', 'label': 'Wave', 'icon': Icons.phone_android},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.payment,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 8),
                Text(
                  'Méthode de paiement'.tr(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...paymentMethods.map((method) {
              return RadioListTile<String>(
                value: method['key'] as String,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
                title: Text(method['label'] as String),
                secondary: Icon(method['icon'] as IconData),
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingEstimate() {
    // TODO: Implement actual pricing calculation
    const basePrice = 500; // Base price in CFA
    final fragilePrice = _isFragile ? 200 : 0;
    final signaturePrice = _requiresSignature ? 100 : 0;
    final total = basePrice + fragilePrice + signaturePrice;

    return Card(
      color: AppTheme.primaryGreen.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estimation du prix',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            _buildPriceRow('Prix de base', '$basePrice CFA'),
            if (_isFragile)
              _buildPriceRow('Manipulation fragile', '+$fragilePrice CFA'),
            if (_requiresSignature)
              _buildPriceRow('Signature requise', '+$signaturePrice CFA'),
            const Divider(),
            _buildPriceRow(
              'Total'.tr(),
              '$total CFA',
              isTotal: true,
            ),
            const SizedBox(height: 8),
            Text(
              'Le prix final sera calculé en fonction de la distance réelle',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.neutralGrey,
                    fontStyle: FontStyle.italic,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                ),
          ),
          Text(
            amount,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                  color: isTotal ? AppTheme.primaryGreen : null,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateOrderButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _canCreateOrder() ? _createOrder : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Créer la commande',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  bool _canCreateOrder() {
    return _packageDescriptionController.text.isNotEmpty &&
        _recipientNameController.text.isNotEmpty &&
        _recipientPhoneController.text.isNotEmpty &&
        _pickupAddress != null &&
        _deliveryAddress != null;
  }

  void _selectAddress({required bool isPickup}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressPickerWidget(
          title: isPickup 
              ? 'Adresse de récupération' 
              : 'Adresse de livraison',
          onAddressSelected: (address) {
            setState(() {
              if (isPickup) {
                _pickupAddress = address;
                _selectedPickupAddress = address.label;
              } else {
                _deliveryAddress = address;
                _selectedDeliveryAddress = address.label;
              }
            });
          },
        ),
      ),
    );
  }

  void _createOrder() {
    if (_formKey.currentState!.validate()) {
      // Show success message and prepare order data
      final orderData = {
        'packageDescription': _packageDescriptionController.text,
        'packageValue': _packageValueController.text.isNotEmpty 
            ? int.tryParse(_packageValueController.text) 
            : null,
        'pickupAddress': _pickupAddress?.toJson(),
        'deliveryAddress': _deliveryAddress?.toJson(),
        'recipientName': _recipientNameController.text,
        'recipientPhone': _recipientPhoneController.text,
        'specialInstructions': _specialInstructionsController.text.isNotEmpty 
            ? _specialInstructionsController.text 
            : null,
        'isFragile': _isFragile,
        'requiresSignature': _requiresSignature,
        'paymentMethod': _selectedPaymentMethod,
      };
      
      // TODO: Navigate to CreateOrderScreen with this data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateOrderScreen(),
        ),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Commande prête à être créée'.tr()),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }
}
