/// Provides helper classes

/// Class to returned when checking if we land in accepting state
class AcceptingStateTest {
  bool isAccepting;
  String finalState;

  AcceptingStateTest({required this.isAccepting, required this.finalState});
}

/// https://stackoverflow.com/a/57883482/5019937
class PermutationAlgorithmStrings {
  final List<List<String>> elements;

  PermutationAlgorithmStrings(this.elements);

  List<List<String>> permutations() {
    List<List<String>> perms = [];
    generatePermutations(elements, perms, 0, []);
    return perms;
  }

  void generatePermutations(List<List<String>> lists, List<List<String>> result,
      int depth, List<String> current) {
    if (depth == lists.length) {
      result.add(current);
      return;
    }

    for (int i = 0; i < lists[depth].length; i++) {
      generatePermutations(
          lists, result, depth + 1, [...current, lists[depth][i]]);
    }
  }
}
