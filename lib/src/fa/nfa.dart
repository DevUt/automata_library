import 'dart:collection';
import 'dart:core';
import 'package:collection/collection.dart';
import 'package:automata_library/src/fa/dfa.dart';
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

  /// Epsilon closure for each node
  Map<String, Set<String>> epsilonClosure = {};

  NFA({
    required this.alphabet,
    required this.initialState,
    required this.acceptingStates,
    required this.states,
    required this.transitionFunction,
  }) {
    if (!validate()) {
      throw InvalidNfaException();
    }
    // First compute the epsilonClosure for all states to cache
    _computeEpsilonClosure();
  }

  void _computeEpsilonClosure() {
    for (String state in states) {
      Set<String> visitedState = {};
      Queue<String> stackSimulate = Queue();

      if (!visitedState.contains(state)) {
        visitedState.add(state);
        stackSimulate.add(state);

        while (stackSimulate.isNotEmpty) {
          String currentState = stackSimulate.removeFirst();
          for (MapEntry transitionObj
              in transitionFunction[currentState]!.entries) {
            if (transitionObj.key == '') {
              Set<String> toAdd = transitionObj.value.difference(visitedState);
              visitedState.addAll(toAdd);
              stackSimulate.addAll(toAdd);
            }
          }
        }
      }
      epsilonClosure.addAll({state: visitedState});
    }
  }

  /// returns epsilonClosure for a state
  Set<String> epsilonClosureOfState(String state) {
    if (epsilonClosure[state] == null) {
      throw InvalidStateException(offendingState: state);
    } else {
      return epsilonClosure[state]!;
    }
  }

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
      if (!({""}..addAll(alphabet))
          .containsAll(MapKeySet(transitionObj.value))) {
        return false;
      }

      // Check if the states in the function is ⊂ states
      for (MapEntry stateMap in transitionObj.value.entries) {
        if (!states.containsAll(stateMap.value)) return false;
      }
    }
    return true;
  }

  /// returns transition from a originState reading a input
  Set<String> transition(
      {required String originState, required String symbol}) {
    // If the originState is not in state throw InvalidStateException
    if (!states.contains(originState)) {
      throw InvalidStateException(offendingState: originState);
    }

    // If the originState doesn't exist in transition function then we have no
    // outgoing arrow
    if (!transitionFunction.containsKey(originState)) return {};

    // if the symbol is not in the alphabet then throw
    // InvalidInputSymbolException
    // If it is an empty string then it is an epsilon transition
    if ((!alphabet.contains(symbol)) && symbol != '') {
      throw InvalidInputSymbolException(offendingSymbol: symbol);
    }

    Set<String> result = {};
    Set<String> statesToCheck = epsilonClosureOfState(originState);

    for (String state in statesToCheck) {
      if (transitionFunction[state]!.containsKey(symbol)) {
        for (String stateAvail in transitionFunction[state]![symbol]!) {
          result.addAll(epsilonClosureOfState(stateAvail));
        }
      }
    }
    return result;
  }

  /// return set of states that is reached by NFA on a input
  Set<Set<String>> testStepWiseInput(List<String> input) {
    Set<Set<String>> statesAtSteps = {};

    Set<String> currentState = {initialState};
    for (String inputSymbol in input) {
      Set<String> statesToAdd = {};
      for (String state in currentState) {
        statesToAdd.addAll(transition(originState: state, symbol: inputSymbol));
      }
      currentState = statesToAdd;
      statesAtSteps.add(statesToAdd);
    }
    return statesAtSteps;
  }

  ///return the result of test input
  Set<String> testInput(List<String> input) {
    return testStepWiseInput(input).last;
  }

  ///Check if set of states have acceptingStates
  bool isAcceptingState(Set<String> states) {
    return acceptingStates.intersection(states).isNotEmpty;
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

  ///Returns the converted DFA object of your NFA
  DFA convertNfaToDfa() {
    Map<String, Map<String, String>> transitionFunctionForDfa = {};
    List<Set<String>> listState = [];
    listState.add(epsilonClosureOfState(initialState));
    for (int i = 0; i < listState.length; i++) {
      Map<String, String> innerMap = {};
      for (String symbol in alphabet) {
        Set<String> toAdd = {};
        for (String state in listState[i]) {
          toAdd.addAll(transition(originState: state, symbol: symbol));
        }
        for (String state in toAdd) {
          toAdd.addAll(epsilonClosureOfState(state));
        }

        String innerNewState = toAdd.toList().sorted().join('');
        if (innerNewState == '') innerNewState = 'null';

        innerMap.addAll({symbol: innerNewState});
        bool contains = false;
        for (Set<String> enStates in listState) {
          if (SetEquality().equals(enStates, toAdd)) {
            contains = true;
          }
        }
        String newState = listState[i].toList().sorted().join('');
        if (newState == '') {
          newState = 'null';
        }
        transitionFunctionForDfa.addAll({newState: innerMap});
        if (!contains) {
          listState.add(toAdd);
        }
      }
    }
    Set<String> setState = {};
    Set<String> newAcceptingStates = {};
    for (Set<String> each in listState) {
      if (each.join('') == '') {
        setState.add('null');
      } else {
        setState.add(each.toList().sorted().join(''));
      }
    }
    for (String acceptingState in acceptingStates) {
      for (String state in setState) {
        if (state.contains(acceptingState)) {
          newAcceptingStates.add(state);
        }
      }
    }
    return DFA(
        alphabet: alphabet,
        initialState: initialState,
        acceptingStates: newAcceptingStates,
        states: setState,
        transitionFunction: transitionFunctionForDfa);
  }
}
