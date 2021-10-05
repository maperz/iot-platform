import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:iot_client/services/auth/auth_service.dart';
import 'package:iot_client/services/connection/address_resolver.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final IAddressResolver addressResolver;
  final IAuthService authService;

  StreamSubscription? _subscription;

  AuthenticationBloc({required this.addressResolver, required this.authService})
      : super(InitialAuthenticationState()) {
    var requiresAuthStream = addressResolver
        .getAddress()
        .map((address) => address.requiresAuthentication);

    var stateStream = CombineLatestStream.combine2(
        requiresAuthStream,
        authService.isLoggedIn(),
        (bool requires, bool isAuth) => (!requires || isAuth));

    stateStream.listen((isAuthenticated) {
      add(IsAuthenticatedChanged(isAuthenticated: isAuthenticated));
    });
  }
  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is IsAuthenticatedChanged) {
      if (event.isAuthenticated) {
        yield ShowDeviceListScreen();
      } else {
        yield ShowLoginScreen();
      }
    }
  }
}
