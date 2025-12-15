import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:nas_masr_app/core/data/providers/chat_provider.dart';
import 'package:nas_masr_app/core/data/reposetory/chat_repository.dart';

import 'package:nas_masr_app/core/data/providers/profile_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:nas_masr_app/screens/public/widgets/chat_audio_player.dart';

class ChatScreen extends StatefulWidget {
  final int? peerId;
  final bool support;
  final String? peerName;
  final String? initialMessage;
  final String? categorySlug;
  final int? listingId;

  final bool autoSend;

  const ChatScreen({
    super.key,
    this.peerId,
    this.support = false,
    this.peerName,
    this.initialMessage,
    this.categorySlug,
    this.listingId,
    this.autoSend = false,
  });

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
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (widget.support) {
                provider.initSupport(myId: 0);
              } else {
                final pid = widget.peerId ?? 0;
                provider.init(peerId: pid, myId: 0);
              }
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

              if (widget.categorySlug != null && widget.listingId != null) {
                if (widget.autoSend) {
                  // Wait for listing summary to load then send
                  await provider.fetchListingSummary(
                      widget.categorySlug!, widget.listingId!);
                  if (provider.listingSummary != null) {
                    await provider.send('',
                        contentType: 'listing_inquiry',
                        listingId: widget.listingId);
                  }
                } else {
                  provider.fetchListingSummary(
                      widget.categorySlug!, widget.listingId!);
                }
              }

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
                    child: provider.loading && provider.messages.isEmpty
                        ? _buildSkeletonLoader(cs)
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.w, vertical: 8.h),
                            itemCount: provider.messages.length,
                            controller: _listController,
                            itemBuilder: (context, index) {
                              final m = provider.messages[index];
                              final isMe = m.senderId == (provider.myId ?? -1);
                              final isOptimistic = (m.id ?? 1) < 0;

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
                                        ? (isOptimistic
                                            ? cs.primary.withOpacity(0.7)
                                            : cs.primary)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                        color: cs.primary.withOpacity(0.25)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (m.contentType == 'listing_inquiry' &&
                                          m.listing != null)
                                        _buildListingCard(m.listing!, cs),
                                      if (m.contentType == 'image')
                                        _buildImageMessage(m, cs),
                                      if (m.contentType == 'video')
                                        _buildVideoMessage(m, cs),
                                      if (m.contentType == 'audio')
                                        _buildAudioMessage(m, isMe, cs),
                                      if (m.message.isNotEmpty &&
                                          m.contentType !=
                                              'audio') // Hide text if audio, or show if caption
                                        Padding(
                                          padding: EdgeInsets.only(top: 4.h),
                                          child: Text(
                                            m.message,
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                color: isMe
                                                    ? Colors.white
                                                    : cs.onSurface),
                                          ),
                                        ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          if (isMe) ...[
                                            if (isOptimistic)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 4.w, top: 4.h),
                                                child: SizedBox(
                                                  width: 12.sp,
                                                  height: 12.sp,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.white),
                                                ),
                                              )
                                            else
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 4.w, top: 4.h),
                                                child: Icon(
                                                  m.readAt != null
                                                      ? Icons.done_all
                                                      : Icons.done,
                                                  size: 16.sp,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                          ],
                                          // Time
                                          Text(
                                            "${m.createdAt.hour}:${m.createdAt.minute.toString().padLeft(2, '0')}",
                                            style: TextStyle(
                                              fontSize: 10.sp,
                                              color: isMe
                                                  ? Colors.white70
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  if (provider.listingSummary != null)
                    _buildPreviewCard(provider, cs),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (provider.uploadProgress > 0 &&
                            provider.uploadProgress < 1)
                          LinearProgressIndicator(
                              value: provider.uploadProgress),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                textInputAction: TextInputAction.send,
                                minLines: 1,
                                maxLines: 4,
                                onSubmitted: (_) => _send(provider),
                                decoration: InputDecoration(
                                  hintText: 'اكتب رسالة...',
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 8.h),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.r),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300)),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.r),
                                      borderSide: BorderSide(
                                          color: Colors.grey.shade300)),
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            IconButton(
                              onPressed: provider.sending
                                  ? null
                                  : () => _send(provider),
                              icon: provider.sending
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : Icon(Icons.send, color: cs.primary),
                            ),
                          ],
                        ),
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
    String? contentType;
    int? listingId;
    if (provider.listingSummary != null) {
      contentType = 'listing_inquiry';
      final lidRaw = provider.listingSummary!['listing_id'] ??
          provider.listingSummary!['id'];
      if (lidRaw is int)
        listingId = lidRaw;
      else if (lidRaw != null) listingId = int.tryParse(lidRaw.toString());
    }
    final ok = await provider.send(text,
        contentType: contentType, listingId: listingId);
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

  Widget _buildSkeletonLoader(ColorScheme cs) {
    return ListView.builder(
      itemCount: 6,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      itemBuilder: (context, index) {
        final isMe = index % 2 == 0;
        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 4.h),
            width: 150.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        );
      },
    );
  }

  Widget _buildListingCard(Map<String, dynamic> data, ColorScheme cs) {
    // Handling data from listing summary or message listing object
    final title = data['title']?.toString() ?? '';
    final price =
        data['price_formatted']?.toString() ?? '${data['price'] ?? ''}';
    final image = data['main_image_url']?.toString() ?? data['image'];
    final categorySlug = data['category_slug']?.toString();
    final listingIdRaw = data['listing_id'] ?? data['id'];
    int? listingId;
    if (listingIdRaw is int)
      listingId = listingIdRaw;
    else if (listingIdRaw != null)
      listingId = int.tryParse(listingIdRaw.toString());

    return Container(
      width: 200.w,
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (image != null)
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
              child: Image.network(image,
                  height: 100.h,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox()),
            ),
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13.sp)),
                SizedBox(height: 4.h),
                Text(price,
                    style: TextStyle(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp)),
                SizedBox(height: 6.h),
                InkWell(
                  onTap: () {
                    if (categorySlug != null && listingId != null) {
                      context.push('/ad/details', extra: {
                        'categorySlug': categorySlug,
                        'adId': listingId.toString()
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r)),
                    child: Text('عرض الإعلان',
                        style: TextStyle(
                            color: cs.primary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPreviewCard(ChatProvider provider, ColorScheme cs) {
    final data = provider.listingSummary!;
    final title = data['title']?.toString() ?? '';
    final price = data['price_formatted']?.toString();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, -2))
          ]),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('استفسار بخصوص:',
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey)),
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13.sp)),
                if (price != null)
                  Text(price,
                      style: TextStyle(color: cs.primary, fontSize: 12.sp)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => provider.removeListingSummary(),
          )
        ],
      ),
    );
  }

  Widget _buildImageMessage(dynamic m, ColorScheme cs) {
    if (m.attachment == null) return const SizedBox();
    final isLocal = !m.attachment!.startsWith('http');

    return GestureDetector(
      onTap: () {
        // Standard light box or viewer
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 4.h),
        constraints: BoxConstraints(maxWidth: 200.w, maxHeight: 200.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: isLocal
              ? Image.file(File(m.attachment!), fit: BoxFit.cover)
              : CachedNetworkImage(
                  imageUrl: m.attachment!,
                  placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: Center(child: CircularProgressIndicator())),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

  Widget _buildVideoMessage(dynamic m, ColorScheme cs) {
    // Ideally show thumbnail. If local, can generate. If remote, need thumbnail URL or generic icon.
    return Container(
      width: 200.w,
      height: 120.h,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Icon(Icons.play_circle_fill, size: 40.sp, color: Colors.white),
      ),
    );
  }

  Widget _buildAudioMessage(dynamic m, bool isMe, ColorScheme cs) {
    if (m.attachment == null) return const SizedBox();
    return ChatAudioPlayer(url: m.attachment!, isMe: isMe);
  }
}
