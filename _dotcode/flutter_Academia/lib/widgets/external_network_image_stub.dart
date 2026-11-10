import 'package:flutter/material.dart';

class ExternalNetworkImage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        url,
        width: double.infinity,
        height: double.infinity,
        fit: fit,
        errorBuilder: errorBuilder == null
            ? null
            : (_, _, _) => errorBuilder!(context),
      ),
    );
  }
}
