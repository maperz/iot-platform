part of 'authentication_bloc.dart';

@immutable
abstract class AuthenticationState {}

class InitialAuthenticationState extends AuthenticationState {}

class ShowLoginScreen extends AuthenticationState {}

class ShowPlaceholderScreen extends AuthenticationState {}

class ShowMainScreen extends AuthenticationState {}
