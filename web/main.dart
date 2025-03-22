import 'dart:html';

import 'package:brainfuck/main.bloc.dart';

double SPEED_RATIO = 100000;

TextAreaElement codeTextarea = TextAreaElement();
ButtonElement playButton = ButtonElement();
ButtonElement stopButton = ButtonElement();
InputElement speedSlider = InputElement();
DivElement outputDiv = DivElement();
MainBloc bloc = MainBloc();

void main() {
  init();

  playButton.addEventListener('click', (Event e) {
    outputDiv.text = '';
    bloc.run(codeTextarea.value!);
  });
  speedSlider.addEventListener('change', (Event event) {
    var speed = SPEED_RATIO / int.parse((event.target as InputElement).value!);
    bloc.delay.sink.add(speed);
  });
  stopButton.addEventListener('click', (event) {
    bloc.stop();
  });
}

void init() {
  bloc = MainBloc();
  codeTextarea = querySelector('#code') as TextAreaElement;
  playButton = querySelector('#play') as ButtonElement;
  stopButton = querySelector('#stop') as ButtonElement;
  speedSlider = querySelector('#speed') as InputElement;
  outputDiv = querySelector('#output') as DivElement;
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
  var tapeDiv = DivElement()..id = 'tape';
  tape.asMap().forEach((int index, int value) {
    tapeDiv.append(_buildCell(value, index == bloc.position));
  });
  document.body?.append(tapeDiv);
}

DivElement _buildCell(int value, bool isActive) {
  var classes = <String>['cell'];
  if (isActive) {
    classes.add('active');
  }
  var cell = DivElement()
    ..innerText = value.toString()
    ..classes = classes;
  return cell;
}
