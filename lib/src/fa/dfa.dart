import 'dart:collection';
import 'dart:core';
import 'package:collection/collection.dart';
import 'package:automata_library/src/base/exceptions.dart';
import 'package:automata_library/src/base/helper_classes.dart';

/// Class that manages and provides operation on a determinstic finite automata
class DFA {
  /// 5 tuples necessary for a DFA
  Set<String> alphabet;
  String initialState;
  Set<String> acceptingStates;
  Set<String> states;
  Map<String, Map<String, String>> transitionFunction;

  DFA(
      {required this.alphabet,
      required this.initialState,
      required this.acceptingStates,
      required this.states,
      required this.transitionFunction});

  /// Validate the DFA
  /// We Validate the DFA by checking whether the transition function is valid
  bool validate() {
    // accpeting states should be a subset of states
    if (!states.containsAll(acceptingStates)) return false;

    //initialState should be in states
    if (!states.contains(initialState)) return false;

    // The Transition function should have transitions for each of the states
    if (!SetEquality().equals(states, MapKeySet(transitionFunction).toSet())) {
      return false;
    }

    for (MapEntry tranistionObj in transitionFunction.entries) {
      Map<String, String> transitions = tranistionObj.value;

      Set<String> alphabetUsedInTransition = MapKeySet(transitions);
      if (!SetEquality().equals(alphabetUsedInTransition, alphabet)) {
        return false;
      }

      Set<String> statesInTransition =
          MapValueSet(transitions, (String str) => str.hashCode);

      if (!states.containsAll(statesInTransition)) return false;
    }
    return true;
  }

  /// Returns state final state after processing the input
  /// throws InvalidStateException if the DFA is invalid
  /// throws InvalidInputSymbolException if the input symbol is not in alphabet
  String testInput(List<String> input) {
    String state = initialState;

    for (String inputSymbol in input) {
      state = transition(originState: state, symbol: inputSymbol);
    }

    return state;
  }

  /// Addon for the [testInput]
  List<String> testStepwiseInput(List<String> input) {
    List<String> statesVisited = [];
    String state = initialState;

    for (String inputSymbol in input) {
      state = transition(originState: state, symbol: inputSymbol);
      statesVisited.add(state);
    }

    return statesVisited;
  }

  /// Returns AcceptingStateTest class on testing the input
  AcceptingStateTest acceptingStateTest(List<String> input) {
    final String finalState = testInput(input);
    final bool isAcceptingState = acceptingStates.contains(finalState);

    return AcceptingStateTest(
        isAccepting: isAcceptingState, finalState: finalState);
  }

  ///Returns 'true' if state is accepting state
  bool isAcceptingState(String state) => acceptingStates.contains(state);

  /// Returns state after doing transition from give state
  String transition({required originState, required symbol}) {
    if (transitionFunction[originState] == null) {
      throw InvalidStateException(offendingState: originState);
    }
    if (transitionFunction[originState]![symbol] == null) {
      throw InvalidInputSymbolException(offendingSymbol: symbol);
    }
    return transitionFunction[originState]![symbol]!;
  }

  DFA complement() {
    DFA newDfa = this;
    newDfa._exchangeFinalAndNonFinal();

    return newDfa;
  }

  void _exchangeFinalAndNonFinal() {
    acceptingStates = states.difference(acceptingStates);
  }

  /// Run a traversal from a node to find reachable nodes
  Set<String> _traversalSearch({required String startState}) {
    Set<String> visitedState = {};
    Queue<String> stackSimulate = Queue();

    stackSimulate.add(startState);
    visitedState.add(startState);

    while (stackSimulate.isNotEmpty) {
      String currentState = stackSimulate.removeFirst();

      for (String stateFound in transitionFunction[currentState]!.values) {
        if (!visitedState.contains(stateFound)) {
          visitedState.add(stateFound);
          stackSimulate.addLast(stateFound);
        }
      }
    }
    return visitedState;
  }

  ///Compute states which are reachable from the initialState
  Set<String> computeReachableStates() {
    return _traversalSearch(startState: initialState);
  }

  ///Find states which are dead (have no path to final state)
  Set<String> computeDeadStates() {
    Set<String> deadStates = {};

    for (String state in states) {
      if (!acceptingStates.contains(state)) {
        Set<String> statesReachable = _traversalSearch(startState: state);

        if (acceptingStates.intersection(statesReachable).isEmpty) {
          deadStates.add(state);
        }
      }
    }
    return deadStates;
  }

  ///Return a directed graph of the DFA
}
