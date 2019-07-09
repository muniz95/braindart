import 'package:brainfuck/brainfuck.dart';
import 'package:test/test.dart';

String BF_CODE_THAT_PRINTS_ZERO = "++++++++++++++++++++++++++++++++++++++++++++++++.";
String BF_CODE_WITH_A_LOOP = "++++++++++++++++++++++++++++++++++++++++++++++++[>+>+>+<<<-]>.>.>.";
String BF_HELLO_WORLD = '++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.';

void main() {
  group("BF Interpreter", () {

    test("can print 0", () {
      expect(Brainfuck().run(BF_CODE_THAT_PRINTS_ZERO).toString(), "0");
    });

    test("can print a string with a loop", () {
      expect(Brainfuck().run(BF_CODE_WITH_A_LOOP).toString(), "000");
    });

    test("can print Hello World", () {
      expect(Brainfuck().run(BF_HELLO_WORLD).toString(), "Hello World!");
    });
  });
}