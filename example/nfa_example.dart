import 'dart:io';

import 'package:automata_library/automata_library.dart';

void main() {
  NFA nfa = NFA(
      alphabet: {"0", "1"},
      initialState: "q0",
      acceptingStates: {"q2"},
      states: {"q0", "q1", "q2"},
      transitionFunction: {
        "q0": {
          "0": {"q2"}
        },
        "q1": {
          "1": {"q2", "q0"}
        },
        "q2": {
          "0": {"q1", "q0"},
          "1": {"q0"}
        }
      });
  print(nfa.convertNfaToDfa().transitionFunction);
  print(nfa.convertNfaToDfa().states);
  print(nfa.convertNfaToDfa().alphabet);
  print(nfa.convertNfaToDfa().validate());
//print(nfa.transitionFunction);
//print(nfa.initialState);
//print(nfa.acceptingStates);
//print(nfa.states);
//print(nfa.alphabet);
}
