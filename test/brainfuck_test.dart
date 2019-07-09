import 'package:brainfuck/main.bloc.dart';
import 'package:test/test.dart';

String BF_CODE_THAT_PRINTS_ZERO = "++++++++++++++++++++++++++++++++++++++++++++++++.";
String BF_CODE_WITH_A_LOOP = "++++++++++++++++++++++++++++++++++++++++++++++++[>+>+>+<<<-]>.>.>.";
String BF_HELLO_WORLD = '++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.';

void main() {
  group("BF Interpreter", () {

    test("can print 0", () async {
      expect(await MainBloc().run(BF_CODE_THAT_PRINTS_ZERO), "0");
    });

    test("can print a string with a loop", () async {
      expect(await MainBloc().run(BF_CODE_WITH_A_LOOP), "000");
    });

    test("can print Hello World", () async {
      expect(await MainBloc().run(BF_HELLO_WORLD), "Hello World!");
    });
  });
}