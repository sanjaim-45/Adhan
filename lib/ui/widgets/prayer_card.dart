import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PrayerCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String arabic;
  final String time;
  final String status; // Completed, Live, Upcoming
  final Color statusColor;
  final IconData? trailingIcon;

  const PrayerCard({
    required this.imagePath,
    required this.title,
    required this.arabic,
    required this.time,
    required this.status,
    required this.statusColor,
    this.trailingIcon,
    super.key,
  });

  @override
  State<PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard> {
  bool isExpanded = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  WebSocketChannel? _channel;
  StreamSubscription? _webSocketSubscription;
  StreamSubscription? _audioPlayerSubscription;
  bool _isPlaying = false;
  String _connectionStatus = 'Disconnected';
  final List<int> _audioBuffer = [];
  late AudioHandler _audioHandler;
  bool _isInitialized = false;
  @override
  void initState() {
    super.initState();
    _initAudioSession();
  }

  @override
  void dispose() {
    _webSocketSubscription?.cancel();
    _audioPlayerSubscription?.cancel();
    _audioPlayer.dispose();
    _channel?.sink.close();
    super.dispose();
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  Future<void> _connectWebSocket() async {
    try {
      // Close existing connection if any
      await _disconnect();

      setState(() {
        _connectionStatus = 'Connecting...';
      });

      _channel = WebSocketChannel.connect(
        Uri.parse(
          'wss://rajwebsocketserver2025.azurewebsites.net/subscriber/sub2',
        ),
      );

      _webSocketSubscription = _channel!.stream.listen(
        (dynamic message) {
          if (message is List<int>) {
            final data = Uint8List.fromList(message);
            _processAudioData(data);
          }
        },
        onError: (error) {
          print('WebSocket error: $error');
          _handleDisconnection(error.toString());
        },
        onDone: () {
          print('WebSocket closed');
          _handleDisconnection('Connection closed');
        },
      );

      setState(() {
        _connectionStatus = 'Connected';
      });
    } catch (e) {
      print('Connection failed: $e');
      _handleDisconnection(e.toString());
    }
  }

  void _handleDisconnection(String error) {
    if (!mounted) return;

    setState(() {
      _connectionStatus = 'Disconnected: $error';
      _isPlaying = false;
    });
    _audioPlayer.pause();
    _reconnect();
  }

  void _processAudioData(Uint8List data) async {
    if (!_isPlaying) return;

    _audioBuffer.addAll(data);

    if (_audioBuffer.length > 8192) {
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/stream_${DateTime.now().millisecondsSinceEpoch}.mp3',
      );
      await file.writeAsBytes(Uint8List.fromList(_audioBuffer));

      await _audioPlayer.stop();
      await _audioPlayer.setFilePath(file.path);
      await _audioPlayer.play();

      _audioBuffer.clear();
    }
  }

  Future<void> _disconnect() async {
    await _webSocketSubscription?.cancel();
    await _audioPlayer.stop();
    _channel?.sink.close();
    setState(() {
      _isPlaying = false;
      _connectionStatus = 'Disconnected';
    });
  }

  void _reconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      if (_isPlaying && _connectionStatus != 'Connected') {
        _connectWebSocket();
      }
    });
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _disconnect();
    } else {
      await _connectWebSocket();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(widget.imagePath, width: 35, height: 35),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.title} ${widget.arabic}',
                      style: GoogleFonts.beVietnamPro(
                        fontWeight: FontWeight.bold,
                        fontSize: screenWidth * 0.035,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          widget.time,
                          style: GoogleFonts.beVietnamPro(
                            color: Colors.grey[700],
                            fontSize: MediaQuery.of(context).size.width * 0.03,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: widget.statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              if (widget.status == "Live") ...[
                                const Icon(
                                  Icons.podcasts,
                                  size: 14,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 4),
                              ] else if (widget.status == "Completed") ...[
                                const Icon(
                                  Icons.check_circle,
                                  size: 14,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 4),
                              ] else ...[
                                const Icon(
                                  Icons.access_time_filled,
                                  size: 14,
                                  color: Colors.brown,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                widget.status,
                                style: GoogleFonts.beVietnamPro(
                                  color: widget.statusColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (widget.trailingIcon != null)
                Icon(widget.trailingIcon, color: Colors.green, size: 26),

              if (widget.status == "Live")
                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                ),
            ],
          ),
          if ((widget.status == "Live") && isExpanded) _buildAudioPlayerUI(),
        ],
      ),
    );
  }

  Widget _buildAudioPlayerUI() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFFF2F9F2),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: IconButton(
                    icon: Icon(
                      _isPlaying
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline_sharp,
                      color: const Color(0xFF2E7D32),
                      size: 40,
                    ),
                    onPressed: _togglePlayback,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 2.5,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6.0,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 12.0,
                          ),
                        ),
                        child: Slider(
                          value: _isPlaying ? 100.0 : 0.0,
                          min: 0.0,
                          max: 100.0,
                          activeColor: const Color(0xFF2E7D32),
                          inactiveColor: Colors.green[200],
                          onChanged: (value) {},
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "00:00",
                            style: GoogleFonts.beVietnamPro(
                              color: Colors.black87,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            "Live Stream",
                            style: GoogleFonts.beVietnamPro(
                              color: Colors.black87,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "30.00",
                            style: GoogleFonts.beVietnamPro(
                              color: Colors.black87,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _connectionStatus,
            style: GoogleFonts.beVietnamPro(
              color:
                  _connectionStatus.contains('Connected')
                      ? Colors.green
                      : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class AudioPlayerHandler extends BaseAudioHandler {
  final _player = AudioPlayer();
  final _playlist = ConcatenatingAudioSource(children: []);

  AudioPlayerHandler() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    _player.setAudioSource(_playlist);
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  Future<void> setAudioFile(String path) async {
    await _player.stop();
    await _player.setFilePath(path);
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [MediaControl.play, MediaControl.pause, MediaControl.stop],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState:
          const {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}
