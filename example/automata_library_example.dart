import 'dart:io';

import 'package:automata_library/automata_library.dart';

void main() {
  var dfa = DFA(
      alphabet: {"0", "1"},
      initialState: "even",
      acceptingStates: {"odd"},
      states: {"odd", "even"},
      transitionFunction: {
        "even": {"0": "odd", "1": "even"},
        "odd": {"0": "even", "1": "odd"}
      });
  print("DFA to check odd number of 0 in string");

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
