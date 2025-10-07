import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:le_livreur_pro/core/models/delivery_order.dart';
import 'package:le_livreur_pro/core/models/payment_models.dart';
import 'package:le_livreur_pro/core/services/auth_service.dart';
import 'package:le_livreur_pro/core/services/order_service.dart';
import 'package:le_livreur_pro/core/providers/payment_providers.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';
import 'package:le_livreur_pro/shared/widgets/payment_status_widget.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> orderData;

  const PaymentScreen({
    super.key,
    required this.orderData,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PaymentMethodConfiguration? _selectedPaymentMethod;
  final _phoneController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  String? _currentPaymentRef;

  @override
  void dispose() {
    _phoneController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch payment processing state
    final paymentProcessingState = ref.watch(paymentProcessingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Paiement'.tr()),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderSummary(),
            const SizedBox(height: 24),
            _buildPaymentMethods(),
            const SizedBox(height: 24),
            if (_selectedPaymentMethod != null) ...[
              _buildPaymentDetails(),
              const SizedBox(height: 24),
            ],
            if (_currentPaymentRef != null) ...[
              PaymentStatusWidget(
                paymentRef: _currentPaymentRef!,
                showDetails: true,
                onRetry: _retryPayment,
                onCancel: _cancelPayment,
              ),
              const SizedBox(height: 24),
            ],
            _buildPaymentButton(),
            if (paymentProcessingState.isProcessing) ...[
              const SizedBox(height: 16),
              _buildProcessingIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Récapitulatif de la commande'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Colis:'.tr()),
                Expanded(
                  child: Text(
                    widget.orderData['packageDescription'],
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('De:'.tr()),
                Expanded(
                  child: Text(
                    widget.orderData['pickupAddress'],
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('À:'.tr()),
                Expanded(
                  child: Text(
                    widget.orderData['deliveryAddress'],
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total à payer:'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.orderData['totalPriceXof']} XOF',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    // Watch enabled payment methods
    final enabledMethods = ref.watch(enabledPaymentMethodsProvider);
    final orderAmount = (widget.orderData['totalPriceXof'] as int).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Méthode de paiement'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...enabledMethods.map((method) {
          // Check if method is available for this amount
          final isAvailable = ref.watch(paymentMethodAvailabilityProvider(
            PaymentMethodAvailabilityRequest(
              configuration: method,
              amount: orderAmount,
              currency: 'XOF',
            ),
          ));

          if (!isAvailable) return const SizedBox.shrink();

          return _buildPaymentMethodCard(method);
        }),
      ],
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethodConfiguration method) {
    final isSelected = _selectedPaymentMethod?.name == method.name;
    final orderAmount = (widget.orderData['totalPriceXof'] as int).toDouble();
    final totalCost = ref.watch(paymentTotalCostProvider(
      PaymentCostRequest(
        configuration: method,
        amount: orderAmount,
      ),
    ));

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedPaymentMethod = method),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Radio<String>(
                value: method.name,
                groupValue: _selectedPaymentMethod?.name,
                onChanged: (value) => setState(() {
                  _selectedPaymentMethod = method;
                }),
                activeColor: AppTheme.primaryGreen,
              ),
              const SizedBox(width: 12),
              _getPaymentMethodIcon(method),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      method.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.neutralGrey,
                      ),
                    ),
                    if (method.processingFee > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Total: ${totalCost.toStringAsFixed(0)} XOF',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.warningOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (method.requiresPhoneNumber)
                const Icon(
                  Icons.phone,
                  color: AppTheme.neutralGrey,
                  size: 20,
                ),
              if (method.requiresCardDetails)
                const Icon(
                  Icons.credit_card,
                  color: AppTheme.neutralGrey,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getPaymentMethodIcon(PaymentMethodConfiguration method) {
    IconData iconData;
    Color color;

    switch (method.provider) {
      case PaymentProvider.orangeMoney:
        iconData = Icons.phone_android;
        color = Colors.orange;
        break;
      case PaymentProvider.mtnMoney:
        iconData = Icons.phone_android;
        color = Colors.yellow;
        break;
      case PaymentProvider.moovMoney:
        iconData = Icons.phone_android;
        color = Colors.blue;
        break;
      case PaymentProvider.wave:
        iconData = Icons.waves;
        color = Colors.blue;
        break;
      case PaymentProvider.visa:
        iconData = Icons.credit_card;
        color = Colors.blue;
        break;
      case PaymentProvider.mastercard:
        iconData = Icons.credit_card;
        color = Colors.red;
        break;
      case PaymentProvider.cash:
        iconData = Icons.money;
        color = AppTheme.successGreen;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildPaymentDetails() {
    if (_selectedPaymentMethod == null) return const SizedBox.shrink();

    if (_selectedPaymentMethod!.requiresPhoneNumber) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Détails du paiement'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone'.tr(),
                  prefixText: '+225 ',
                  border: const OutlineInputBorder(),
                  hintText: '07 00 00 00 00',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              Text(
                'Un code de confirmation sera envoyé à ce numéro'.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.neutralGrey,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (_selectedPaymentMethod!.requiresCardDetails) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Informations de carte'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: 'Numéro de carte'.tr(),
                  border: const OutlineInputBorder(),
                  hintText: '1234 5678 9012 3456',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      decoration: InputDecoration(
                        labelText: 'MM/YY'.tr(),
                        border: const OutlineInputBorder(),
                        hintText: '12/25',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      decoration: InputDecoration(
                        labelText: 'CVV'.tr(),
                        border: const OutlineInputBorder(),
                        hintText: '123',
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (_selectedPaymentMethod!.provider == PaymentProvider.cash) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppTheme.infoBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Paiement à la livraison'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Vous paierez en espèces au livreur lors de la réception du colis.'
                    .tr(),
                style: const TextStyle(
                  color: AppTheme.neutralGrey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Montant à préparer: ${widget.orderData['totalPriceXof']} XOF'
                    .tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPaymentButton() {
    final paymentProcessingState = ref.watch(paymentProcessingProvider);
    final canProceed = _selectedPaymentMethod != null &&
        (!_selectedPaymentMethod!.requiresPhoneNumber ||
            _phoneController.text.isNotEmpty) &&
        (!_selectedPaymentMethod!.requiresCardDetails ||
            (_cardNumberController.text.isNotEmpty &&
                _expiryController.text.isNotEmpty &&
                _cvvController.text.isNotEmpty));

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canProceed && !paymentProcessingState.isProcessing
            ? _processPayment
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: paymentProcessingState.isProcessing
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Traitement en cours...'),
                ],
              )
            : Text(
                _selectedPaymentMethod?.provider == PaymentProvider.cash
                    ? 'Confirmer la commande'.tr()
                    : 'Procéder au paiement'.tr(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) return;

    try {
      final userAsync = ref.read(currentUserProfileProvider);
      final user = userAsync.value;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Validate payment details
      if (_selectedPaymentMethod!.requiresPhoneNumber &&
          _phoneController.text.length < 8) {
        throw Exception('Numéro de téléphone invalide');
      }

      if (_selectedPaymentMethod!.requiresCardDetails) {
        if (_cardNumberController.text.length < 13 ||
            _expiryController.text.length < 5 ||
            _cvvController.text.length < 3) {
          throw Exception('Informations de carte incomplètes');
        }
      }

      // Create the order
      final order = await ref.read(orderServiceProvider).createPackageOrder(
            customerId: user.id,
            packageDescription: widget.orderData['packageDescription'],
            pickupLatitude: widget.orderData['pickupLatitude'],
            pickupLongitude: widget.orderData['pickupLongitude'],
            deliveryLatitude: widget.orderData['deliveryLatitude'],
            deliveryLongitude: widget.orderData['deliveryLongitude'],
            pickupAddress: widget.orderData['pickupAddress'],
            deliveryAddress: widget.orderData['deliveryAddress'],
            recipientName: widget.orderData['recipientName'],
            recipientPhone: widget.orderData['recipientPhone'],
            recipientEmail: widget.orderData['recipientEmail'],
            specialInstructions: widget.orderData['specialInstructions'],
            paymentMethod: PaymentMethod.values.firstWhere(
              (method) => method.name == _selectedPaymentMethod!.name,
              orElse: () => PaymentMethod.cashOnDelivery,
            ),
            packageValueXof: widget.orderData['packageValueXof'] ?? 0,
            fragile: widget.orderData['fragile'] ?? false,
            requiresSignature: widget.orderData['requiresSignature'] ?? false,
            priorityLevel: widget.orderData['priorityLevel'] ?? 1,
          );

      // Process payment if not cash on delivery
      if (_selectedPaymentMethod!.provider != PaymentProvider.cash) {
        // Prepare payment details
        final Map<String, dynamic> paymentDetails = {};

        if (_selectedPaymentMethod!.requiresPhoneNumber) {
          paymentDetails['phone_number'] = '+225${_phoneController.text}';
        }

        if (_selectedPaymentMethod!.requiresCardDetails) {
          paymentDetails.addAll({
            'card_number': _cardNumberController.text,
            'expiry_month': int.parse(_expiryController.text.split('/')[0]),
            'expiry_year':
                2000 + int.parse(_expiryController.text.split('/')[1]),
            'cvv': _cvvController.text,
          });
        }

        // Use payment provider to process payment
        await ref.read(paymentProcessingProvider.notifier).processPayment(
              paymentMethodId: _selectedPaymentMethod!.name,
              orderId: order.id,
              amount: (widget.orderData['totalPriceXof'] as int).toDouble(),
              currency: 'XOF',
              userId: user.id,
              customerDetails: {
                'name': user.fullName,
                'phone': _selectedPaymentMethod!.requiresPhoneNumber
                    ? '+225${_phoneController.text}'
                    : user.phone,
                'email': user.email,
              },
              paymentDetails: paymentDetails,
            );

        // Check payment result
        final paymentState = ref.read(paymentProcessingProvider);
        if (paymentState.result?.isSuccess == false) {
          // Cancel the order if payment failed
          await ref.read(orderServiceProvider).cancelOrder(
                order.id,
                'Échec du paiement: ${paymentState.result?.errorMessage}',
              );
          throw Exception(
              paymentState.result?.errorMessage ?? 'Échec du paiement');
        }

        // Store payment reference for status tracking
        if (paymentState.result?.paymentRef != null) {
          setState(() {
            _currentPaymentRef = paymentState.result!.paymentRef;
          });
        }
      }

      // Show success dialog
      if (mounted) {
        _showSuccessDialog(order);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'.tr()),
            backgroundColor: AppTheme.errorRed,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showSuccessDialog(DeliveryOrder order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Commande confirmée !'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppTheme.successGreen,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Votre commande ${order.orderNumber} a été créée avec succès.'
                  .tr(),
              textAlign: TextAlign.center,
            ),
            if (_selectedPaymentMethod?.provider == PaymentProvider.cash)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Préparez ${widget.orderData['totalPriceXof']} XOF pour le paiement à la livraison.'
                      .tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.warningOrange,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close payment screen
              Navigator.pop(context); // Close create order screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGreen,
            ),
            child: Text('Retour à l\'accueil'.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingIndicator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Traitement du paiement en cours...'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Veuillez patienter pendant que nous traitons votre paiement.'
                  .tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.neutralGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _retryPayment() {
    // Clear current payment reference and retry
    setState(() {
      _currentPaymentRef = null;
    });
    ref.read(paymentProcessingProvider.notifier).clearState();
    _processPayment();
  }

  void _cancelPayment() {
    setState(() {
      _currentPaymentRef = null;
    });
    ref.read(paymentProcessingProvider.notifier).clearState();
  }
}
