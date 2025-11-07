import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:le_livreur_pro/shared/theme/app_theme.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  final List<PaymentMethodData> _paymentMethods = [
    PaymentMethodData(
      id: 'orange_money',
      name: 'Orange Money',
      icon: Icons.phone_android,
      isConnected: true,
      phoneNumber: '+225 07 XX XX XX XX',
      description: 'Compte Orange Money connecté',
    ),
    PaymentMethodData(
      id: 'mtn_momo',
      name: 'MTN Mobile Money',
      icon: Icons.phone_android,
      isConnected: false,
      phoneNumber: null,
      description: 'Non connecté',
    ),
    PaymentMethodData(
      id: 'wave',
      name: 'Wave',
      icon: Icons.account_balance_wallet,
      isConnected: true,
      phoneNumber: '+225 05 XX XX XX XX',
      description: 'Compte Wave connecté',
    ),
    PaymentMethodData(
      id: 'moov_money',
      name: 'Moov Money',
      icon: Icons.phone_android,
      isConnected: false,
      phoneNumber: null,
      description: 'Non connecté',
    ),
    PaymentMethodData(
      id: 'visa',
      name: 'Carte Visa',
      icon: Icons.credit_card,
      isConnected: false,
      phoneNumber: null,
      description: 'Aucune carte ajoutée',
    ),
    PaymentMethodData(
      id: 'mastercard',
      name: 'Carte Mastercard',
      icon: Icons.credit_card,
      isConnected: false,
      phoneNumber: null,
      description: 'Aucune carte ajoutée',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Méthodes de paiement'.tr()),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildInfoCard(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _paymentMethods.length,
              itemBuilder: (context, index) {
                final method = _paymentMethods[index];
                return _buildPaymentMethodCard(method);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppTheme.primaryGreen,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sécurisé et pratique'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vos informations de paiement sont cryptées et sécurisées. Vous pouvez gérer vos méthodes de paiement à tout moment.'.tr(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethodData method) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: method.isConnected 
                    ? AppTheme.primaryGreen.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                method.icon,
                color: method.isConnected 
                    ? AppTheme.primaryGreen 
                    : Colors.grey[600],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    method.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (method.phoneNumber != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      method.phoneNumber!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (method.isConnected) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Connecté'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (value) => _handleMethodAction(value, method),
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
                  PopupMenuItem(
                    value: 'disconnect',
                    child: Row(
                      children: [
                        const Icon(Icons.link_off, size: 20, color: AppTheme.errorRed),
                        const SizedBox(width: 8),
                        Text('Déconnecter'.tr(), style: const TextStyle(color: AppTheme.errorRed)),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              TextButton(
                onPressed: () => _connectPaymentMethod(method),
                child: Text('Connecter'.tr()),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleMethodAction(String action, PaymentMethodData method) {
    switch (action) {
      case 'edit':
        _editPaymentMethod(method);
        break;
      case 'disconnect':
        _disconnectPaymentMethod(method);
        break;
    }
  }

  void _connectPaymentMethod(PaymentMethodData method) {
    if (method.id.contains('card')) {
      _showCardConnectionDialog(method);
    } else {
      _showMobileMoneyConnectionDialog(method);
    }
  }

  void _showMobileMoneyConnectionDialog(PaymentMethodData method) {
    final phoneController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Connecter ${method.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Entrez votre numéro ${method.name} pour le connecter à votre compte.'.tr()),
            const SizedBox(height: 16),
            TextFormField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Numéro de téléphone'.tr(),
                hintText: '+225 XX XX XX XX XX',
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              if (phoneController.text.isNotEmpty) {
                setState(() {
                  final index = _paymentMethods.indexWhere((m) => m.id == method.id);
                  _paymentMethods[index] = _paymentMethods[index].copyWith(
                    isConnected: true,
                    phoneNumber: phoneController.text,
                    description: 'Compte ${method.name} connecté',
                  );
                });
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${method.name} connecté avec succès'.tr()),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: Text('Connecter'.tr()),
          ),
        ],
      ),
    );
  }

  void _showCardConnectionDialog(PaymentMethodData method) {
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();
    final cvvController = TextEditingController();
    final nameController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter une ${method.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Numéro de carte'.tr(),
                  hintText: '1234 5678 9012 3456',
                  prefixIcon: const Icon(Icons.credit_card),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: expiryController,
                      decoration: InputDecoration(
                        labelText: 'MM/AA'.tr(),
                        hintText: '12/25',
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV'.tr(),
                        hintText: '123',
                        prefixIcon: const Icon(Icons.lock),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nom sur la carte'.tr(),
                  hintText: 'JOHN DOE',
                  prefixIcon: const Icon(Icons.person),
                ),
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
            onPressed: () {
              if (cardNumberController.text.isNotEmpty && 
                  expiryController.text.isNotEmpty &&
                  cvvController.text.isNotEmpty &&
                  nameController.text.isNotEmpty) {
                setState(() {
                  final index = _paymentMethods.indexWhere((m) => m.id == method.id);
                  _paymentMethods[index] = _paymentMethods[index].copyWith(
                    isConnected: true,
                    phoneNumber: '**** **** **** ${cardNumberController.text.substring(cardNumberController.text.length - 4)}',
                    description: 'Carte connectée',
                  );
                });
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Carte ajoutée avec succès'.tr()),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: Text('Ajouter'.tr()),
          ),
        ],
      ),
    );
  }

  void _editPaymentMethod(PaymentMethodData method) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Modification de ${method.name} bientôt disponible'.tr()),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  void _disconnectPaymentMethod(PaymentMethodData method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Déconnecter ${method.name}'),
        content: Text('Êtes-vous sûr de vouloir déconnecter ${method.name} ?'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final index = _paymentMethods.indexWhere((m) => m.id == method.id);
                _paymentMethods[index] = _paymentMethods[index].copyWith(
                  isConnected: false,
                  phoneNumber: null,
                  description: method.id.contains('card') 
                      ? 'Aucune carte ajoutée'
                      : 'Non connecté',
                );
              });
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${method.name} déconnecté'.tr()),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: Text('Déconnecter'.tr()),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodData {
  final String id;
  final String name;
  final IconData icon;
  final bool isConnected;
  final String? phoneNumber;
  final String description;

  PaymentMethodData({
    required this.id,
    required this.name,
    required this.icon,
    required this.isConnected,
    this.phoneNumber,
    required this.description,
  });

  PaymentMethodData copyWith({
    String? id,
    String? name,
    IconData? icon,
    bool? isConnected,
    String? phoneNumber,
    String? description,
  }) {
    return PaymentMethodData(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isConnected: isConnected ?? this.isConnected,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      description: description ?? this.description,
    );
  }
}