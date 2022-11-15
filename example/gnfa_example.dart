import 'package:automata_library/src/fa/dfa.dart';
import 'package:automata_library/src/fa/gnfa.dart';

void main() {
  DFA dfa = DFA(
      alphabet: {"0", "1"},
      initialState: "q0",
      acceptingStates: {"q0"},
      states: {"q0", "q1"},
      transitionFunction: {
        "q0": {"0": "q1", "1": "q0"},
        "q1": {"0": "q0", "1": "q1"}
      });

  print(GNFA.fromDFA(dfa).regex());

  GNFA gnfa = GNFA(
      alphabet: {'0', '1'},
      states: {'q0', 'q1', 'q2'},
      acceptingState: 'q2',
      initialState: 'q0',
      transitionFunction: {
        "q0": {
          "0": {"q1"},
          "1": {"q0"}
        },
        "q1": {
          "1": {"q2", "q0"}
        },
        "q2": {
          "0": {"q1"},
        },
      });

  print(gnfa.regex());
}
