import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:video_compress/video_compress.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:nas_masr_app/core/data/models/chat_message.dart';
import 'package:nas_masr_app/core/data/reposetory/chat_repository.dart';
import 'package:nas_masr_app/core/data/web_services/error_handler.dart';

class ChatProvider with ChangeNotifier {
  final ChatRepository _repo;
  ChatProvider({required ChatRepository repository}) : _repo = repository;

  int? _peerId;
  int? _myId;
  bool _supportMode = false;
  bool _sending = false;
  bool _loading = false;
  String? _error;
  final List<ChatMessage> _messages = [];
  int _page = 1;
  int _lastPage = 1;
  String? _conversationId;

  Map<String, dynamic>? _listingSummary;
  bool _loadingListing = false;

  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  double _uploadProgress = 0.0;
  Timer? _recordTimer;
  int _recordDuration = 0;

  // Expose recorder to check amplitude if needed for UI, but keeping it simple for now

  @override
  void dispose() {
    _audioRecorder.dispose();
    _recordTimer?.cancel();
    super.dispose();
  }

  int? get peerId => _peerId;
  int? get myId => _myId;
  bool get supportMode => _supportMode;
  bool get sending => _sending;
  bool get loading => _loading;
  String? get error => _error;
  List<ChatMessage> get messages => List.unmodifiable(_messages);
  String? get conversationId => _conversationId;
  Map<String, dynamic>? get listingSummary => _listingSummary;
  bool get loadingListing => _loadingListing;
  bool get isRecording => _isRecording;
  double get uploadProgress => _uploadProgress;
  int get recordDuration => _recordDuration;

  void init({required int peerId, required int myId}) {
    _peerId = peerId;
    _myId = myId;
    _supportMode = false;
    _listingSummary = null;
    notifyListeners();
  }

  void initSupport({required int myId}) {
    _peerId = null;
    _myId = myId;
    _supportMode = true;
    notifyListeners();
  }

  Future<bool> send(String text,
      {String? contentType, int? listingId, String? filePath}) async {
    if (!_supportMode && (_peerId ?? 0) <= 0) {
      _setError('المستلم غير محدد');
      return false;
    }
    // Allow empty text if file is present
    if (text.trim().isEmpty && contentType == null && filePath == null) {
      _setError('نص الرسالة فارغ');
      return false;
    }

    _uploadProgress = 0.0;

    // Optimistic Update
    final tempId = -DateTime.now().millisecondsSinceEpoch;
    final tempMsg = ChatMessage(
        id: tempId,
        senderId: _myId ?? -1,
        receiverId: _supportMode ? 0 : (_peerId ?? 0),
        message: text,
        createdAt: DateTime.now(),
        contentType: contentType,
        listing: _listingSummary,
        attachment: filePath // Show local file path as attachment initially
        );

    _messages.add(tempMsg);
    notifyListeners();

    _setSending(true);
    _setError(null);
    try {
      final res = _supportMode
          ? await _repo.sendSupportMessage(message: text)
          : await _repo.sendMessage(
              receiverId: _peerId ?? 0,
              message: text,
              contentType: contentType,
              listingId: listingId,
              filePath: filePath,
              onSendProgress: (sent, total) {
                _uploadProgress = sent / total;
                notifyListeners();
              });

      // Remove temp message
      _messages.removeWhere((m) => m.id == tempId);

      int? id;
      try {
        final raw = res['id'] ?? res['message_id'];
        if (raw != null) id = int.tryParse(raw.toString());
      } catch (_) {}

      final msg = ChatMessage(
          id: id,
          senderId: _myId ?? -1,
          receiverId: _supportMode ? 0 : (_peerId ?? 0),
          message: text,
          createdAt: DateTime.now(),
          contentType: contentType, // Should be returned by API correctly
          listing: res['listing'] ?? _listingSummary,
          attachment: res['attachment'] // Server URL
          );

      _messages.add(msg);

      // Clear summary after sending if it was an inquiry
      if (contentType == 'listing_inquiry') {
        _listingSummary = null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _messages.removeWhere((m) => m.id == tempId);
      _setSending(false);
      final msg = e is AppError ? e.message : 'فشل إرسال الرسالة';
      _setError(msg);
      // Clean up temp file if needed?
      return false;
    } finally {
      // _setSending(false); // Handled inside catch for specific logic or here?
      // If success, we already set sending false? No, I removed it.
      if (_sending) _setSending(false);
      _uploadProgress = 0.0;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.camera) {
        if (!await Permission.camera.request().isGranted) {
          _setError('تحتاج إلى إعطاء صلاحية الكاميرا');
          return;
        }
      } else {
        // Photos permission - varies by API level, usually handled by picker but good to check if needed
        // For now relying on picker for gallery as it handles read media permissions complexity (READ_MEDIA_IMAGES etc) on Android 13+
      }

      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);
      if (image == null) return;

      _setSending(true); // Show loading/progress start

      // Compress
      // Get temp path
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        image.path,
        targetPath,
        quality: 70,
      );

      if (result == null) throw Exception('فشل ضغط الصورة');

      await send('', contentType: 'image', filePath: result.path);
    } catch (e) {
      _setError('فشل اختيار الصورة: $e');
    } finally {
      _setSending(false);
    }
  }

  Future<void> pickVideo(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? video = await picker.pickVideo(source: source);
      if (video == null) return;

      _setSending(true);

      // Compress
      await VideoCompress.setLogLevel(0);
      final MediaInfo? info = await VideoCompress.compressVideo(
        video.path,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
      );

      if (info == null || info.path == null) throw Exception('فشل ضغط الفيديو');

      await send('', contentType: 'video', filePath: info.path);
    } catch (e) {
      _setError('فشل اختيار الفيديو: $e');
    } finally {
      _setSending(false);
    }
  }

  Future<void> startRecording() async {
    try {
      if (!await Permission.microphone.request().isGranted) {
        _setError('تحتاج إلى إعطاء صلاحية الميكروفون');
        return;
      }

      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';
        const config = RecordConfig(encoder: AudioEncoder.aacLc);
        await _audioRecorder.start(config, path: path);
        _isRecording = true;
        _recordDuration = 0;
        _startTimer();
        notifyListeners();
      }
    } catch (e) {
      _setError('فشل بدء التسجيل');
    }
  }

  Future<void> stopRecording() async {
    try {
      if (!_isRecording) return;
      _stopTimer();
      final path = await _audioRecorder.stop();
      _isRecording = false;
      notifyListeners();

      if (path != null) {
        await send('', contentType: 'audio', filePath: path);
      }
    } catch (e) {
      _setError('فشل إيقاف التسجيل');
    }
  }

  Future<void> cancelRecording() async {
    try {
      if (!_isRecording) return;
      _stopTimer();
      await _audioRecorder.stop();
      // Do not send
      _isRecording = false;
      notifyListeners();
    } catch (_) {}
  }

  // Extension for recording amplitude if we want visualizer later
  Future<Amplitude> getAmplitude() => _audioRecorder.getAmplitude();

  Future<void> fetchListingSummary(String slug, int id) async {
    _loadingListing = true;
    notifyListeners();
    try {
      final res =
          await _repo.fetchListingSummary(categorySlug: slug, listingId: id);
      if (res['success'] == true && res['data'] != null) {
        _listingSummary = res['data'];
      }
    } catch (_) {
      // ignore error or handle
    } finally {
      _loadingListing = false;
      notifyListeners();
    }
  }

  void removeListingSummary() {
    _listingSummary = null;
    notifyListeners();
  }

  void deleteMessage(int id) {
    _messages.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  Future<void> load({bool reset = false, bool silent = false}) async {
    if (!_supportMode && (_peerId ?? 0) <= 0) return;
    if (!silent) _setLoading(true);
    _setError(null);
    try {
      final pageToLoad = reset ? 1 : _page;
      final (items, current, last) = _supportMode
          ? await _repo.fetchSupport(page: pageToLoad)
          : await _repo.fetchChat(peerId: _peerId!, page: pageToLoad);
      // حاول استخراج conversation_id من أول رسالة
      if (items.isNotEmpty) {
        final cid = items.first.conversationId;
        if (cid != null && cid.isNotEmpty) {
          _conversationId = cid;
        }
      }
      if (reset) {
        _messages
          ..clear()
          ..addAll(items);
        if (_conversationId != null) refreshReadMarks();
      } else {
        final indexById = <int, int>{};
        for (var i = 0; i < _messages.length; i++) {
          final id = _messages[i].id;
          if (id != null) indexById[id] = i;
        }
        for (final m in items) {
          final id = m.id;
          if (id != null && indexById.containsKey(id)) {
            final idx = indexById[id]!;
            final old = _messages[idx];
            _messages[idx] = ChatMessage(
              id: old.id,
              senderId: old.senderId,
              receiverId: old.receiverId,
              message: old.message,
              createdAt: old.createdAt,
              readAt: m.readAt ?? old.readAt,
              conversationId: old.conversationId ?? m.conversationId,
            );
          } else {
            _messages.add(m);
          }
        }
      }
      _page = current;
      _lastPage = last;
      notifyListeners();
    } catch (e) {
      final msg = e is AppError ? e.message : 'فشل تحميل الرسائل';
      _setError(msg);
    } finally {
      if (!silent) _setLoading(false);
    }
  }

  Future<void> loadMore() async {
    if (_page >= _lastPage) return;
    _page += 1;
    await load();
  }

  void _setSending(bool v) {
    _sending = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void setMyId(int id) {
    _myId = id;
    notifyListeners();
  }

  Future<void> refreshReadMarks() async {
    final cid = _conversationId;
    if (cid == null || cid.isEmpty) return;
    try {
      await _repo.fetchReadMarks(conversationId: cid);
      // The API now returns only count, so we rely on periodic load() to update UI
      // or we could optimistically mark all as read if we wanted.
    } catch (e) {
      // Ignore silent errors
    }
  }

  void _startTimer() {
    _recordTimer?.cancel();
    _recordTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      _recordDuration++;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _recordTimer?.cancel();
    _recordTimer = null;
  }
}
