library push_express_lib;

import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_express_lib/enums/common.dart';
import 'package:push_express_lib/notification_manager.dart';
import 'package:push_express_lib/src/domain/common/common_repo.dart';
import 'package:push_express_lib/src/domain/common/icommon_repo.dart';
import 'package:push_express_lib/src/utils/foreground_service_token.dart';
import 'package:push_express_lib/src/utils/generate_unique_id.dart';
import 'package:push_express_lib/src/utils/notification_token.dart';

@pragma('vm:entry-point')
void _handleNotificationPressed(NotificationResponse? message) {
  NotificationManager().handleNotificationPressed(
    message?.payload?.toString() ?? "",
  );
}

class PushExpressManager {
  static final PushExpressManager _instance = PushExpressManager._internal();
  final ICommonRepo commonRepo = CommonRepo();

  factory PushExpressManager() => _instance;

  PushExpressManager._internal();

  String? _appId;
  String? _icId;

  Future<void> init(
    String appId,
    TransportType transportType, {
    bool foreground = false,
    required String transportToken,
    String? extId,
  }) async {
    _appId = appId;
    _icId = await getNotificationToken();

    FlutterLocalNotificationsPlugin().initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings(
          'mipmap/ic_launcher',
        ),
      ),
      onDidReceiveNotificationResponse: _handleNotificationPressed,
      onDidReceiveBackgroundNotificationResponse: _handleNotificationPressed,
    );

    // save foreground service
    saveForegroundServiceToken(foreground);

    // If the app instance id is not available, create a new one
    if (_icId != null) {
      updateAppInstance(
        transportType: transportType,
        id: extId,
        transportToken: transportToken,
      );
    } else {
      createAppInstance(
        transportType: transportType,
        transportToken: transportToken,
        id: _icId,
      );
    }
  }

  // App instance creation
  Future<void> createAppInstance({
    required TransportType transportType,
    required String transportToken,
    String? id,
  }) async {
    _icId = id ?? generateUniqueId();

    final response = await commonRepo.createAppInstance(
      appId: _appId!,
      transportType: transportType,
      icId: _icId!,
    );

    if (response.error == false) {
      saveNotificationToken(response.data['id']);
      updateAppInstance(
        transportType: transportType,
        id: id,
        transportToken: transportToken,
        shouldRetry: true,
      );
    } else {
      print('Failed to create app instance: ${response.error}');
    }
  }

  // App instance update
  Future<void> updateAppInstance({
    required TransportType transportType,
    required String transportToken,
    String? id,
    bool? shouldRetry = true,
  }) async {
    try {
      final response = await commonRepo.updateAppInstance(
        appId: _appId!,
        transportType: transportType,
        icId: _icId!,
        extId: id,
        transportToken: transportToken,
      );

      if (response.error == false) {
        scheduleUpdateAppInstance(
          transportType: transportType,
          transportToken: transportToken,
          id: id,
          seconds: response.data['update_interval_sec'] ?? 120,
        );
      } else {
        print('Failed to update app instance: ${response.data}');
      }
    } catch (e) {
      if (shouldRetry == true) {
        // print('Error updating app instance: $e');
        retryUpdateAppInstance(
          transportType: transportType,
          id: id,
          transportToken: transportToken,
        );
      }
    }
  }

  // Retry update app instance
  Future<void> retryUpdateAppInstance({
    required TransportType transportType,
    required String transportToken,
    String? id,
  }) async {
    for (int i = 0; i < 15; i++) {
      try {
        await Future.delayed(const Duration(milliseconds: 120));
        await updateAppInstance(
          transportType: transportType,
          transportToken: transportToken,
          id: id,
          shouldRetry: false,
        );
        return;
      } catch (e) {
        if (i == 14) {
          print(
            "Something went wrong, while trying to update your app instance: $e",
          );
          throw e;
        }
      }
    }
  }

  Future<void> scheduleUpdateAppInstance({
    required TransportType transportType,
    required String transportToken,
    String? id,
    required int seconds,
  }) async {
    Timer.periodic(Duration(seconds: seconds), (timer) async {
      try {
        await updateAppInstance(
          transportType: transportType,
          transportToken: transportToken,
          id: id,
        );
      } catch (e) {
        print('Error updating app instance: $e');
      }
    });
  }

  // Send notification event
  Future<void> sendNotificationEvent(String msgId, Events event) async {
    try {
      final response = await commonRepo.sendNotificationEvent(
        msgId: msgId,
        event: event,
        appId: _appId!,
        icId: _icId!,
      );

      if (response.error == false) {
        print('Notification event sent: ${event.name}');
      } else {
        print('Failed to send notification event: ${response.error}');
      }
    } catch (e) {
      print('Failed to send notification event: $e');
    }
  }

  // Send lifecycle event
  Future<void> sendLifecycleEvent(Events event) async {
    try {
      final response = await commonRepo.sendLifecycleEvent(
        event: event,
        appId: _appId!,
        icId: _icId!,
      );

      if (response.error == false) {
        print('Lifecycle event sent: ${response.data}');
      } else {
        print('Failed to send lifecycle event: ${response.error}');
      }
    } catch (e) {
      print('[PushExpress] Failed to send lifecycle event: $e');
    }
  }
}
