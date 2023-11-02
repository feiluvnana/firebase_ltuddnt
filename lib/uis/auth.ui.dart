import 'package:firebase_ltuddnt/blocs/auth.bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthUI extends StatefulWidget {
  const AuthUI({super.key});

  @override
  State<AuthUI> createState() => _AuthUIState();
}

class _AuthUIState extends State<AuthUI> {
  final username = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                controller: username, decoration: const InputDecoration(labelText: "Tài khoản")),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                controller: password, decoration: const InputDecoration(labelText: "Mật khẩu")),
          ),
          ElevatedButton(
              onPressed: BlocProvider.of<AuthBloc>(context, listen: true).state.authStatus ==
                      AuthStatus.authenticating
                  ? null
                  : () => context.read<AuthBloc>().add(AuthLogin(username.text, password.text)),
              child: const Text("Đăng nhập"))
        ],
      ),
    );
  }
}
