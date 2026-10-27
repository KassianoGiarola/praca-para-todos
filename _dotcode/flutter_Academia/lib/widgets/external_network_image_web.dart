import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

class ExternalNetworkImage extends StatefulWidget {
  const ExternalNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.borderRadius = 8,
    this.errorBuilder,
  });

  final String url;
  final BoxFit fit;
  final double borderRadius;
  final WidgetBuilder? errorBuilder;

  @override
  State<ExternalNetworkImage> createState() => _ExternalNetworkImageState();
}

class _ExternalNetworkImageState extends State<ExternalNetworkImage> {
  static int _nextViewId = 0;

  late String _viewType;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _registerView();
  }

  @override
  void didUpdateWidget(covariant ExternalNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        oldWidget.fit != widget.fit ||
        oldWidget.borderRadius != widget.borderRadius) {
      _failed = false;
      _registerView();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed && widget.errorBuilder != null) {
      return widget.errorBuilder!(context);
    }

    return SizedBox.expand(child: HtmlElementView(viewType: _viewType));
  }

  void _registerView() {
    final url = widget.url;
    final objectFit = _objectFit(widget.fit);
    final radius = '${widget.borderRadius}px';
    final viewType = 'external-network-image-${_nextViewId++}';
    _viewType = viewType;

    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final wrapper = web.document.createElement('div') as web.HTMLDivElement;
      wrapper.style
        ..setProperty('width', '100%')
        ..setProperty('height', '100%')
        ..setProperty('overflow', 'hidden')
        ..setProperty('border-radius', radius)
        ..setProperty('display', 'flex')
        ..setProperty('align-items', 'center')
        ..setProperty('justify-content', 'center')
        ..setProperty('background', 'transparent');

      final image = web.document.createElement('img') as web.HTMLImageElement;
      image.src = url;
      image.decoding = 'async';
      image.style
        ..setProperty('width', '100%')
        ..setProperty('height', '100%')
        ..setProperty('max-width', '100%')
        ..setProperty('max-height', '100%')
        ..setProperty('display', 'block')
        ..setProperty('object-fit', objectFit)
        ..setProperty('border-radius', radius);

      image.addEventListener(
        'error',
        ((web.Event _) {
          if (mounted) {
            setState(() => _failed = true);
          }
        }).toJS,
      );

      wrapper.appendChild(image);
      return wrapper;
    });
  }

  String _objectFit(BoxFit fit) {
    return switch (fit) {
      BoxFit.fill => 'fill',
      BoxFit.contain => 'contain',
      BoxFit.cover => 'cover',
      BoxFit.fitWidth => 'contain',
      BoxFit.fitHeight => 'contain',
      BoxFit.none => 'none',
      BoxFit.scaleDown => 'scale-down',
    };
  }
}
