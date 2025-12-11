import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nas_masr_app/widgets/custom_bottom_nav.dart';
import 'package:provider/provider.dart';
import 'package:nas_masr_app/core/data/providers/chat_inbox_provider.dart';
import 'package:nas_masr_app/core/data/reposetory/chat_repository.dart';

class ChatInboxScreen extends StatefulWidget {
  const ChatInboxScreen({super.key});
  @override
  State<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends State<ChatInboxScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  Timer? _pollTimer;
  late final ChatInboxProvider _prov =
      ChatInboxProvider(repository: ChatRepository());

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _tabController = TabController(length: 2, vsync: this);
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      _prov.load(silent: true);
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _tabController.dispose();
    _searchController.dispose();
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ChangeNotifierProvider(
      create: (_) => _prov,
      child: Consumer<ChatInboxProvider>(
        builder: (context, prov, _) {
          if (!prov.loading && prov.error == null && prov.items.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              prov.load(silent: true);
            });
          }
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              bottomNavigationBar: const CustomBottomNav(currentIndex: 3),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: cs.onSurface),
                  onPressed: () {
                    final r = GoRouter.of(context);
                    if (r.canPop()) {
                      r.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                ),
                title: Text('الرسائل', style: TextStyle(color: cs.onSurface)),
                bottom: TabBar(
                  controller: _tabController,
                  labelColor: cs.secondary,
                  unselectedLabelColor: cs.onSurface,
                  onTap: (index) {
                    final provInner = context.read<ChatInboxProvider>();
                    provInner.setTab(index == 0 ? 'peer' : 'admin');
                    if (index == 1) {
                      context.push('/chat', extra: {
                        'support': true,
                        'peerName': 'الدعم',
                      });
                    }
                  },
                  tabs: const [
                    Tab(text: 'العملاء'),
                    Tab(text: 'الإدارة'),
                  ],
                ),
              ),
              body: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12.w),
                    child: TextField(
                      controller: _searchController,
                      onChanged: prov.setQuery,
                      decoration: const InputDecoration(
                        hintText: 'ابحث...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _PeerList(prov: prov),
                        _AdminPlaceholder(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PeerList extends StatelessWidget {
  final ChatInboxProvider prov;
  const _PeerList({required this.prov});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (prov.error != null) {
      return Center(child: Text(prov.error!));
    }
    if (prov.displayedItems.isEmpty) {
      return Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: cs.primary.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            'لا توجد رسائل حتى الآن',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              color: cs.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      itemCount: prov.displayedItems.length,
      itemBuilder: (context, index) {
        final item = prov.displayedItems[index];
        final idText = item.otherPartyId.toString();
        final last = item.lastMessage ?? '';
        final unread = item.unreadCount;
        return InkWell(
          onTap: () async {
            await context.push('/chat', extra: {
              'peerId': item.otherPartyId,
              'peerName': 'العميل #${item.otherPartyId}',
            });
            await prov.load();
          },
          child: Container(
            margin: EdgeInsets.symmetric(vertical: 6.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: cs.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(Icons.person, color: cs.onSurface),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("العميل ${idText}",
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4.h),
                      Text(last,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              TextStyle(color: cs.onSurface.withOpacity(0.8))),
                    ],
                  ),
                ),
                if (unread > 0)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: cs.secondary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(unread.toString(),
                        style: const TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AdminPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          context.push('/chat', extra: {
            'support': true,
            'peerName': 'الدعم',
          });
        },
        icon: const Icon(Icons.support_agent),
        label: const Text('بدء محادثة مع الإدارة'),
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        ),
      ),
    );
  }
}
