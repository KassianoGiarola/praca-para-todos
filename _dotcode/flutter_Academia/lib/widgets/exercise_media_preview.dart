import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'external_network_image.dart';

class ExerciseMediaPreview extends StatefulWidget {
  const ExerciseMediaPreview({
    super.key,
    this.videoUrl,
    this.thumbnailUrl,
    this.height,
  });

  final String? videoUrl;
  final String? thumbnailUrl;
  final double? height;

  @override
  State<ExerciseMediaPreview> createState() => _ExerciseMediaPreviewState();
}

class _ExerciseMediaPreviewState extends State<ExerciseMediaPreview> {
  VideoPlayerController? _controller;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _setupVideo();
  }

  @override
  void didUpdateWidget(covariant ExerciseMediaPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _controller?.dispose();
      _controller = null;
      _failed = false;
      _setupVideo();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _setupVideo() async {
    final url = widget.videoUrl?.trim();
    if (url == null || url.isEmpty) {
      return;
    }
    if (_isGifUrl(url)) {
      return;
    }

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      _controller = controller;
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      if (mounted) {
        setState(() {});
      }
    } on Object {
      if (mounted) {
        setState(() => _failed = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = _controller;
    final height = widget.height ?? 190;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          child: controller != null && controller.value.isInitialized
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                )
              : _fallback(theme),
        ),
      ),
    );
  }

  Widget _fallback(ThemeData theme) {
    final media = widget.videoUrl?.trim();
    if (media != null && media.isNotEmpty && _isGifUrl(media)) {
      return _networkImage(media, theme, fit: BoxFit.contain);
    }

    final thumbnail = widget.thumbnailUrl?.trim();
    if (thumbnail != null && thumbnail.isNotEmpty) {
      return _networkImage(thumbnail, theme, fit: BoxFit.cover);
    }

    if (widget.videoUrl != null && !_failed) {
      return const Center(child: CircularProgressIndicator());
    }

    return _placeholder(theme);
  }

  Widget _networkImage(String url, ThemeData theme, {required BoxFit fit}) {
    return ExternalNetworkImage(
      url: url,
      fit: fit,
      borderRadius: 8,
      errorBuilder: (_) => _placeholder(theme),
    );
  }

  bool _isGifUrl(String url) {
    final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
    return path.endsWith('.gif');
  }

  Widget _placeholder(ThemeData theme) {
    return Center(
      child: Icon(
        Icons.play_circle_outline,
        size: 54,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
      ),
    );
  }
}
