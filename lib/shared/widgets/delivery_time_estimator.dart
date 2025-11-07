import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:le_livreur_pro/core/services/pricing_service.dart';

class DeliveryTimeEstimator extends StatefulWidget {
  final double? fromLatitude;
  final double? fromLongitude;
  final double? toLatitude;
  final double? toLongitude;
  final int priorityLevel;
  final ValueChanged<Duration>? onTimeEstimated;

  const DeliveryTimeEstimator({
    super.key,
    this.fromLatitude,
    this.fromLongitude,
    this.toLatitude,
    this.toLongitude,
    this.priorityLevel = 1,
    this.onTimeEstimated,
  });

  @override
  State<DeliveryTimeEstimator> createState() => _DeliveryTimeEstimatorState();
}

class _DeliveryTimeEstimatorState extends State<DeliveryTimeEstimator> {
  Duration? _estimatedTime;
  bool _isCalculating = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _calculateDeliveryTime();
  }

  @override
  void didUpdateWidget(DeliveryTimeEstimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fromLatitude != widget.fromLatitude ||
        oldWidget.fromLongitude != widget.fromLongitude ||
        oldWidget.toLatitude != widget.toLatitude ||
        oldWidget.toLongitude != widget.toLongitude ||
        oldWidget.priorityLevel != widget.priorityLevel) {
      _calculateDeliveryTime();
    }
  }

  Future<void> _calculateDeliveryTime() async {
    if (widget.fromLatitude == null ||
        widget.fromLongitude == null ||
        widget.toLatitude == null ||
        widget.toLongitude == null) {
      setState(() {
        _estimatedTime = null;
        _errorMessage = 'incomplete_location_data'.tr();
        _isCalculating = false;
      });
      return;
    }

    setState(() {
      _isCalculating = true;
      _errorMessage = null;
    });

    try {
      // Calculate distance first
      final distance = PricingService.calculateDistance(
        lat1: widget.fromLatitude!,
        lon1: widget.fromLongitude!,
        lat2: widget.toLatitude!,
        lon2: widget.toLongitude!,
      );

      // Check if it's currently traffic hour (7-9 AM, 12-2 PM, 5-8 PM)
      final now = DateTime.now();
      final hour = now.hour;
      final isTrafficHour = (hour >= 7 && hour <= 9) ||
          (hour >= 12 && hour <= 14) ||
          (hour >= 17 && hour <= 20);

      // Estimate delivery time
      final estimatedTime = PricingService.estimateDeliveryTime(
        distanceKm: distance,
        priorityLevel: widget.priorityLevel,
        isTrafficHour: isTrafficHour,
      );

      setState(() {
        _estimatedTime = estimatedTime;
        _isCalculating = false;
      });

      // Notify parent widget
      widget.onTimeEstimated?.call(estimatedTime);
    } catch (e) {
      setState(() {
        _errorMessage = 'calculation_error'.tr();
        _isCalculating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'estimated_delivery_time'.tr(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isCalculating) ...[
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text('calculating'.tr()),
              ],
            ),
          ] else if (_errorMessage != null) ...[
            Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade600),
                  ),
                ),
              ],
            ),
          ] else if (_estimatedTime != null) ...[
            _buildTimeDisplay(),
            const SizedBox(height: 8),
            _buildDeliveryFactors(),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeDisplay() {
    final time = _estimatedTime!;
    final hours = time.inHours;
    final minutes = time.inMinutes % 60;

    String timeText;
    if (hours > 0) {
      timeText = '${hours}h ${minutes}min';
    } else {
      timeText = '${minutes}min';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_shipping,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            timeText,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryFactors() {
    final now = DateTime.now();
    final hour = now.hour;
    final isTrafficHour = (hour >= 7 && hour <= 9) ||
        (hour >= 12 && hour <= 14) ||
        (hour >= 17 && hour <= 20);

    final factors = <Widget>[];

    // Priority level factor
    if (widget.priorityLevel == 3) {
      factors.add(_buildFactorChip(
        'express_delivery'.tr(),
        Icons.flash_on,
        Colors.orange,
      ));
    } else if (widget.priorityLevel == 2) {
      factors.add(_buildFactorChip(
        'urgent_delivery'.tr(),
        Icons.priority_high,
        Colors.red,
      ));
    }

    // Traffic factor
    if (isTrafficHour) {
      factors.add(_buildFactorChip(
        'traffic_hour'.tr(),
        Icons.traffic,
        Colors.amber,
      ));
    }

    // Weather factor (mock)
    factors.add(_buildFactorChip(
      'good_weather'.tr(),
      Icons.wb_sunny,
      Colors.green,
    ));

    if (factors.isEmpty) {
      factors.add(_buildFactorChip(
        'normal_conditions'.tr(),
        Icons.check_circle,
        Colors.green,
      ));
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: factors,
    );
  }

  Widget _buildFactorChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}