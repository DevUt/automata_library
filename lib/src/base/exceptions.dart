/// This supports various Exceptions that may occur
import 'dart:core';

/// Exception raised  when testing input through a automata, the inputSymbol
/// does not belong in the alphabet
class InvalidInputSymbolException implements Exception {
  final String message;
  final String offendingSymbol;

  const InvalidInputSymbolException(
      {this.message = "Input symbol invalid", required this.offendingSymbol});

  @override
  String toString() => message;
}

/// Exception raised when accessing an invalid state
class InvalidStateException implements Exception {
  final String message;
  final String offendingState;

  const InvalidStateException(
      {this.message = "Invalid state accessed", required this.offendingState});

  @override
  String toString() => message;
}

/// Exception raised when invalid NFA object is instantiated
class InvalidNfaException implements Exception {
  @override
  String toString() => "Invalid NFA";
}
