import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../models/chat_message.dart';
import '../services/chat/chat_service.dart';
import '../services/chat/groq_config_service.dart';
import '../services/chat/groq_api_service.dart';

class ChatController extends ChangeNotifier {
  ChatController({this.initialSessionId});

  final String? initialSessionId;

  final TextEditingController messageController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final ImagePicker imagePicker = ImagePicker();
  final stt.SpeechToText speech = stt.SpeechToText();
  final FlutterTts tts = FlutterTts();

  static const int dailyImageLimit = 5;
  static const List<String> modes = [
    'General',
    'Tech',
    'Hinglish',
    'Simple',
    'Compare',
  ];

  static const List<Map<String, String>> languages = [
    {'code': 'en_US', 'label': 'English'},
    {'code': 'hi_IN', 'label': 'Hindi'},
    {'code': 'mr_IN', 'label': 'Marathi'},
    {'code': 'gu_IN', 'label': 'Gujarati'},
    {'code': 'bn_IN', 'label': 'Bengali'},
  ];

  List<ChatMessage> messages = [];
  bool isLoading = false;
  String apiKey = '';
  String selectedMode = 'General';
  String? currentSessionId;
  String? lastUserQuery;
  String? speakingMsgId;
  bool isListening = false;
  String voiceLocale = 'en_US';
  bool isSearchMode = false;
  String searchQuery = '';

  List<File> pendingImages = [];
  String? pendingPdfText;
  String? pendingPdfName;

  bool _initialized = false;
  bool get isReady => _initialized;

  List<ChatMessage> get filteredMessages {
    if (searchQuery.isEmpty) return messages;
    return messages
        .where((m) => m.text.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  List<ChatMessage> get favoriteMessages =>
      messages.where((m) => m.isFavorite).toList();

  Future<void> initialize() async {
    await _initSpeech();
    await _initTts();
    apiKey = await GroqConfigService.loadApiKey();
    if (initialSessionId != null) {
      await loadSession(initialSessionId!);
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> _initSpeech() async {
    await speech.initialize(
      onError: (e) => debugPrint('Speech error: $e'),
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') {
          isListening = false;
          notifyListeners();
        }
      },
    );
  }

  Future<void> _initTts() async {
    await tts.setLanguage('en-US');
    await tts.setSpeechRate(0.5);
    tts.setCompletionHandler(() {
      speakingMsgId = null;
      notifyListeners();
    });
  }

  bool get needsApiKey => apiKey.isEmpty;

  Future<void> reloadApiKey() async {
    GroqConfigService.clearCache();
    apiKey = await GroqConfigService.loadApiKey();
    notifyListeners();
  }

  Future<void> loadSession(String sessionId) async {
    final session = await ChatService.instance.getSession(sessionId);
    if (session == null) return;
    currentSessionId = sessionId;
    messages = List.from(session.messages);
    notifyListeners();
    scrollToBottom();
  }

  /// Returns error message if send blocked (e.g. daily image limit).
  Future<String?> sendMessage({String? overrideText}) async {
    final text = overrideText ?? messageController.text.trim();
    final hasImages = pendingImages.isNotEmpty;
    final hasPdf = pendingPdfText != null;

    if (text.isEmpty && !hasImages && !hasPdf) return null;
    if (apiKey.isEmpty) return 'API key required';

    if (text.isNotEmpty) lastUserQuery = text;

    if (hasImages && !await _canSendImage()) {
      return 'Daily image limit reached';
    }

    var displayText = text;
    if (hasImages && text.isEmpty) {
      displayText = '📷 ${pendingImages.length} Image(s)';
    }
    if (hasPdf && text.isEmpty) displayText = '📄 $pendingPdfName';
    if (hasPdf && text.isNotEmpty) displayText = '📄 $pendingPdfName\n\n$text';

    final userMsg = ChatMessage(
      text: displayText,
      isUser: true,
      type: hasImages
          ? MessageType.image
          : hasPdf
              ? MessageType.pdf
              : MessageType.text,
      filePath: hasImages ? pendingImages.first.path : null,
      fileName: hasPdf ? pendingPdfName : null,
    );

    final imagesToSend = List<File>.from(pendingImages);
    final pdfText = pendingPdfText;
    final pdfName = pendingPdfName;

    messages.add(userMsg);
    isLoading = true;
    pendingImages = [];
    pendingPdfText = null;
    pendingPdfName = null;
    if (overrideText == null) messageController.clear();
    notifyListeners();
    scrollToBottom();

    try {
      currentSessionId ??=
          await ChatService.instance.createSession(displayText);
      await ChatService.instance.addMessage(currentSessionId!, userMsg);
    } catch (e) {
      debugPrint('Storage: $e');
    }

    try {
      final groq = GroqApiService(apiKey: apiKey);
      final String response;
      if (imagesToSend.isNotEmpty) {
        response = await groq.imageCompletion(
          mode: selectedMode,
          image: imagesToSend.first,
          question: text,
        );
      } else if (pdfText != null) {
        response = await groq.documentCompletion(
          mode: selectedMode,
          fileContent: pdfText,
          fileName: pdfName ?? 'Document',
          question: text,
        );
      } else {
        response = await groq.textCompletion(
          mode: selectedMode,
          history: messages,
          query: text,
        );
      }

      final aiMsg = ChatMessage(text: response, isUser: false);
      messages.add(aiMsg);
      if (currentSessionId != null) {
        await ChatService.instance.addMessage(currentSessionId!, aiMsg);
      }
    } catch (e) {
      messages.add(ChatMessage(text: 'Error: $e', isUser: false));
    } finally {
      isLoading = false;
      notifyListeners();
      scrollToBottom();
    }
    return null;
  }

  Future<void> regenerate() async {
    if (lastUserQuery == null || isLoading) return;
    if (messages.isNotEmpty && !messages.last.isUser) {
      messages.removeLast();
    }
    isLoading = true;
    notifyListeners();
    try {
      final groq = GroqApiService(apiKey: apiKey);
      final response = await groq.textCompletion(
        mode: selectedMode,
        history: messages,
        query: lastUserQuery!,
      );
      final aiMsg = ChatMessage(text: response, isUser: false);
      messages.add(aiMsg);
      if (currentSessionId != null) {
        await ChatService.instance.addMessage(currentSessionId!, aiMsg);
      }
    } catch (e) {
      messages.add(ChatMessage(text: 'Error: $e', isUser: false));
    } finally {
      isLoading = false;
      notifyListeners();
      scrollToBottom();
    }
  }

  void clearChat() {
    messages.clear();
    currentSessionId = null;
    pendingImages = [];
    pendingPdfText = null;
    pendingPdfName = null;
    lastUserQuery = null;
    notifyListeners();
  }

  void newChat() => clearChat();

  void setMode(String mode) {
    selectedMode = mode;
    notifyListeners();
  }

  void toggleSearch() {
    isSearchMode = !isSearchMode;
    if (!isSearchMode) {
      searchQuery = '';
      searchController.clear();
    }
    notifyListeners();
  }

  void setSearchQuery(String value) {
    searchQuery = value;
    notifyListeners();
  }

  void toggleFavorite(ChatMessage msg) {
    msg.isFavorite = !msg.isFavorite;
    notifyListeners();
  }

  void copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  void shareMessage(String text) {
    Share.share('AI Chatbot:\n\n$text', subject: 'AI Chatbot');
  }

  Future<void> toggleListening() async {
    if (isListening) {
      await speech.stop();
      isListening = false;
      notifyListeners();
      return;
    }
    final available = await speech.initialize();
    if (!available) return;
    isListening = true;
    notifyListeners();
    speech.listen(
      localeId: voiceLocale,
      onResult: (result) {
        messageController.text = result.recognizedWords;
        messageController.selection = TextSelection.fromPosition(
          TextPosition(offset: messageController.text.length),
        );
        notifyListeners();
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          isListening = false;
          notifyListeners();
        }
      },
    );
  }

  Future<void> toggleSpeak(ChatMessage msg) async {
    if (speakingMsgId == msg.id) {
      await tts.stop();
      speakingMsgId = null;
      notifyListeners();
      return;
    }
    await tts.setLanguage(voiceLocale.replaceAll('_', '-'));
    speakingMsgId = msg.id;
    notifyListeners();
    await tts.speak(msg.text);
  }

  void setVoiceLocale(String code) {
    voiceLocale = code;
    notifyListeners();
  }

  Future<int> todayImageCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return prefs.getInt('img_count_$today') ?? 0;
  }

  Future<bool> _canSendImage() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final key = 'img_count_$today';
    final count = prefs.getInt(key) ?? 0;
    if (count >= dailyImageLimit) return false;
    await prefs.setInt(key, count + 1);
    return true;
  }

  Future<String?> pickImages(ImageSource source) async {
    try {
      final used = await todayImageCount();
      final remaining = dailyImageLimit - used;
      if (remaining <= 0) return 'Daily image limit reached';

      if (source == ImageSource.gallery) {
        final picked = await imagePicker.pickMultiImage(
          imageQuality: 85,
          maxWidth: 1024,
        );
        if (picked.isNotEmpty) {
          pendingImages =
              picked.take(remaining).map((f) => File(f.path)).toList();
          pendingPdfText = null;
          pendingPdfName = null;
          notifyListeners();
          if (picked.length > remaining) {
            return 'Only $remaining image(s) added (daily limit)';
          }
        }
      } else {
        final picked = await imagePicker.pickImage(
          source: source,
          imageQuality: 85,
          maxWidth: 1024,
        );
        if (picked != null) {
          pendingImages = [File(picked.path)];
          pendingPdfText = null;
          pendingPdfName = null;
          notifyListeners();
        }
      }
    } catch (e) {
      return 'Image pick failed: $e';
    }
    return null;
  }

  Future<String?> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'doc'],
      );
      if (result == null || result.files.single.path == null) return null;

      final path = result.files.single.path!;
      final name = result.files.single.name;
      isLoading = true;
      notifyListeners();

      String content;
      if (name.endsWith('.txt')) {
        content = await File(path).readAsString();
      } else {
        content = base64Encode(await File(path).readAsBytes());
      }

      pendingPdfText = content;
      pendingPdfName = name;
      pendingImages = [];
      isLoading = false;
      notifyListeners();
      return '$name ready — type your question';
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return 'File pick failed: $e';
    }
  }

  void removePendingImage(int index) {
    pendingImages.removeAt(index);
    notifyListeners();
  }

  void clearPendingPdf() {
    pendingPdfText = null;
    pendingPdfName = null;
    notifyListeners();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    searchController.dispose();
    scrollController.dispose();
    tts.stop();
    super.dispose();
  }
}
