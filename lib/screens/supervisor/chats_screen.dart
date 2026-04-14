import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../models/models.dart';
import '../../providers/supervisor_helpers.dart';

class ChatsScreen extends StatefulWidget {
  final int supervisorId;
  final String supervisorName;

  const ChatsScreen({
    super.key,
    required this.supervisorId,
    required this.supervisorName,
  });

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _chats = [];
  int? _selectedChatId;
  String? _selectedGroupName;
  List<Map<String, dynamic>> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('chats')
          .select('*, groups(group_name)')
          .eq('id_sprvsr', widget.supervisorId)
          .order('last_message_time', ascending: false);

      setState(() {
        _chats = List<Map<String, dynamic>>.from(response);
        if (_chats.isNotEmpty && _selectedChatId == null) {
          _selectChat(_chats[0]['chat_id'], _chats[0]['groups']['group_name']);
        }
      });
    } catch (e) {
      debugPrint('Error loading chats: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectChat(int chatId, String groupName) async {
    setState(() {
      _selectedChatId = chatId;
      _selectedGroupName = groupName;
      _messages = [];
    });
    _loadMessages(chatId);
  }

  Future<void> _loadMessages(int chatId) async {
    try {
      final response = await Supabase.instance.client
          .from('messages')
          .select()
          .eq('id_chat', chatId)
          .order('created_at', ascending: true);

      setState(() {
        _messages = List<Map<String, dynamic>>.from(response);
      });
      _scrollToBottom();
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _selectedChatId == null) return;

    final text = _messageController.text.trim();
    _messageController.clear();

    try {
      await Supabase.instance.client.from('messages').insert({
        'id_chat': _selectedChatId,
        'sender_id': widget.supervisorId,
        'sender_role': 'supervisor',
        'message_text': text,
      });

      await Supabase.instance.client.from('chats').update({
        'last_message': text,
        'last_message_time': DateTime.now().toIso8601String(),
      }).eq('chat_id', _selectedChatId!);

      _loadMessages(_selectedChatId!);
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'نظام إدارة ومتابعة أبحاث التخرج',
          style: TextStyle(color: Color(0xFF2D62ED), fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D62ED)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.grey),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFE0E0E0),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          if (!isMobile) _buildChatList(width: 300),
          Expanded(
            child: _selectedChatId == null
                ? const Center(child: Text('اختر محادثة للبدء'))
                : _buildChatWindow(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList({double? width}) {
    return Container(
      width: width,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'بحث عن مجموعة...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _chats.length,
                    itemBuilder: (context, index) {
                      final chat = _chats[index];
                      final isSelected = _selectedChatId == chat['chat_id'];
                      return ListTile(
                        onTap: () => _selectChat(chat['chat_id'], chat['groups']['group_name']),
                        selected: isSelected,
                        selectedTileColor: const Color(0xFFF0F4FF),
                        leading: CircleAvatar(
                          backgroundColor: isSelected ? const Color(0xFF2D62ED) : const Color(0xFFE2E8F0),
                          child: Text(
                            chat['groups']['group_name'][0],
                            style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF64748B)),
                          ),
                        ),
                        title: Text(
                          chat['groups']['group_name'],
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        subtitle: Text(
                          chat['last_message'] ?? 'لا توجد رسائل',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Text(
                          SupervisorHelpers.getTimeDifference(
                            DateTime.tryParse(chat['last_message_time'] ?? ''),
                          ),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatWindow() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _selectedGroupName ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Text('متصل الآن', style: TextStyle(color: Colors.green, fontSize: 12)),
                ],
              ),
              const SizedBox(width: 12),
              const CircleAvatar(
                backgroundColor: Color(0xFFF0F4FF),
                child: Icon(Icons.group, color: Color(0xFF2D62ED)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              final isMe = msg['sender_role'] == 'supervisor';
              return _buildMessageBubble(msg['message_text'], isMe, msg['created_at']);
            },
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildMessageBubble(String text, bool isMe, String time) {
    final date = DateTime.tryParse(time);
    final timeStr = date != null ? '${date.hour}:${date.minute.toString().padLeft(2, '0')}' : '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF2D62ED) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(color: isMe ? Colors.white : const Color(0xFF1E293B), fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              timeStr,
              style: TextStyle(color: isMe ? Colors.white70 : Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.grey),
            onPressed: () {},
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك هنا...',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundColor: const Color(0xFF2D62ED),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
