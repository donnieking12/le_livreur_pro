import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import 'package:le_livreur_pro/core/models/delivery_order_simple.dart';
import 'package:le_livreur_pro/core/services/auth_service.dart';
import 'package:le_livreur_pro/core/services/order_service.dart';
import 'package:le_livreur_pro/core/services/pricing_service.dart';
import 'package:le_livreur_pro/shared/theme/app_theme.dart';
import 'package:le_livreur_pro/features/orders/presentation/screens/payment_screen.dart';

class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _packageDescriptionController = TextEditingController();
  final _pickupAddressController = TextEditingController();
  final _deliveryAddressController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  final _recipientEmailController = TextEditingController();
  final _specialInstructionsController = TextEditingController();

  int _currentStep = 0;
  bool _fragile = false;
  bool _requiresSignature = false;
  int _priorityLevel = 1;
  int _packageValueXof = 0;

  // Location data
  double? _pickupLatitude;
  double? _pickupLongitude;
  double? _deliveryLatitude;
  double? _deliveryLongitude;

  // Pricing data
  Map<String, dynamic>? _pricingResult;
  bool _isCalculatingPrice = false;

  @override
  void dispose() {
    _packageDescriptionController.dispose();
    _pickupAddressController.dispose();
    _deliveryAddressController.dispose();
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _recipientEmailController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nouvelle Livraison'.tr()),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepTapped: (step) => setState(() => _currentStep = step),
          controlsBuilder: (context, details) {
            return Row(
              children: [
                if (details.stepIndex > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: Text('Précédent'.tr()),
                  ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                  child: Text(
                    details.stepIndex == 3
                        ? 'Procéder au paiement'.tr()
                        : 'Suivant'.tr(),
                  ),
                ),
              ],
            );
          },
          steps: [
            Step(
              title: Text('Détails du colis'.tr()),
              content: _buildPackageDetailsStep(),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
            ),
            Step(
              title: Text('Adresses'.tr()),
              content: _buildAddressesStep(),
              isActive: _currentStep >= 1,
              state: _currentStep > 1
                  ? StepState.complete
                  : _currentStep == 1
                      ? StepState.indexed
                      : StepState.disabled,
            ),
            Step(
              title: Text('Destinataire'.tr()),
              content: _buildRecipientStep(),
              isActive: _currentStep >= 2,
              state: _currentStep > 2
                  ? StepState.complete
                  : _currentStep == 2
                      ? StepState.indexed
                      : StepState.disabled,
            ),
            Step(
              title: Text('Confirmation'.tr()),
              content: _buildConfirmationStep(),
              isActive: _currentStep >= 3,
              state: _currentStep == 3 ? StepState.indexed : StepState.disabled,
            ),
          ],
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
        ),
      ),
    );
  }

  Widget _buildPackageDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _packageDescriptionController,
          decoration: InputDecoration(
            labelText: 'Description du colis'.tr(),
            hintText: 'Ex: Documents, vêtements, nourriture...'.tr(),
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez décrire le contenu du colis'.tr();
            }
            return null;
          },
          maxLines: 2,
        ),
        const SizedBox(height: 20),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Valeur déclarée (XOF)'.tr(),
            hintText: '0'.tr(),
            border: const OutlineInputBorder(),
            suffixText: 'XOF',
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              _packageValueXof = int.tryParse(value) ?? 0;
            });
          },
        ),
        const SizedBox(height: 20),
        Text(
          'Options de livraison'.tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          title: Text('Colis fragile'.tr()),
          subtitle: Text('Manutention délicate requise'.tr()),
          value: _fragile,
          onChanged: (value) => setState(() => _fragile = value ?? false),
          activeColor: AppTheme.primaryGreen,
        ),
        CheckboxListTile(
          title: Text('Signature requise'.tr()),
          subtitle: Text('Le destinataire doit signer à la livraison'.tr()),
          value: _requiresSignature,
          onChanged: (value) =>
              setState(() => _requiresSignature = value ?? false),
          activeColor: AppTheme.primaryGreen,
        ),
        const SizedBox(height: 20),
        Text(
          'Priorité de livraison'.tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<int>(
          segments: [
            ButtonSegment(
              value: 1,
              label: Text('Standard'.tr()),
              icon: const Icon(Icons.schedule),
            ),
            ButtonSegment(
              value: 2,
              label: Text('Urgent'.tr()),
              icon: const Icon(Icons.fast_forward),
            ),
            ButtonSegment(
              value: 3,
              label: Text('Express'.tr()),
              icon: const Icon(Icons.flash_on),
            ),
          ],
          selected: {_priorityLevel},
          onSelectionChanged: (Set<int> selection) {
            setState(() => _priorityLevel = selection.first);
          },
        ),
      ],
    );
  }

  Widget _buildAddressesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adresse de ramassage'.tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _pickupAddressController,
          decoration: InputDecoration(
            labelText: 'Adresse complète de ramassage'.tr(),
            hintText: 'Ex: Cocody, Angré 8ème tranche, Villa 123'.tr(),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _getCurrentLocation,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir l\'adresse de ramassage'.tr();
            }
            return null;
          },
          maxLines: 2,
        ),
        const SizedBox(height: 20),
        Text(
          'Adresse de livraison'.tr(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _deliveryAddressController,
          decoration: InputDecoration(
            labelText: 'Adresse complète de livraison'.tr(),
            hintText: 'Ex: Plateau, Immeuble BCEAO, 2ème étage'.tr(),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.location_on),
              onPressed: _selectDeliveryLocation,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir l\'adresse de livraison'.tr();
            }
            return null;
          },
          maxLines: 2,
          onChanged: (value) => _calculatePricing(),
        ),
        const SizedBox(height: 20),
        if (_pricingResult != null) ...[
          Card(
            color: AppTheme.successGreen.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimation du coût'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Distance estimée:'.tr()),
                      Text(
                          '${(_pricingResult!['distanceKm'] as double).toStringAsFixed(1)} km'),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Prix de base:'.tr()),
                      Text('${_pricingResult!['basePriceXof']} XOF'),
                    ],
                  ),
                  if ((_pricingResult!['additionalDistancePriceXof'] as int) >
                      0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Distance supplémentaire:'.tr()),
                        Text(
                            '${_pricingResult!['additionalDistancePriceXof']} XOF'),
                      ],
                    ),
                  if ((_pricingResult!['urgencyPriceXof'] as int) > 0)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Supplément urgence:'.tr()),
                        Text('${_pricingResult!['urgencyPriceXof']} XOF'),
                      ],
                    ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total:'.tr(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_pricingResult!['totalPriceXof']} XOF',
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
          ),
        ] else if (_isCalculatingPrice) ...[
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Calcul du prix en cours...'),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRecipientStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _recipientNameController,
          decoration: InputDecoration(
            labelText: 'Nom complet du destinataire'.tr(),
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir le nom du destinataire'.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _recipientPhoneController,
          decoration: InputDecoration(
            labelText: 'Téléphone du destinataire'.tr(),
            border: const OutlineInputBorder(),
            prefixText: '+225 ',
          ),
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez saisir le téléphone du destinataire'.tr();
            }
            if (value.length < 8) {
              return 'Numéro de téléphone invalide'.tr();
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _recipientEmailController,
          decoration: InputDecoration(
            labelText: 'Email du destinataire (optionnel)'.tr(),
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _specialInstructionsController,
          decoration: InputDecoration(
            labelText: 'Instructions spéciales (optionnel)'.tr(),
            hintText: 'Ex: Sonner à l\'interphone, demander M. Koffi...'.tr(),
            border: const OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildConfirmationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Récapitulatif de la commande'.tr(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow(
                    'Colis:'.tr(), _packageDescriptionController.text),
                if (_packageValueXof > 0)
                  _buildSummaryRow(
                      'Valeur déclarée:'.tr(), '$_packageValueXof XOF'),
                _buildSummaryRow(
                    'Priorité:'.tr(), _getPriorityText(_priorityLevel)),
                if (_fragile) _buildSummaryRow('Options:'.tr(), 'Fragile'),
                const Divider(),
                _buildSummaryRow('De:'.tr(), _pickupAddressController.text),
                _buildSummaryRow('À:'.tr(), _deliveryAddressController.text),
                const Divider(),
                _buildSummaryRow(
                    'Destinataire:'.tr(), _recipientNameController.text),
                _buildSummaryRow('Téléphone:'.tr(),
                    '+225 ${_recipientPhoneController.text}'),
                if (_recipientEmailController.text.isNotEmpty)
                  _buildSummaryRow(
                      'Email:'.tr(), _recipientEmailController.text),
                if (_specialInstructionsController.text.isNotEmpty)
                  _buildSummaryRow('Instructions:'.tr(),
                      _specialInstructionsController.text),
                const Divider(),
                if (_pricingResult != null)
                  _buildSummaryRow(
                    'Total à payer:'.tr(),
                    '${_pricingResult!['totalPriceXof']} XOF',
                    isTotal: true,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                color: AppTheme.neutralGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 16 : 14,
                color: isTotal ? AppTheme.primaryGreen : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPriorityText(int level) {
    switch (level) {
      case 1:
        return 'Standard';
      case 2:
        return 'Urgent';
      case 3:
        return 'Express';
      default:
        return 'Standard';
    }
  }

  void _onStepContinue() {
    if (_currentStep < 3) {
      if (_validateCurrentStep()) {
        setState(() => _currentStep++);
        if (_currentStep == 1) {
          _calculatePricing();
        }
      }
    } else {
      _proceedToPayment();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _packageDescriptionController.text.isNotEmpty;
      case 1:
        return _pickupAddressController.text.isNotEmpty &&
            _deliveryAddressController.text.isNotEmpty;
      case 2:
        return _recipientNameController.text.isNotEmpty &&
            _recipientPhoneController.text.isNotEmpty;
      case 3:
        return true;
      default:
        return false;
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Permission de localisation refusée'.tr()),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _pickupLatitude = position.latitude;
        _pickupLongitude = position.longitude;
      });

      // TODO: Reverse geocoding to get address
      _pickupAddressController.text =
          'Localisation actuelle (${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)})';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Localisation obtenue'.tr()),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la localisation: $e'.tr()),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  void _selectDeliveryLocation() {
    // TODO: Implement location picker (Google Maps)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sélection de localisation bientôt disponible'.tr()),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  Future<void> _calculatePricing() async {
    if (_pickupAddressController.text.isEmpty ||
        _deliveryAddressController.text.isEmpty) {
      return;
    }

    setState(() => _isCalculatingPrice = true);

    try {
      // For demo purposes, use default coordinates if not set
      final pickupLat = _pickupLatitude ?? 5.3364;
      final pickupLng = _pickupLongitude ?? -4.0267;
      final deliveryLat = _deliveryLatitude ?? 5.2893;
      final deliveryLng = _deliveryLongitude ?? -3.9926;

      // Calculate distance
      final distanceKm = PricingService.calculateDistance(
        lat1: pickupLat,
        lon1: pickupLng,
        lat2: deliveryLat,
        lon2: deliveryLng,
      );

      // Get pricing breakdown
      final pricing = PricingService.getPricingBreakdown(
        distanceKm: distanceKm,
        priorityLevel: _priorityLevel,
        fragile: _fragile,
      );

      setState(() {
        _pricingResult = {
          'distanceKm': distanceKm,
          'basePriceXof': pricing['basePrice'],
          'additionalDistancePriceXof': pricing['distancePrice'],
          'urgencyPriceXof': pricing['priorityPrice'],
          'fragilePriceXof': pricing['fragilePrice'],
          'totalPriceXof': pricing['totalPrice'],
          'baseZoneRadiusKm': pricing['baseZoneRadius'],
        };
        _isCalculatingPrice = false;
      });
    } catch (e) {
      setState(() => _isCalculatingPrice = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du calcul du prix: $e'.tr()),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  void _proceedToPayment() {
    if (!_formKey.currentState!.validate() || _pricingResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez compléter tous les champs requis'.tr()),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    // Navigate to payment screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          orderData: {
            'packageDescription': _packageDescriptionController.text,
            'packageValueXof': _packageValueXof,
            'fragile': _fragile,
            'requiresSignature': _requiresSignature,
            'priorityLevel': _priorityLevel,
            'pickupAddress': _pickupAddressController.text,
            'deliveryAddress': _deliveryAddressController.text,
            'pickupLatitude': _pickupLatitude ?? 5.3364,
            'pickupLongitude': _pickupLongitude ?? -4.0267,
            'deliveryLatitude': _deliveryLatitude ?? 5.2893,
            'deliveryLongitude': _deliveryLongitude ?? -3.9926,
            'recipientName': _recipientNameController.text,
            'recipientPhone': _recipientPhoneController.text,
            'recipientEmail': _recipientEmailController.text.isEmpty
                ? null
                : _recipientEmailController.text,
            'specialInstructions': _specialInstructionsController.text.isEmpty
                ? null
                : _specialInstructionsController.text,
            'totalPriceXof': _pricingResult!['totalPriceXof'],
          },
        ),
      ),
    );
  }
}
