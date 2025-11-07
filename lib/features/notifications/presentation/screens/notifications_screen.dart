import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('notifications_title'.tr()),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'orders'.tr(), icon: const Icon(Icons.shopping_bag)),
            Tab(text: 'promotions'.tr(), icon: const Icon(Icons.local_offer)),
            Tab(text: 'system'.tr(), icon: const Icon(Icons.settings)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: _markAllAsRead,
            tooltip: 'mark_all_read'.tr(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderNotifications(),
          _buildPromotionNotifications(),
          _buildSystemNotifications(),
        ],
      ),
    );
  }

  Widget _buildOrderNotifications() {
    final orderNotifications = _getOrderNotifications();
    
    if (orderNotifications.isEmpty) {
      return _buildEmptyState('no_order_notifications'.tr());
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orderNotifications.length,
      itemBuilder: (context, index) {
        final notification = orderNotifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildPromotionNotifications() {
    final promotionNotifications = _getPromotionNotifications();
    
    if (promotionNotifications.isEmpty) {
      return _buildEmptyState('no_promotion_notifications'.tr());
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: promotionNotifications.length,
      itemBuilder: (context, index) {
        final notification = promotionNotifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildSystemNotifications() {
    final systemNotifications = _getSystemNotifications();
    
    if (systemNotifications.isEmpty) {
      return _buildEmptyState('no_system_notifications'.tr());
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: systemNotifications.length,
      itemBuilder: (context, index) {
        final notification = systemNotifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 1 : 3,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.isRead 
            ? Colors.grey.shade300 
            : Theme.of(context).primaryColor,
          child: Icon(
            notification.icon,
            color: notification.isRead ? Colors.grey : Colors.white,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.message),
            const SizedBox(height: 4),
            Text(
              _formatTime(notification.timestamp),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: notification.isRead 
          ? null 
          : Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
            ),
        onTap: () => _markAsRead(notification),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'just_now'.tr();
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}${'minutes_ago'.tr()}';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}${'hours_ago'.tr()}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}${'days_ago'.tr()}';
    } else {
      return DateFormat('dd/MM/yyyy').format(timestamp);
    }
  }

  void _markAsRead(AppNotification notification) {
    setState(() {
      notification.isRead = true;
    });
    // TODO: Update notification status in backend
  }

  void _markAllAsRead() {
    setState(() {
      _getAllNotifications().forEach((notification) {
        notification.isRead = true;
      });
    });
    // TODO: Update all notification statuses in backend
  }

  List<AppNotification> _getOrderNotifications() {
    return [
      AppNotification(
        id: '1',
        title: 'order_delivered'.tr(),
        message: 'your_order_llp123456_delivered'.tr(),
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        type: NotificationType.order,
        icon: Icons.check_circle,
        isRead: false,
      ),
      AppNotification(
        id: '2',
        title: 'order_in_transit'.tr(),
        message: 'your_order_llp123457_in_transit'.tr(),
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        type: NotificationType.order,
        icon: Icons.local_shipping,
        isRead: false,
      ),
      AppNotification(
        id: '3',
        title: 'order_confirmed'.tr(),
        message: 'your_order_llp123458_confirmed'.tr(),
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: NotificationType.order,
        icon: Icons.assignment_turned_in,
        isRead: true,
      ),
    ];
  }

  List<AppNotification> _getPromotionNotifications() {
    return [
      AppNotification(
        id: '4',
        title: 'new_promotion'.tr(),
        message: 'get_20_percent_off_next_delivery'.tr(),
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        type: NotificationType.promotion,
        icon: Icons.local_offer,
        isRead: false,
      ),
      AppNotification(
        id: '5',
        title: 'weekend_special'.tr(),
        message: 'free_delivery_this_weekend'.tr(),
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.promotion,
        icon: Icons.celebration,
        isRead: true,
      ),
    ];
  }

  List<AppNotification> _getSystemNotifications() {
    return [
      AppNotification(
        id: '6',
        title: 'app_update_available'.tr(),
        message: 'new_version_available_with_improvements'.tr(),
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        type: NotificationType.system,
        icon: Icons.system_update,
        isRead: false,
      ),
      AppNotification(
        id: '7',
        title: 'maintenance_notice'.tr(),
        message: 'scheduled_maintenance_tonight'.tr(),
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        type: NotificationType.system,
        icon: Icons.build,
        isRead: true,
      ),
    ];
  }

  List<AppNotification> _getAllNotifications() {
    return [
      ..._getOrderNotifications(),
      ..._getPromotionNotifications(),
      ..._getSystemNotifications(),
    ];
  }
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final NotificationType type;
  final IconData icon;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    required this.icon,
    this.isRead = false,
  });
}

enum NotificationType {
  order,
  promotion,
  system,
}