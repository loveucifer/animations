import 'package:flutter/material.dart';

OverlayEntry? currentNotificationEntry;

class ExpandableNotification extends StatefulWidget {
  final String title;
  final String preview;
  final String content;
  final VoidCallback? onExpand;
  final VoidCallback? onCollapse;
  final VoidCallback? onDismiss;
  final Color backgroundColor;
  final Color textColor;
  final Duration animationDuration;
  final bool autoExpand;
  final bool enableSwipeToDismiss;
  final bool showIndicator;
  final Color? indicatorColor;
  final double? indicatorWidth;
  final double? indicatorHeight;
  final double borderRadius;
  final EdgeInsets padding;
  final double? titleFontSize;
  final double? contentFontSize;
  final FontWeight? titleFontWeight;

  const ExpandableNotification({
    Key? key,
    required this.title,
    required this.preview,
    required this.content,
    this.onExpand,
    this.onCollapse,
    this.onDismiss,
    this.backgroundColor = const Color(0xFF424242),
    this.textColor = Colors.white,
    this.animationDuration = const Duration(milliseconds: 300),
    this.autoExpand = false,
    this.enableSwipeToDismiss = true,
    this.showIndicator = true,
    this.indicatorColor,
    this.indicatorWidth = 40,
    this.indicatorHeight = 3,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(20),
    this.titleFontSize = 16,
    this.contentFontSize = 14,
    this.titleFontWeight = FontWeight.bold,
  }) : super(key: key);

  @override
  State<ExpandableNotification> createState() => _ExpandableNotificationState();

  static void show({
    required BuildContext context,
    required String title,
    required String preview,
    required String content,
    VoidCallback? onExpand,
    VoidCallback? onCollapse,
    VoidCallback? onDismiss,
    Color backgroundColor = const Color(0xFF424242),
    Color textColor = Colors.white,
    Duration animationDuration = const Duration(milliseconds: 300),
    bool autoExpand = false,
    Duration? autoDismiss,
    bool enableSwipeToDismiss = true,
    bool showIndicator = true,
    Color? indicatorColor,
    double indicatorWidth = 40,
    double indicatorHeight = 3,
    double borderRadius = 20,
    EdgeInsets padding = const EdgeInsets.all(20),
    double? titleFontSize = 16,
    double? contentFontSize = 14,
    FontWeight? titleFontWeight = FontWeight.bold,
    double? topOffset,
  }) {
    if (currentNotificationEntry != null && currentNotificationEntry!.mounted) {
      currentNotificationEntry!.remove();
    }

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: topOffset ?? (MediaQuery.of(context).padding.top + 8),
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: ExpandableNotification(
            title: title,
            preview: preview,
            content: content,
            onExpand: onExpand,
            onCollapse: onCollapse,
            onDismiss: () {
              entry.remove();
              if (currentNotificationEntry == entry) {
                currentNotificationEntry = null;
              }
              onDismiss?.call();
            },
            backgroundColor: backgroundColor,
            textColor: textColor,
            animationDuration: animationDuration,
            autoExpand: autoExpand,
            enableSwipeToDismiss: enableSwipeToDismiss,
            showIndicator: showIndicator,
            indicatorColor: indicatorColor,
            indicatorWidth: indicatorWidth,
            indicatorHeight: indicatorHeight,
            borderRadius: borderRadius,
            padding: padding,
            titleFontSize: titleFontSize,
            contentFontSize: contentFontSize,
            titleFontWeight: titleFontWeight,
          ),
        ),
      ),
    );

    currentNotificationEntry = entry;
    overlay.insert(entry);

    if (autoDismiss != null) {
      Future.delayed(autoDismiss, () {
        if (entry.mounted) {
          entry.remove();
          if (currentNotificationEntry == entry) {
            currentNotificationEntry = null;
          }
        }
      });
    }
  }
}

class _ExpandableNotificationState extends State<ExpandableNotification>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  double _dragStartY = 0;
  double _dragDistance = 0;
  double _horizontalDragDistance = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (widget.autoExpand) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _toggleExpansion();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
        widget.onExpand?.call();
      } else {
        _controller.reverse();
        widget.onCollapse?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget notification = AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        return GestureDetector(
          onVerticalDragStart: (details) {
            _dragStartY = details.globalPosition.dy;
          },
          onVerticalDragUpdate: (details) {
            _dragDistance = details.globalPosition.dy - _dragStartY;
          },
          onVerticalDragEnd: (details) {
            // More precise drag detection for Android
            if (_dragDistance.abs() > 30) { // Increased threshold for more intentional swipes
              if (_dragDistance > 0 && !_isExpanded) {
                _toggleExpansion();
              } else if (_dragDistance < 0 && _isExpanded) {
                _toggleExpansion();
              }
            }
            _dragDistance = 0;
          },
          onTap: _toggleExpansion, // Add tap to expand/collapse for better UX
          behavior: HitTestBehavior.translucent, // Allow events to pass through when needed
          child: Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: widget.padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: widget.titleFontSize,
                    fontWeight: widget.titleFontWeight,
                    color: widget.textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isExpanded ? widget.content : widget.preview,
                  style: TextStyle(
                    fontSize: widget.contentFontSize,
                    color: widget.textColor.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
                if (widget.showIndicator) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      width: widget.indicatorWidth,
                      height: widget.indicatorHeight,
                      decoration: BoxDecoration(
                        color: widget.indicatorColor ?? widget.textColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );

    if (widget.enableSwipeToDismiss) {
      // Wrap the Dismissible in a Container with specific behavior for Android
      notification = Container(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        child: Dismissible(
          key: UniqueKey(),
          direction: DismissDirection.horizontal,
          onDismissed: (direction) {
            widget.onDismiss?.call();
          },
          child: notification,
        ),
      );
    }

    return notification;
  }
}
