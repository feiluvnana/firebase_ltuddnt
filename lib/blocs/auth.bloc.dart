import 'dart:async';
import 'package:firebase_ltuddnt/main.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

part 'auth.bloc.freezed.dart';

abstract class AuthEvent {
  const AuthEvent();
}

class AuthLogin extends AuthEvent {
  final String username, password;

  const AuthLogin(this.username, this.password);
}

class AuthLogout extends AuthEvent {}

class _AuthInternal extends AuthEvent {
  final AuthState authState;

  _AuthInternal(this.authState);
}

enum AuthStatus { authenticated, authenticating, unauthenticated }

@freezed
class AuthState with _$AuthState {
  const factory AuthState(
      {@Default(AuthStatus.unauthenticated) AuthStatus authStatus,
      StreamSubscription? sub,
      String? username,
      int? count}) = _AuthState;
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final db = FirebaseDatabase.instance;

  AuthBloc() : super(const AuthState()) {
    on<AuthLogin>((event, emit) async {
      emit(state.copyWith(authStatus: AuthStatus.authenticating));
      await db.ref("/users/${event.username}").get().then((value) {
        var obj = (value.value ?? {}) as Map<Object?, Object?>;

        if (obj == {} || obj["password"].toString() != event.password) {
          Fluttertoast.showToast(msg: "Tài khoản hoặc mật khẩu không đúng");
          emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
          return;
        }

        db.ref("/users/${event.username}").set({
          "password": obj["password"].toString(),
          "count": int.parse(obj["count"].toString()) + 1
        });
        Fluttertoast.showToast(msg: "Đăng nhập thành công");
        emit(state.copyWith(
            authStatus: AuthStatus.authenticated,
            username: event.username,
            count: int.parse(obj["count"].toString()) + 1,
            sub: db.ref("/users/${event.username}").onValue.listen((event) {
              var subObj = (event.snapshot.value ?? {}) as Map<Object?, Object?>;
              if (subObj != {}) {
                if ((state.count ?? 0) < int.parse(subObj["count"].toString())) {
                  flutterLocalNotificationsPlugin.show(
                      0,
                      'Thông báo',
                      'Tài khoản bị đăng nhập tại vị trí khác.',
                      const NotificationDetails(
                          android: AndroidNotificationDetails(
                              'your channel id', 'your channel name',
                              channelDescription: 'your channel description',
                              importance: Importance.max,
                              priority: Priority.high,
                              ticker: 'ticker')),
                      payload: 'item x');
                }
                add(_AuthInternal(state.copyWith(
                    authStatus: state.authStatus,
                    count: int.parse(subObj["count"].toString()),
                    username: state.username,
                    sub: state.sub)));
              }
            })));
      });
    });

    on<_AuthInternal>((event, emit) {
      emit(event.authState);
    });

    on<AuthLogout>((event, emit) async {
      await state.sub?.cancel();
      Fluttertoast.showToast(msg: "Đăng xuất thành công");
      emit(state.copyWith(authStatus: AuthStatus.unauthenticated));
      await db.ref("/users/${state.username}").get().then((value) async {
        var obj = (value.value ?? {}) as Map<Object?, Object?>;
        if (obj != {}) {
          await db.ref("/users/${state.username}").set({
            "password": obj["password"].toString(),
            "count": int.parse(obj["count"].toString()) - 1
          });
        }
      });
      emit(state.copyWith(sub: null, count: null, username: null));
    });
  }

  @override
  void onChange(Change<AuthState> change) {
    super.onChange(change);
    if (change.currentState.authStatus == AuthStatus.authenticated &&
        change.nextState.authStatus != AuthStatus.authenticated) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil("/auth", (route) => false);
    } else if (change.currentState.authStatus != AuthStatus.authenticated &&
        change.nextState.authStatus == AuthStatus.authenticated) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil("/home", (route) => false);
    }
  }
}
