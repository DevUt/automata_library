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
          "0": {"q1"},
          "1": {""}
        },
        "q1": {
          "0": {"q2", "q0"},
          "1": {"q2"}
        },
        "q2": {
          "0": {"q0"},
          "1": {"q0", "q1"}
        }
      });

  print(nfa.alphabet);
  print(nfa.states);
  print(nfa.acceptingStates);
  print(nfa.initialState);
  print(nfa.transitionFunction);
  print("Is NFA valid? ${nfa.validate()}");
  print(nfa.epsilonClosure);
  String? inputString;
  print("Test a input string");
  inputString = stdin.readLineSync();

  if (inputString == null) {
    return;
  } else {
    print(nfa.testInput(inputString.split("")));
  }
}
