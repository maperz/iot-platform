part of 'authentication_bloc.dart';

@immutable
abstract class AuthenticationEvent {}

class IsAuthenticatedChanged extends AuthenticationEvent {
  final bool isAuthenticated;

  IsAuthenticatedChanged({required this.isAuthenticated});
}
