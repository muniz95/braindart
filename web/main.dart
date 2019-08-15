import 'dart:html';

import 'package:brainfuck/main.bloc.dart';

TextAreaElement codeTextarea;
ButtonElement playButton;
ButtonElement stopButton;
DivElement outputDiv;
MainBloc bloc;

void main() {
  init();

  playButton.addEventListener('click', (Event e) {
    bloc.run(codeTextarea.value);
  });
}

void init() {
  bloc = MainBloc();
  codeTextarea = querySelector('#code');
  playButton = querySelector('#play');
  stopButton = querySelector('#stop');
  outputDiv = querySelector('#output');
  codeTextarea.value = BF_HELLO_WORLD;
  bloc.composingOutput.listen((List<String> output) {
    outputDiv.text = output.join('');
  });
  bloc.tapeStream.listen((List<int> tape) {
    document.getElementById('tape')?.remove();
    _buildTape(tape);
  });
  bloc.positionStream.listen((int position) {
    document.getElementById('tape')?.remove();
    _buildTape(bloc.tape);
  });
}

void _buildTape(List<int> tape) {
  DivElement tapeDiv = DivElement()
    ..id = 'tape'
    ;
  tape.asMap().forEach((int index, int value) {
    tapeDiv.append(_buildCell(value, index == bloc.position));
  });
  document.body.append(tapeDiv);
}

DivElement _buildCell(int value, bool isActive) {
  List<String> classes = ['cell'];
  if (isActive) {
    classes.add('active');
  }
  DivElement cell = DivElement()
    ..innerText = value.toString()
    ..classes = classes
    ;
  return cell;
}
