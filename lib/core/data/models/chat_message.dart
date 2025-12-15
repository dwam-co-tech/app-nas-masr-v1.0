class ChatMessage {
  final int? id;
  final int senderId;
  final int receiverId;
  final String message;
  final DateTime createdAt;
  final DateTime? readAt;
  final String? conversationId;
  final String? contentType;
  final Map<String, dynamic>? listing;
  final String? attachment;

  const ChatMessage({
    this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.createdAt,
    this.readAt,
    this.conversationId,
    this.contentType,
    this.listing,
    this.attachment,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    int? _toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      return int.tryParse(v.toString());
    }

    final id = _toInt(map['id']);
    final senderId = _toInt(map['sender_id']) ?? 0;
    final receiverId = _toInt(map['receiver_id']) ?? 0;
    final message = map['message']?.toString() ?? '';
    final createdAtStr = map['created_at']?.toString();
    final createdAt = createdAtStr != null
        ? (DateTime.tryParse(createdAtStr) ?? DateTime.now())
        : DateTime.now();
    final readAtStr = map['read_at']?.toString();
    final readAt = readAtStr != null ? DateTime.tryParse(readAtStr) : null;
    final conversationId = map['conversation_id']?.toString();

    final contentType = map['content_type']?.toString();
    final listing = map['listing'] is Map<String, dynamic>
        ? map['listing'] as Map<String, dynamic>
        : null;

    return ChatMessage(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      createdAt: createdAt,
      readAt: readAt,
      conversationId: conversationId,
      contentType: contentType,
      listing: listing,
    );
  }

  factory ChatMessage.fromApiChat(Map<String, dynamic> map) {
    int _toInt(dynamic v) =>
        v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    final idRaw = map['id'];
    final id = idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? '');
    final sender = map['sender'] is Map<String, dynamic>
        ? map['sender'] as Map<String, dynamic>
        : <String, dynamic>{};
    final receiver = map['receiver'] is Map<String, dynamic>
        ? map['receiver'] as Map<String, dynamic>
        : <String, dynamic>{};
    final senderId = _toInt(sender['id']);
    final receiverId = _toInt(receiver['id']);
    final message = map['message']?.toString() ?? '';
    final createdAtStr = map['created_at']?.toString();
    final createdAt = createdAtStr != null
        ? (DateTime.tryParse(createdAtStr) ?? DateTime.now())
        : DateTime.now();
    final readAtStr = map['read_at']?.toString();
    final readAt = readAtStr != null ? DateTime.tryParse(readAtStr) : null;
    final conversationId = map['conversation_id']?.toString();

    final contentType = map['content_type']?.toString();
    final listing = map['listing'] is Map<String, dynamic>
        ? map['listing'] as Map<String, dynamic>
        : null;

    return ChatMessage(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      message: message,
      createdAt: createdAt,
      readAt: readAt,
      conversationId: conversationId,
      contentType: contentType,
      listing: listing,
    );
  }

  factory ChatMessage.fromApiSupport(Map<String, dynamic> map) {
    int _toInt(dynamic v) =>
        v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    final idRaw = map['id'];
    final id = idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? '');
    final sender = map['sender'] is Map<String, dynamic>
        ? map['sender'] as Map<String, dynamic>
        : <String, dynamic>{};
    final senderId = _toInt(sender['id']);
    final message = map['message']?.toString() ?? '';
    final createdAtStr = map['created_at']?.toString();
    final createdAt = createdAtStr != null
        ? (DateTime.tryParse(createdAtStr) ?? DateTime.now())
        : DateTime.now();
    final readAtStr = map['read_at']?.toString();
    final readAt = readAtStr != null ? DateTime.tryParse(readAtStr) : null;
    final conversationId = map['conversation_id']?.toString();

    final contentType = map['content_type']?.toString();
    final listing = map['listing'] is Map<String, dynamic>
        ? map['listing'] as Map<String, dynamic>
        : null;
    final attachment = map['attachment']?.toString();

    return ChatMessage(
      id: id,
      senderId: senderId,
      receiverId: 0,
      message: message,
      createdAt: createdAt,
      readAt: readAt,
      conversationId: conversationId,
      contentType: contentType,
      listing: listing,
      attachment: attachment,
    );
  }
}
