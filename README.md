# Push Express

## Get Started

This guide will walk you through integrating PushExpressLib into your application and handling push notifications in both foreground and background states.

Import package in your **main.dart** file

```dart
import 'package:push_express_lib/push_express_lib.dart';
```

Then, you can use the package's functions and features in your code.

## Guide

### First step

**Initialize package**

```dart
void initFirebase() async {
    // Initialize firebase app
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
    );

    // Request permissions for push notifications
    await FirebaseMessaging.instance.requestPermission();

    // get unique token for messaging from firebase messaging
    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
        // initialize package
        PushExpressManager().init(
            // your application id from https://app.push.express/
            '21486-1212',
            TransportType.fcmData,
            transportToken: token,
            // set property foreground "true" if you need to get notifications when app is in foreground (IOS only)
            foreground: true,
        );
    }
}

@override
void initState() {
    super.initState();

    // call to init
    initFirebase();
}

```

### Second step

Enable Background messaging

```dart
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // initialize firebase app
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // call function from the package to handle notifications,
  // and show them properly in background
  NotificationManager().handleNotification(message);
}

void main() {
  // ensure widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // handle Firebase background messages
  // and call our handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}
```

### Third step (OPTIONAL)

```dart
    // If you want to get any push notification in foreground
    // add this lines to your code
    FirebaseMessaging.onMessage.listen(
        // provide this function to handle notifications and show them properly
        NotificationManager().handleNotification,
    );
```

## Examples

Here are some examples to help you get started:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test_package/firebase_options.dart';
import 'package:push_express_lib/enums/common.dart';
import 'package:push_express_lib/notification_manager.dart';
import 'package:push_express_lib/push_express_lib.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  NotificationManager().handleNotification(message);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initFirebase();
  }

  void initFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await FirebaseMessaging.instance.requestPermission();

    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      PushExpressManager().init(
        '21486-1212',
        TransportType.fcm,
        transportToken: token,
        foreground: true,
      );
    }

    FirebaseMessaging.onMessage.listen(
      NotificationManager().handleNotification,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
```
