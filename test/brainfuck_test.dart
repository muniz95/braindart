import 'package:brainfuck/brainfuck.dart';
import 'package:test/test.dart';

String BF_CODE_THAT_PRINTS_0 = "++++++++++++++++++++++++++++++++++++++++++++++++.";

void main() {
  group("BF Interpreter", () {

    test("can print 0", () {
      expect(Brainfuck(BF_CODE_THAT_PRINTS_0).toString(), "0");
    });
  });
}