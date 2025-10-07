// lib/shared/widgets/pricing_widgets.dart - Comprehensive pricing widgets for the delivery platform

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:le_livreur_pro/core/models/pricing_models.dart';
import 'package:le_livreur_pro/core/providers/pricing_providers.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';

/// Comprehensive pricing calculator widget
class PricingCalculatorWidget extends ConsumerStatefulWidget {
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final VoidCallback? onPriceCalculated;

  const PricingCalculatorWidget({
    super.key,
    this.pickupLatitude,
    this.pickupLongitude,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.onPriceCalculated,
  });

  @override
  ConsumerState<PricingCalculatorWidget> createState() =>
      _PricingCalculatorWidgetState();
}

class _PricingCalculatorWidgetState
    extends ConsumerState<PricingCalculatorWidget> {
  PriorityLevel _priorityLevel = PriorityLevel.normal;
  bool _fragile = false;
  bool _isWeekend = false;
  bool _isNightDelivery = false;
  String? _categoryCode;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildLocationInfo(),
            const SizedBox(height: 16),
            _buildPricingOptions(),
            const SizedBox(height: 16),
            _buildCalculateButton(),
            const SizedBox(height: 16),
            _buildPricingResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.calculate,
          color: AppTheme.primaryGreen,
          size: 28,
        ),
        const SizedBox(width: 12),
        Text(
          'Calculateur de prix'.tr(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    if (widget.pickupLatitude == null || widget.deliveryLatitude == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.warningOrange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_off, color: AppTheme.warningOrange),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Veuillez sélectionner les adresses de collecte et de livraison'
                    .tr(),
                style: const TextStyle(color: AppTheme.warningOrange),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.successGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.my_location,
                  color: AppTheme.successGreen, size: 16),
              const SizedBox(width: 8),
              Text(
                'Collecte: ${widget.pickupLatitude!.toStringAsFixed(4)}, ${widget.pickupLongitude!.toStringAsFixed(4)}',
                style: const TextStyle(
                  color: AppTheme.successGreen,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on,
                  color: AppTheme.successGreen, size: 16),
              const SizedBox(width: 8),
              Text(
                'Livraison: ${widget.deliveryLatitude!.toStringAsFixed(4)}, ${widget.deliveryLongitude!.toStringAsFixed(4)}',
                style: const TextStyle(
                  color: AppTheme.successGreen,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPricingOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Options de livraison'.tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Priority Level
        _buildPrioritySelector(),
        const SizedBox(height: 12),

        // Additional Options
        _buildOptionCheckboxes(),
        const SizedBox(height: 12),

        // Category Selection
        _buildCategorySelector(),
      ],
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priorité'.tr(),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        ...PriorityLevel.values.map((priority) {
          return RadioListTile<PriorityLevel>(
            value: priority,
            groupValue: _priorityLevel,
            onChanged: (value) => setState(() => _priorityLevel = value!),
            title: Text(_getPriorityLabel(priority)),
            subtitle: Text(_getPriorityDescription(priority)),
            contentPadding: EdgeInsets.zero,
            dense: true,
          );
        }),
      ],
    );
  }

  Widget _buildOptionCheckboxes() {
    return Column(
      children: [
        CheckboxListTile(
          value: _fragile,
          onChanged: (value) => setState(() => _fragile = value ?? false),
          title: Text('Colis fragile'.tr()),
          subtitle: Text('Manipulation spéciale requise (+200 XOF)'.tr()),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        CheckboxListTile(
          value: _isWeekend,
          onChanged: (value) => setState(() => _isWeekend = value ?? false),
          title: Text('Livraison week-end'.tr()),
          subtitle: Text('Supplément week-end (+25%)'.tr()),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
        CheckboxListTile(
          value: _isNightDelivery,
          onChanged: (value) =>
              setState(() => _isNightDelivery = value ?? false),
          title: Text('Livraison nocturne'.tr()),
          subtitle: Text('Livraison entre 20h et 6h (+50%)'.tr()),
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    final categories = [
      {'code': 'package', 'label': 'Colis standard'},
      {'code': 'food', 'label': 'Nourriture'},
      {'code': 'pharmacy', 'label': 'Pharmacie'},
      {'code': 'grocery', 'label': 'Épicerie'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégorie'.tr(),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _categoryCode,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          hint: Text('Sélectionner une catégorie'.tr()),
          items: categories.map((category) {
            return DropdownMenuItem<String>(
              value: category['code'] as String,
              child: Text(category['label'] as String),
            );
          }).toList(),
          onChanged: (value) => setState(() => _categoryCode = value),
        ),
      ],
    );
  }

  Widget _buildCalculateButton() {
    final canCalculate =
        widget.pickupLatitude != null && widget.deliveryLatitude != null;

    final calculationState = ref.watch(pricingCalculationStateProvider);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canCalculate && !calculationState.isCalculating
            ? _calculatePricing
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: calculationState.isCalculating
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
                  Text('Calcul en cours...'),
                ],
              )
            : Text('Calculer le prix'.tr()),
      ),
    );
  }

  Widget _buildPricingResult() {
    final calculationState = ref.watch(pricingCalculationStateProvider);

    if (calculationState.errorMessage != null) {
      return _buildErrorCard(calculationState.errorMessage!);
    }

    if (calculationState.calculation != null) {
      return PricingResultWidget(calculation: calculationState.calculation!);
    }

    return const SizedBox.shrink();
  }

  Widget _buildErrorCard(String error) {
    return Container(
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
              error,
              style: const TextStyle(color: AppTheme.errorRed),
            ),
          ),
        ],
      ),
    );
  }

  void _calculatePricing() {
    if (widget.pickupLatitude == null || widget.deliveryLatitude == null) {
      return;
    }

    final request = PricingRequest(
      pickupLatitude: widget.pickupLatitude!,
      pickupLongitude: widget.pickupLongitude!,
      deliveryLatitude: widget.deliveryLatitude!,
      deliveryLongitude: widget.deliveryLongitude!,
      priorityLevel: _priorityLevel,
      fragile: _fragile,
      isWeekend: _isWeekend,
      isNightDelivery: _isNightDelivery,
      categoryCode: _categoryCode,
    );

    ref
        .read(pricingCalculationStateProvider.notifier)
        .calculatePricing(request);

    if (widget.onPriceCalculated != null) {
      widget.onPriceCalculated!();
    }
  }

  String _getPriorityLabel(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.normal:
        return 'Normale';
      case PriorityLevel.urgent:
        return 'Urgente (+200 XOF)';
      case PriorityLevel.express:
        return 'Express (+400 XOF)';
    }
  }

  String _getPriorityDescription(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.normal:
        return 'Livraison standard sous 2-4h';
      case PriorityLevel.urgent:
        return 'Livraison sous 2h';
      case PriorityLevel.express:
        return 'Livraison sous 1h';
    }
  }
}

/// Widget to display pricing calculation results
class PricingResultWidget extends StatelessWidget {
  final PricingCalculation calculation;

  const PricingResultWidget({
    super.key,
    required this.calculation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppTheme.primaryGreen.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildPriceBreakdown(),
            const SizedBox(height: 16),
            _buildCommissionInfo(),
            const SizedBox(height: 16),
            _buildDeliveryInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Prix calculé'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            '${calculation.totalPriceXof} XOF',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Détail du prix'.tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _buildBreakdownItem(
          'Prix de base (${calculation.zone.name})',
          '${calculation.basePriceXof} XOF',
        ),
        if (calculation.distancePriceXof > 0)
          _buildBreakdownItem(
            'Distance supplémentaire',
            '${calculation.distancePriceXof} XOF',
          ),
        ...calculation.appliedModifiers.map((modifier) {
          return _buildBreakdownItem(
            modifier.modifier.name,
            '${modifier.calculatedAmountXof} XOF',
            color: AppTheme.warningOrange,
          );
        }),
        const Divider(),
        _buildBreakdownItem(
          'Sous-total',
          '${calculation.subtotalXof} XOF',
          isBold: true,
        ),
      ],
    );
  }

  Widget _buildCommissionInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.infoBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Répartition des revenus'.tr(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.infoBlue,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Commission plateforme (10%)',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                '${calculation.platformCommission.toStringAsFixed(0)} XOF',
                style: const TextStyle(fontSize: 12, color: AppTheme.infoBlue),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Revenus livreur',
                style: TextStyle(fontSize: 12),
              ),
              Text(
                '${calculation.courierEarningsXof} XOF',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.successGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            Icons.straighten,
            'Distance',
            '${calculation.totalDistance.toStringAsFixed(1)} km',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildInfoCard(
            Icons.schedule,
            'Temps estimé',
            '${calculation.estimatedDuration.inMinutes} min',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildInfoCard(
            Icons.location_city,
            'Zone',
            calculation.zone.name,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownItem(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.neutralGreyLight),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppTheme.neutralGrey),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.neutralGrey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple pricing summary widget
class PricingSummaryWidget extends ConsumerWidget {
  final double pickupLatitude;
  final double pickupLongitude;
  final double deliveryLatitude;
  final double deliveryLongitude;

  const PricingSummaryWidget({
    super.key,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = PricingRequest(
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
    );

    final calculationAsync = ref.watch(pricingCalculationProvider(request));

    return calculationAsync.when(
      data: (calculation) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prix estimé'.tr(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.neutralGrey,
                  ),
                ),
                Text(
                  '${calculation.totalPriceXof} XOF',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${calculation.totalDistance.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.neutralGrey,
                  ),
                ),
                Text(
                  '~${calculation.estimatedDuration.inMinutes} min',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.neutralGrey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      loading: () => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.neutralGreyLight.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 8),
            Text('Calcul du prix...'),
          ],
        ),
      ),
      error: (error, stackTrace) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.errorRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Erreur de calcul: ${error.toString()}',
          style: const TextStyle(
            color: AppTheme.errorRed,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
