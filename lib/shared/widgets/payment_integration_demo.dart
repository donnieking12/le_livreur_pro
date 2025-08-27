import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:le_livreur_pro/core/models/payment_models.dart';
import 'package:le_livreur_pro/core/providers/payment_providers.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';
import 'package:le_livreur_pro/shared/widgets/payment_status_widget.dart';

/// Comprehensive payment integration demo widget showcasing all new payment features
///
/// This widget demonstrates:
/// - Real-time payment method configuration
/// - Dynamic payment method filtering by amount
/// - Payment cost calculation with fees
/// - Live payment processing with state management
/// - Real-time payment status tracking
/// - Payment history and summaries
/// - Comprehensive error handling
class PaymentIntegrationDemo extends ConsumerStatefulWidget {
  final double demoAmount;

  const PaymentIntegrationDemo({
    super.key,
    this.demoAmount = 5000.0,
  });

  @override
  ConsumerState<PaymentIntegrationDemo> createState() =>
      _PaymentIntegrationDemoState();
}

class _PaymentIntegrationDemoState
    extends ConsumerState<PaymentIntegrationDemo> {
  PaymentMethodConfiguration? _selectedMethod;
  String? _currentPaymentRef;
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Integration Demo'.tr()),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildPaymentMethodsSection(),
            const SizedBox(height: 16),
            if (_selectedMethod != null) ...[
              _buildSelectedMethodDetails(),
              const SizedBox(height: 16),
            ],
            _buildPaymentActions(),
            const SizedBox(height: 16),
            if (_currentPaymentRef != null) ...[
              _buildPaymentStatusSection(),
              const SizedBox(height: 16),
            ],
            _buildPaymentHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Integration Demo'.tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Démonstration complète des fonctionnalités de paiement pour la Côte d\'Ivoire'
                  .tr(),
              style: const TextStyle(
                color: AppTheme.neutralGrey,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.monetization_on, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'Montant de démonstration: ${widget.demoAmount.toStringAsFixed(0)} XOF',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsSection() {
    final enabledMethods = ref.watch(enabledPaymentMethodsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Méthodes de paiement disponibles'.tr(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...enabledMethods.map((method) {
              final isAvailable = ref.watch(paymentMethodAvailabilityProvider(
                PaymentMethodAvailabilityRequest(
                  configuration: method,
                  amount: widget.demoAmount,
                  currency: 'XOF',
                ),
              ));

              if (!isAvailable) return const SizedBox.shrink();

              return _buildMethodCard(method);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodCard(PaymentMethodConfiguration method) {
    final isSelected = _selectedMethod?.name == method.name;
    final totalCost = ref.watch(paymentTotalCostProvider(
      PaymentCostRequest(
        configuration: method,
        amount: widget.demoAmount,
      ),
    ));

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? AppTheme.primaryGreen.withOpacity(0.1) : null,
      child: ListTile(
        leading: _getMethodIcon(method),
        title: Text(
          method.displayName,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(method.description),
            if (method.processingFee > 0)
              Text(
                'Total avec frais: ${totalCost.toStringAsFixed(0)} XOF',
                style: const TextStyle(
                  color: AppTheme.warningOrange,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (method.isInstant)
              const Icon(
                Icons.flash_on,
                color: AppTheme.successGreen,
                size: 16,
              ),
            if (method.requiresPhoneNumber)
              const Icon(
                Icons.phone,
                color: AppTheme.infoBlue,
                size: 16,
              ),
            if (method.requiresCardDetails)
              const Icon(
                Icons.credit_card,
                color: AppTheme.warningOrange,
                size: 16,
              ),
          ],
        ),
        onTap: () => setState(() => _selectedMethod = method),
        selected: isSelected,
      ),
    );
  }

  Widget _buildSelectedMethodDetails() {
    final method = _selectedMethod!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Détails de la méthode sélectionnée'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow('Nom:', method.displayName),
            _buildDetailRow('Provider:', method.provider.name.toUpperCase()),
            _buildDetailRow('Instantané:', method.isInstant ? 'Oui' : 'Non'),
            _buildDetailRow('Frais:',
                '${(method.processingFee * 100).toStringAsFixed(1)}%'),
            _buildDetailRow('Min:', '${method.minimumAmount} XOF'),
            _buildDetailRow('Max:', '${method.maximumAmount} XOF'),
            if (method.requiresPhoneNumber) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Numéro de téléphone'.tr(),
                  prefixText: '+225 ',
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildPaymentActions() {
    final paymentState = ref.watch(paymentProcessingProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions de paiement'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (paymentState.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: AppTheme.errorRed),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        paymentState.errorMessage!,
                        style: const TextStyle(color: AppTheme.errorRed),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _selectedMethod != null && !paymentState.isProcessing
                            ? _processDemo
                            : null,
                    child: paymentState.isProcessing
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Traitement...'),
                            ],
                          )
                        : Text('Lancer démonstration'.tr()),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _clearDemo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neutralGrey,
                  ),
                  child: Text('Effacer'.tr()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statut du paiement en temps réel'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            PaymentStatusWidget(
              paymentRef: _currentPaymentRef!,
              showDetails: true,
              onRetry: _processDemo,
              onCancel: _clearDemo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentHistorySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Historique des paiements'.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const PaymentHistoryWidget(
              userId: 'demo-user-id',
              limit: 5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getMethodIcon(PaymentMethodConfiguration method) {
    IconData iconData;
    Color color;

    switch (method.provider) {
      case PaymentProvider.orangeMoney:
        iconData = Icons.phone_android;
        color = Colors.orange;
        break;
      case PaymentProvider.mtnMoney:
        iconData = Icons.phone_android;
        color = Colors.yellow.shade700;
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

  Future<void> _processDemo() async {
    if (_selectedMethod == null) return;

    final paymentDetails = <String, dynamic>{};
    if (_selectedMethod!.requiresPhoneNumber &&
        _phoneController.text.isNotEmpty) {
      paymentDetails['phone_number'] = '+225${_phoneController.text}';
    }

    await ref.read(paymentProcessingProvider.notifier).processPayment(
          paymentMethodId: _selectedMethod!.name,
          orderId: 'demo-order-${DateTime.now().millisecondsSinceEpoch}',
          amount: widget.demoAmount,
          currency: 'XOF',
          userId: 'demo-user-id',
          customerDetails: {
            'name': 'Demo User',
            'phone': '+2250700000000',
            'email': 'demo@lelivreurpro.ci',
          },
          paymentDetails: paymentDetails,
        );

    final result = ref.read(paymentProcessingProvider).result;
    if (result?.paymentRef != null) {
      setState(() {
        _currentPaymentRef = result!.paymentRef;
      });
    }
  }

  void _clearDemo() {
    setState(() {
      _selectedMethod = null;
      _currentPaymentRef = null;
    });
    _phoneController.clear();
    ref.read(paymentProcessingProvider.notifier).clearState();
  }
}
