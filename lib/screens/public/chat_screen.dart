import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:nas_masr_app/core/data/providers/chat_provider.dart';
import 'package:nas_masr_app/core/data/reposetory/chat_repository.dart';
import 'package:nas_masr_app/core/data/providers/profile_provider.dart';

class ChatScreen extends StatefulWidget {
  final int? peerId;
  final bool support;
  final String? peerName;
  final String? initialMessage;
  const ChatScreen(
      {super.key,
      this.peerId,
      this.support = false,
      this.peerName,
      this.initialMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _initialized = false;
  final ScrollController _listController = ScrollController();
  Timer? _streamTimer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _controller.dispose();
    _listController.dispose();
    _streamTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(repository: ChatRepository()),
      child: Consumer<ChatProvider>(
        builder: (context, provider, _) {
          if (!_initialized) {
            if (widget.support) {
              provider.initSupport(myId: 0);
            } else {
              final pid = widget.peerId ?? 0;
              provider.init(peerId: pid, myId: 0);
            }
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              int myId = 0;
              try {
                final profileProv = context.read<ProfileProvider>();
                if (profileProv.profile == null) {
                  try {
                    await profileProv.loadProfile();
                  } catch (_) {}
                }
                final myIdStr = profileProv.profile?.id ?? '0';
                myId = int.tryParse(myIdStr) ?? 0;
              } catch (_) {}
              provider.setMyId(myId);
              await provider.load(reset: true);
              _scrollToEnd();
              _streamTimer =
                  Timer.periodic(const Duration(seconds: 1), (t) async {
                if (!mounted) return;
                await provider.load(reset: true, silent: true);
                await provider.refreshReadMarks();
                _scrollToEnd();
              });
            });
            _initialized = true;
          }
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: cs.onSurface),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  widget.peerName ?? (widget.support ? 'الدعم' : 'محادثة'),
                  style: TextStyle(color: cs.onSurface),
                ),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      itemCount: provider.messages.length,
                      controller: _listController,
                      itemBuilder: (context, index) {
                        final m = provider.messages[index];
                        final isMe = m.senderId == (provider.myId ?? -1);
                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 4.h),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? cs.primary.withOpacity(0.12)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                  color: cs.primary.withOpacity(0.25)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                 if (isMe) ...[
                                 
                                  Icon(
                                    m.readAt != null
                                        ? Icons.done_all
                                        : Icons.done,
                                    size: 18.sp,
                                    color: m.readAt != null
                                        ? cs.primary
                                        : cs.onSurface.withOpacity(0.45),
                                  ),
                                ],
                                SizedBox(width: 6.w),
                                Flexible(
                                  child: Text(
                                    m.message,
                                    style: TextStyle(
                                        fontSize: 14.sp, color: cs.onSurface),
                                  ),
                                ),
                               
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(provider),
                            decoration: const InputDecoration(
                                hintText: 'اكتب رسالة...',
                                border: OutlineInputBorder()),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        ElevatedButton(
                          onPressed:
                              provider.sending ? null : () => _send(provider),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: cs.primary,
                              foregroundColor: Colors.white,
                              fixedSize: Size(90.w, 44.h)),
                          child: provider.sending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Text('إرسال'),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 38.w),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _send(ChatProvider provider) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    int myId = 0;
    try {
      final profileProv = context.read<ProfileProvider>();
      if (profileProv.profile == null) {
        try {
          await profileProv.loadProfile();
        } catch (_) {}
      }
      final myIdStr = profileProv.profile?.id ?? '0';
      myId = int.tryParse(myIdStr) ?? 0;
    } catch (_) {}
    if ((provider.myId ?? 0) <= 0) {
      provider.setMyId(myId);
    }
    final ok = await provider.send(text);
    if (ok) {
      _controller.clear();
      _scrollToEnd();
    } else {
      final msg = provider.error ?? 'فشل إرسال الرسالة';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_listController.hasClients) return;
      final max = _listController.position.maxScrollExtent;
      _listController.jumpTo(max);
    });
  }
}
