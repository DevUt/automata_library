import 'package:automata_library/src/base/helper_classes.dart';
import 'package:automata_library/src/fa/nfa.dart';
import 'package:automata_library/src/fa/dfa.dart';

/// Class to support Generalized Nondeterministic finite automata
class GNFA extends NFA {
  late String acceptingState;
  GNFA({
    required Set<String> alphabet,
    required Set<String> states,
    required this.acceptingState,
    required String initialState,
    required Map<String, Map<String, Set<String>>> transitionFunction,
  }) : super(
            alphabet: alphabet,
            states: states,
            acceptingStates: {acceptingState},
            initialState: initialState,
            transitionFunction: transitionFunction) {
    // We have reached here it means the NFA has been validated.

    // First we need to add a new initialState to the GNFA
    _addNewInitialState();

    // New acceptingState to which the current accepting state points
    _addNewAcceptingState(currrentAcceptingStates: {acceptingState});
  }

  /// Construct GNFA from dfa
  GNFA.fromNfa(NFA nfa)
      : super(
            alphabet: nfa.alphabet,
            states: nfa.acceptingStates,
            acceptingStates: nfa.acceptingStates,
            initialState: nfa.initialState,
            transitionFunction: nfa.transitionFunction) {
    // First we need to add a new initialState to the GNFA
    _addNewInitialState();

    // New acceptingState to which the current accepting state points
    _addNewAcceptingState(currrentAcceptingStates: acceptingStates);
  }

  /// Construct GNFA from DFA
  GNFA.fromDFA(DFA dfa) : super.fromDFA(dfa: dfa) {
    // First we need to add a new initialState to the GNFA
    _addNewInitialState();

    // New acceptingState to which the current accepting state points
    _addNewAcceptingState(currrentAcceptingStates: dfa.acceptingStates);
  }

  /// Add new initialState which points to the exisiting initialState
  _addNewInitialState() {
    String newInitialState = _addNewState();
    transitionFunction.addAll({
      newInitialState: {
        "": {initialState}
      }
    });
    initialState = newInitialState;
  }

  ///Add new acceptingState which points to the current acceptingState
  void _addNewAcceptingState({required Set<String> currrentAcceptingStates}) {
    String newFinalState = _addNewState();
    for (String finalStates in currrentAcceptingStates) {
      if (transitionFunction[finalStates] != null) {
        if (transitionFunction[finalStates]!.containsKey("")) {
          transitionFunction[finalStates]![""]!.add(newFinalState);
        } else {
          transitionFunction[finalStates]!.addAll({
            "": {newFinalState}
          });
        }
      } else {
        transitionFunction.addAll({
          finalStates: {
            "": {newFinalState},
          }
        });
      }
    }
    acceptingState = newFinalState;
  }

  /// Add a new state which is not in [states]
  String _addNewState({int start = 0}) {
    int i = start;
    while (states.contains(i.toString())) {
      i++;
    }
    states.add(i.toString());
    return i.toString();
  }

  ///Check if parenthesis required
  bool _isParenthesisReq(String regex) {
    int bracketOpen = 0;

    for (int i = 0; i < regex.length; i++) {
      String element = regex[i];
      if (element == '(') {
        bracketOpen++;
      } else if (element == ')') {
        bracketOpen--;
      }
      if (bracketOpen == 0 && element == '|') return true;
    }

    return false;
  }

  /// Use state elimination to get the regex
  String regex() {
    List<String> stateSet =
        states.difference({initialState, acceptingState}).toList();

    // {State, {State, symbol}}
    Map<String, Map<String, String>> newTransition = {};
    for (MapEntry transitions in transitionFunction.entries) {
      for (MapEntry transitionOfState in transitions.value.entries) {
        for (String eachState in transitionOfState.value) {
          if (newTransition[transitions.key] == null) {
            newTransition.addAll({
              transitions.key: {eachState: transitionOfState.key}
            });
          } else {
            if (newTransition[transitions.key]!.containsKey(eachState)) {
              newTransition[transitions.key]!.addAll({
                eachState: newTransition[transitions.key]![eachState]! +
                    (" | ${transitionOfState.key}")
              });
            } else {
              newTransition[transitions.key]!
                  .addAll({eachState: transitionOfState.key});
            }
          }
        }
      }
    }
    while (stateSet.isNotEmpty) {
      String qR = stateSet[0];
      stateSet.removeAt(0);
      Set<String> newStates = states;
      newStates.remove(qR);
      List<List<String>> crossProduct = PermutationAlgorithmStrings([
        newStates.difference({acceptingState}).toList(),
        newStates.difference({initialState}).toList()
      ]).permutations();
      for (List<String> permutation in crossProduct) {
        String qI = permutation[0];
        String qJ = permutation[1];
        String? r1 = newTransition[qI]?[qR];
        String? r2 = newTransition[qR]?[qR] ?? '';
        String? r3 = newTransition[qR]?[qJ];
        String? r4 = newTransition[qI]?[qJ] ?? '';
        if (r1 == null || r3 == null) {
          continue;
        }

        if (_isParenthesisReq(r1)) r1 = '($r1)';

        if (r2 != '') {
          if (r2.length == 1) {
            r2 = '$r2*';
          } else {
            r2 = '($r2)*';
          }
        }

        if (_isParenthesisReq(r3)) r3 = '($r3)';

        if (r4 != '') {
          r4 = '| ($r4)';
        }

        String tempResult = '($r1$r2$r3$r4)';
        newTransition[qI]!.addAll({qJ: tempResult});
      }
      newTransition.remove(qR);

      for (String state in states.difference({acceptingState})) {
        if (newTransition[state] != null && newTransition[state]![qR] != null) {
          newTransition[state]!.remove(qR);
        }
      }
    }
    return newTransition[initialState]![acceptingState]!;
  }
}
