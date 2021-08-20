part of 'authentication_bloc.dart';

@immutable
abstract class AuthenticationState {}

class InitialAuthenticationState extends AuthenticationState {}

class ShowLoginScreen extends AuthenticationState {}

class ShowConnectionPlaceholderScreen extends AuthenticationState {}

class ShowDeviceListScreen extends AuthenticationState {}
