import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:le_livreur_pro/core/models/delivery_order.dart';
import 'package:le_livreur_pro/core/models/user.dart';
import 'package:le_livreur_pro/core/models/maps_models.dart';
import 'package:le_livreur_pro/core/services/notification_service.dart';

class RealtimeService {
  static final SupabaseClient _client = Supabase.instance.client;
  static RealtimeChannel? _ordersChannel;
  static RealtimeChannel? _courierLocationChannel;
  static RealtimeChannel? _chatChannel;
  
  // Stream controllers for real-time updates
  static final StreamController<DeliveryOrder> _orderUpdatesController =
      StreamController<DeliveryOrder>.broadcast();
  static final StreamController<Location> _courierLocationController =
      StreamController<Location>.broadcast();
  static final StreamController<Map<String, dynamic>> _chatController =
      StreamController<Map<String, dynamic>>.broadcast();
  static final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Getters for streams
  static Stream<DeliveryOrder> get orderUpdates => _orderUpdatesController.stream;
  static Stream<Location> get courierLocationUpdates => _courierLocationController.stream;
  static Stream<Map<String, dynamic>> get chatUpdates => _chatController.stream;
  static Stream<Map<String, dynamic>> get notificationUpdates => _notificationController.stream;

  /// Initialize real-time service
  static Future<void> initialize() async {
    try {
      _setupOrdersChannel();
      _setupCourierLocationChannel();
      _setupChatChannel();
      _setupNotificationChannel();
      
      if (kDebugMode) {
        debugPrint('🔄 Real-time service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error initializing real-time service: $e');
      }
    }
  }

  /// Setup orders real-time channel
  static void _setupOrdersChannel() {
    _ordersChannel = _client.channel('orders');
    
    _ordersChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'delivery_orders',
          callback: (payload) {
            _handleOrderUpdate(payload);
          },
        )
        .subscribe();
  }

  /// Setup courier location real-time channel
  static void _setupCourierLocationChannel() {
    _courierLocationChannel = _client.channel('courier_locations');
    
    _courierLocationChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'courier_locations',
          callback: (payload) {
            _handleCourierLocationUpdate(payload);
          },
        )
        .subscribe();
  }

  /// Setup chat real-time channel
  static void _setupChatChannel() {
    _chatChannel = _client.channel('chat_messages');
    
    _chatChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          callback: (payload) {
            _handleChatMessage(payload);
          },
        )
        .subscribe();
  }

  /// Setup notification real-time channel
  static void _setupNotificationChannel() {
    // Listen for notification events via broadcast
    _client.channel('notifications')
        .onBroadcast(
          event: 'notification',
          callback: (payload) {
            _handleNotification(payload);
          },
        )
        .subscribe();
  }

  /// Handle order updates
  static void _handleOrderUpdate(PostgresChangePayload payload) {
    try {
      final eventType = payload.eventType;
      final newRecord = payload.newRecord;
      final oldRecord = payload.oldRecord;
      
      if (kDebugMode) {
        debugPrint('📦 Order update: ${eventType.name}');
      }

      if (newRecord.isNotEmpty) {
        final order = DeliveryOrder.fromJson(newRecord);
        _orderUpdatesController.add(order);
        
        // Send notifications based on status change
        _sendOrderStatusNotification(order, oldRecord);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error handling order update: $e');
      }
    }
  }

  /// Handle courier location updates
  static void _handleCourierLocationUpdate(PostgresChangePayload payload) {
    try {
      final newRecord = payload.newRecord;
      
      if (newRecord.isNotEmpty) {
        final location = Location(
          latitude: (newRecord['latitude'] as num).toDouble(),
          longitude: (newRecord['longitude'] as num).toDouble(),
          timestamp: DateTime.parse(newRecord['updated_at'] as String),
        );
        
        _courierLocationController.add(location);
        
        if (kDebugMode) {
          debugPrint('📍 Courier location updated: ${location.latitude}, ${location.longitude}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error handling courier location update: $e');
      }
    }
  }

  /// Handle chat messages
  static void _handleChatMessage(PostgresChangePayload payload) {
    try {
      final newRecord = payload.newRecord;
      
      if (newRecord.isNotEmpty) {
        _chatController.add(newRecord);
        
        // Send chat notification
        _sendChatNotification(newRecord);
        
        if (kDebugMode) {
          debugPrint('💬 New chat message: ${newRecord['message']}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error handling chat message: $e');
      }
    }
  }

  /// Handle notifications
  static void _handleNotification(Map<String, dynamic> payload) {
    try {
      _notificationController.add(payload);
      
      // Show local notification
      NotificationService.showNotification(
        title: payload['title'] ?? 'Notification',
        body: payload['body'] ?? '',
        data: payload,
      );
      
      if (kDebugMode) {
        debugPrint('🔔 Notification received: ${payload['title']}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error handling notification: $e');
      }
    }
  }

  /// Send order status notification
  static void _sendOrderStatusNotification(
    DeliveryOrder order,
    Map<String, dynamic> oldRecord,
  ) {
    final oldStatus = oldRecord['status'];
    final newStatus = order.status.name;
    
    if (oldStatus != newStatus) {
      String title;
      String body;
      
      switch (order.status) {
        case DeliveryStatus.assigned:
          title = 'Coursier assigné';
          body = 'Un coursier a été assigné à votre commande ${order.id}';
          break;
        case DeliveryStatus.courierEnRoute:
          title = 'Coursier en route';
          body = 'Le coursier se dirige vers le point de ramassage';
          break;
        case DeliveryStatus.pickedUp:
          title = 'Colis récupéré';
          body = 'Votre colis a été récupéré et est en transit';
          break;
        case DeliveryStatus.inTransit:
          title = 'En transit';
          body = 'Votre colis est en route vers la destination';
          break;
        case DeliveryStatus.arrivedDestination:
          title = 'Coursier arrivé';
          body = 'Le coursier est arrivé à destination';
          break;
        case DeliveryStatus.delivered:
          title = 'Livraison terminée';
          body = 'Votre colis a été livré avec succès';
          break;
        case DeliveryStatus.cancelled:
          title = 'Commande annulée';
          body = 'Votre commande a été annulée';
          break;
        default:
          return; // No notification for other statuses
      }
      
      // Send notification to customer
      NotificationService.sendNotificationToCustomer(
        customerId: order.customerId,
        title: title,
        body: body,
        data: {'order_id': order.id, 'status': newStatus},
      );
      
      // Send notification to courier if applicable
      if (order.courierId != null) {
        NotificationService.sendNotificationToCourier(
          courierId: order.courierId!,
          title: title,
          body: body,
          data: {'order_id': order.id, 'status': newStatus},
        );
      }
    }
  }

  /// Send chat notification
  static void _sendChatNotification(Map<String, dynamic> chatMessage) {
    final senderId = chatMessage['sender_id'];
    final receiverId = chatMessage['receiver_id'];
    final message = chatMessage['message'];
    
    NotificationService.sendNotificationToUser(
      userId: receiverId,
      title: 'Nouveau message',
      body: message.length > 50 ? '${message.substring(0, 50)}...' : message,
      data: {
        'type': 'chat',
        'sender_id': senderId,
        'chat_id': chatMessage['chat_id'],
      },
    );
  }

  /// Subscribe to order updates for specific order
  static void subscribeToOrder(String orderId) {
    try {
      _client.channel('order_$orderId')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'delivery_orders',
            filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'id', value: orderId),
            callback: (payload) {
              _handleOrderUpdate(payload);
            },
          )
          .subscribe();
          
      if (kDebugMode) {
        debugPrint('📦 Subscribed to order updates: $orderId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error subscribing to order: $e');
      }
    }
  }

  /// Subscribe to courier location for specific courier
  static void subscribeToCourierLocation(String courierId) {
    try {
      _client.channel('courier_location_$courierId')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'courier_locations',
            filter: PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'courier_id', value: courierId),
            callback: (payload) {
              _handleCourierLocationUpdate(payload);
            },
          )
          .subscribe();
          
      if (kDebugMode) {
        debugPrint('📍 Subscribed to courier location: $courierId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error subscribing to courier location: $e');
      }
    }
  }

  /// Send broadcast notification
  static Future<void> sendBroadcastNotification({
    required String channel,
    required String event,
    required Map<String, dynamic> payload,
  }) async {
    try {
      await _client.channel(channel).sendBroadcastMessage(
        event: event,
        payload: payload,
      );
      
      if (kDebugMode) {
        debugPrint('📢 Broadcast sent: $channel/$event');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error sending broadcast: $e');
      }
    }
  }

  /// Update courier location in real-time
  static Future<void> updateCourierLocation({
    required String courierId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      await _client.from('courier_locations').upsert({
        'courier_id': courierId,
        'latitude': latitude,
        'longitude': longitude,
        'updated_at': DateTime.now().toIso8601String(),
      });
      
      if (kDebugMode) {
        debugPrint('📍 Courier location updated: $courierId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error updating courier location: $e');
      }
    }
  }

  /// Send chat message
  static Future<void> sendChatMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String message,
    String? messageType,
  }) async {
    try {
      await _client.from('chat_messages').insert({
        'chat_id': chatId,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'message': message,
        'message_type': messageType ?? 'text',
        'created_at': DateTime.now().toIso8601String(),
      });
      
      if (kDebugMode) {
        debugPrint('💬 Chat message sent: $chatId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error sending chat message: $e');
      }
    }
  }

  /// Get chat history
  static Future<List<Map<String, dynamic>>> getChatHistory(String chatId) async {
    try {
      final response = await _client
          .from('chat_messages')
          .select()
          .eq('chat_id', chatId)
          .order('created_at', ascending: true)
          .limit(100);
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error getting chat history: $e');
      }
      return [];
    }
  }

  /// Create or get chat session
  static Future<String> createChatSession({
    required String orderId,
    required String customerId,
    required String courierId,
  }) async {
    try {
      // Check if chat session already exists
      final existingChat = await _client
          .from('chat_sessions')
          .select()
          .eq('order_id', orderId)
          .single();
      
      return existingChat['id'];
    } catch (e) {
      // Create new chat session
      try {
        final response = await _client.from('chat_sessions').insert({
          'order_id': orderId,
          'customer_id': customerId,
          'courier_id': courierId,
          'created_at': DateTime.now().toIso8601String(),
        }).select().single();
        
        return response['id'];
      } catch (createError) {
        if (kDebugMode) {
          debugPrint('❌ Error creating chat session: $createError');
        }
        throw createError;
      }
    }
  }

  /// Dispose all channels and stream controllers
  static void dispose() {
    try {
      _ordersChannel?.unsubscribe();
      _courierLocationChannel?.unsubscribe();
      _chatChannel?.unsubscribe();
      
      _orderUpdatesController.close();
      _courierLocationController.close();
      _chatController.close();
      _notificationController.close();
      
      if (kDebugMode) {
        debugPrint('🔄 Real-time service disposed');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error disposing real-time service: $e');
      }
    }
  }

  /// Check connection status
  static bool get isConnected {
    try {
      return _client.realtime.isConnected;
    } catch (e) {
      return false;
    }
  }

  /// Reconnect to real-time service
  static Future<void> reconnect() async {
    try {
      await _client.realtime.connect();
      
      if (kDebugMode) {
        debugPrint('🔄 Real-time service reconnected');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Error reconnecting real-time service: $e');
      }
    }
  }
}
