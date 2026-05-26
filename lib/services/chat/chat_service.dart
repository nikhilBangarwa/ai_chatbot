import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/chat_message.dart';
import '../../models/chat_session.dart';

class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _chatsRef {
    final uid = _uid;
    if (uid == null) {
      throw StateError('User not logged in');
    }
    return _db.collection('users').doc(uid).collection('chats');
  }

  Future<String> createSession(String firstMessage) async {
    final docRef = _chatsRef.doc();
    final now = DateTime.now();
    final session = ChatSession(
      id: docRef.id,
      title: firstMessage,
      messages: [],
      createdAt: now,
      updatedAt: now,
    );
    await docRef.set(session.toMap());
    return docRef.id;
  }

  Future<void> addMessage(String sessionId, ChatMessage message) async {
    final docRef = _chatsRef.doc(sessionId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final data = doc.data()!;
    final messages = (data['messages'] as List<dynamic>? ?? [])
        .map((m) => ChatMessage.fromMap(m as Map<String, dynamic>))
        .toList();
    messages.add(message);

    await docRef.update({
      'messages': messages.map((m) => m.toMap()).toList(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<ChatSession>> getAllSessions() async {
    if (_uid == null) return [];
    final snapshot = await _chatsRef
        .orderBy('updatedAt', descending: true)
        .limit(50)
        .get();

    return snapshot.docs
        .map((d) => ChatSession.fromMap({...d.data(), 'id': d.id}))
        .toList();
  }

  Future<ChatSession?> getSession(String sessionId) async {
    final doc = await _chatsRef.doc(sessionId).get();
    if (!doc.exists) return null;
    return ChatSession.fromMap({...doc.data()!, 'id': doc.id});
  }

  Future<void> deleteSession(String sessionId) async {
    await _chatsRef.doc(sessionId).delete();
  }

  Stream<List<ChatSession>> sessionsStream() {
    if (_uid == null) return const Stream.empty();
    return _chatsRef
        .orderBy('updatedAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ChatSession.fromMap({...d.data(), 'id': d.id}))
              .toList(),
        );
  }
}
