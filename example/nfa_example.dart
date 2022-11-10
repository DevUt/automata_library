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
          "0": {"q1"}
        },
        "q1": {
          "1": {"q2"}
        },
        "q2": {
          "0": {"q2"},
          "1": {"q2"}
        }
      });

  print("Is NFA valid? ${nfa.validate()}");

  String? inputString;
  print("Test a input string");
  inputString = stdin.readLineSync();

  if (inputString == null)
    return;
  else {
    print(nfa.testInput(inputString.split("")));
  }
}
