import 'package:automata_library/src/fa/gnfa.dart';

void main() {
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
