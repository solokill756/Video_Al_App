import 'package:injectable/injectable.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// 🔌 **PaymentSocketService** - Quản lý WebSocket connection cho payment
///
/// Architecture:
/// - Singleton pattern: Chỉ 1 connection duy nhất cho toàn app
/// - Auto reconnect: Tự động reconnect nếu connection bị mất
/// - Event-based: Sử dụng callbacks để notify listeners khi có events
///
/// Lifecycle:
/// 1. **Init**: Tạo connection khi user mở payment modal
/// 2. **Listen**: Lắng nghe event 'paymentSuccess' từ backend
/// 3. **Cleanup**: Ngắt connection khi modal đóng hoặc user navigate away
///
/// Important: Backend emit 'paymentSuccess' qua Socket khi thanh toán được xác nhận
/// Frontend nhận event này và update UI (show success, redirect, etc)

typedef PaymentSuccessCallback = void Function(Map<String, dynamic> data);

/// 🎧 **PaymentSocketService** - Singleton WebSocket manager
///
/// Responsibilities:
/// - Connect/disconnect Socket.IO connection tới `/payment` namespace
/// - Register/unregister event listeners
/// - Handle connection errors và auto-reconnect
/// - Provide callback mechanism để notify UI layers
@injectable
class PaymentSocketService {
  // 🔧 Singleton instance
  static final PaymentSocketService _instance =
      PaymentSocketService._internal();

  // Socket instance
  IO.Socket? _socket;

  // 📢 Event listeners (callbacks)
  PaymentSuccessCallback? _onPaymentSuccessCallback;
  Function(String)? _onPaymentErrorCallback;
  Function()? _onConnectCallback;
  Function(String)? _onConnectErrorCallback;
  Function(String)? _onDisconnectCallback;

  // 🔄 Connection state
  bool _isConnected = false;
  bool _isConnecting = false;

  // 🔧 Config
  static const String _paymentNamespace = '/payment';
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const int _reconnectDelayMax = 25000; // 25 seconds

  PaymentSocketService._internal();

  /// 🏭 **factory** - Get singleton instance
  factory PaymentSocketService() {
    return _instance;
  }

  /// 🔗 **connect** - Kết nối tới Socket.IO server
  ///
  /// Features:
  /// - Auto retry nếu connection fail
  /// - Timeout handling
  /// - Error logging
  /// - Bearer token authentication
  ///
  /// Parameters:
  ///   - baseUrl: Backend URL (ví dụ: http://localhost:3000)
  ///   - token: Bearer token để authenticate
  ///
  /// Example:
  /// ```dart
  /// await paymentSocketService.connect(
  ///   baseUrl: 'http://localhost:3000',
  ///   token: 'Bearer eyJhbGc...',
  /// );
  /// ```
  Future<void> connect({
    required String baseUrl,
    required String token,
  }) async {
    if (_isConnected || _isConnecting) {
      print('✅ Payment socket already connected or connecting');
      return;
    }

    if (baseUrl.isEmpty || token.isEmpty) {
      print('❌ Socket URL or token is empty');
      return;
    }

    _isConnecting = true;

    try {
      print('🔌 Connecting to payment socket...');
      print('   URL: $baseUrl$_paymentNamespace');

      // Disconnect existing connection
      await disconnect();

      // Create socket with auth
      _socket = IO.io(
        '$baseUrl$_paymentNamespace',
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling']) // Fallback to polling
            .enableAutoConnect()
            .setAuth({'token': token})
            .setReconnectionDelay(
              _reconnectDelay.inMilliseconds,
            )
            .setReconnectionDelayMax(_reconnectDelayMax)
            .build(),
      );

      // Setup event listeners
      _setupEventListeners();

      print('✅ Payment socket created, waiting for connection...');

      // Wait a bit and check connection status
      Future.delayed(const Duration(seconds: 2), () {
        if (_socket != null) {
          print('🔍 Checking socket connection status after 2 seconds...');
          print('   Socket ID: ${_socket?.id}');
          print('   Is connected: ${_socket?.connected}');
          print('   Is connecting: $_isConnecting');
          print('   Is connected (internal): $_isConnected');

          if (!_isConnected && !_isConnecting) {
            print('⚠️⚠️⚠️ Socket not connected after 2 seconds!');
            print('   This might indicate a connection problem.');
            print('   Please check:');
            print('   1. Backend socket server is running');
            print('   2. URL is correct: $baseUrl$_paymentNamespace');
            print('   3. Token is valid');
            print('   4. Network connection is available');
          }
        }
      });
    } catch (e) {
      _isConnecting = false;
      print('❌ Error connecting to payment socket: $e');
      rethrow;
    }
  }

  /// 📡 **_setupEventListeners** - Setup socket event listeners
  ///
  /// Listens to:
  /// - connect: Socket connected
  /// - disconnect: Socket disconnected
  /// - connect_error: Connection error
  /// - paymentSuccess: Payment confirmed from backend
  /// - paymentError: Payment failed from backend
  void _setupEventListeners() {
    if (_socket == null) {
      print('❌ PaymentSocketService: Socket is null, cannot setup listeners');
      return;
    }

    print('🔌 PaymentSocketService: Setting up event listeners...');

    // ✅ Connected
    _socket!.on('connect', (_) {
      _isConnected = true;
      _isConnecting = false;
      print('✅✅✅ Connected to payment socket successfully!');
      print('   Socket ID: ${_socket?.id}');
      print('   Namespace: $_paymentNamespace');
      _onConnectCallback?.call();
    });

    // ❌ Disconnected
    _socket!.on('disconnect', (reason) {
      _isConnected = false;
      print('❌❌❌ Disconnected from payment socket: $reason');
      _onDisconnectCallback?.call(reason as String? ?? 'unknown');
    });

    // ⚠️ Connection error
    _socket!.on('connect_error', (error) {
      _isConnecting = false;
      print('⚠️⚠️⚠️ Payment socket connection error: $error');
      print('   Error type: ${error.runtimeType}');
      _onConnectErrorCallback?.call(error.toString());
    });

    // 📡 Listen to ALL events for debugging (remove in production)
    _socket!.onAny((event, data) {
      print('📡📡📡 Socket event received: $event');
      print('   Data: $data');
      print('   Data type: ${data.runtimeType}');
    });

    // 💰 Payment success event from backend
    _socket!.on('paymentSuccess', (data) {
      print('✨✨✨ Received paymentSuccess event: $data');
      print('   Data type: ${data.runtimeType}');

      try {
        Map<String, dynamic> mapData;

        if (data is Map) {
          // 🎯 Already a map
          mapData = Map<String, dynamic>.from(data);
        } else if (data is String) {
          // ⚠️ Might be JSON string - parse it
          // For now, create a default structure
          mapData = {
            'status': 'success',
            'message': 'Payment successful!',
            'subscription': null,
          };
        } else {
          print('⚠️ Unexpected paymentSuccess data type: ${data.runtimeType}');
          mapData = {
            'status': 'success',
            'message': 'Payment successful!',
            'subscription': null,
          };
        }

        print('✅ Calling paymentSuccess callback with data: $mapData');
        _onPaymentSuccessCallback?.call(mapData);
        print('✅ PaymentSuccess callback called successfully');
      } catch (e) {
        print('❌ Error parsing paymentSuccess data: $e');
        print('   Stack trace: ${StackTrace.current}');
        // Fallback: Call with default success structure
        print('⚠️ Using fallback success data');
        _onPaymentSuccessCallback?.call({
          'status': 'success',
          'message': 'Payment successful!',
          'subscription': null,
        });
      }
    });

    // ❌ Payment error event from backend
    _socket!.on('paymentError', (data) {
      print('❌ Received paymentError event: $data');

      String errorMessage = 'Unknown error';
      if (data is Map) {
        final mapData = Map<String, dynamic>.from(data);
        errorMessage = mapData['message'] as String? ?? errorMessage;
      } else if (data is String) {
        errorMessage = data;
      }

      _onPaymentErrorCallback?.call(errorMessage);
    });
  }

  /// 👂 **onPaymentSuccess** - Register callback cho event 'paymentSuccess'
  ///
  /// Event này được emit từ backend khi payment verified
  /// Data format: { status: "success", subscription: {...} }
  ///
  /// Example:
  /// ```dart
  /// paymentSocketService.onPaymentSuccess((data) {
  ///   if (data['status'] == 'success') {
  ///     // Update plan
  ///     // Show success toast
  ///     // Redirect to video management
  ///   }
  /// });
  /// ```
  void onPaymentSuccess(PaymentSuccessCallback callback) {
    _onPaymentSuccessCallback = callback;
  }

  /// ❌ **onPaymentError** - Register callback cho event 'paymentError'
  void onPaymentError(Function(String) callback) {
    _onPaymentErrorCallback = callback;
  }

  /// ✅ **onConnect** - Register callback khi connect thành công
  void onConnect(Function() callback) {
    _onConnectCallback = callback;
  }

  /// ⚠️ **onConnectError** - Register callback khi connect fail
  void onConnectError(Function(String) callback) {
    _onConnectErrorCallback = callback;
  }

  /// 🔌 **onDisconnect** - Register callback khi disconnect
  void onDisconnect(Function(String) callback) {
    _onDisconnectCallback = callback;
  }

  /// � **disconnect** - Ngắt kết nối từ Socket.IO server
  ///
  /// Gọi khi user đóng payment modal hoặc navigate away
  /// Cleanup resources và remove listeners
  Future<void> disconnect() async {
    try {
      if (_socket == null && !_isConnected) {
        return;
      }

      print('🔌 Disconnecting from payment socket...');

      // Unregister all listeners
      if (_socket != null) {
        _socket!.offAny();
      }

      // Disconnect
      if (_socket?.connected ?? false) {
        _socket!.disconnect();
      }

      // Clear state
      _socket = null;
      _isConnected = false;
      _isConnecting = false;
      _clearCallbacks();

      print('✅ Disconnected from payment socket');
    } catch (e) {
      print('❌ Error disconnecting payment socket: $e');
    }
  }

  /// 🗑️ **_clearCallbacks** - Clear all event callbacks
  void _clearCallbacks() {
    _onPaymentSuccessCallback = null;
    _onPaymentErrorCallback = null;
    _onConnectCallback = null;
    _onConnectErrorCallback = null;
    _onDisconnectCallback = null;
  }

  /// �🚫 **offPaymentSuccess** - Remove payment success listener
  ///
  /// Gọi khi cleanup
  void offPaymentSuccess() {
    _onPaymentSuccessCallback = null;
  }

  /// 🔄 **reconnect** - Manually reconnect socket
  ///
  /// Useful if connection was lost and auto-reconnect didn't work
  void reconnect() {
    if (_socket != null && !_socket!.connected) {
      print('🔄 Manually reconnecting socket...');
      _socket!.connect();
    }
  }

  /// ❓ **isConnected** - Check connection status
  bool get isConnected => _isConnected;

  /// ✅ **getConnectionStatus** - Get detailed status info
  Map<String, dynamic> getConnectionStatus() {
    return {
      'isConnected': _isConnected,
      'isConnecting': _isConnecting,
      'socketId': _socket?.id ?? 'N/A',
    };
  }

  /// 📡 **emit** - Emit event to backend (if needed)
  ///
  /// Generic method để emit custom events
  /// Usage: paymentSocketService.emit('eventName', data);
  void emit(String event, [dynamic data]) {
    if (_socket?.connected ?? false) {
      _socket!.emit(event, data);
      print('📤 Emitted event: $event');
    } else {
      print('⚠️ Socket not connected, cannot emit $event');
    }
  }
}
