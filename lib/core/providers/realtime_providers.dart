import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:le_livreur_pro/core/services/realtime_service.dart';
import 'package:le_livreur_pro/core/models/delivery_order.dart';
import 'package:le_livreur_pro/core/models/maps_models.dart';

/// Provider for real-time order updates
final orderUpdatesProvider = StreamProvider<DeliveryOrder>((ref) {
  return RealtimeService.orderUpdates;
});

/// Provider for real-time courier location updates
final courierLocationUpdatesProvider = StreamProvider<Location>((ref) {
  return RealtimeService.courierLocationUpdates;
});

/// Provider for real-time chat updates
final chatUpdatesProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return RealtimeService.chatUpdates;
});

/// Provider for real-time notification updates
final notificationUpdatesProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return RealtimeService.notificationUpdates;
});

/// Provider for real-time connection status
final realtimeConnectionProvider = StateProvider<bool>((ref) {
  return RealtimeService.isConnected;
});

/// Provider for specific order tracking
final orderTrackingProvider = StreamProvider.family<DeliveryOrder?, String>((ref, orderId) {
  return RealtimeService.orderUpdates.where((order) => order.id == orderId);
});

/// Provider for specific courier location tracking
final courierTrackingProvider = StreamProvider.family<Location?, String>((ref, courierId) {
  // This would need to be enhanced with courier ID filtering in the service
  return RealtimeService.courierLocationUpdates;
});

/// Provider for chat history
final chatHistoryProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, chatId) async {
  return await RealtimeService.getChatHistory(chatId);
});

/// Provider for creating chat session
final createChatSessionProvider = FutureProvider.family<String, Map<String, String>>((ref, params) async {
  return await RealtimeService.createChatSession(
    orderId: params['orderId']!,
    customerId: params['customerId']!,
    courierId: params['courierId']!,
  );
});