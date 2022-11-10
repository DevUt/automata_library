import 'dart:io';

import 'package:automata_library/automata_library.dart';

void main() {
  var dfa = DFA(
      alphabet: {"0", "1"},
      initialState: "q0",
      acceptingStates: {"q1"},
      states: {"q0", "q1"},
      transitionFunction: {
        "q0": {"0": "q1", "1": "q0"},
        "q1": {"0": "q0", "1": "q1"}
      });
  print("DFA to check odd number of 0 in string");
  print("Is valid? ${dfa.validate().toString()}");
  String? inputString;
  print("Test a input string");
  inputString = stdin.readLineSync();

  if (inputString == null) return;

  try {
    AcceptingStateTest test = dfa.acceptingStateTest(inputString.split(""));
    print(
        "Is Accepting? ${test.isAccepting}, final state is ${test.finalState}");
  } catch (e) {
    print(e.toString());
  }

  print("Lets try step by step transitions");
  inputString = stdin.readLineSync();
  if (inputString == null) return;

  try {
    String state = dfa.initialState;
    List<String> inputSplit = inputString.split("");

    stdout.write("$state ");
    for (String symbol in inputSplit) {
      String newstate = dfa.transition(originState: state, symbol: symbol);
      stdout.write("$newstate ");
      state = newstate;
    }
    print("");
  } catch (e) {
    print(e.toString());
  }
}
