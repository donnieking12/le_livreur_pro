import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Optimized image widget for better performance
class OptimizedImage extends StatelessWidget {
  final String? imageUrl;
  final String? assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool enableMemoryCache;
  final bool enableDiskCache;
  final Duration? cacheTime;

  const OptimizedImage({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
    this.cacheTime,
  }) : assert(imageUrl != null || assetPath != null, 'Either imageUrl or assetPath must be provided');

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (assetPath != null) {
      // Asset image
      image = Image.asset(
        assetPath!,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: _getCacheWidth(),
        cacheHeight: _getCacheHeight(),
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      );
    } else {
      // Network image with caching
      image = CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        memCacheWidth: _getCacheWidth(),
        memCacheHeight: _getCacheHeight(),
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
        useOldImageOnUrlChange: true,
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 100),
        // Performance optimizations
        filterQuality: FilterQuality.low,
        maxWidthDiskCache: (width ?? 800).round(),
        maxHeightDiskCache: (height ?? 600).round(),
      );
    }

    // Apply border radius if specified
    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  /// Calculate cache width for memory optimization
  int? _getCacheWidth() {
    if (!enableMemoryCache || width == null) return null;
    
    // Scale down for memory efficiency
    final devicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
    return (width! * devicePixelRatio * 0.8).round();
  }

  /// Calculate cache height for memory optimization
  int? _getCacheHeight() {
    if (!enableMemoryCache || height == null) return null;
    
    // Scale down for memory efficiency
    final devicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
    return (height! * devicePixelRatio * 0.8).round();
  }

  /// Build placeholder widget
  Widget _buildPlaceholder() {
    if (placeholder != null) return placeholder!;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      ),
    );
  }

  /// Build error widget
  Widget _buildErrorWidget() {
    if (errorWidget != null) return errorWidget!;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: borderRadius,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image,
            color: Colors.grey.shade400,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            'Image non disponible',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Optimized avatar widget for user profiles
class OptimizedAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double radius;
  final Color? backgroundColor;
  final Color? textColor;

  const OptimizedAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.radius = 20,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? Colors.grey.shade200,
        child: OptimizedImage(
          imageUrl: imageUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(radius),
          enableMemoryCache: true,
          enableDiskCache: true,
        ),
      );
    }

    // Fallback to initials
    final initials = _getInitials(name);
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? _getColorFromName(name),
      child: Text(
        initials,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: radius * 0.6,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Extract initials from name
  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';
    
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }
    
    return '${words[0].substring(0, 1)}${words[1].substring(0, 1)}'.toUpperCase();
  }

  /// Generate color from name for consistent avatar colors
  Color _getColorFromName(String? name) {
    if (name == null || name.isEmpty) return Colors.grey;
    
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
    ];
    
    final hash = name.hashCode;
    return colors[hash.abs() % colors.length];
  }
}

/// Optimized list item image for better scrolling performance
class OptimizedListImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final BorderRadius? borderRadius;

  const OptimizedListImage({
    super.key,
    this.imageUrl,
    this.size = 56,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return OptimizedImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      fit: BoxFit.cover,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      enableMemoryCache: true,
      enableDiskCache: true,
      placeholder: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.image,
          color: Colors.grey.shade400,
          size: size * 0.4,
        ),
      ),
      errorWidget: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.broken_image,
          color: Colors.grey.shade400,
          size: size * 0.4,
        ),
      ),
    );
  }
}