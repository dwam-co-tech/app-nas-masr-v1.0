import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nas_masr_app/core/data/reposetory/notifications_repository.dart';

class NotificationsBadgeIcon extends StatefulWidget {
  final bool isLand;
  const NotificationsBadgeIcon({super.key, required this.isLand});
  @override
  State<NotificationsBadgeIcon> createState() => _NotificationsBadgeIconState();
}

class _NotificationsBadgeIconState extends State<NotificationsBadgeIcon> {
  final NotificationsRepository _repo = NotificationsRepository();
  int _count = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _load();
    });
  }

  Future<void> _load() async {
    try {
      final c = await _repo.getStatusUnreadCount();
      if (mounted) setState(() => _count = c);
    } catch (_) {
      if (mounted) setState(() => _count = 0);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(Icons.notifications_rounded,
            color: cs.onSurface, size: widget.isLand ? 15.sp : 30.sp),
        if (_count > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: cs.secondary,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                _count.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
      ],
    );
  }
}
