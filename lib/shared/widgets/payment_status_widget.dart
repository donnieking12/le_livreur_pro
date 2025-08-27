import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:le_livreur_pro/core/models/payment_models.dart';
import 'package:le_livreur_pro/core/providers/payment_providers.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';

class PaymentStatusWidget extends ConsumerWidget {
  final String paymentRef;
  final bool showDetails;
  final VoidCallback? onRetry;
  final VoidCallback? onCancel;

  const PaymentStatusWidget({
    super.key,
    required this.paymentRef,
    this.showDetails = true,
    this.onRetry,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentStatusAsync = ref.watch(paymentStatusProvider(paymentRef));

    return paymentStatusAsync.when(
      data: (status) => _buildStatusCard(context, status),
      loading: () => _buildLoadingCard(),
      error: (error, stackTrace) => _buildErrorCard(context, error.toString()),
    );
  }

  Widget _buildStatusCard(BuildContext context, String status) {
    final statusInfo = _getStatusInfo(status);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  statusInfo.icon,
                  color: statusInfo.color,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusInfo.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        statusInfo.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.neutralGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (statusInfo.showProgress)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(statusInfo.color),
                    ),
                  ),
              ],
            ),
            if (showDetails) ...[
              const SizedBox(height: 12),
              _buildPaymentReference(),
            ],
            if (statusInfo.showActions) ...[
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 12),
            Text('Vérification du statut de paiement...'.tr()),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppTheme.errorRed,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Erreur de vérification'.tr(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Impossible de vérifier le statut du paiement'.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.neutralGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              error,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.errorRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentReference() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.neutralGreyLight,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.receipt_outlined,
            size: 16,
            color: AppTheme.neutralGrey,
          ),
          const SizedBox(width: 8),
          Text(
            'Référence: $paymentRef'.tr(),
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: AppTheme.neutralGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (onRetry != null)
          Expanded(
            child: OutlinedButton(
              onPressed: onRetry,
              child: Text('Réessayer'.tr()),
            ),
          ),
        if (onRetry != null && onCancel != null) const SizedBox(width: 12),
        if (onCancel != null)
          Expanded(
            child: ElevatedButton(
              onPressed: onCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
              ),
              child: Text('Annuler'.tr()),
            ),
          ),
      ],
    );
  }

  PaymentStatusInfo _getStatusInfo(String status) {
    switch (status) {
      case 'pending':
        return PaymentStatusInfo(
          title: 'Paiement en attente'.tr(),
          description: 'Votre paiement est en cours de traitement'.tr(),
          icon: Icons.schedule,
          color: AppTheme.warningOrange,
          showProgress: true,
          showActions: true,
        );
      case 'processing':
        return PaymentStatusInfo(
          title: 'Traitement en cours'.tr(),
          description: 'Votre paiement est en cours de vérification'.tr(),
          icon: Icons.sync,
          color: AppTheme.infoBlue,
          showProgress: true,
          showActions: false,
        );
      case 'completed':
        return PaymentStatusInfo(
          title: 'Paiement réussi'.tr(),
          description: 'Votre paiement a été traité avec succès'.tr(),
          icon: Icons.check_circle,
          color: AppTheme.successGreen,
          showProgress: false,
          showActions: false,
        );
      case 'failed':
        return PaymentStatusInfo(
          title: 'Paiement échoué'.tr(),
          description: 'Le paiement n\'a pas pu être traité'.tr(),
          icon: Icons.error,
          color: AppTheme.errorRed,
          showProgress: false,
          showActions: true,
        );
      case 'refunded':
        return PaymentStatusInfo(
          title: 'Paiement remboursé'.tr(),
          description: 'Le montant a été remboursé sur votre compte'.tr(),
          icon: Icons.undo,
          color: AppTheme.neutralGrey,
          showProgress: false,
          showActions: false,
        );
      default:
        return PaymentStatusInfo(
          title: 'Statut inconnu'.tr(),
          description: 'Le statut du paiement ne peut être déterminé'.tr(),
          icon: Icons.help_outline,
          color: AppTheme.neutralGrey,
          showProgress: false,
          showActions: true,
        );
    }
  }
}

class PaymentStatusInfo {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool showProgress;
  final bool showActions;

  const PaymentStatusInfo({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.showProgress,
    required this.showActions,
  });
}

class PaymentHistoryWidget extends ConsumerWidget {
  final String userId;
  final int limit;

  const PaymentHistoryWidget({
    super.key,
    required this.userId,
    this.limit = 10,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentHistoryAsync = ref.watch(paymentHistoryProvider(userId));

    return paymentHistoryAsync.when(
      data: (transactions) => _buildHistoryList(transactions),
      loading: () => _buildLoadingList(),
      error: (error, stackTrace) => _buildErrorWidget(error.toString()),
    );
  }

  Widget _buildHistoryList(List<PaymentTransaction> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.payment,
              size: 64,
              color: AppTheme.neutralGrey,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun historique de paiement'.tr(),
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.neutralGrey,
              ),
            ),
          ],
        ),
      );
    }

    final limitedTransactions = transactions.take(limit).toList();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: limitedTransactions.length,
      itemBuilder: (context, index) {
        final transaction = limitedTransactions[index];
        return _buildTransactionCard(transaction);
      },
    );
  }

  Widget _buildTransactionCard(PaymentTransaction transaction) {
    final statusInfo = _getTransactionStatusInfo(transaction);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          statusInfo.icon,
          color: statusInfo.color,
        ),
        title: Text(
          _getProviderDisplayName(transaction.provider),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${transaction.amount} ${transaction.currency}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              DateFormat('dd/MM/yyyy HH:mm').format(transaction.createdAt),
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.neutralGrey,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusInfo.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusInfo.label,
            style: TextStyle(
              fontSize: 12,
              color: statusInfo.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () => _showTransactionDetails(transaction),
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.neutralGreyLight,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            title: Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.neutralGreyLight,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            subtitle: Container(
              height: 12,
              width: 100,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                color: AppTheme.neutralGreyLight,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppTheme.errorRed,
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement'.tr(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.neutralGrey,
            ),
          ),
        ],
      ),
    );
  }

  TransactionStatusInfo _getTransactionStatusInfo(
      PaymentTransaction transaction) {
    if (transaction.isSuccess) {
      return TransactionStatusInfo(
        label: 'Réussi'.tr(),
        icon: Icons.check_circle,
        color: AppTheme.successGreen,
      );
    } else if (transaction.isPending) {
      return TransactionStatusInfo(
        label: 'En cours'.tr(),
        icon: Icons.schedule,
        color: AppTheme.warningOrange,
      );
    } else {
      return TransactionStatusInfo(
        label: 'Échoué'.tr(),
        icon: Icons.error,
        color: AppTheme.errorRed,
      );
    }
  }

  String _getProviderDisplayName(PaymentProvider provider) {
    switch (provider) {
      case PaymentProvider.orangeMoney:
        return 'Orange Money';
      case PaymentProvider.mtnMoney:
        return 'MTN Money';
      case PaymentProvider.moovMoney:
        return 'Moov Money';
      case PaymentProvider.wave:
        return 'Wave';
      case PaymentProvider.visa:
        return 'Visa';
      case PaymentProvider.mastercard:
        return 'Mastercard';
      case PaymentProvider.cash:
        return 'Espèces';
    }
  }

  void _showTransactionDetails(PaymentTransaction transaction) {
    // TODO: Implement transaction details dialog
  }
}

class TransactionStatusInfo {
  final String label;
  final IconData icon;
  final Color color;

  const TransactionStatusInfo({
    required this.label,
    required this.icon,
    required this.color,
  });
}
