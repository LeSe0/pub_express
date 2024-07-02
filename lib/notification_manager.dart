import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:push_express_lib/enums/common.dart';
import 'package:push_express_lib/push_express_lib.dart';
import 'package:push_express_lib/src/utils/foreground_service_token.dart';

const channelId = "high_importance_channel";
const channelName = "High Importance Notifications";
const channelDescription = "This channel is used for important notifications.";

class NotificationManager {
  NotificationManager();

  Future<void> handleNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      String msgId = message.data['px.msg_id'] ?? '';
      String title = message.data['px.title'] ?? notification.title ?? '';
      String body = message.data['px.body'] ?? notification.body ?? '';
      String? icon = message.data['px.icon'];

      // Send the delivered event to PushExpressManager
      PushExpressManager().sendNotificationEvent(
        msgId,
        Events.delivered,
      );

      File? imageFile;

      if (message.data['px.image'] != null ||
          notification.android?.imageUrl != null) {
        String imageUrl =
            message.data['px.image'] ?? notification.android?.imageUrl ?? '';
        imageFile = await _downloadImage(imageUrl);
      }

      if (imageFile != null) {
        _showNotification(
          msgId,
          title,
          body,
          icon,
          image: imageFile.path,
        );
        return;
      } else {
        _showNotification(msgId, title, body, icon);
      }
    }
  }

  Future<void> handleNotificationPressed(String? id) async {
    if (id != null) {
      // Send the delivered event to PushExpressManager
      PushExpressManager().sendNotificationEvent(
        id.toString(),
        Events.clicked,
      );
    }
  }

  Future<File?> _downloadImage(String url) async {
    try {
      final Directory directory = await getTemporaryDirectory();
      final String filePath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      Response response = await Dio().download(url, filePath);

      if (response.statusCode == 200) {
        return File(filePath);
      } else {
        print("Failed to download image: ${response.statusCode}");
      }
    } catch (e) {
      print("Failed to download image: $e");
    }
    return null;
  }

  NotificationDetails _getNotificationDetailsForNotificationWithoutImage(
    String? icon,
    bool shouldShowInForeground,
  ) {
    // android notification settings
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      icon: icon,
    );

    // specify the channel for android
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    return platformChannelSpecifics;
  }

  NotificationDetails _getNotificationDetailsForNotificationWithImage(
    String imagePath,
    String? icon,
    bool shouldShowInForeground,
  ) {
    // picture information
    final BigPictureStyleInformation bigPictureStyleInformation =
        BigPictureStyleInformation(
      FilePathAndroidBitmap(
        imagePath,
      ),
    );

    // android notification settings
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      styleInformation: bigPictureStyleInformation,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
      icon: icon,
    );

    // specify the channel for android
    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    return platformChannelSpecifics;
  }

  void _showNotification(
    String id,
    String title,
    String body,
    String? icon, {
    String? image,
  }) async {
    bool shouldShowInForeground = await getForegroundServiceToken() ?? false;
    if (Platform.isAndroid && shouldShowInForeground) {
      NotificationDetails? platformChannelSpecifics;

      if (image != null) {
        platformChannelSpecifics =
            _getNotificationDetailsForNotificationWithImage(
          image,
          icon,
          shouldShowInForeground,
        );
      } else {
        platformChannelSpecifics =
            _getNotificationDetailsForNotificationWithoutImage(
          icon,
          shouldShowInForeground,
        );
      }

      await FlutterLocalNotificationsPlugin().show(
        id.hashCode,
        title,
        body,
        platformChannelSpecifics,
        payload: id,
      );
    }
  }
}
