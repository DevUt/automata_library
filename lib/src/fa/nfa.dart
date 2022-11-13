import 'dart:collection';
import 'dart:core';
import 'package:collection/collection.dart';
import 'package:automata_library/src/base/exceptions.dart';

/// Class that manages and provides operation on a non-determinstic finite
/// automata
class NFA {
  /// Alphabet that is allowed for the automata denoted formally as Σ
  /// To write epsilon use empty string
  Set<String> alphabet;

  /// Initial state for the NFA formally as q0
  String initialState;

  /// The set of final accepting states formally denoted as F
  Set<String> acceptingStates;

  /// The set of all states formally denoted as Q
  Set<String> states;

  /// The transition function δ: Q × Σ -> P(Q) where P denotes the power set
  /// state : [alphabet, Set<State>]
  Map<String, Map<String, Set<String>>> transitionFunction;

  NFA({
    required this.alphabet,
    required this.initialState,
    required this.acceptingStates,
    required this.states,
    required this.transitionFunction,
  });

  /// Validate the NFA
  /// For a valid NFA, initialState ⊂ states, acceptingStates ⊂ states
  /// The transitionFunction should contain valid states and alphabet
  bool validate() {
    // Check initialState ⊂ states
    if (!states.contains(initialState)) return false;

    // Check acceptingStates ⊂ states
    if (!states.containsAll(acceptingStates)) return false;

    // Check if the states of the transition function ⊂ states
    // The states that are missing don't have any outgoing transitions
    if (!states.containsAll(MapKeySet(transitionFunction))) return false;

    for (MapEntry transitionObj in transitionFunction.entries) {
      // Check if the alphabet used is ⊂ alphabet
      if (!alphabet.containsAll(MapKeySet(transitionObj.value))) return false;

      // Check if the states in the function is ⊂ states
      for (MapEntry stateMap in transitionObj.value.entries) {
        if (!states.containsAll(stateMap.value)) return false;
      }
    }
    return true;
  }

  Set<String>? transition(
      {required String originState, required String symbol}) {
    // If the originState is not in state throw InvalidStateException
    if (!states.contains(originState)) {
      throw InvalidStateException(offendingState: originState);
    }

    // If the originState doesn't exist in transition function then we have no
    // outgoing arrow
    if (!transitionFunction.containsKey(originState)) return null;

    // if the symbol is not in the alphabet then throw
    // InvalidInputSymbolException
    // If it is an empty string then it is an epsilon transition
    if ((!alphabet.contains(symbol)) && symbol != '') {
      throw InvalidInputSymbolException(offendingSymbol: symbol);
    }

    return transitionFunction[originState]![symbol];
  }

  /// return set of states that is reached by NFA on a input
  Set<Set<String>> testStepWiseInput(List<String> input) {
    Set<Set<String>> statesAtSteps = {};
    List<String> statesToCheck = [initialState];
    for (String inputSymbol in input) {
      List<String> newStates = [];

      for (String state in statesToCheck) {
        newStates.addAll(
            transition(originState: state, symbol: inputSymbol)?.toList() ??
                []);
        statesAtSteps.add(statesToCheck.toSet());
      }
      statesToCheck = newStates;
    }
    return statesAtSteps;
  }

  ///return the result of test input
  Set<String>? testInput(List<String> input) {
    return testStepWiseInput(input).last;
  }

  ///Internal helper to search the Multigraph formed by the NFA
  Set<String> _traversalSearch({required String startState}) {
    Set<String> visitedState = {};
    Queue<String> stackSimulate = Queue();

    stackSimulate.add(startState);
    visitedState.add(startState);

    while (stackSimulate.isNotEmpty) {
      String currentState = stackSimulate.removeFirst();

      for (Set<String> setOfStates
          in transitionFunction[currentState]!.values) {
        for (String state in setOfStates) {
          if (!visitedState.contains(state)) {
            visitedState.add(state);
            stackSimulate.addLast(state);
          }
        }
      }
    }

    return visitedState;
  }

  ///Compute reachable states from initialState
  Set<String> computeReachableStates() {
    return _traversalSearch(startState: initialState);
  }
}
