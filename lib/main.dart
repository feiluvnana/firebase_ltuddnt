import 'package:firebase_ltuddnt/blocs/auth.bloc.dart';
import 'package:firebase_ltuddnt/uis/auth.ui.dart';
import 'package:firebase_ltuddnt/uis/home.ui.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => AuthBloc(),
        child: SafeArea(
            child: MaterialApp(
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                title: 'Firebase Database Demo',
                theme: ThemeData(
                    colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigoAccent),
                    useMaterial3: true),
                routes: {"/auth": (_) => const AuthUI(), "/home": (_) => const HomeUI()},
                initialRoute: "/auth")));
  }
}
