import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';

class ChatAudioPlayer extends StatefulWidget {
  final String url;
  final bool isMe;

  const ChatAudioPlayer({super.key, required this.url, required this.isMe});

  @override
  State<ChatAudioPlayer> createState() => _ChatAudioPlayerState();
}

class _ChatAudioPlayerState extends State<ChatAudioPlayer> {
  late AudioPlayer _player;
  bool _playing = false;
  bool _loading = false;
  Duration? _duration;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    try {
      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _playing = state.playing;
            if (state.processingState == ProcessingState.completed) {
              _playing = false;
              _player.seek(Duration.zero);
              _player.pause();
            }
          });
        }
      });

      _player.positionStream.listen((p) {
        if (mounted) setState(() => _position = p);
      });

      _player.durationStream.listen((d) {
        if (mounted) setState(() => _duration = d);
      });

      // Preload? dynamic loading on play is better for list
      // await _player.setUrl(widget.url);
    } catch (_) {}
  }

  Future<void> _toggle() async {
    try {
      if (_playing) {
        await _player.pause();
      } else {
        if (_player.processingState == ProcessingState.idle) {
          setState(() => _loading = true);
          if (widget.url.startsWith('http')) {
            await _player.setUrl(widget.url);
          } else {
            await _player.setFilePath(widget.url);
          }
          setState(() => _loading = false);
        }
        await _player.play();
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = widget.isMe ? Colors.white : cs.onSurface;

    return Container(
      width: 200.w,
      padding: EdgeInsets.all(8.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isMe
                    ? Colors.white.withOpacity(0.3)
                    : cs.primary.withOpacity(0.1),
              ),
              child: _loading
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                          color: color, strokeWidth: 2))
                  : Icon(_playing ? Icons.pause : Icons.play_arrow,
                      color: color),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(
                  value: (_duration == null || _duration!.inMilliseconds == 0)
                      ? 0
                      : _position.inMilliseconds / _duration!.inMilliseconds,
                  backgroundColor: color.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatDuration(_position),
                  style: TextStyle(fontSize: 10.sp, color: color),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
