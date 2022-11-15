import 'dart:collection';
import 'dart:io';

import 'package:automata_library/automata_library.dart';
import 'package:collection/collection.dart';

void main() {
  NFA nfa = NFA(
      alphabet: {"a", "b", "c"},
      initialState: "p",
      acceptingStates: {"r"},
      states: {"p", "q", "r"},
      transitionFunction: {
        "p": {
          "": {"q", "r"},
          "b": {"q"},
          "c": {"r"}
        },
        "q": {
          "a": {"p"},
          "b": {"r"},
          "c": {"p", "q"}
        },
        "r": {}
      });

  List<Set<String>> listState = [];
  listState.add(nfa.epsilonClosureOfState(nfa.initialState));
  for (int i = 0; i < listState.length; i++) {
    print("Now iterating ${listState[i]}");
    for (String symbol in nfa.alphabet) {
      Set<String> toAdd = {};
      for (String state in listState[i]) {
        toAdd.addAll(nfa.transition(originState: state, symbol: symbol));

        print(
            "Did transition ${nfa.transition(originState: state, symbol: symbol)} for $state at $symbol");
      }
      for (String state in toAdd) {
        toAdd.addAll(nfa.epsilonClosureOfState(state));
      }

      print({toAdd});
      bool contains = false;
      for (Set<String> enStates in listState) {
        if (SetEquality().equals(enStates, toAdd)) {
          contains = true;
        }
      }

      if (!contains) {
        print("Added $toAdd");
        listState.add(toAdd);
      }
    }
  }
  print(listState);
}
