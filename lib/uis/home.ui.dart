import 'package:firebase_ltuddnt/blocs/auth.bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeUI extends StatelessWidget {
  const HomeUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Chào mừng ${BlocProvider.of<AuthBloc>(context, listen: true).state.username}!"),
            Text(
                "Có ${BlocProvider.of<AuthBloc>(context, listen: true).state.count} người đang đăng nhập tài khoản này."),
            ElevatedButton(
                onPressed: () => context.read<AuthBloc>(), child: const Text("Đăng xuất"))
          ],
        ),
      ),
    );
  }
}
