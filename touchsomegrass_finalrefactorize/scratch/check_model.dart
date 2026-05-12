import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() async {
  print('Loading plant_model.tflite...');
  final model1 = await Interpreter.fromFile(File('assets/models/plant_model.tflite'));
  print('Input: \${model1.getInputTensors()}');
  print('Output: \${model1.getOutputTensors()}');

  print('Loading plants_classifier.tflite...');
  final model2 = await Interpreter.fromFile(File('assets/models/plants_classifier.tflite'));
  print('Input: \${model2.getInputTensors()}');
  print('Output: \${model2.getOutputTensors()}');
}
