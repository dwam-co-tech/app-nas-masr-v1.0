class ChatInboxItem {
  final String conversationId;
  final String? type;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final bool isRead;
  final int otherPartyId;
  final String? otherPartyName;
  final int unreadCount;
  final Map<String, dynamic> raw;

  const ChatInboxItem({
    required this.conversationId,
    this.type,
    this.lastMessage,
    this.lastMessageAt,
    required this.isRead,
    required this.otherPartyId,
    this.otherPartyName,
    required this.unreadCount,
    required this.raw,
  });

  factory ChatInboxItem.fromMap(Map<String, dynamic> map) {
    String _toStr(dynamic v) => v?.toString() ?? '';
    int _toInt(dynamic v) => v is int ? v : int.tryParse(_toStr(v)) ?? 0;
    bool _toBool(dynamic v) {
      if (v is bool) return v;
      final s = _toStr(v).toLowerCase();
      return s == 'true' || s == '1';
    }

    final conversationId = _toStr(map['conversation_id']);
    final type = map['type']?.toString();
    final lastMessage = map['last_message']?.toString();
    final lastMessageAtStr = map['last_message_at']?.toString();
    final lastMessageAt =
        lastMessageAtStr != null ? DateTime.tryParse(lastMessageAtStr) : null;
    final isRead = _toBool(map['is_read']);
    final other = map['other_party'] is Map<String, dynamic>
        ? map['other_party'] as Map<String, dynamic>
        : <String, dynamic>{};
    final otherPartyId = _toInt(other['id']);
    final otherPartyName = other['name']?.toString();
    final unreadCount = _toInt(map['unread_count']);
    return ChatInboxItem(
      conversationId: conversationId,
      type: type,
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt,
      isRead: isRead,
      otherPartyId: otherPartyId,
      otherPartyName: otherPartyName,
      unreadCount: unreadCount,
      raw: Map<String, dynamic>.from(map),
    );
  }
}
