import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:le_livreur_pro/core/models/address.dart';
import 'package:le_livreur_pro/core/models/user.dart';
import 'package:le_livreur_pro/core/services/auth_service.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';
import 'package:le_livreur_pro/shared/widgets/address_picker_widget.dart';

class AddressManagementScreen extends ConsumerStatefulWidget {
  const AddressManagementScreen({super.key});

  @override
  ConsumerState<AddressManagementScreen> createState() => _AddressManagementScreenState();
}

class _AddressManagementScreenState extends ConsumerState<AddressManagementScreen> {
  List<Address> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  void _loadAddresses() async {
    // Load demo addresses for now
    final userAsync = ref.read(currentUserProfileProvider);
    final user = userAsync.value;
    
    if (user != null) {
      setState(() {
        _addresses = [
          Address(
            id: '1',
            label: 'Domicile',
            fullAddress: 'Cocody, Riviera 2, Villa 123, Abidjan',
            latitude: 5.3800,
            longitude: -3.9700,
            type: AddressType.home,
            isDefault: true,
            userId: user.id,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Address(
            id: '2',
            label: 'Bureau',
            fullAddress: 'Plateau, Tour BCEAO, 15ème étage, Abidjan',
            latitude: 5.3200,
            longitude: -4.0100,
            type: AddressType.work,
            isDefault: false,
            userId: user.id,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes adresses'.tr()),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showAddAddressDialog(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
              ? _buildEmptyState()
              : _buildAddressList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAddressDialog(),
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
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
            'Aucune adresse enregistrée'.tr(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez votre première adresse pour faciliter vos livraisons'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddAddressDialog(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: Text('Ajouter une adresse'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _addresses.length,
      itemBuilder: (context, index) {
        final address = _addresses[index];
        return _buildAddressCard(address);
      },
    );
  }

  Widget _buildAddressCard(Address address) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getAddressIcon(address.type),
                  color: AppTheme.primaryGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            address.label,
                            style: const TextStyle(
                              fontSize: 16,
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
                                color: AppTheme.primaryGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Par défaut'.tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
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
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleAddressAction(value, address),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit, size: 20),
                          const SizedBox(width: 8),
                          Text('Modifier'.tr()),
                        ],
                      ),
                    ),
                    if (!address.isDefault)
                      PopupMenuItem(
                        value: 'default',
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 20),
                            const SizedBox(width: 8),
                            Text('Définir par défaut'.tr()),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, size: 20, color: AppTheme.errorRed),
                          const SizedBox(width: 8),
                          Text('Supprimer'.tr(), style: const TextStyle(color: AppTheme.errorRed)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
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

  void _handleAddressAction(String action, Address address) {
    switch (action) {
      case 'edit':
        _showEditAddressDialog(address);
        break;
      case 'default':
        _setDefaultAddress(address);
        break;
      case 'delete':
        _showDeleteConfirmation(address);
        break;
    }
  }

  void _showAddAddressDialog() {
    showDialog(
      context: context,
      builder: (context) => AddAddressDialog(
        onAddressAdded: (address) {
          setState(() {
            _addresses.add(address);
          });
        },
      ),
    );
  }

  void _showEditAddressDialog(Address address) {
    showDialog(
      context: context,
      builder: (context) => EditAddressDialog(
        address: address,
        onAddressUpdated: (updatedAddress) {
          setState(() {
            final index = _addresses.indexWhere((a) => a.id == address.id);
            if (index != -1) {
              _addresses[index] = updatedAddress;
            }
          });
        },
      ),
    );
  }

  void _setDefaultAddress(Address address) {
    setState(() {
      // Remove default from all addresses
      _addresses = _addresses.map((a) => a.copyWith(isDefault: false)).toList();
      
      // Set new default
      final index = _addresses.indexWhere((a) => a.id == address.id);
      if (index != -1) {
        _addresses[index] = _addresses[index].copyWith(isDefault: true);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${address.label} définie comme adresse par défaut'.tr()),
        backgroundColor: AppTheme.successGreen,
      ),
    );
  }

  void _showDeleteConfirmation(Address address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer l\'adresse'.tr()),
        content: Text('Êtes-vous sûr de vouloir supprimer "${address.label}" ?'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _addresses.removeWhere((a) => a.id == address.id);
              });
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Adresse supprimée'.tr()),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: Text('Supprimer'.tr()),
          ),
        ],
      ),
    );
  }
}

class AddAddressDialog extends StatefulWidget {
  final Function(Address) onAddressAdded;

  const AddAddressDialog({
    super.key,
    required this.onAddressAdded,
  });

  @override
  State<AddAddressDialog> createState() => _AddAddressDialogState();
}

class _AddAddressDialogState extends State<AddAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  final _addressController = TextEditingController();
  AddressType _selectedType = AddressType.home;
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Ajouter une adresse'.tr()),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _labelController,
                decoration: InputDecoration(
                  labelText: 'Nom de l\'adresse'.tr(),
                  hintText: 'Ex: Domicile, Bureau, Chez un ami'.tr(),
                  prefixIcon: const Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom pour cette adresse'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Adresse complète'.tr(),
                  hintText: 'Ex: Cocody, Riviera 2, Villa 123, Abidjan'.tr(),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer l\'adresse complète'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AddressType>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Type d\'adresse'.tr(),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: AddressType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getAddressTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: Text('Définir comme adresse par défaut'.tr()),
                value: _isDefault,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
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
          onPressed: _isLoading ? null : _saveAddress,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text('Ajouter'.tr()),
        ),
      ],
    );
  }

  String _getAddressTypeLabel(AddressType type) {
    switch (type) {
      case AddressType.home:
        return 'Domicile'.tr();
      case AddressType.work:
        return 'Bureau'.tr();
      case AddressType.other:
        return 'Autre'.tr();
    }
  }

  void _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate geocoding - in real implementation, use Google Places API
      final address = Address(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: _labelController.text,
        fullAddress: _addressController.text,
        latitude: 5.3600 + (DateTime.now().millisecond % 100) / 1000, // Demo coordinates
        longitude: -4.0083 + (DateTime.now().millisecond % 100) / 1000,
        type: _selectedType,
        isDefault: _isDefault,
        userId: 'demo_user',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onAddressAdded(address);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Adresse ajoutée avec succès'.tr()),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'ajout de l\'adresse'.tr()),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class EditAddressDialog extends StatefulWidget {
  final Address address;
  final Function(Address) onAddressUpdated;

  const EditAddressDialog({
    super.key,
    required this.address,
    required this.onAddressUpdated,
  });

  @override
  State<EditAddressDialog> createState() => _EditAddressDialogState();
}

class _EditAddressDialogState extends State<EditAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _addressController;
  late AddressType _selectedType;
  late bool _isDefault;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.address.label);
    _addressController = TextEditingController(text: widget.address.fullAddress);
    _selectedType = widget.address.type;
    _isDefault = widget.address.isDefault;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Modifier l\'adresse'.tr()),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _labelController,
                decoration: InputDecoration(
                  labelText: 'Nom de l\'adresse'.tr(),
                  prefixIcon: const Icon(Icons.label),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un nom pour cette adresse'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Adresse complète'.tr(),
                  prefixIcon: const Icon(Icons.location_on),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer l\'adresse complète'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AddressType>(
                value: _selectedType,
                decoration: InputDecoration(
                  labelText: 'Type d\'adresse'.tr(),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: AddressType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getAddressTypeLabel(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: Text('Définir comme adresse par défaut'.tr()),
                value: _isDefault,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
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
          onPressed: _isLoading ? null : _saveAddress,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryGreen,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text('Sauvegarder'.tr()),
        ),
      ],
    );
  }

  String _getAddressTypeLabel(AddressType type) {
    switch (type) {
      case AddressType.home:
        return 'Domicile'.tr();
      case AddressType.work:
        return 'Bureau'.tr();
      case AddressType.other:
        return 'Autre'.tr();
    }
  }

  void _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedAddress = widget.address.copyWith(
        label: _labelController.text,
        fullAddress: _addressController.text,
        type: _selectedType,
        isDefault: _isDefault,
        updatedAt: DateTime.now(),
      );

      widget.onAddressUpdated(updatedAddress);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Adresse modifiée avec succès'.tr()),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la modification de l\'adresse'.tr()),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}