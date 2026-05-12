import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../services/notification_service.dart';
import '../services/database_helper.dart';
import '../models/focus_model.dart';

const int _kWorkChunkSeconds = 20 * 60;
const int _kRestChunkSeconds = 2 * 60;
const int _kLongBreakSeconds = 120 * 60;
const int _kOverloadSeconds  = 180 * 60;

const int _kMinTargetMinutes = 60;
const int _kMaxTargetMinutes = 8 * 60;
const int _kTargetStepMinutes = 30;

const List<Map<String, String>> kMusicVibes = [
  {'label': 'Lo-Fi',   'emoji': '🎵', 'file': 'audio/lofimusic_sample.mp3'},
  {'label': 'EDM',     'emoji': '⚡', 'file': 'audio/edmmusic_sample.mp3'},
  {'label': 'Rock',    'emoji': '🎸', 'file': 'audio/roxkmusic_sample.mp3'},
  {'label': 'Classic', 'emoji': '🎻', 'file': 'audio/classicmusic_sample.mp3'},
  {'label': 'J-Pop',   'emoji': '🌸', 'file': 'audio/jpopmusic_sample.mp3'},
  {'label': 'Jazz',    'emoji': '🎷', 'file': 'audio/jjmusic_sample.mp3'},
];

enum TimerState { idle, running, stopped }
enum TimerPhase { work, rest }

class TimerProvider extends ChangeNotifier {
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  int _totalWorkSeconds = 0;
  int _workChunkSeconds = 0;
  int _restSeconds = 0;
  int _targetMinutes = _kMinTargetMinutes;
  int _persistedPoints = 0;

  TimerState _state = TimerState.idle;
  TimerPhase _phase = TimerPhase.work;

  bool _longBreakNotifSent = false;
  bool _overloadNotifSent = false;
  bool _showOverloadDialog = false;
  bool _isPersistingPoints = false;

  bool _isSoundEnabled = false;
  int _selectedVibeIndex = 0;
  bool _isAudioPlaying = false;

  Future<void> Function(int points, int minutes)? _awardPointsCallback;

  bool get showOverloadDialog => _showOverloadDialog;
  bool get isSoundEnabled => _isSoundEnabled;
  bool get isAudioPlaying => _isAudioPlaying;
  int get selectedVibeIndex => _selectedVibeIndex;
  int get totalWorkSeconds => _totalWorkSeconds;
  int get targetMinutes => _targetMinutes;
  int get targetSeconds => _targetMinutes * 60;
  TimerState get state => _state;
  TimerPhase get phase => _phase;
  bool get isRestMode => _phase == TimerPhase.rest;
  bool get isOverload => _totalWorkSeconds >= _kOverloadSeconds;
  int get elapsedMinutes => _totalWorkSeconds ~/ 60;
  int get restSecondsLeft => (_kRestChunkSeconds - _restSeconds).clamp(0, _kRestChunkSeconds);
  int get earnedPoints => _totalWorkSeconds ~/ 300;
  String get currentVibeName => kMusicVibes[_selectedVibeIndex]['label']!;
  String get currentVibeEmoji => kMusicVibes[_selectedVibeIndex]['emoji']!;

  int get remainingWorkSeconds => (targetSeconds - _totalWorkSeconds).clamp(0, targetSeconds);

  String get formattedTime {
    if (_phase == TimerPhase.rest) {
      final s = restSecondsLeft;
      final m = s ~/ 60;
      final sec = s % 60;
      return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
    }
    final seconds = remainingWorkSeconds;
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  double get progress {
    if (_phase == TimerPhase.rest) {
      return _restSeconds / _kRestChunkSeconds;
    }
    if (_workChunkSeconds == 0 && _state == TimerState.idle) return 0;
    return (_workChunkSeconds / _kWorkChunkSeconds).clamp(0.0, 1.0);
  }

  double get sessionProgress {
    if (targetSeconds == 0) return 0;
    return (_totalWorkSeconds / targetSeconds).clamp(0.0, 1.0);
  }

  String get statusLabel {
    if (_phase == TimerPhase.rest) return 'rest_mode';
    if (_totalWorkSeconds >= _kOverloadSeconds) return 'overload';
    if (_totalWorkSeconds >= _kLongBreakSeconds) return 'long_break';
    return 'ok';
  }

  void setPointsAwarder(Future<void> Function(int points, int minutes) callback) {
    _awardPointsCallback = callback;
  }

  void dismissOverloadDialog() {
    _showOverloadDialog = false;
    notifyListeners();
  }

  Future<void> setVibe(int index) async {
    if (index < 0 || index >= kMusicVibes.length) return;
    _selectedVibeIndex = index;
    if (_isAudioPlaying) {
      await _startAmbientAudio();
    }
    notifyListeners();
  }

  Future<void> toggleSound() async {
    _isSoundEnabled = !_isSoundEnabled;
    if (_isSoundEnabled && _state == TimerState.running && _phase == TimerPhase.work) {
      await _startAmbientAudio();
    } else {
      await _stopAmbientAudio();
    }
    notifyListeners();
  }

  Future<void> playVibeStandalone(int index) async {
    _selectedVibeIndex = index;
    _isSoundEnabled = true;
    await _startAmbientAudio();
    notifyListeners();
  }

  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
    _isAudioPlaying = false;
    notifyListeners();
  }

  Future<void> resumeAudio() async {
    await _audioPlayer.resume();
    _isAudioPlaying = true;
    notifyListeners();
  }

  Future<void> stopVibeStandalone() async {
    await _stopAmbientAudio();
    _isSoundEnabled = false;
    notifyListeners();
  }

  Future<void> _startAmbientAudio() async {
    final file = kMusicVibes[_selectedVibeIndex]['file']!;
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource(file));
    _isAudioPlaying = true;
  }

  Future<void> _stopAmbientAudio() async {
    await _audioPlayer.stop();
    _isAudioPlaying = false;
  }

  void setTarget(double minutes) {
    if (_state == TimerState.running) return;
    final rounded = _roundToStep(minutes);
    final clamped = rounded.clamp(_kMinTargetMinutes, _kMaxTargetMinutes).toInt();
    _targetMinutes = clamped;
    _resetSession();
    notifyListeners();
  }

  void start() {
    if (_state == TimerState.running) return;
    if (remainingWorkSeconds <= 0) _beginNewWorkSession();
    if (_phase == TimerPhase.rest) {
      _phase = TimerPhase.work;
      _workChunkSeconds = 0;
      _restSeconds = 0;
    }
    _state = TimerState.running;
    NotificationService.scheduleRestReminder(interval: const Duration(minutes: 20));
    if (_isSoundEnabled) _startAmbientAudio();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    notifyListeners();
  }

  void _tick() {
    if (_state != TimerState.running) return;

    if (_phase == TimerPhase.work) {
      _totalWorkSeconds++;
      _workChunkSeconds++;
      _syncPoints();

      if (!_longBreakNotifSent && _totalWorkSeconds == _kLongBreakSeconds) {
        _longBreakNotifSent = true;
        NotificationService.notifyLongBreak();
      }
      if (!_overloadNotifSent && _totalWorkSeconds == _kOverloadSeconds) {
        _overloadNotifSent = true;
        _showOverloadDialog = true;
        NotificationService.notifyOverload(elapsedMinutes: elapsedMinutes);
      }
      if (remainingWorkSeconds <= 0) {
        _completeWorkSession();
        notifyListeners();
        return;
      }
      if (_workChunkSeconds >= _kWorkChunkSeconds) {
        _enterRestPhase();
        notifyListeners();
        return;
      }
    } else {
      _restSeconds++;
      if (_restSeconds >= _kRestChunkSeconds) {
        _phase = TimerPhase.work;
        _workChunkSeconds = 0;
        _restSeconds = 0;
        if (_isSoundEnabled) _startAmbientAudio();
      }
    }

    notifyListeners();
  }

  void _enterRestPhase() {
    _phase = TimerPhase.rest;
    _workChunkSeconds = 0;
    _restSeconds = 0;
    if (_isAudioPlaying) {
      _audioPlayer.pause();
      _isAudioPlaying = false;
    }
    NotificationService.notifyEyeHealth();
  }

  Future<void> stop() async {
    _timer?.cancel();
    _state = TimerState.stopped;
    await _stopAmbientAudio();
    await _syncPoints(force: true);
    await NotificationService.cancelRestReminders();
    notifyListeners();
  }

  Future<void> reset() async {
    _timer?.cancel();
    await _stopAmbientAudio();
    await _syncPoints(force: true);
    _resetSession();
    await NotificationService.cancelRestReminders();
    notifyListeners();
  }

  Future<Map<String, int>> finish() async {
    _timer?.cancel();
    await _syncPoints(force: true);
    await NotificationService.cancelRestReminders();
    await _stopAmbientAudio();
    final points = earnedPoints;
    final minutes = elapsedMinutes;
    _state = TimerState.stopped;
    _phase = TimerPhase.rest;
    
    // Simpan riwayat jika ada menit yang terlewati
    if (minutes > 0) {
      await _saveFocusHistory(minutes);
    }
    
    notifyListeners();
    return <String, int>{'points': points, 'minutes': minutes};
  }

  void _beginNewWorkSession() {
    _totalWorkSeconds = 0;
    _workChunkSeconds = 0;
    _restSeconds = 0;
    _persistedPoints = 0;
    _phase = TimerPhase.work;
    _longBreakNotifSent = false;
    _overloadNotifSent = false;
    _showOverloadDialog = false;
  }

  void _completeWorkSession() {
    _timer?.cancel();
    _state = TimerState.stopped;
    _phase = TimerPhase.rest;
    _syncPoints(force: true);
    _stopAmbientAudio();
    NotificationService.cancelRestReminders();
    
    if (elapsedMinutes > 0) {
      _saveFocusHistory(elapsedMinutes);
    }
  }

  Future<void> _saveFocusHistory(int minutes) async {
    final now = DateTime.now();
    final dateStr = "\${now.year}-\${now.month.toString().padLeft(2, '0')}-\${now.day.toString().padLeft(2, '0')} \${now.hour.toString().padLeft(2, '0')}:\${now.minute.toString().padLeft(2, '0')}";
    
    final history = FocusHistory(
      taskName: 'Sesi Fokus',
      durationMinutes: minutes,
      date: dateStr,
      categoryId: 1, // Default ke 'Belajar' (ID 1)
    );
    
    try {
      await DatabaseHelper.instance.insertFocusHistory(history);
    } catch (e) {
      debugPrint('Error saving focus history: $e');
    }
  }

  void _resetSession() {
    _totalWorkSeconds = 0;
    _workChunkSeconds = 0;
    _restSeconds = 0;
    _state = TimerState.idle;
    _phase = TimerPhase.work;
    _persistedPoints = 0;
    _longBreakNotifSent = false;
    _overloadNotifSent = false;
    _showOverloadDialog = false;
  }

  Future<void> _syncPoints({bool force = false}) async {
    final currentPoints = earnedPoints;
    final delta = currentPoints - _persistedPoints;
    if (delta <= 0) return;
    if (_isPersistingPoints && !force) return;
    _isPersistingPoints = true;
    try {
      final callback = _awardPointsCallback;
      if (callback != null) {
        await callback(delta, delta * 5);
      }
      _persistedPoints = currentPoints;
    } finally {
      _isPersistingPoints = false;
    }
  }

  int _roundToStep(double minutes) {
    return ((minutes / _kTargetStepMinutes).round() * _kTargetStepMinutes);
  }

  String formatTarget() {
    final hours = _targetMinutes ~/ 60;
    final remainder = _targetMinutes % 60;
    if (remainder == 0) return '$hours jam';
    if (hours == 0) return '$remainder menit';
    return '$hours jam $remainder menit';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopAmbientAudio();
    _syncPoints(force: true);
    NotificationService.cancelRestReminders();
    _audioPlayer.dispose();
    super.dispose();
  }
}
