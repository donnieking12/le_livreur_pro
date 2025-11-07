import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class DeliveryProgressTracker extends StatelessWidget {
  final DeliveryStatus currentStatus;
  final DateTime? orderTime;
  final DateTime? pickupTime;
  final DateTime? inTransitTime;
  final DateTime? deliveredTime;
  final bool isAnimated;

  const DeliveryProgressTracker({
    super.key,
    required this.currentStatus,
    this.orderTime,
    this.pickupTime,
    this.inTransitTime,
    this.deliveredTime,
    this.isAnimated = true,
  });

  @override
  Widget build(BuildContext context) {
    final steps = _getDeliverySteps();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'delivery_progress'.tr(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(steps.length, (index) {
            final step = steps[index];
            final isLast = index == steps.length - 1;
            
            return _buildProgressStep(
              context,
              step,
              index,
              isLast,
            );
          }),
        ],
      ),
    );
  }

  List<DeliveryStep> _getDeliverySteps() {
    return [
      DeliveryStep(
        status: DeliveryStatus.confirmed,
        title: 'order_confirmed_step'.tr(),
        description: 'order_being_prepared'.tr(),
        icon: Icons.receipt_long,
        timestamp: orderTime,
        isCompleted: currentStatus.index >= DeliveryStatus.confirmed.index,
        isActive: currentStatus == DeliveryStatus.confirmed,
      ),
      DeliveryStep(
        status: DeliveryStatus.preparing,
        title: 'order_preparing_step'.tr(),
        description: 'restaurant_preparing_order'.tr(),
        icon: Icons.restaurant_menu,
        timestamp: pickupTime,
        isCompleted: currentStatus.index >= DeliveryStatus.preparing.index,
        isActive: currentStatus == DeliveryStatus.preparing,
      ),
      DeliveryStep(
        status: DeliveryStatus.pickupReady,
        title: 'ready_for_pickup_step'.tr(),
        description: 'courier_on_way_to_pickup'.tr(),
        icon: Icons.inventory_2,
        timestamp: pickupTime,
        isCompleted: currentStatus.index >= DeliveryStatus.pickupReady.index,
        isActive: currentStatus == DeliveryStatus.pickupReady,
      ),
      DeliveryStep(
        status: DeliveryStatus.inTransit,
        title: 'in_transit_step'.tr(),
        description: 'courier_on_way_to_delivery'.tr(),
        icon: Icons.local_shipping,
        timestamp: inTransitTime,
        isCompleted: currentStatus.index >= DeliveryStatus.inTransit.index,
        isActive: currentStatus == DeliveryStatus.inTransit,
      ),
      DeliveryStep(
        status: DeliveryStatus.delivered,
        title: 'delivered_step'.tr(),
        description: 'order_successfully_delivered'.tr(),
        icon: Icons.check_circle,
        timestamp: deliveredTime,
        isCompleted: currentStatus.index >= DeliveryStatus.delivered.index,
        isActive: currentStatus == DeliveryStatus.delivered,
      ),
    ];
  }

  Widget _buildProgressStep(
    BuildContext context,
    DeliveryStep step,
    int index,
    bool isLast,
  ) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step indicator
            Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.isCompleted 
                        ? theme.primaryColor 
                        : step.isActive
                            ? theme.primaryColor.withOpacity(0.2)
                            : Colors.grey.shade300,
                    border: step.isActive && !step.isCompleted
                        ? Border.all(color: theme.primaryColor, width: 2)
                        : null,
                  ),
                  child: step.isCompleted
                      ? Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        )
                      : Icon(
                          step.icon,
                          color: step.isActive 
                              ? theme.primaryColor 
                              : Colors.grey.shade500,
                          size: 20,
                        ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 60,
                    color: step.isCompleted 
                        ? theme.primaryColor 
                        : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Step content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: step.isActive || step.isCompleted 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                      color: step.isCompleted || step.isActive
                          ? theme.textTheme.titleMedium?.color
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: step.isCompleted || step.isActive
                          ? theme.textTheme.bodyMedium?.color
                          : Colors.grey.shade500,
                    ),
                  ),
                  if (step.timestamp != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatTimestamp(step.timestamp!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (step.isActive && !step.isCompleted) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        if (!isLast) const SizedBox(height: 8),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.isNegative) {
      // Future timestamp (estimated)
      return 'estimated'.tr() + ' ' + DateFormat('HH:mm').format(timestamp);
    } else if (difference.inMinutes < 1) {
      return 'just_now'.tr();
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} ${'minutes_ago'.tr()}';
    } else if (difference.inDays < 1) {
      return DateFormat('HH:mm').format(timestamp);
    } else {
      return DateFormat('dd/MM HH:mm').format(timestamp);
    }
  }
}

class DeliveryStep {
  final DeliveryStatus status;
  final String title;
  final String description;
  final IconData icon;
  final DateTime? timestamp;
  final bool isCompleted;
  final bool isActive;

  DeliveryStep({
    required this.status,
    required this.title,
    required this.description,
    required this.icon,
    this.timestamp,
    required this.isCompleted,
    required this.isActive,
  });
}

enum DeliveryStatus {
  pending,
  confirmed,
  preparing,
  pickupReady,
  inTransit,
  delivered,
  cancelled,
}