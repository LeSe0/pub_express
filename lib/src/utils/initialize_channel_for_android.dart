import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_express_lib/notification_manager.dart';

const channelId = "high_importance_channel";
const channelName = "High Importance Notifications";
const channelDescription = "This channel is used for important notifications.";

@pragma('vm:entry-point')
void handleNotificationPressed(NotificationResponse? message) {
  inspect(message);
  NotificationManager().handleNotificationPressed(message);
}

Future<void> initializeChannelForAndroid() async {
  // android initialization settings
  var initializationSettingsAndroid = const AndroidInitializationSettings(
    'mipmap/ic_launcher',
  );

  var initializationSettingsIOS = const DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  // initialize
  await FlutterLocalNotificationsPlugin().initialize(
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    ),
    onDidReceiveNotificationResponse: handleNotificationPressed,
    onDidReceiveBackgroundNotificationResponse: handleNotificationPressed,
  );
}
