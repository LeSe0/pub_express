enum TransportType {
  fcm('fcm'),
  onesignal('onesignal'),
  fcmData('fcm.data'),
  apns('apns');

  final String value;

  const TransportType(this.value);
}

enum Events {
  clicked,
  delivered,
}
