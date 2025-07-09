import 'package:flutter/material.dart';

class ScrollDirectionIndicator extends StatefulWidget {
  final ScrollController scrollController;
  final double scrollOffset;

  const ScrollDirectionIndicator({
    Key? key,
    required this.scrollController,
    this.scrollOffset = 300,
  }) : super(key: key);

  @override
  State<ScrollDirectionIndicator> createState() =>
      _ScrollDirectionIndicatorState();
}

class _ScrollDirectionIndicatorState extends State<ScrollDirectionIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool atBottom = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    widget.scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (!widget.scrollController.hasClients) return;
    final maxScroll = widget.scrollController.position.maxScrollExtent;
    final current = widget.scrollController.offset;

    if (mounted) {
      setState(() {
        atBottom = (current >= maxScroll);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.scrollController.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollAction() {
    if (atBottom) {
      widget.scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      widget.scrollController.animateTo(
        widget.scrollController.offset + widget.scrollOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _scrollAction,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _animation.value),
            child: child,
          );
        },
        child: Icon(
          atBottom
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded,
          size: 32,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}
