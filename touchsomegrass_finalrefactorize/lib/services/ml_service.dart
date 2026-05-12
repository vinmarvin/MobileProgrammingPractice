import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:logger/logger.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'plant_database_service.dart';

/// Enum untuk model yang tersedia
enum PlantModel {
  aiy('assets/models/aiy_vision_classifier_plants_V1_3.tflite', 'AIY Plants V1.3', 224),
  yolo('assets/models/plant_model.tflite', 'YOLOv8 (46 kelas)', 640);

  final String assetPath;
  final String displayName;
  final int inputSize;
  const PlantModel(this.assetPath, this.displayName, this.inputSize);
}

class MLService {
  static final MLService _instance = MLService._internal();
  factory MLService() => _instance;
  MLService._internal();

  Interpreter? _interpreter;
  final Logger _logger = Logger();
  bool _isModelLoaded = false;
  PlantModel _currentModel = PlantModel.aiy;

  // 46-label untuk model YOLOv8 Kaggle
  static const List<String> _yoloLabels = [
    'ginger', 'banana', 'tobacco', 'ornamental', 'rose', 'soybean', 'papaya',
    'garlic', 'raspberry', 'mango', 'cotton', 'corn', 'pomegranate', 'strawberry',
    'blueberry', 'brinjal', 'potato', 'wheat', 'olive', 'rice', 'lemon', 'cabbage',
    'guava', 'chilli', 'capsicum', 'sunflower', 'cherry', 'cassava', 'apple', 'tea',
    'sugarcane', 'groundnut', 'weed', 'peach', 'coffee', 'cauliflower', 'tomato',
    'onion', 'gram', 'chiku', 'jamun', 'castor', 'pea', 'cucumber', 'grape', 'cardamom',
  ];

  PlantModel get currentModel => _currentModel;

  Future<void> setModel(PlantModel model) async {
    if (_currentModel == model && _isModelLoaded) return;
    _interpreter?.close();
    _interpreter = null;
    _isModelLoaded = false;
    _currentModel = model;
    await initModel();
  }

  Future<void> initModel() async {
    if (_isModelLoaded) return;
    try {
      _interpreter = await Interpreter.fromAsset(_currentModel.assetPath);
      _isModelLoaded = true;
      final inShape  = _interpreter!.getInputTensor(0).shape;
      final outShape = _interpreter!.getOutputTensor(0).shape;
      final inType   = _interpreter!.getInputTensor(0).type.toString();
      final outType  = _interpreter!.getOutputTensor(0).type.toString();
      _logger.i('✅ Model ${_currentModel.displayName} dimuat');
      _logger.d('   In: $inShape ($inType) | Out: $outShape ($outType)');
    } catch (e) {
      _logger.e('❌ Gagal memuat model ${_currentModel.displayName}: $e');
    }
  }

  Future<Map<String, dynamic>?> predictPlant(File imageFile) async {
    if (!_isModelLoaded || _interpreter == null) {
      await initModel();
      if (!_isModelLoaded) return null;
    }

    try {
      // ── 1. Decode + fix EXIF ──────────────────────────────────────────
      final bytes = await imageFile.readAsBytes();
      img.Image? raw = img.decodeImage(bytes);
      if (raw == null) return null;
      img.Image oriented = img.bakeOrientation(raw);

      final int inputSize = _currentModel.inputSize;

      // ── 2. Letterbox resize ───────────────────────────────────────────
      double scale = inputSize / max(oriented.width, oriented.height);
      int newW = (oriented.width  * scale).round();
      int newH = (oriented.height * scale).round();
      img.Image resized = img.copyResize(oriented, width: newW, height: newH);
      img.Image canvas  = img.Image(width: inputSize, height: inputSize);
      img.fill(canvas, color: img.ColorRgb8(114, 114, 114));
      img.compositeImage(canvas, resized,
          dstX: (inputSize - newW) ~/ 2,
          dstY: (inputSize - newH) ~/ 2);

      // ── 3. Tentukan tipe input tensor ────────────────────────────────
      final inTypeName = _interpreter!.getInputTensor(0).type.toString();
      final bool isUint8Input = inTypeName.contains('uint8');

      _logger.d('Input type: $inTypeName | isUint8: $isUint8Input');

      // ── 4. Build input tensor ─────────────────────────────────────────
      // AIY V1.3 real type: float32 [1,224,224,3], normalized [0,1]
      // YOLOv8 Kaggle: float32 atau uint8 [1,640,640,3]
      final inputTensor = List.generate(
        1,
        (_) => List.generate(
          inputSize,
          (y) => List.generate(
            inputSize,
            (x) {
              final p = canvas.getPixel(x, y);
              if (isUint8Input) {
                return [p.r.toInt(), p.g.toInt(), p.b.toInt()];
              } else {
                // float32 normalized [0,1]
                return [p.r / 255.0, p.g / 255.0, p.b / 255.0];
              }
            },
          ),
        ),
      );

      // ── 5. Inference & parse output ───────────────────────────────────
      final outShape  = _interpreter!.getOutputTensor(0).shape;
      final outType   = _interpreter!.getOutputTensor(0).type.toString();
      final bool isUint8Out = outType.contains('uint8');

      _logger.d('Output shape: $outShape | type: $outType');

      int bestIdx = 0;
      double maxConf = 0.0;

      if (outShape.length == 2) {
        // ── Klasifikasi [1, N] ─────────────────────────────────────────
        final int numClasses = outShape[1];
        if (isUint8Out) {
          final output = List.generate(1, (_) => List.filled(numClasses, 0));
          _interpreter!.run(inputTensor, output);
          for (int c = 0; c < numClasses; c++) {
            double prob = output[0][c] / 255.0;
            if (prob > maxConf) { maxConf = prob; bestIdx = c; }
          }
        } else {
          final output = List.generate(1, (_) => List.filled(numClasses, 0.0));
          _interpreter!.run(inputTensor, output);
          for (int c = 0; c < numClasses; c++) {
            double prob = output[0][c].toDouble();
            // handle logit (nilai > 1 atau < 0)
            if (prob < 0 || prob > 1) prob = 1.0 / (1.0 + exp(-prob));
            if (prob > maxConf) { maxConf = prob; bestIdx = c; }
          }
        }
      } else if (outShape.length == 3) {
        // ── YOLO [1, attrs, anchors] atau [1, anchors, attrs] ──────────
        bool transposed = outShape[1] >= 1000;
        int anchors    = transposed ? outShape[1] : outShape[2];
        int attributes = transposed ? outShape[2] : outShape[1];
        int numClasses = attributes - 4;

        final output = transposed
            ? List.generate(1, (_) => List.generate(anchors,    (_) => List.filled(attributes, 0.0)))
            : List.generate(1, (_) => List.generate(attributes, (_) => List.filled(anchors, 0.0)));
        _interpreter!.run(inputTensor, output);

        for (int i = 0; i < anchors; i++) {
          for (int c = 0; c < numClasses; c++) {
            double prob = transposed
                ? output[0][i][c + 4].toDouble()
                : output[0][c + 4][i].toDouble();
            if (prob > maxConf) { maxConf = prob; bestIdx = c; }
          }
        }
      }

      _logger.i('→ bestIdx=$bestIdx  conf=${(maxConf * 100).toStringAsFixed(1)}%');

      if (maxConf < 0.03) {
        _logger.w('Confidence terlalu rendah');
        return null;
      }

      // ── 6. Resolve label ─────────────────────────────────────────────
      String labelName, latinName, benefits;
      if (_currentModel == PlantModel.yolo) {
        labelName = bestIdx < _yoloLabels.length
            ? _capitalize(_yoloLabels[bestIdx])
            : 'Tanaman #$bestIdx';
        latinName = '';
        benefits  = 'Informasi detail tersedia untuk model AIY Plants.';
      } else {
        final info = PlantDatabaseService().lookup(bestIdx);
        labelName = info.commonName;
        latinName = info.latinName;
        benefits  = info.benefits;
      }

      return {
        'modelIndex': bestIdx,
        'label':      labelName,
        'latinName':  latinName,
        'benefits':   benefits,
        'confidence': maxConf,
      };
    } catch (e, st) {
      _logger.e('Error prediksi: $e\n$st');
      return null;
    }
  }

  String _capitalize(String s) => s.isEmpty
      ? s
      : s[0].toUpperCase() + s.substring(1).toLowerCase();

  void dispose() {
    _interpreter?.close();
    _isModelLoaded = false;
  }
}
